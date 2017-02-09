//
//  HMCacheManager.m
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMCacheManager.h"

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif  /* TARGET_OS_IPHONE */


HMCustomStringKeyMaker(HMCacheConfigGroup, @"HMCacheConfigGroup_AvoidSameNameByAccidentXXX123")
HMCustomStringKeyMaker(HMCacheDefaultGroup, @"HMCacheDefaultGroup_AvoidSameNameByAccidentXXx42")
HMCustomStringKeyMaker(HMCacheReserveGroup, @"HMCacheReserveGroup_AvoidSameNameByAccidentEEwr2XX")


static NSString *CacheDirectoryRoot() {
    static NSString *root;
    
    if (!root) {
//        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *cacheDirectory = directories.firstObject;
        root = [cacheDirectory stringByAppendingPathComponent:@"HMCache"];
        
        NSLog(@"HMCacheManager root directory is: %@", root);
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:root]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:root
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
        
        // disable iCloud backup
        NSURL *URL = [NSURL fileURLWithPath:root];
        [URL setResourceValue:@YES
                       forKey:NSURLIsExcludedFromBackupKey
                        error:NULL];
    }
    
    return root;
}

static NSString *CacheDirectoryForGroup(NSString *group) {
    
    group = [group stringByReplacingOccurrencesOfString:@"." withString:@"/"];
    
    NSString *directory = [CacheDirectoryRoot() stringByAppendingPathComponent:group];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    return directory;
}

static NSString *CachePathForKeyInGroup(NSString *key, NSString *group) {
    return [CacheDirectoryForGroup(group) stringByAppendingPathComponent:key];
}


@interface HMCacheManager ()

@property (nonatomic, strong) NSMutableDictionary *cacheOfGroups;

#if OS_OBJECT_USE_OBJC
@property (nonatomic, strong) dispatch_queue_t ioQueue;
#else
@property (nonatomic, assign) dispatch_queue_t ioQueue;
#endif  /* OS_OBJECT_USE_OBJC */

#if HMCACHE_MANAGER_VERSION_CHECK
@property (nonatomic, strong) NSArray *compatibleVersions;
#endif /* HMCACHE_MANAGER_VERSION_CHECK */

@end


@implementation HMCacheManager

#pragma mark - singleton

+ (instancetype)sharedManager {
    static id instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        
        _ioQueue = dispatch_queue_create("HMCacheManagerIOQueue", DISPATCH_QUEUE_SERIAL);
        
#if HMCACHE_MANAGER_VERSION_CHECK
        [self checkVersion];
#endif /* HMCACHE_MANAGER_VERSION_CHECK */
        
#if TARGET_OS_IPHONE
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
#endif  /* TARGET_OS_IPHONE */
    }
    return self;
}

- (void)dealloc {
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_ioQueue);
#endif
}

#pragma mark - lazy loading

- (NSMutableDictionary *)cacheOfGroups {
    if (!_cacheOfGroups) {
        _cacheOfGroups = [NSMutableDictionary new];
    }
    return _cacheOfGroups;
}

#if HMCACHE_MANAGER_VERSION_CHECK
- (NSArray *)compatibleVersions {
    if (!_compatibleVersions) {
        _compatibleVersions = @[];
    }
    return _compatibleVersions;
}
#endif /* HMCACHE_MANAGER_VERSION_CHECK */

#pragma mark - private

#if HMCACHE_MANAGER_VERSION_CHECK
- (void)checkVersion {
    
    HMStringKeyMaker(kHMCacheConfigGroupKeyVersion)
    
    NSString *lastVersion = [self objectForKey:kHMCacheConfigGroupKeyVersion inGroup:HMCacheConfigGroup];
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    [self cacheObject:currentVersion forKey:kHMCacheConfigGroupKeyVersion inGroup:HMCacheConfigGroup];
    
    NSLog(@"lastVersion is: %@, currentVersion is: %@", lastVersion, currentVersion);
    
    if (![lastVersion isEqualToString:currentVersion]
        && ![self.compatibleVersions containsObject:lastVersion]) {
        
        NSLog(@"clearing cache cause new version detected");
        
        dispatch_async(_ioQueue, ^{
            NSString *root = CacheDirectoryRoot();
            
            NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:root error:NULL];
            NSLog(@"files are: %@", files);
            [files enumerateObjectsUsingBlock:^(NSString *file, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *fullPath = [root stringByAppendingPathComponent:file];
                
                BOOL isDirectory = NO;
                if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
                    if (!isDirectory) {
                        return;
                    }
                    
                    // If app is updated, delete all cached data except for kHMCacheConfigGroup and kHMCacheReserveGroup
                    if ([file isEqualToString:HMCacheConfigGroup]
                        || [file isEqualToString:HMCacheReserveGroup]) {
                        
                        NSLog(@"skip file: %@", file);
                        return;
                    }
                    
                    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:NULL];
                }
            }];
            
            NSLog(@"clearing cache finished");
        });
    }
}
#endif /* HMCACHE_MANAGER_VERSION_CHECK */

#pragma mark - memory warning

- (void)didReceiveMemoryWarning {
    
    dispatch_async(_ioQueue, ^{
        [self.cacheOfGroups removeAllObjects];
    });
}

#pragma mark - public

- (void)clearCache {
    [self clearCacheWithCompletion:nil];
}

- (void)clearCacheWithCompletion:(void (^)())completion {
    
    NSLog(@"clearing cache...");
    
    dispatch_async(_ioQueue, ^{
        
        [self.cacheOfGroups removeAllObjects];
        
        [[NSFileManager defaultManager] removeItemAtPath:CacheDirectoryRoot() error:NULL];
        
        NSLog(@"cache cleared!");
        
        if (completion) {
            completion();
        }
    });
}

