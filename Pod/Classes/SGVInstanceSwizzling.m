//
//  SGVInstanceSwizzling.m
//  SGVInstanceSwizzling
//
//  Created by Aleksandr Gusev on 3/22/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "SGVInstanceSwizzling.h"
#import "SGVInstanceSwizzlingUndoToken.h"
@import ObjectiveC.runtime;
#import "SGVSuperMessagingProxy.h"
#import "SGVInstranceSwizzlingDeallocObserver.h"

static const void * const kOverrideIsActiveKey = &kOverrideIsActiveKey;
static const void * const kUndoTokenKey = &kUndoTokenKey;

@implementation SGVInstanceSwizzling

#pragma mark - Public

+ (nullable id)overrideMethodWithSelector:(nonnull SEL)selector
                                 inObject:(nonnull id)object
                   withConfigurationBlock:(nonnull SGVInstanceSwizzlingConfigurationBlock)configurationBlock {
    return [self overrideMethodWithSelector:selector
                                   inObject:object
                     withConfigurationBlock:configurationBlock
                               augmentClass:YES];
}

+ (nullable id)overrideMethodWithSelector:(nonnull SEL)selector
                                 inObject:(nonnull id)object
                   withConfigurationBlock:(nonnull SGVInstanceSwizzlingConfigurationBlock)configurationBlock
                             augmentClass:(BOOL)augmentClass {
    NSCParameterAssert(selector);
    NSCParameterAssert(object);
    NSCParameterAssert(configurationBlock);
    if (!selector || !object || !configurationBlock) {
        return nil;
    }
    
    Class __unsafe_unretained objectClass = object_getClass(object);
    NSString *subclassNameString = [self subclassNameForObject:object
                                                   andSelector:selector];
    const char *subclassName = subclassNameString.UTF8String;
    Class __unsafe_unretained subclass = objc_allocateClassPair(objectClass,
                                                                subclassName,
                                                                0);
    NSCAssert(subclass, @"subclass should be created successfully");
    if (!subclass) {
        return nil;
    }
    
    NSMutableArray *overriddenMethodDescriptors = [NSMutableArray new];
    
    SGVInstanceSwizzlingMethodDescriptor *methodDescriptor =
        [self originalMethodDescriptorForAddingMethodWithSelector:selector
                                                          toClass:subclass
                                                        forObject:object
                                           withConfigurationBlock:configurationBlock];
    if (!methodDescriptor) {
        objc_disposeClassPair(subclass);
        return nil;
    }
    
    [overriddenMethodDescriptors addObject:methodDescriptor];
    
    if (augmentClass) {
        SGVInstanceSwizzlingMethodDescriptor *classMethodDescriptor =
        [self originalMethodDescriptorForAddingMethodWithSelector:@selector(class)
                                                          toClass:subclass
                                                        forObject:object
                                           withConfigurationBlock:^id(id _super) {
                                               return ^Class(id _self) {
                                                   return objectClass;
                                               };
                                           }];
        if (!classMethodDescriptor) {
            objc_disposeClassPair(subclass);
            return nil;
        }
        
        [overriddenMethodDescriptors addObject:classMethodDescriptor];
    }
    
    objc_registerClassPair(subclass);
    
    objc_setAssociatedObject(subclass,
                             kOverrideIsActiveKey,
                             @YES,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    SGVInstanceSwizzlingUndoToken *undoToken = [[SGVInstanceSwizzlingUndoToken alloc] initWithObject:object
                                                                                               class:subclass
                                                                         overriddenMethodDescriptors:overriddenMethodDescriptors];
    
    objc_setAssociatedObject(subclass,
                             kUndoTokenKey,
                             undoToken,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    SGVInstranceSwizzlingDeallocObserver * __unused deallocObserver =
        [[SGVInstranceSwizzlingDeallocObserver alloc] initWithObject:object
                                                        deallocBlock:^(__nonnull id object) {
                                                            [self undoAllMethodOverridesForObject:object];
                                                        }];
    
    return undoToken;
}

+ (BOOL)undoMethodOverrideForObject:(nonnull id)object
                      withUndoToken:(nonnull id)undoToken {
    NSCParameterAssert(object);
    NSCParameterAssert(undoToken);
    if (!object || !undoToken) {
        return NO;
    }
    NSCAssert([undoToken isMemberOfClass:[SGVInstanceSwizzlingUndoToken class]],
              @"incorrect object passed as undo token");
    if (![undoToken isMemberOfClass:[SGVInstanceSwizzlingUndoToken class]]) {
        return NO;
    }
    SGVInstanceSwizzlingUndoToken *token = undoToken;
    
    NSCAssert(token.object == object, @"token was created for a different object");
    if (token.object != object) {
        return NO;
    }
    
    [self undoMethodOverridesWithToken:token];
    
    [self undoDynamicSubclassingForObject:object];
    
    return YES;
}

+ (BOOL)undoAllMethodOverridesForObject:(nonnull id)object {
    NSCParameterAssert(object);
    if (!object) {
        return NO;
    }
    
    Class __unsafe_unretained objectClass = object_getClass(object);
    while (objectClass) {
        SGVInstanceSwizzlingUndoToken *undoToken = objc_getAssociatedObject(objectClass, kUndoTokenKey);
        if (undoToken) {
            [self undoMethodOverridesWithToken:undoToken];
        }
        objectClass = class_getSuperclass(objectClass);
    }
    
    [self undoDynamicSubclassingForObject:object];
    
    return YES;
}

#pragma mark - Private

+ (NSString *)subclassNameForObject:(id)object andSelector:(SEL)selector {
    NSCParameterAssert(object);
    NSCParameterAssert(selector);
    if (!object || !selector) {
        return nil;
    }
    NSString *className = @(object_getClassName(object));
    NSString *subclassName = [NSString stringWithFormat:@"%@_sgv%p%s",
                              className,
                              object,
                              sel_getName(selector)];
    return subclassName;
}

+ (BOOL)isBlock:(id)object {
    NSCParameterAssert(object);
    if (!object) {
        return nil;
    }
    static Class __unsafe_unretained BlockClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class blockClass = [^{} class];
        while ([blockClass superclass] != [NSObject class]) {
            blockClass = [blockClass superclass];
        }
        BlockClass = blockClass;
    });
    return [object isKindOfClass:BlockClass];
}

