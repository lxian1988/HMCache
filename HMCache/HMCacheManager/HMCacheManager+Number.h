//
//  HMCacheManager+Number.h
//  HMCache
//
//  Created by 李宪 on 21/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMCacheManager.h"

@interface HMCacheManager (Number)

/**
 * Boolean convenient methods.
 */
- (void)cacheBool:(BOOL)boolean forKey:(NSString *)key;
- (void)cacheBool:(BOOL)boolean forKey:(NSString *)key inGroup:(NSString *)group;
- (BOOL)boolForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * Integer convenient methods.
 */
- (void)cacheInteger:(NSInteger)integer forKey:(NSString *)key;
- (void)cacheInteger:(NSInteger)integer forKey:(NSString *)key inGroup:(NSString *)group;
- (NSInteger)integerForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * Unsigned Integer convenient methods.
 */
- (void)cacheUnsignedInteger:(NSUInteger)uinteger forKey:(NSString *)key;
- (void)cacheUnsignedInteger:(NSUInteger)uinteger forKey:(NSString *)key inGroup:(NSString *)group;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key;
- (NSUInteger)unsignedIntegerForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * float convenient methods.
 */
- (void)cacheFloat:(float)aFloat forKey:(NSString *)key;
- (void)cacheFloat:(float)aFloat forKey:(NSString *)key inGroup:(NSString *)group;
- (float)floatForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key inGroup:(NSString *)group;

/**
 * double convenient methods.
 */
- (void)cacheDouble:(double)aDouble forKey:(NSString *)key;
- (void)cacheDouble:(double)aDouble forKey:(NSString *)key inGroup:(NSString *)group;
- (double)doubleForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key inGroup:(NSString *)group;

@end
