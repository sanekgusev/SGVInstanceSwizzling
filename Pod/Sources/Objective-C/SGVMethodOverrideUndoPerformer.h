//
//  SGVMethodOverrideUndoPerformer.h
//  Pods
//
//  Created by Aleksandr Gusev on 8/21/16.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface SGVMethodOverrideUndoPerformer : NSObject

- (void)pushUndoItemForOriginalClass:(Class)originalClass
                              object:(id)object
            overriddenImplementation:(IMP)overriddenImplementation;
- (BOOL)undoLastMethodOverride;
- (BOOL)undoAllMethodOverrides;

@end

NS_ASSUME_NONNULL_END
