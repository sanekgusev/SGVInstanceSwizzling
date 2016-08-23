//
//  SGVMethodOverride.h
//  Pods
//
//  Created by Aleksandr Gusev on 8/21/16.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

typedef id _Nonnull (^SGVMehodOverrideImplementationBlockProvider)(id _Nonnull original);

extern NSString * const SGVMethodOverrideErrorDomain;

extern NSInteger const SGVMethodOverrideClassAllocationFailure;
extern NSInteger const SGVMethodOverrideMethodLookupFailure;
extern NSInteger const SGVMethodOverrideImplementationCreationFailure;
extern NSInteger const SGVMethodOverrideMethodAdditionFailure;

@interface SGVMethodOverride : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (BOOL)overrideMethodWithSelector:(SEL)selector
                          onObject:(id)object
       implementationBlockProvider:(SGVMehodOverrideImplementationBlockProvider)implementationBlockProvider
                             error:(NSError * __autoreleasing * _Nullable)error;
+ (BOOL)undoLastMethodOverrideForObject:(id)object;
+ (BOOL)undoAllMethodOverridesForObject:(id)object;

@end

NS_ASSUME_NONNULL_END
