//
//  SGVInstanceSwizzlingMethodDescriptor.h
//  SGVInstanceSwizzling
//
//  Created by Aleksandr Gusev on 3/24/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ObjectiveC.runtime;

@interface SGVInstanceSwizzlingMethodDescriptor : NSObject

@property (nonatomic, readonly, nonnull) Method originalMethod;

- (nullable instancetype)initWithOriginalMethod:(nonnull Method)originalMethod NS_DESIGNATED_INITIALIZER;

@end
