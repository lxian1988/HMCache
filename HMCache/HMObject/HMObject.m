//
//  HMObject.m
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMObject.h"

#import "HMObject+Cache.h"

#import <objc/runtime.h>
#import "HMKeyMaker.h"
#import "HMCacheManager.h"
#import "HMMigrationData.h"


static HMCustomStringKeyMaker(HMObjectClassMapCacheKey, @"HMObjectClassMap")
HMCustomStringKeyMaker(HMObjectClassVersionCacheKey, @"classVersion")




@interface HMObject () <NSKeyedUnarchiverDelegate>

@end

@implementation HMObject

+ (void)load {
    // Check classMap file. If broken, remove all HMObject Cache files.
    NSDictionary *classMap = [[HMCacheManager sharedManager] objectForKey:HMObjectClassMapCacheKey
                                                                  inGroup:HMCacheReserveGroup];
    if (!classMap) {
        NSLog(@"cannot find class map file, clear all cache data.");
        [self clearCache];
    }
}

+ (dispatch_queue_t)propertiesAccessQueue {

    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.hmobject.map.access.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

#pragma mark - Property Names

+ (NSString *)currentVersion {
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}

+ (NSString *)propertyNamesCacheKeyWithClassName:(NSString *)className version:(NSString *)version {
    return [NSString stringWithFormat:@"%@-V%@", className, version];
}

+ (NSSet *)propertyNamesWithVersion:(NSString *)version {
    return [self propertyNamesWithClassName:NSStringFromClass(self) version:version];
}

+ (NSSet *)propertyNamesWithClassName:(NSString *)className version:(NSString *)version {

    __block NSSet *propertyNames = nil;

    dispatch_sync(self.propertiesAccessQueue, ^{
        NSString *key = [self propertyNamesCacheKeyWithClassName:className version:version];

        // Already have runtime cache some no need to keep in memory
        NSMutableDictionary *classMap = [[HMCacheManager sharedManager] objectForKey:HMObjectClassMapCacheKey
                                                                             inGroup:HMCacheReserveGroup];
        propertyNames = classMap[key];
    });

    return propertyNames;
}

+ (void)cachePropertyNames:(NSSet *)propertyNames {

    dispatch_async(self.propertiesAccessQueue, ^{
        NSString *key = [self propertyNamesCacheKeyWithClassName:NSStringFromClass(self) version:[self currentVersion]];

        // Already have runtime cache some no need to keep in memory
        NSMutableDictionary *classMap = [[HMCacheManager sharedManager] objectForKey:HMObjectClassMapCacheKey
                                                                             inGroup:HMCacheReserveGroup];
        if (!classMap) {
            classMap = [NSMutableDictionary dictionary];
        }
        classMap[key] = propertyNames;
        [[HMCacheManager sharedManager] cacheObject:classMap
                                             forKey:HMObjectClassMapCacheKey
                                            inGroup:HMCacheReserveGroup];
    });
}

+ (void)deletePropertyNamesWithVersion:(NSString *)version {

    dispatch_async(self.propertiesAccessQueue, ^{

        NSString *key = [self propertyNamesCacheKeyWithClassName:NSStringFromClass(self) version:version];

        NSMutableDictionary *classMap = [[HMCacheManager sharedManager] objectForKey:HMObjectClassMapCacheKey
                                                                             inGroup:HMCacheReserveGroup];
        if (!classMap) {
            return;
        }
        classMap[key] = nil;
        [[HMCacheManager sharedManager] cacheObject:classMap
                                             forKey:HMObjectClassMapCacheKey
                                            inGroup:HMCacheReserveGroup];
    });
}

+ (NSSet *)propertyNames {
    
    NSString *kPropertyNames = @"propertyNames";
    
    // Check for a cached value from runtime memory
    NSMutableSet *propertyNames = objc_getAssociatedObject(self, kPropertyNames.UTF8String);
    if (propertyNames) {
        return propertyNames;
    }
    
    NSString *version = [self currentVersion];
    
    // Check for a cached value from disk
    propertyNames = (NSMutableSet *)[self propertyNamesWithVersion:version];
    if (propertyNames) {
        objc_setAssociatedObject(self, kPropertyNames.UTF8String, propertyNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return propertyNames;
    }
    
    // Loop through our superclasses until we hit NSObject
    propertyNames = [NSMutableSet set];

    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        // Get property name
        objc_property_t property = properties[i];
        const char *propertyName = property_getName(property);
        NSString *key = @(propertyName);

        // Check if there is a backing ivar
        char *ivar = property_copyAttributeValue(property, "V");
        if (ivar) {
            // Check if ivar has KVC-compliant name
            NSString *ivarName = @(ivar);
            if ([ivarName isEqualToString:key] ||
                [ivarName isEqualToString:[@"_" stringByAppendingString:key]]) {
                // setValue:forKey: will work
                [propertyNames addObject:key];
            }
            free(ivar);
        }
    }
    free(properties);

    if ([self superclass] != [NSObject class]) {
        NSSet *superClassPropertiesName = [[self superclass] propertyNames];
        [propertyNames unionSet:superClassPropertiesName];
    }

    // Cache in runtime memory
    objc_setAssociatedObject(self, kPropertyNames.UTF8String, propertyNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // Cache in disk
    [self cachePropertyNames:propertyNames];
    
    return propertyNames;
}

#pragma mark - NSKeyedUnarchiverDelegate <NSObject>

- (nullable Class)unarchiver:(NSKeyedUnarchiver *)unarchiver
cannotDecodeObjectOfClassName:(NSString *)name
             originalClasses:(NSArray<NSString *> *)classNames {
    
    unarchiver.deletedClassName = name;
    return [HMMigrationData class];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSKeyedUnarchiver *)aDecoder {
    if ((self = [super init])) {
        
        id delegate = aDecoder.delegate;
        aDecoder.delegate = self;
        
        // check for migration
        NSString *cacheVersion = [aDecoder decodeObjectForKey:HMObjectClassVersionCacheKey];
        NSString *currentVersion = [[self class] currentVersion];
        
        if (![cacheVersion isEqualToString:currentVersion]) {
            NSSet *cachePropertyNames = [[self class] propertyNamesWithVersion:cacheVersion];
            
            HMMigrationData *migrationData = [HMMigrationData new];
            for (NSString *key in cachePropertyNames) {
                id value = [aDecoder decodeObjectForKey:key];
                if (value) {
                    migrationData[key] = value;
                }
            }
            
            // Do migration. When succeed set all the values to self.
            if ([self migrateWithData:migrationData fromVersion:cacheVersion]) {
                [migrationData enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
                    [self setValue:value forKey:key];
                }];
            }
            else {
                // Migration failure, remove the class data structure information of this very version.
                [[self class] deletePropertyNamesWithVersion:cacheVersion];
            }
        }
        else {
            // Loop through the properties
            NSSet *propertyNames = [[self class] propertyNames];
            for (NSString *key in propertyNames) {
                // Decode the property, and use the KVC setValueForKey: method to set it
                id value = [aDecoder decodeObjectForKey:key];
                if (value) {
                    [self setValue:value forKey:key];
                }
            }
        }
        
        aDecoder.delegate = delegate;
    }
    return self;
}

- (void)encodeWithCoder:(NSKeyedArchiver *)aCoder {
    
    NSString *version = [[self class] currentVersion];
    [aCoder encodeObject:version forKey:HMObjectClassVersionCacheKey];
    
    // Loop through the properties
    NSSet *propertyNames = [[self class] propertyNames];
    for (NSString *key in propertyNames) {
        // Use the KVC valueForKey: method to get the property and then encode it
        id value = [self valueForKey:key];
        if (value) {
            [aCoder encodeObject:value forKey:key];
        }
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    
    id copy = [[self.class allocWithZone:zone]init];
    
    NSSet *propertyNames = [[self class] propertyNames];
    for (NSString *key in propertyNames) {
        // Use the KVC valueForKey: method to get the property and then encode it
        id value = [self valueForKey:key];
        if (value) {
            if ([value isKindOfClass:[NSMutableString class]] ||
                [value isKindOfClass:[NSMutableAttributedString class]] ||
                [value isKindOfClass:[NSMutableArray class]] ||
                [value isKindOfClass:[NSMutableDictionary class]] ||
                [value isKindOfClass:[NSMutableData class]] ||
                [value isKindOfClass:[NSMutableSet class]] ||
                [value isKindOfClass:[NSMutableOrderedSet class]] ||
                [value isKindOfClass:[NSMutableIndexSet class]] ||
                [value isKindOfClass:[NSMutableCharacterSet class]] ||
                [value isKindOfClass:[NSMutableURLRequest class]]) {
                
                [copy setValue:[value mutableCopyWithZone:zone] forKey:key];
            }
            else if ([value conformsToProtocol:@protocol(NSCopying)]) {
                [copy setValue:[value copyWithZone:zone] forKey:key];
            }
            else {
                [copy setValue:value forKey:key];
            }
        }
    }
    
    return copy;
}

#pragma mark - hash

- (NSUInteger)hash {
    NSUInteger value = 0;
    
    for (NSString *key in [[self class] propertyNames]) {
        value ^= [[self valueForKey:key] hash];
    }
    
    return value;
}

#pragma mark - isEqual

- (BOOL)isEqual:(HMObject *)object {
    
    if (self == object) {
        return YES;
    }
    
    if (![object isMemberOfClass:self.class]) {
        return NO;
    }
    
    for (NSString *key in [[self class] propertyNames]) {
        id selfValue = [self valueForKey:key];
        id objectValue = [object valueForKey:key];
        
        if (!selfValue && !objectValue) {
            continue;
        }
        
        if (![selfValue isEqual:objectValue]) {
            return NO;
        }
    }
    
    return YES;
}

#if !DEBUG
// Avoid crash in RELEASE mode
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@ is setting value: %@ for undefined key: %@ ", NSStringFromClass([self class]), value, key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"%@ is reading undefined key: %@ ", NSStringFromClass([self class]), key);
    return nil;
}

#endif

@end


@implementation HMObject (Migration)

- (BOOL)migrateWithData:(HMMigrationData *)migrationData fromVersion:(NSString *)version {
    return YES;
}

@end


@implementation HMObject (SupportCategory)

+ (NSSet *)categoryPropertyNames {
    return objc_getAssociatedObject(self, "categoryPropertyNames");
}

+ (void)registerPropertyName:(NSString *)propertyName {
    [self registerPropertyName:propertyName withCategoryName:@"Category"];
}

+ (void)registerPropertyName:(NSString *)propertyName withCategoryName:(NSString *)categoryName {
    // add to category property names for tracking
    NSMutableSet *categoryPropertyNames = (NSMutableSet *)[self categoryPropertyNames];
    if (!categoryPropertyNames) {
        categoryPropertyNames = [NSMutableSet set];
        objc_setAssociatedObject(self, "categoryPropertyNames", categoryPropertyNames, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    NSString *categoryPropertyName = [NSString stringWithFormat:@"(%@)%@", categoryName, propertyName];
    [categoryPropertyNames addObject:categoryPropertyName];
    
    // add to class property names add save to disk
    NSMutableSet *propertyNames = (NSMutableSet *)[[self class] propertyNames];
    if ([propertyNames containsObject:propertyName]) {
        return;
    }
    
    [propertyNames addObject:propertyName];
    [self cachePropertyNames:propertyNames];
}

@end
