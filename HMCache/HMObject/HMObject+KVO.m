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
    
    NSMutableDictionary *keyPathMap = objectMap[keyPath];
    if (!keyPathMap) {
        keyPathMap = [NSMutableDictionary dictionary];
        objectMap[keyPath] = keyPathMap;
        
        [object addObserver:self
                 forKeyPath:keyPath
                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                    context:NULL];
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
        
        if (objectMap.count == 0) {
            self.observedObjectMaps[objectMapKey] = nil;
        }
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
        
        if (objectMap.count == 0) {
            self.observedObjectMaps[objectMapKey] = nil;
        }
    }
}

@end


HMStringKeyMaker(HMObjectWillConnectAllInstanceKeyPathValueChangeNotification)
HMStringKeyMaker(HMObjectWillDisconnectAllInstanceKeyPathValueChangeNotification)


#import <objc/runtime.h>

@interface HMObjectKVOInfo : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) HMObjectKVOBlock block;

@end

@implementation HMObjectKVOInfo

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

#pragma mark - KVO for class

+ (void)setObservedInstanceKeyPaths:(NSMutableDictionary *)observedInstanceKeyPaths {
    objc_setAssociatedObject(self, "observedInstanceKeyPaths", observedInstanceKeyPaths, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
+ (NSMutableDictionary *)observedInstanceKeyPaths {
    return objc_getAssociatedObject(self, "observedInstanceKeyPaths");
}

+ (void)connectKeyPathValueChange:(NSString *)keyPath toObserver:(NSObject *)observer withBlock:(HMObjectKVOBlock)block {
    
    // Notify already newed instances
    NSDictionary *userInfo = @{@"keyPath" : keyPath,
                               @"observer" : observer,
                               @"block" : block};
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HMObjectWillConnectAllInstanceKeyPathValueChangeNotification
     object:self
     userInfo:userInfo];
    
    // Save information for unnewed instances
    NSMutableDictionary *keyPaths = [self observedInstanceKeyPaths];
    if (!keyPaths) {
        keyPaths = [NSMutableDictionary dictionary];
        [[self class] setObservedInstanceKeyPaths:keyPaths];
    }
    
    NSMutableDictionary *keyPathMap = keyPaths[keyPath];
    if (!keyPathMap) {
        keyPathMap = [NSMutableDictionary dictionary];
        keyPaths[keyPath] = keyPathMap;
    }
    
    HMObjectKVOInfo *kvoInfo = [HMObjectKVOInfo new];
    kvoInfo.observer = observer;
    kvoInfo.block = block;
    
    NSString *observerKey = [NSString stringWithFormat:@"%@(%p)", NSStringFromClass([observer class]), observer];
    keyPathMap[observerKey] = kvoInfo;
}

+ (void)disconnectKeyPathValueChange:(NSString *)keyPath fromObserver:(NSObject *)observer {
    
    // Notify already newed instances
    NSDictionary *userInfo = @{@"keyPath" : keyPath,
                               @"observer" : observer};
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:HMObjectWillDisconnectAllInstanceKeyPathValueChangeNotification
     object:self
     userInfo:userInfo];
    
    // Delete information for unnewed instances
    NSMutableDictionary *keyPaths = [self observedInstanceKeyPaths];
    if (keyPaths.count == 0) {
        return;
    }
    
    NSMutableDictionary *keyPathMap = keyPaths[keyPath];
    if (keyPathMap.count == 0) {
        return;
    }
    
    NSString *observerKey = [NSString stringWithFormat:@"%@(%p)", NSStringFromClass([observer class]), observer];
    keyPathMap[observerKey] = nil;
    
    if (keyPathMap.count == 0) {
        keyPaths[keyPath] = nil;
        
        if (keyPaths.count == 0) {
            [self setObservedInstanceKeyPaths:nil];
        }
    }
}

+ (void)enumerateKeyPathObserverBlockWithBlock:(void (^)(NSString *keyPath, NSObject *observer, HMObjectKVOBlock block))block {
    
    NSMutableDictionary *keyPaths = [self observedInstanceKeyPaths];
    if (keyPaths.count == 0) {
        return;
    }
    
    [keyPaths enumerateKeysAndObjectsUsingBlock:^(NSString *keyPath, NSMutableDictionary *keyPathMap, BOOL *stop) {
        [keyPathMap enumerateKeysAndObjectsUsingBlock:^(NSString *observerKey, HMObjectKVOInfo *kvoInfo, BOOL *stop) {
            if (!kvoInfo.observer) {
                keyPathMap[observerKey] = nil;
            }
            else {
                block(keyPath, kvoInfo.observer, kvoInfo.block);
            }
        }];
        
        if (keyPathMap.count == 0) {
            keyPaths[keyPath] = nil;
            
            if (keyPaths.count == 0) {
                [self setObservedInstanceKeyPaths:nil];
            }
        }
    }];
}

@end


@implementation NSObject (Bind)

- (void)bindKeyPath:(NSString *)keyPath toObject:(HMObject *)object keyPath:(NSString *)objectKeyPath {
    [object connectKeyPathValueChange:objectKeyPath toObserver:self withBlock:^(HMObject *object, id oldValue, id newValue, BOOL *stop) {
        [self setValue:newValue forKeyPath:keyPath];
    }];
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
