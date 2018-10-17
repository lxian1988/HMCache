//
//  HMObject+Cache.h
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMObject.h"

@interface HMObject (Cache)

@property (readonly) NSString *cacheKey;
@property (readonly) NSString *cacheGroup;

/**
 * Fetch a cached object instance with default key.
 */
+ (instancetype)objectInCache;

/**
 * Fetch a cached object instance with a specified key.
 */
+ (instancetype)objectInCacheForKey:(NSString *)key;

/**
 * Fetch a cached object instance with a specified key and group.
 */
+ (instancetype)objectInCacheForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * Cache a object instance with default key.
 */
- (void)cache;

/**
 * Cache a object instance with a specified key.
 */
- (void)cacheForKey:(NSString *)key;

/**
 * Cache a object instance with a specified key and group.
 */
- (void)cacheForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * Cache a object instance with a specified key and group with a completion block
 */
- (void)cacheForKey:(NSString *)key inGroup:(NSString *)group completion:(void (^)(void))completion;

/**
 * Delete cache of the object instance;
 */
- (void)removeCache;

/**
 * Clear cache for all HMObject subclass.
 */
+ (void)clearCache;

@end


@interface HMObject (CacheArray)

/**
 * Fetch a cached array of object instance with default key.
 */
+ (NSArray<HMObject *> *)arrayInCache;

/**
 * Fetch a cached array of object instance with a specified key.
 */
+ (NSArray<HMObject *> *)arrayInCacheForKey:(NSString *)key;

/**
 * Fetch a cached array of object instance with a specified key and group.
 */
+ (NSArray<HMObject *> *)arrayInCacheForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * Cache a array of object instance with default key.
 */
+ (void)cacheArray:(NSArray<HMObject *> *)array;

/**
 * Fetch a cached array of object instance with a specified key.
 */
+ (void)cacheArray:(NSArray<HMObject *> *)array forKey:(NSString *)key;

/**
 * Fetch a cached array of object instance with a specified key and group.
 */
+ (void)cacheArray:(NSArray<HMObject *> *)array forKey:(NSString *)key inGroup:(NSString *)group;

/**
 * Fetch a cached array of object instance with a specified key and group with a completion block.
 */
+ (void)cacheArray:(NSArray<HMObject *> *)array forKey:(NSString *)key inGroup:(NSString *)group completion:(void (^)(void))completion;

@end
