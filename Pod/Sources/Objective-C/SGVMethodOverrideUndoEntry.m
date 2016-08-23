//
//  SGVMethodOverrideUndoEntry.m
//  Pods
//
//  Created by Aleksandr Gusev on 8/21/16.
//
//

@import ObjectiveC.runtime;

#import "SGVMethodOverrideUndoEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGVMethodOverrideUndoEntry()

@property (nonatomic, unsafe_unretained) Class originalClass;
@property (nonatomic, weak) id object;
@property (nonatomic, assign) IMP overriddenImplementation;

@end

@implementation SGVMethodOverrideUndoEntry

#pragma mark - Init/dealloc

- (instancetype)initWithOriginalClass:(Class)originalClass
                               object:(id)object
             overriddenImplementation:(IMP)overriddenImplementation {
    if (self = [super init]) {
        _originalClass = originalClass;
        _object = object;
        _overriddenImplementation = overriddenImplementation;
    }
    return self;
}

- (void)dealloc {
    [self undoMethodOverride];
}

#pragma mark - Public

- (void)undoMethodOverride {
    id object = self.object;
    if (object == nil) {
        return;
    }
    Class objectClass = object_getClass(object);
    if (objectClass == nil || class_getSuperclass(objectClass) != self.originalClass) {
        return;
    }
    
    object_setClass(object, self.originalClass);
    imp_removeBlock(self.overriddenImplementation);
    objc_disposeClassPair(objectClass);
}

@end

NS_ASSUME_NONNULL_END
