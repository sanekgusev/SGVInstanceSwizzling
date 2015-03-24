//
//  SGVInstanceSwizzlingUndoToken.h
//  SGVInstanceSwizzling
//
//  Created by Aleksandr Gusev on 3/22/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGVInstanceSwizzlingMethodDescriptor.h"

@interface SGVInstanceSwizzlingUndoToken : NSObject

@property (nonatomic, readonly, unsafe_unretained, nonnull) id object;
@property (nonatomic, readonly, unsafe_unretained, nonnull) Class objectClass;
@property (nonatomic, readonly, nonnull) NSArray *overriddenMethodDescriptors;

- (nullable instancetype)initWithObject:(nonnull id __unsafe_unretained)object
                                  class:(nonnull Class __unsafe_unretained)class
            overriddenMethodDescriptors:(nonnull NSArray *)overriddenMethodDescriptors NS_DESIGNATED_INITIALIZER;

@end
