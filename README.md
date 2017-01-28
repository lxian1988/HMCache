Overview
========

[![Version](http://cocoapod-badges.herokuapp.com/v/HMCache/badge.png)](http://cocoadocs.org/docsets/HMCache)
[![Platform](http://cocoapod-badges.herokuapp.com/p/HMCache/badge.png)](https://github.com/swisspol/HMCache)
[![License](http://img.shields.io/cocoapods/l/HMCache.svg)](LICENSE)

HMCache is a library for data persistence in iOS app with some of other useful features. It is written from scratch and powered by Apple's NSCoding/NSCoder. 
HMCache implements a set of objects which are working interactively to provide a super convenient persistence API. These objects are list behind:

* **HMObject** is a base abstract class whose subclass can automatically scans their own and superclass's (till NSObject) property names and save the keys to disk for each version of the class. The records for those versions will be used for serialize/deserialize instance of the subclass of HMObject by NSCoding methods <code>initWithCoder:</code> and <code>encodeWithCoder:</code>, and migration from a earlier serialized data to current version class structure and initilize a instance.
* **HMCacheManager** is a file cache engine offers a key-value style API. It's a singleton. The lowest API is used for write a NSData to a file with a key name and read a NSData from disk with the same key. And it also supply the concept of 'group' which is actually directory. Using the read/write API with key and group can sorted keys in a specific group. 
* **HMMigrationData** is used for migrate cached data serialized from a  HMObject subclass instance. When deserializing a cached data and detected that the data is from a old version, a HMMigrationData will be newed and all the HMObject subclass object's cached values will be read and set to the HMMigration data instance. Then the HMMigration data instance will be given to the HMObject subclass by <code>- (BOOL)migrateWithData:(HMMigrationData *)migrationData fromVersion:(NSString *)version</code> method. The subclass must change, delete the key-values according to the difference between the old version and current version for migration purpose. 

Extra built-in features:

* Automatic implement NSCopying protocol for subclass.
* Implement <code>isEqual:</code>
* Implement <code>- (NSUInteger)hash</code>
* Automatic implement a JSON format <code>- (NSString *)description</code>
* Are the features metioned above supports **category** properties.

Getting Started
===============

Download or check out the [latest release](https://github.com/lxian1988/HMCache) of HMCache then add the entire "HMCache" subfolder to your Xcode project.

Alternatively, you can install HMCache using [CocoaPods](http://cocoapods.org/) by simply adding this line to your Podfile:

```
pod "HMCache", "~> 0.1.0"
```

Finally run `$ pod install`.


Hello World
===========

### Subclass of HMObject

Subclassing from HMObject is no diffenence from subclassing from another Cocoa class like NSObject.

```objectivec
#import "HMObject"

@interface FooObject : HMObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, strong) NSNumber *number;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) BarObject *barObject;

@end
```

### Cache and restore

```objectivec
NSString *key = @"key";
    
FooObject *foo = [FooObject objectInCacheForKey:key];
if (foo) {
	NSLog(@"cached foo is: %@", foo);
}
else {
	foo = [FooObject new];
	NSLog(@"new foo is: %@", foo);
        
	[foo cacheForKey:key];
}
```

### Category property

Declare a property in category interface as normal.

```objectivec
@interface FooObject (Category)

@property (nonatomic, strong) NSString *categoryString;

@end
```

Then using runtime to implement setter and getter for the property. And register the property by method <code> - (void)registerPropertyName:(NSString *)propertyName </code> or
 <code> - (void)registerPropertyName:(NSString *)propertyName withCategoryName:(NSString *)categoryName </code>.
 

```objectivec
@implementation FooObject (Category)

- (void)setCategoryString:(NSString *)categoryString {
    objc_setAssociatedObject(self, "categoryString", categoryString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self registerPropertyName:@"categoryString"];
}
- (NSString *)categoryString {
    return objc_getAssociatedObject(self, "categoryString");
}

@end
```

### Migration

When should you migration?

* Change a property's name.
* Change a property's type.
* Change both a property's name and type.
* Delete a property.

Add property does not need for migration.

The method <code> - (BOOL)migrateWithData:(HMMigrationData *)migrationData fromVersion:(NSString *)version </code> is used for migration old version data to current version. HMObject subclass using XCode project version for class version by default. And if there are more than one versions has been released, the migration code must be write by timeline order.

```objectivec
- (BOOL)migrateWithData:(HMMigrationData *)migrationData fromVersion:(NSString *)version {
    
    if ([version isEqualToString:@"1.0.0"]) {
        
        // change name
        [migrationData replaceKey:@"string" withKey:@"changeNameString"];
        
        // change type
        NSDate *date = [migrationData objectForKey:@"date"];
        [migrationData setObject:@([date timeIntervalSince1970]) forKey:@"date"];
        
        // delete
        [migrationData removeObjectForKey:@"integer"];
        
        // delete bar object, move barobject.string to fooobject.addString
        HMMigrationData *barObject = [migrationData objectForKey:@"barObject"];
        [migrationData removeObjectForKey:@"barObject"];
        NSString *barObjectString = [barObject objectForKey:@"string"];
        [migrationData setObject:barObjectString forKey:@"addString"];
    }

    if ([version isEqualToString:@"1.0.1"] ||
		[version isEqualToString:@"1.0.2"] ||) {
        
        // delete
        [migrationData removeObjectForKey:@"array"];
    }
    
    ...
    
    return YES;
}

```

And there are some tips:

1. Return YES means migration succeed while NO means failure or give up. Return NO will cause the class structure for the very verison be deleted from disk and no furture migration can be done for the specific version in the future.
2. If there is nothing need to be done for migration from a specific version (e.g. Nothing changed or you just add some property), just return YES. But, if you have implemented migration code for a older version, the no-migration-need version must using it's the migration code for it's former version. Like the migraion sample code above, version '1.0.1' and '1.0.2' have the same class structure so there is no need for migration from '1.0.1' to '1.0.2', but they must use the same migration code for migration from/to other version purpose.