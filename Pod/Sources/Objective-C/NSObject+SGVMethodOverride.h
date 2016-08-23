//
//  NSObject+SGVMethodOverride.h
//  Pods
//
//  Created by Aleksandr Gusev on 23/08/16.
//
//

#import <Foundation/Foundation.h>
#import "SGVMethodOverride.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SGVMethodOverride)

- (BOOL)sgv_overrideMethodWithSelector:(SEL)selector
           implementationBlockProvider:(SGVMehodOverrideImplementationBlockProvider)implementationBlockProvider
                                 error:(NSError * __autoreleasing * _Nullable)error;

- (BOOL)sgv_undoLastMethodOverride;
- (BOOL)sgv_undoAllMethodOverrides;

@end

NS_ASSUME_NONNULL_END
