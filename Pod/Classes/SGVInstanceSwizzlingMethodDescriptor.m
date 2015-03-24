//
//  SGVInstanceSwizzlingMethodDescriptor.m
//  SGVInstanceSwizzling
//
//  Created by Aleksandr Gusev on 3/24/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import "SGVInstanceSwizzlingMethodDescriptor.h"

@implementation SGVInstanceSwizzlingMethodDescriptor

#pragma mark - Init/dealloc

- (nullable instancetype)initWithOriginalMethod:(nonnull Method)originalMethod {
    NSCParameterAssert(originalMethod);
    if (!originalMethod) {
        return nil;
    }
    if (self = [super init]) {
        _originalMethod = originalMethod;
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return [self init];
}

@end
