//
//  HMMigrationData.h
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMMigrationData : NSObject <NSCoding>

+ (void)registerClassName:(NSString *)className
            forUnarchiver:(NSKeyedUnarchiver *)unarchiver;

@property (nonatomic, strong) NSMutableDictionary *keyValues;

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(NSString *key, id value, BOOL *stop))block;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

- (void)replaceKey:(NSString *)oldKey withKey:(NSString *)newKey;
- (void)replaceKey:(NSString *)oldKey withKey:(NSString *)newKey object:(id)newObject;

@end
