//
//  HMCacheManager.h
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMKeyMaker.h"

/*
 * If this macro is set, HMCacheManager will automatically check app version during initializing and delete
 * all cached data if current version does not equal to the version which was read and saved last time.
 * See kHMCacheReserveGroup for more information.
 */
#define HMCACHE_MANAGER_VERSION_CHECK                           0

/*
 * This value of data size determines whether a cached data item in disk should also be cached in memory.
 * For instance, if the macro is set to 1 Megabytes, a cached data item which is sized 900 kilobytes will be
 * cached both in disk and memory, and another cached data whose size is 1.2 megabytes will only be cached in
 * disk.
 */

#define HMCACHE_MANAGER_MEMORY_CACHE_SIZE_THRESHOLD             (1 * 1024 * 1024)

/*
 * Default group
 */
HMExternStringKeyMaker(HMCacheDefaultGroup)

/*
 * Cached data in this group will not be delete during version check, and only atom types(e.g. NSString, NSNumber)
 * are allowed to be cached in this group.
 */
HMExternStringKeyMaker(HMCacheReserveGroup)


@interface HMCacheManager : NSObject

#pragma mark - singleton

+ (instancetype)sharedManager;

#pragma mark - Cache and fetch methods

/**
 *  clear all cache data
 */
- (void)clearCache;
- (void)clearCacheWithCompletion:(void (^)(void))completion;

/**
 *  clear cache data of a group
 */
- (void)clearGroup:(NSString *)group;

/**
 *  remove a cache item
 */
- (void)removeCacheForKey:(NSString *)key;
- (void)removeCacheForKey:(NSString *)key inGroup:(NSString *)group;

/**
 *  NSData
 */
- (void)cacheData:(NSData *)data forKey:(NSString *)key;
- (void)cacheData:(NSData *)data forKey:(NSString *)key inGroup:(NSString *)group;
- (void)cacheData:(NSData *)data forKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;
- (NSData *)dataForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key inGroup:(NSString *)group;
- (NSData *)dataForKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;

/**
 *  Object
 */
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key;
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key inGroup:(NSString *)group;
- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;
- (id)objectForKey:(NSString *)key;
- (id)objectForKey:(NSString *)key inGroup:(NSString *)group;
- (id)objectForKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;

/**
 *  Group
 */
- (void)enumerateCachesInGroup:(NSString *)group block:(void (^)(NSString *name, BOOL isSubGroup, BOOL *stop))block;

@end
