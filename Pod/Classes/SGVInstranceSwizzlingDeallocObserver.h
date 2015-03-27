//
//  SGVInstranceSwizzlingDeallocObserver.h
//  Pods
//
//  Created by Aleksandr Gusev on 3/27/15.
//
//

#import <Foundation/Foundation.h>

@interface SGVInstranceSwizzlingDeallocObserver : NSObject

- (nullable instancetype)initWithObject:(nonnull id)object
                           deallocBlock:(nonnull void(^)(__nonnull id object))deallocBlock NS_DESIGNATED_INITIALIZER;

@end