+ (SGVInstanceSwizzlingMethodDescriptor *)originalMethodDescriptorForAddingMethodWithSelector:(SEL)selector
                                                                                      toClass:(Class __unsafe_unretained)class
                                                                                    forObject:(id)object
                                                                       withConfigurationBlock:(SGVInstanceSwizzlingConfigurationBlock)configurationBlock {
    NSCParameterAssert(selector);
    NSCParameterAssert(class);
    NSCParameterAssert(configurationBlock);
    if (!selector || !class || !configurationBlock) {
        return nil;
    }
    
    Method existingMethod = class_getInstanceMethod(class, selector);
    NSCAssert(existingMethod, @"method for selector %@ should exist",
              NSStringFromSelector(selector));
    if (!existingMethod) {
        return nil;
    }
    
    const char *typeEncoding = method_getTypeEncoding(existingMethod);
    NSCAssert(typeEncoding, @"typeEncoding should not be NULL");
    if (!typeEncoding) {
        return nil;
    }
    
    id block = configurationBlock([SGVSuperMessagingProxy proxyWithObject:object]);
    NSCAssert(block, @"Block should not be nil");
    NSCAssert([self isBlock:block], @"returned value is not a block");
    if (![self isBlock:block]) {
        return nil;
    }
    
    IMP implementation = imp_implementationWithBlock(block);
    BOOL addResult = class_addMethod(class,
                                     selector,
                                     implementation,
                                     typeEncoding);
    
    NSCAssert(addResult, @"Method should be added successfully");
    if (!addResult) {
        return nil;
    }

    return [[SGVInstanceSwizzlingMethodDescriptor alloc] initWithOriginalMethod:existingMethod];
}

+ (void)undoMethodOverridesWithToken:(SGVInstanceSwizzlingUndoToken *)token {
    NSCParameterAssert(token);
    if (!token) {
        return;
    }
    [token.overriddenMethodDescriptors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SGVInstanceSwizzlingMethodDescriptor *methodDescriptor = obj;
        Method originalSuperclassMethod = methodDescriptor.originalMethod;
        Method overriddenMethod = class_getInstanceMethod(token.objectClass,
                                                          method_getName(originalSuperclassMethod));
        
        // TODO: try using dynamic message dispatch to superclass implementation here
        IMP overriddenImplementation = method_setImplementation(overriddenMethod,
                                                                method_getImplementation(originalSuperclassMethod));
        BOOL removeBlockResult = imp_removeBlock(overriddenImplementation);
        NSCAssert(removeBlockResult, @"block should be removed successfully");
    }];
    
    objc_setAssociatedObject(token.objectClass,
                             kUndoTokenKey,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(token.objectClass,
                             kOverrideIsActiveKey,
                             @NO,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)undoDynamicSubclassingForObject:(id)object {
    NSCParameterAssert(object);
    if (!object) {
        return;
    }
    
    Class __unsafe_unretained objectClass = object_getClass(object);
    NSNumber *overrideIsActiveNumber = objc_getAssociatedObject(objectClass, kOverrideIsActiveKey);
    
    while (overrideIsActiveNumber && !overrideIsActiveNumber.boolValue) {
        Class __unsafe_unretained originalSuperclass = class_getSuperclass(objectClass);
        
        objc_setAssociatedObject(objectClass,
                                 kOverrideIsActiveKey,
                                 nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        object_setClass(object, originalSuperclass);
        objc_disposeClassPair(objectClass);
        
        objectClass = originalSuperclass;
        overrideIsActiveNumber = objc_getAssociatedObject(objectClass, kOverrideIsActiveKey);
    }
}

@end
