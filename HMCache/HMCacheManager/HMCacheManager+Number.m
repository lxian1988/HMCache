//
//  HMCacheManager+Number.m
//  HMCache
//
//  Created by 李宪 on 21/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMCacheManager+Number.h"

@implementation HMCacheManager (Number)

#pragma mark - Boolean

- (void)cacheBool:(BOOL)boolean forKey:(NSString *)key {
    [self cacheBool:boolean forKey:key inGroup:nil];
}

- (void)cacheBool:(BOOL)boolean forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheObject:@(boolean) forKey:key inGroup:group];
}

- (BOOL)boolForKey:(NSString *)key {
    return [self boolForKey:key inGroup:nil];
}

- (BOOL)boolForKey:(NSString *)key inGroup:(NSString *)group {
    NSNumber *value = [self objectForKey:key inGroup:group];
    if (!value) {
        return NO;
    }
    
    return value.boolValue;
}

#pragma mark - Integer

- (void)cacheInteger:(NSInteger)integer forKey:(NSString *)key {
    [self cacheInteger:integer forKey:key inGroup:nil];
}

- (void)cacheInteger:(NSInteger)integer forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheObject:@(integer) forKey:key inGroup:group];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [self integerForKey:key inGroup:nil];
}

- (NSInteger)integerForKey:(NSString *)key inGroup:(NSString *)group {
    NSNumber *value = [self objectForKey:key inGroup:group];
    if (!value) {
        return 0;
    }
    
    return value.integerValue;
}

#pragma mark - Unsigned Integer

- (void)cacheUnsignedInteger:(NSUInteger)uinteger forKey:(NSString *)key {
    [self cacheUnsignedInteger:uinteger forKey:key inGroup:nil];
}

- (void)cacheUnsignedInteger:(NSUInteger)uinteger forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheObject:@(uinteger) forKey:key inGroup:group];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
    return [self unsignedIntegerForKey:key inGroup:nil];
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key inGroup:(NSString *)group {
    NSNumber *value = [self objectForKey:key inGroup:group];
    if (!value) {
        return 0;
    }
    
    return value.unsignedIntegerValue;
}

#pragma mark - Float

- (void)cacheFloat:(float)aFloat forKey:(NSString *)key {
    [self cacheFloat:aFloat forKey:key inGroup:nil];
}

- (void)cacheFloat:(float)aFloat forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheObject:@(aFloat) forKey:key inGroup:group];
}

- (float)floatForKey:(NSString *)key {
    return [self floatForKey:key inGroup:nil];
}

- (float)floatForKey:(NSString *)key inGroup:(NSString *)group {
    NSNumber *value = [self objectForKey:key inGroup:group];
    if (!value) {
        return 0.f;
    }
    
    return value.floatValue;
}

#pragma mark - Double

- (void)cacheDouble:(double)aDouble forKey:(NSString *)key {
    [self cacheDouble:aDouble forKey:key inGroup:nil];
}

- (void)cacheDouble:(double)aDouble forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheObject:@(aDouble) forKey:key inGroup:group];
}

- (double)doubleForKey:(NSString *)key {
    return [self doubleForKey:key inGroup:nil];
}

- (double)doubleForKey:(NSString *)key inGroup:(NSString *)group {
    NSNumber *value = [self objectForKey:key inGroup:group];
    if (!value) {
        return 0.f;
    }
    
    return value.floatValue;
}

@end
