 //
//  HMObject+Cache.m
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMObject+Cache.h"

#import <objc/runtime.h>
#import "HMCacheManager.h"


static HMStringKeyMaker(HMObjectRootCacheGroup)


@interface HMObject ()

@property (nonatomic, copy, readwrite) NSString *cacheKey;
@property (nonatomic, copy, readwrite) NSString *cacheGroup;

@end

@implementation HMObject (Cache)

#pragma mark - setters and getters

- (void)setCacheKey:(NSString *)cacheKey {
    objc_setAssociatedObject(self, "cacheKey", cacheKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)cacheKey {
    return objc_getAssociatedObject(self, "cacheKey");
}

- (void)setCacheGroup:(NSString *)cacheGroup {
    objc_setAssociatedObject(self, "cacheGroup", cacheGroup, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)cacheGroup {
    return objc_getAssociatedObject(self, "cacheGroup");
}

#pragma mark - cache methods

+ (NSString *)defaultCacheKey {
    return [NSStringFromClass(self) stringByAppendingString:@"DefaultCacheKey"];
}

+ (instancetype)objectInCache {
    return [self objectInCacheForKey:[self defaultCacheKey]];
}

+ (instancetype)objectInCacheForKey:(NSString *)key {
    return [self objectInCacheForKey:key inGroup:nil];
}

+ (instancetype)objectInCacheForKey:(NSString *)key inGroup:(NSString *)group {
    
    NSString *subgroup = [NSString stringWithFormat:@"%@.%@", HMObjectRootCacheGroup, group ? : @""];
    
    HMObject *object = [[HMCacheManager sharedManager] objectForKey:key inGroup:subgroup];
    if (object) {
        object.cacheKey = key;
        object.cacheGroup = group;
    }
    return object;
}

- (void)cache {
    [self cacheForKey:[[self class] defaultCacheKey]];
}

- (void)cacheForKey:(NSString *)key {
    [self cacheForKey:key inGroup:nil];
}

- (void)cacheForKey:(NSString *)key inGroup:(NSString *)group {
    
    if (self.cacheKey.length == 0 && self.cacheGroup.length == 0) {
        self.cacheKey = key;
        self.cacheGroup = group;
    }
    
    NSString *subgroup = [NSString stringWithFormat:@"%@.%@", HMObjectRootCacheGroup, group ? : @""];
    [[HMCacheManager sharedManager] cacheObject:self forKey:key inGroup:subgroup];
}

- (void)removeCache {
    
    NSString *key = self.cacheKey;
    NSString *group = self.cacheGroup;
    
    NSString *subgroup = [NSString stringWithFormat:@"%@.%@", HMObjectRootCacheGroup, group ? : @""];
    [[HMCacheManager sharedManager] removeCacheForKey:key inGroup:subgroup];
    
    self.cacheKey = nil;
    self.cacheGroup = nil;
}

+ (void)clearCache {
    [[HMCacheManager sharedManager] clearGroup:HMObjectRootCacheGroup];
}

@end


@implementation HMObject (CacheArray)

+ (NSString *)defaultArrayCacheKey {
    return [NSStringFromClass(self) stringByAppendingString:@"DefaultArrayCacheKey"];
}

+ (NSArray<HMObject *> *)arrayInCache {
    return [self arrayInCacheForKey:[self defaultArrayCacheKey]];
}

+ (NSArray<HMObject *> *)arrayInCacheForKey:(NSString *)key {
    return [self arrayInCacheForKey:key inGroup:nil];
}

+ (NSArray<HMObject *> *)arrayInCacheForKey:(NSString *)key inGroup:(NSString *)group {
    NSString *subgroup = [NSString stringWithFormat:@"%@.%@", HMObjectRootCacheGroup, group ? : @""];
    return [[HMCacheManager sharedManager] objectForKey:key inGroup:subgroup];
}

+ (void)cacheArray:(NSArray<HMObject *> *)array {
    [self arrayInCacheForKey:[self defaultArrayCacheKey]];
}

+ (void)cacheArray:(NSArray<HMObject *> *)array forKey:(NSString *)key {
    [self cacheArray:array forKey:key inGroup:nil];
}

+ (void)cacheArray:(NSArray<HMObject *> *)array forKey:(NSString *)key inGroup:(NSString *)group {
    NSString *subgroup = [NSString stringWithFormat:@"%@.%@", HMObjectRootCacheGroup, group ? : @""];
    [[HMCacheManager sharedManager] cacheObject:array forKey:key inGroup:subgroup];
}

@end
