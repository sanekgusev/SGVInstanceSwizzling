//
//  SGVInstanceSwizzling.h
//  SGVInstanceSwizzling
//
//  Created by Aleksandr Gusev on 3/22/15.
//  Copyright (c) 2015 Alexander Gusev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef __nonnull id(^SGVInstanceSwizzlingConfigurationBlock)(__nonnull id super);

@interface SGVInstanceSwizzling : NSObject

+ (nullable id)overrideMethodWithSelector:(nonnull SEL)selector
                                 inObject:(nonnull id)object
                   withConfigurationBlock:(nonnull SGVInstanceSwizzlingConfigurationBlock)configurationBlock;

+ (nullable id)overrideMethodWithSelector:(nonnull SEL)selector
                                 inObject:(nonnull id)object
                   withConfigurationBlock:(nonnull SGVInstanceSwizzlingConfigurationBlock)configurationBlock
                             augmentClass:(BOOL)augmentClass;

+ (BOOL)undoMethodOverrideForObject:(nonnull id)object
                      withUndoToken:(nonnull id)undoToken;

@end
