//
//  HMObject+KVO.h
//  HMCacheDemo
//
//  Created by 李宪 on 7/2/2017.
//  Copyright © 2017 lxian1988@gmail.com. All rights reserved.
//

#import "HMObject.h"


/**
 * HMObject KVO notify block type.
 * If *stop has been set to YES, the KVO observer will be removed.
 */
typedef void (^HMObjectKVOBlock)(HMObject *object, id oldValue, id newValue, BOOL *stop);


@interface HMObject (KVO)

/**
 * Connect self's keyPath value change event to an NSObject observer. When value specified by keyPath changed,
 * block invokes. 
 * If the block parameter *stop is set to YES, the KVO observer will be removed internally.
 * Either self or the observer is dealloced, the KVO observer will automatically be removed internally.
 *
 * Note: This connection cannot be removed by - (void)removeObserver:forKeyPath:context: method, 
 * your should call - (void)disconnectKeyPathValueChange:fromObserver: to disconnect the KVO relationship.
 */
- (void)connectKeyPathValueChange:(NSString *)keyPath toObserver:(NSObject *)observer withBlock:(HMObjectKVOBlock)block;

/**
 * Disconnect self's keyPath value change event to the observer.
 * Note: This method cannot remove KVO added by the NSObject API addObserver:forKeyPath:options:context: .
 */
- (void)disconnectKeyPathValueChange:(NSString *)keyPath fromObserver:(NSObject *)observer;

/**
 * Disconnect all of self's keyPath value change event to any observer. This method will be invoke in HMObject's dealloc method.
 * Note: This method cannot remove KVO added by the NSObject API addObserver:forKeyPath:options:context: .
 */
- (void)disconnectAllObservers;

+ (void)connectKeyPathValueChange:(NSString *)keyPath toObserver:(NSObject *)observer withBlock:(HMObjectKVOBlock)block;
+ (void)disconnectKeyPathValueChange:(NSString *)keyPath fromObserver:(NSObject *)observer;
+ (void)enumerateKeyPathObserverBlockWithBlock:(void (^)(NSString *keyPath, NSObject *observer, HMObjectKVOBlock block))block;

@end


#define HMBind(target, keypath1, object, keypath2)    \
[target bindKeyPath:@#keypath1 toObject:object keyPath:@#keypath2];

@interface NSObject (Bind)

- (void)bindKeyPath:(NSString *)keyPath toObject:(HMObject *)object keyPath:(NSString *)objectKeyPath;

@end


// NSArray convenient methods
@interface NSArray (HMObjectKVO)

- (void)connectObjectsKeyPathValueChange:(NSString *)keyPath toObserver:(NSObject *)observer withBlock:(HMObjectKVOBlock)block;
- (void)disconnectObjectsKeyPathValueChange:(NSString *)keyPath fromObserver:(NSObject *)observer;

@end

