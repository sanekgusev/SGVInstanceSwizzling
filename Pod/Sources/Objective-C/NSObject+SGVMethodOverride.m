//
//  NSObject+SGVMethodOverride.m
//  Pods
//
//  Created by Aleksandr Gusev on 23/08/16.
//
//

#import "NSObject+SGVMethodOverride.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (SGVMethodOverride)

- (BOOL)sgv_overrideMethodWithSelector:(SEL)selector
           implementationBlockProvider:(SGVMehodOverrideImplementationBlockProvider)implementationBlockProvider
                                 error:(NSError * __autoreleasing * _Nullable)error {
    return [SGVMethodOverride overrideMethodWithSelector:selector
                                                onObject:self
                             implementationBlockProvider:implementationBlockProvider
                                                   error:error];
}

- (BOOL)sgv_undoLastMethodOverride {
    return [SGVMethodOverride undoLastMethodOverrideForObject:self];
}

- (BOOL)sgv_undoAllMethodOverrides {
    return [SGVMethodOverride undoAllMethodOverridesForObject:self];
}

@end

NS_ASSUME_NONNULL_END