- (void)clearGroup:(NSString *)group {
    
    NSLog(@"clearing group %@ ...", group);
    
    dispatch_async(_ioQueue, ^{
        
        [self.cacheOfGroups removeObjectForKey:group];
        
        [[NSFileManager defaultManager] removeItemAtPath:CacheDirectoryForGroup(group) error:NULL];
    });
}

- (void)removeCacheForKey:(NSString *)key {
    [self removeCacheForKey:key inGroup:HMCacheDefaultGroup];
}

- (void)removeCacheForKey:(NSString *)key inGroup:(NSString *)group {
    
    dispatch_async(_ioQueue, ^{
        
        NSCache *cache = self.cacheOfGroups[group];
        if (cache) {
            [cache removeObjectForKey:key];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:CachePathForKeyInGroup(key, group) error:NULL];
    });
}

#pragma mark - NSData IO

- (void)cacheData:(NSData *)data forKey:(NSString *)key {
    [self cacheData:data forKey:key inGroup:HMCacheDefaultGroup];
}

- (void)cacheData:(NSData *)data forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheData:data forKey:key inGroup:group keepInMemory:NO];
}

- (void)cacheData:(NSData *)data
           forKey:(NSString *)key
          inGroup:(NSString *)group
     keepInMemory:(BOOL)keepInMemory {
    
    NSParameterAssert(data);
    NSParameterAssert(key.length);
    
    if (group.length == 0) {
        group = HMCacheDefaultGroup;
    }
    
    dispatch_async(_ioQueue, ^{
        
        NSCache *cache = self.cacheOfGroups[group];
        if (!cache) {
            cache = [NSCache new];
            cache.name = [NSString stringWithFormat:@"HMCache.%@", group];
            self.cacheOfGroups[group] = cache;
        }
        
        if (keepInMemory
            || data.length < HMCACHE_MANAGER_MEMORY_CACHE_SIZE_THRESHOLD) {
            [cache setObject:data forKey:key cost:data.length];
        }
        else {
            [cache removeObjectForKey:key];
        }
        
        [data writeToFile:CachePathForKeyInGroup(key, group) atomically:YES];
    });
}

- (NSData *)dataForKey:(NSString *)key {
    return [self dataForKey:key inGroup:HMCacheDefaultGroup];
}

- (NSData *)dataForKey:(NSString *)key inGroup:(NSString *)group {
    return [self dataForKey:key inGroup:group keepInMemory:NO];
}

- (NSData *)dataForKey:(NSString *)key
               inGroup:(NSString *)group
          keepInMemory:(BOOL)keepInMemory {
    
    NSParameterAssert(key.length);
    
    if (group.length == 0) {
        group = HMCacheDefaultGroup;
    }
    
    __block NSData *data;
    
    dispatch_sync(_ioQueue, ^{
        // try to read data in memory
        
        NSCache *cache = self.cacheOfGroups[group];
        if (cache) {
            data = [cache objectForKey:key];
        }
        
        if (!data) {
            // read data from disk
            data = [NSData dataWithContentsOfFile:CachePathForKeyInGroup(key, group) options:0 error:NULL];
            
            // save data in memory
            if (data) {
                if (data.length < HMCACHE_MANAGER_MEMORY_CACHE_SIZE_THRESHOLD
                    && keepInMemory) {
                    [cache setObject:data forKey:key];
                }
            }
        }
    });
    
    return data;
}

#pragma mark - Object IO

- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key {
    [self cacheObject:object forKey:key inGroup:HMCacheDefaultGroup];
}

- (void)cacheObject:(id<NSCoding>)object forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheObject:object forKey:key inGroup:group keepInMemory:NO];
}

- (void)cacheObject:(id<NSCoding>)object
             forKey:(NSString *)key
            inGroup:(NSString *)group
       keepInMemory:(BOOL)keepInMemory {
    
#ifdef DEBUG
    
    if (group == HMCacheReserveGroup) {
        NSString *className = NSStringFromClass([(NSObject *)object class]);
        className = [className stringByReplacingOccurrencesOfString:@"_" withString:@""];
        if (![className hasPrefix:@"NS"]) {
            NSAssert(NO, @"Only object of class from NSFoundation can be cached in HMCacheReserveGroup!");
        }
    }
    
#endif
    
    if (!object) {
        [self removeCacheForKey:key inGroup:group];
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self cacheData:data forKey:key inGroup:group keepInMemory:keepInMemory];
}

- (id)objectForKey:(NSString *)key {
    return [self objectForKey:key inGroup:HMCacheDefaultGroup];
}

- (id)objectForKey:(NSString *)key inGroup:(NSString *)group {
    return [self objectForKey:key inGroup:group keepInMemory:NO];
}

- (id)objectForKey:(NSString *)key
           inGroup:(NSString *)group
      keepInMemory:(BOOL)keepInMemory {
    
    NSData *data = [self dataForKey:key inGroup:group keepInMemory:keepInMemory];
    if (!data) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

/**
 *  Group
 */
- (void)enumerateCachesInGroup:(NSString *)group block:(void (^)(NSString *name, BOOL isSubGroup, BOOL *stop))block {
    
    NSString *directoryPath = CacheDirectoryForGroup(group);
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:directoryPath error:NULL];
    
    [files enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRange range = [fileName rangeOfString:@"."];
        if (range.length > 0) {
            return;
        }
        
        range = [fileName rangeOfString:@"/"];
        if (range.length > 0) {
            return;
        }
        
        NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
        
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
            block(fileName, isDirectory, stop);
        }
    }];
}

@end
