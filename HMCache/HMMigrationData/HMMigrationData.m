//
//  HMMigrationData.m
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMMigrationData.h"

#import "HMObject.h"

@implementation HMMigrationData

+ (NSMutableDictionary *)classInfoDictionary {
    static NSMutableDictionary *dictionary;
    if (!dictionary) {
        dictionary = [NSMutableDictionary new];
    }
    return dictionary;
}

+ (void)registerClassName:(NSString *)className forUnarchiver:(NSKeyedUnarchiver *)unarchiver {
    NSString *key = [NSString stringWithFormat:@"%p", unarchiver];
    [self classInfoDictionary][key] = className;
}

+ (NSString *)classNameForUnarchiver:(NSKeyedUnarchiver *)unarchiver {
    NSString *key = [NSString stringWithFormat:@"%p", unarchiver];
    return [self classInfoDictionary][key];
}

+ (void)deleteClassName:(NSString *)className forUnarchiver:(NSKeyedUnarchiver *)unarchiver {
    NSString *key = [NSString stringWithFormat:@"%p", unarchiver];
    [self classInfoDictionary][key] = nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSKeyedUnarchiver *)aDecoder {
    if ((self = [super init])) {
        
        NSString *className = [[self class] classNameForUnarchiver:aDecoder];
        NSString *cacheVersion = [aDecoder decodeObjectForKey:@"version"];
        
        NSSet *cachePropertyNames = [HMObject propertyNamesWithClassName:className version:cacheVersion];
        
        for (NSString *key in cachePropertyNames) {
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setObject:value forKey:key];
            }
        }
        
        [[self class] deleteClassName:className forUnarchiver:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSKeyedUnarchiver *)aCoder {
    // do nothing
}

#pragma mark - setters and getters

- (NSMutableDictionary *)keyValues {
    if (!_keyValues) {
        _keyValues = [NSMutableDictionary dictionary];
    }
    return _keyValues;
}

#pragma mark - public

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString *key, id value, BOOL *stop))block {
    [self.keyValues enumerateKeysAndObjectsUsingBlock:block];
}

- (id)objectForKey:(NSString *)key {
    return self.keyValues[key];
}

- (void)setObject:(id)object forKey:(NSString *)key {
    self.keyValues[key] = object;
}

- (void)removeObjectForKey:(NSString *)key {
    self.keyValues[key] = nil;
}

- (void)replaceKey:(NSString *)oldKey withKey:(NSString *)newKey {
    id value = self.keyValues[oldKey];
    if (!value) {
        return;
    }
    
    self.keyValues[oldKey] = nil;
    self.keyValues[newKey] = value;
}

- (void)replaceKey:(NSString *)oldKey withKey:(NSString *)newKey object:(id)newObject {
    
    id value = self.keyValues[oldKey];
    if (!value) {
        return;
    }
    
    self.keyValues[oldKey] = nil;
    
    if (!newObject) {
        return;
    }
    self.keyValues[newKey] = newObject;
}

@end
