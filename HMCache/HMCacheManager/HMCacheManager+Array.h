//
//  HMCacheManager+Array.h
//  HMCache
//
//  Created by 李宪 on 21/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMCacheManager.h"

@interface HMCacheManager (Array)

/**
 * NSArray cache convenient methods.
 */
- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key;
- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key maxItems:(NSUInteger)maxItems;
- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group;
- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group maxItems:(NSUInteger)maxItems;
- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;
- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory maxItems:(NSUInteger)maxItems;

/**
 * NSArray restore convenient methods.
 */
- (NSArray *)arrayForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key inGroup:(NSString *)group;
- (NSArray *)arrayForKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;
- (NSMutableArray *)mutableArrayForKey:(NSString *)key;
- (NSMutableArray *)mutableArrayForKey:(NSString *)key inGroup:(NSString *)group;
- (NSMutableArray *)mutableArrayForKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory;

@end
