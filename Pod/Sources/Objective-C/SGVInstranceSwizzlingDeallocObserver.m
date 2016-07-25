//
//  SGVInstranceSwizzlingDeallocObserver.m
//  Pods
//
//  Created by Aleksandr Gusev on 3/27/15.
//
//

#import "SGVInstranceSwizzlingDeallocObserver.h"
@import ObjectiveC.runtime;

@interface SGVInstranceSwizzlingDeallocObserver () {
    id __weak _object;
    void (^_deallocBlock)(__nonnull id object);
}

@end

static const void * const kDeallocObserverKey = &kDeallocObserverKey;

@implementation SGVInstranceSwizzlingDeallocObserver

#pragma mark - Init/dealloc

- (nullable instancetype)initWithObject:(nonnull id)object
                           deallocBlock:(nonnull void(^)(__nonnull id object))deallocBlock {
    NSCParameterAssert(object);
    NSCParameterAssert(deallocBlock);
    if (!object || !deallocBlock) {
        return nil;
    }
    if (self = [super init]) {
        _object = object;
        _deallocBlock = deallocBlock;
        objc_setAssociatedObject(object,
                                 kDeallocObserverKey,
                                 self,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return [self init];
}

- (void)dealloc {
    _deallocBlock(_object);
}

@end
