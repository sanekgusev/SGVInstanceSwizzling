//
//  SGVMethodOverrideUndoPerformer.m
//  Pods
//
//  Created by Aleksandr Gusev on 8/21/16.
//
//

#import "SGVMethodOverrideUndoPerformer.h"
#import "SGVMethodOverrideUndoEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface SGVMethodOverrideUndoPerformer ()

@property (nonatomic, copy) NSMutableArray *undoers;

@end

@implementation SGVMethodOverrideUndoPerformer

#pragma mark - Init/dealloc

- (instancetype)init {
    if (self = [super init]) {
        _undoers = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc {
    [self undoAllMethodOverrides];
}

#pragma mark - Public

- (void)pushUndoItemForOriginalClass:(Class)originalClass
                              object:(id)object
            overriddenImplementation:(IMP)overriddenImplementation {
    [self.undoers addObject:[[SGVMethodOverrideUndoEntry alloc] initWithOriginalClass:originalClass
                                                                            object:object
                                                          overriddenImplementation:overriddenImplementation]];
}

- (BOOL)undoLastMethodOverride {
    SGVMethodOverrideUndoEntry *lastUndoer = self.undoers.lastObject;
    if (lastUndoer == nil) {
        return NO;
    }
    [self.undoers removeLastObject];
    [lastUndoer undoMethodOverride];
    return YES;
}

- (BOOL)undoAllMethodOverrides {
    if (![self undoLastMethodOverride]) {
        return NO;
    }
    while ([self undoLastMethodOverride]) {}
    return YES;
}

@end

NS_ASSUME_NONNULL_END
