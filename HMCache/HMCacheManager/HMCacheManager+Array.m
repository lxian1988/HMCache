//
//  HMCacheManager+Array.m
//  HMCache
//
//  Created by 李宪 on 21/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMCacheManager+Array.h"

@implementation HMCacheManager (Array)

- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key {
    [self cacheArray:array forKey:key inGroup:nil];
}

- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key maxItems:(NSUInteger)maxItems {
    [self cacheArray:array forKey:key inGroup:nil maxItems:maxItems];
}

- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group {
    [self cacheArray:array forKey:key inGroup:group keepInMemory:NO];
}

- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group maxItems:(NSUInteger)maxItems {
    [self cacheArray:array forKey:key inGroup:group keepInMemory:NO maxItems:maxItems];
}

- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory {
    [self cacheArray:array forKey:key inGroup:group keepInMemory:keepInMemory maxItems:NSUIntegerMax];
}

- (void)cacheArray:(NSArray<id<NSCoding>> *)array forKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory maxItems:(NSUInteger)maxItems {
    
    NSParameterAssert([array isKindOfClass:[NSArray class]]);
    
    if (array.count > maxItems) {
        NSArray *subarray = [array subarrayWithRange:NSMakeRange(0, maxItems)];
        [self cacheObject:subarray forKey:key inGroup:group keepInMemory:keepInMemory];
    }
    else {
        [self cacheObject:array forKey:key inGroup:group keepInMemory:keepInMemory];
    }
}

- (NSArray *)arrayForKey:(NSString *)key {
    return [self arrayForKey:key inGroup:nil];
}

- (NSArray *)arrayForKey:(NSString *)key inGroup:(NSString *)group {
    return [self arrayForKey:key inGroup:group keepInMemory:NO];
}

- (NSArray *)arrayForKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory {
    return [self objectForKey:key inGroup:group keepInMemory:keepInMemory];
}

- (NSMutableArray *)mutableArrayForKey:(NSString *)key {
    return [self mutableArrayForKey:key inGroup:nil];
}

- (NSMutableArray *)mutableArrayForKey:(NSString *)key inGroup:(NSString *)group {
    return [self mutableArrayForKey:key inGroup:group keepInMemory:NO];
}

- (NSMutableArray *)mutableArrayForKey:(NSString *)key inGroup:(NSString *)group keepInMemory:(BOOL)keepInMemory {
    
    NSArray *array = [[self arrayForKey:key inGroup:group keepInMemory:keepInMemory]mutableCopy];
    if (!array) {
        return nil;
    }
    
    if ([array isKindOfClass:[NSMutableArray class]]) {
        return (NSMutableArray *)array;
    }
    
    return [array mutableCopy];
}

@end
