//
//  SGVInstanceSwizzlingUndoToken.m
//  SGVInstanceSwizzling
//
//  Created by Aleksandr Gusev on 3/22/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "SGVInstanceSwizzlingUndoToken.h"

@implementation SGVInstanceSwizzlingUndoToken

#pragma mark - Init/dealloc

- (nullable instancetype)initWithObject:(nonnull id __unsafe_unretained)object
                                  class:(nonnull Class __unsafe_unretained)class
            overriddenMethodDescriptors:(nonnull NSArray *)overriddenMethodDescriptors {
    NSCParameterAssert(object);
    NSCParameterAssert(class);
    NSCParameterAssert(overriddenMethodDescriptors);
    if (!object || !class || !overriddenMethodDescriptors) {
        return nil;
    }
    if (self = [super init]) {
        _object = object;
        _objectClass = class;
        _overriddenMethodDescriptors = [overriddenMethodDescriptors copy];
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return [self init];
}

@end
