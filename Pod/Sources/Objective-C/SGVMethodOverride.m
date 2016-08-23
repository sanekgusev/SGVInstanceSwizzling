//
//  SGVMethodOverride.m
//  Pods
//
//  Created by Aleksandr Gusev on 8/21/16.
//
//

@import ObjectiveC.runtime;

#import "SGVMethodOverride.h"
#import "SGVMethodOverrideUndoPerformer.h"
#import <SGVSuperMessagingProxy/SGVSuperMessagingProxy.h>

NS_ASSUME_NONNULL_BEGIN

NSString * const SGVMethodOverrideErrorDomain = @"SGVMethodOverrideErrorDomain";

NSInteger const SGVMethodOverrideClassAllocationFailure = 0;
NSInteger const SGVMethodOverrideMethodLookupFailure = 1;
NSInteger const SGVMethodOverrideImplementationCreationFailure = 2;
NSInteger const SGVMethodOverrideMethodAdditionFailure = 3;

static NSInteger const kMethodOverrideUndoPerformerKey = 0;

@implementation SGVMethodOverride

#pragma mark - Public

+ (BOOL)overrideMethodWithSelector:(SEL)selector
                          onObject:(id)object
       implementationBlockProvider:(SGVMehodOverrideImplementationBlockProvider)implementationBlockProvider
                             error:(NSError * __autoreleasing * _Nullable)error {
    Class objectClass = object_getClass(object);
    
    void(^setError)(NSError *) = ^(NSError *anError) {
        if (error != NULL) {
            *error = anError;
        }
    };
    
    if (objectClass == nil) {
        setError([self errorWithCode: SGVMethodOverrideClassAllocationFailure]);
        return NO;
    }
    Class generatedSubclass = objc_allocateClassPair(objectClass,
                                                     [self generatedSubclassNameForClassName: NSStringFromClass(objectClass)].UTF8String,
                                                     0);
    if (generatedSubclass == nil) {
        setError([self errorWithCode: SGVMethodOverrideClassAllocationFailure]);
        return NO;
    }
    
    BOOL overrideResult = [self performOverrideOfMethodWithSelector:selector
                                                            inClass:objectClass
                                                           onObject:object
                                                  generatedSubclass:generatedSubclass
                                        implementationBlockProvider:implementationBlockProvider
                                                              error:error];
    if (!overrideResult) {
        objc_disposeClassPair(generatedSubclass);
        return NO;
    }
    
    objc_registerClassPair(generatedSubclass);
    
    object_setClass(object, generatedSubclass);
    return YES;
}

+ (BOOL)undoLastMethodOverrideForObject:(id)object {
    return [[self undoPerformerForObject:object] undoLastMethodOverride];
}

+ (BOOL)undoAllMethodOverridesForObject:(id)object {
    return [[self undoPerformerForObject:object] undoAllMethodOverrides];
}

#pragma mark - Private

+ (BOOL)performOverrideOfMethodWithSelector:(SEL)selector
                                    inClass:(Class)class
                                   onObject:(id)object
                          generatedSubclass:(Class)generatedSubclass
                implementationBlockProvider:(SGVMehodOverrideImplementationBlockProvider)implementationBlockProvider
                                      error:(NSError * __autoreleasing * _Nullable)error {
    
    void(^setError)(NSError *) = ^(NSError *anError) {
        if (error != NULL) {
            *error = anError;
        }
    };
    
    Method method = class_getInstanceMethod(class, selector);
    if (method == NULL) {
        setError([self errorWithCode:SGVMethodOverrideMethodLookupFailure]);
        return NO;
    }
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding == NULL) {
        setError([self errorWithCode:SGVMethodOverrideMethodLookupFailure]);
        return NO;
    }
    
    id implementationBlock = implementationBlockProvider([SGVSuperMessagingProxy proxyWithObject:object retainsObject:YES]);
    IMP implementation = imp_implementationWithBlock(implementationBlock);
    
    if (implementation == nil) {
        setError([self errorWithCode:SGVMethodOverrideImplementationCreationFailure]);
        return NO;
    }
    
    if (!class_addMethod(generatedSubclass, selector, implementation, typeEncoding)) {
        imp_removeBlock(implementation);
        setError([self errorWithCode:SGVMethodOverrideMethodAdditionFailure]);
        return NO;
    }
    
    [[self undoPerformerForObject:object] pushUndoItemForOriginalClass:class
                                                                object:object
                                              overriddenImplementation:implementation];
    return YES;
}

+ (SGVMethodOverrideUndoPerformer *)undoPerformerForObject:(id)object {
    SGVMethodOverrideUndoPerformer *undoPerformer = objc_getAssociatedObject(object, &kMethodOverrideUndoPerformerKey);
    if (undoPerformer != nil) {
        return undoPerformer;
    }
    undoPerformer = [SGVMethodOverrideUndoPerformer new];
    objc_setAssociatedObject(object, &kMethodOverrideUndoPerformerKey, undoPerformer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return undoPerformer;
}

+ (NSString *)generatedSubclassNameForClassName:(NSString *)className {
    return [NSString stringWithFormat:@"sgv_%@_%@", className, [NSUUID UUID].UUIDString];
}

+ (NSError *)errorWithCode:(NSInteger)code {
    return [NSError errorWithDomain:SGVMethodOverrideErrorDomain code:code userInfo:nil];
}

@end

NS_ASSUME_NONNULL_END
