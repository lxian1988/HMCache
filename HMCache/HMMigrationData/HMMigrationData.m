//
//  HMMigrationData.m
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMMigrationData.h"
#import "HMObject.h"

@interface HMMigrationData ()

@property (nonatomic, strong) NSMutableDictionary *keyValues;

@end

@implementation HMMigrationData

#pragma mark - NSCoding

- (id)initWithCoder:(NSKeyedUnarchiver *)aDecoder {
    if ((self = [super init])) {
        
        NSString *className = aDecoder.deletedClassName;
        NSString *cacheVersion = [aDecoder decodeObjectForKey:HMObjectClassVersionCacheKey];
        
        NSSet *cachePropertyNames = [HMObject propertyNamesWithClassName:className version:cacheVersion];
        
        for (NSString *key in cachePropertyNames) {
            id value = [aDecoder decodeObjectForKey:key];
            if (value) {
                [self setObject:value forKey:key];
            }
        }
        
        aDecoder.deletedClassName = nil;
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

#pragma mark - Subscripting

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self.keyValues objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [self.keyValues setObject:obj forKeyedSubscript:key];
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


#import <objc/runtime.h>

@implementation NSKeyedUnarchiver (HMCacheMigration)

- (void)setDeletedClassName:(NSString *)deletedClassName {
    objc_setAssociatedObject(self, "deletedClassName", deletedClassName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)deletedClassName {
    return objc_getAssociatedObject(self, "deletedClassName");
}

@end
