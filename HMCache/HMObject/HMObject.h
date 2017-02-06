//
//  HMObject.h
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HMKeyMaker.h"


HMExternStringKeyMaker(HMObjectClassVersionCacheKey)


@interface HMObject : NSObject <NSCoding, NSCopying>

+ (NSSet *)propertyNames;
+ (NSSet *)propertyNamesWithClassName:(NSString *)className version:(NSString *)version;

@end


@class HMMigrationData;

@interface HMObject (Migration)

/**
 * Migration method for override.
 * The migrationData parameter contains the cached data of the object in a key-value format.
 * The version parameter indictators which version the data in migrationData is derived from.
 * Return 'YES' -- which is default impletentaion by HMObject -- means succeed, otherwise the
 * initWithCoder method will return self with none of the properties set. And the cached object
 * structure information of this version will be deleted from disk.
 */
- (BOOL)migrateWithData:(HMMigrationData *)migrationData fromVersion:(NSString *)version;

@end


@interface HMObject (SupportCategory)

+ (NSSet *)categoryPropertyNames;

+ (void)registerPropertyName:(NSString *)propertyName;
+ (void)registerPropertyName:(NSString *)propertyName withCategoryName:(NSString *)categoryName;

@end
