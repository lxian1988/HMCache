//
//  HMObject+KVO.m
//  HMCacheDemo
//
//  Created by 李宪 on 7/2/2017.
//  Copyright © 2017 lxian1988@gmail.com. All rights reserved.
//

#import "HMObject+KVO.h"


typedef BOOL(^HMObjectObserverWrapBlock)(NSString *keyPath, HMObject *object, id oldValue, id newValue);


@interface HMObjectObserver : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *observedObjectMaps;

@end

@implementation HMObjectObserver

#pragma mark - Singleton

+ (instancetype)observer {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self class] new];
    });
    return instance;
}

#pragma mark - private

- (NSString *)objectMapKeyForObject:(HMObject *)object {
    return [NSString stringWithFormat:@"Object-%@(%p)", NSStringFromClass([object class]), object];
}

- (NSString *)blockKeyForObserver:(NSObject *)observer {
    return [NSString stringWithFormat:@"Observer-%@(%p)", NSStringFromClass([observer class]), observer];
}

#pragma mark - setters and getters

- (NSMutableDictionary<NSString *, NSMutableDictionary *> *)observedObjectMaps {
    if (!_observedObjectMaps) {
        _observedObjectMaps = [NSMutableDictionary dictionary];
    }
    return _observedObjectMaps;
}

#pragma mark - Observe methods

- (void)addObserver:(NSObject *)observer
           toObject:(HMObject *)object
         forKeyPath:(NSString *)keyPath
          withBlock:(HMObjectKVOBlock)block {
    
    NSParameterAssert(keyPath.length > 0);
    
    if (!observer || !object) {
        return;
    }
    
    NSString *objectMapKey = [self objectMapKeyForObject:object];
    NSMutableDictionary *objectMap = self.observedObjectMaps[objectMapKey];
    if (!objectMap) {
        objectMap = [NSMutableDictionary dictionary];
        self.observedObjectMaps[objectMapKey] = objectMap;
    }
    
    __weak typeof(observer) weakObserver = observer;
    HMObjectObserverWrapBlock wrapBlock = ^(NSString *keyPath, HMObject *object, id oldValue, id newValue) {
        if (!weakObserver) {
            return NO;
        }
        
        BOOL stop = NO;
        
        block(object, oldValue, newValue, &stop);
        if (stop) {
            return NO;
        }
        
        return YES;
    };
    
    NSMutableDictionary *keyPathMap = objectMap[keyPath];
    if (!keyPathMap) {
        keyPathMap = [NSMutableDictionary dictionary];
        objectMap[keyPath] = keyPathMap;
        
        [object addObserver:self
                 forKeyPath:keyPath
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:NULL];
    }
    
    NSString *blockKey = [self blockKeyForObserver:observer];
    keyPathMap[blockKey] = wrapBlock;
}

- (void)removeObserver:(NSObject *)observer
            fromObject:(HMObject *)object
            forKeyPath:(NSString *)keyPath {
    
    NSParameterAssert(keyPath.length > 0);
    
    if (!observer || !object) {
        return;
    }
    
    NSString *objectMapKey = [self objectMapKeyForObject:object];
    NSMutableDictionary *objectMap = self.observedObjectMaps[objectMapKey];
    if (!objectMap) {
        return;
    }
    
    NSMutableDictionary *keyPathMap = objectMap[keyPath];
    if (!keyPathMap) {
        return;
    }
    
    NSString *blockKey = [self blockKeyForObserver:observer];
    keyPathMap[blockKey] = nil;
    
    if (keyPathMap.count == 0) {
        objectMap[keyPath] = nil;
        
        [object removeObserver:self
                    forKeyPath:keyPath
                       context:NULL];
    }
    
    if (objectMap.count == 0) {
        self.observedObjectMaps[objectMapKey] = nil;
    }
}

- (void)removeAllObserversForObject:(HMObject *)object {
    
    NSString *objectMapKey = [self objectMapKeyForObject:object];
    NSMutableDictionary *objectMap = self.observedObjectMaps[objectMapKey];
    if (!objectMap) {
        return;
    }
    
    [objectMap enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, NSMutableDictionary *keyPathMap, BOOL *stop) {
        
        [object removeObserver:self
                    forKeyPath:keyPath
                       context:NULL];
        
        objectMap[keyPath] = nil;
    }];
    
    self.observedObjectMaps[objectMapKey] = nil;
}

#pragma mark - NSObject KVO callback

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    NSString *objectMapKey = [self objectMapKeyForObject:object];
    NSMutableDictionary *objectMap = self.observedObjectMaps[objectMapKey];
    
    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    
    if ([oldValue isEqual:newValue]) {
        return;
    }
    
    NSMutableDictionary *keyPathMap = objectMap[keyPath];
    [keyPathMap enumerateKeysAndObjectsUsingBlock:^(NSString *blockKey, HMObjectObserverWrapBlock wrapBlock, BOOL *stop) {
        if (!wrapBlock(keyPath, object, oldValue, newValue)) {
            keyPathMap[blockKey] = nil;
        }
    }];
    
    if (keyPathMap.count == 0) {
        objectMap[keyPath] = nil;
        
        [object removeObserver:self
                    forKeyPath:keyPath
                       context:NULL];
    }
    
    if (objectMap.count == 0) {
        self.observedObjectMaps[objectMapKey] = nil;
    }
}

@end


@implementation HMObject (KVO)

- (void)connectKeyPathValueChange:(NSString *)keyPath toObserver:(NSObject *)observer withBlock:(HMObjectKVOBlock)block {
    [[HMObjectObserver observer] addObserver:observer
                                    toObject:self
                                  forKeyPath:keyPath
                                   withBlock:block];
}

- (void)disconnectKeyPathValueChange:(NSString *)keyPath fromObserver:(NSObject *)observer {
    [[HMObjectObserver observer] removeObserver:observer
                                     fromObject:self
                                     forKeyPath:keyPath];
}

- (void)disconnectAllObservers {
    [[HMObjectObserver observer] removeAllObserversForObject:self];
}

@end


@implementation NSArray (HMObjectKVO)

- (void)connectObjectsKeyPathValueChange:(NSString *)keyPath toObserver:(NSObject *)observer withBlock:(HMObjectKVOBlock)block {
    
    for (HMObject *object in self) {
        [object connectKeyPathValueChange:keyPath toObserver:observer withBlock:block];
    }
}

- (void)disconnectObjectsKeyPathValueChange:(NSString *)keyPath fromObserver:(NSObject *)observer {
    
    for (HMObject *object in self) {
        [object disconnectKeyPathValueChange:keyPath fromObserver:observer];
    }
}

@end
