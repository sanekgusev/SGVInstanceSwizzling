//
//  SGVMethodOverrideUndoEntry.h
//  Pods
//
//  Created by Aleksandr Gusev on 8/21/16.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface SGVMethodOverrideUndoEntry : NSObject

- (instancetype)initWithOriginalClass:(Class)originalClass
                               object:(id)object
             overriddenImplementation:(IMP)overriddenImplementation NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (void)undoMethodOverride;

@end


NS_ASSUME_NONNULL_END
