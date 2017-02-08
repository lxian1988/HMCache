//
//  FooObject.m
//  HMCacheDemo
//
//  Created by 李宪 on 6/2/2017.
//  Copyright © 2017 lxian1988@gmail.com. All rights reserved.
//

#import "FooObject.h"

#import "BarObject.h"

#import "HMMigrationData.h"

@implementation FooObject

- (void)dealloc {
    NSLog(@"foo dealloc!");
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.integer = 1;
        self.string = @"I am a foo!";
        self.categoryString = @"This is a NSString in category";
//        self.barObject = [BarObject new];
    }
    return self;
}

- (BOOL)migrateWithData:(HMMigrationData *)migrationData fromVersion:(NSString *)version {
    if ([version isEqualToString:@"1.0.0"]) {
        HMMigrationData *barObject = migrationData[@"barObject"];
        NSDate *barObjectDate = barObject[@"date"];
        [migrationData replaceKey:@"barObject" withKey:@"barObjectDate" object:barObjectDate];
    }
    
    return YES;
}

@end


#import <objc/runtime.h>

@implementation FooObject (TestCategory)

+ (void)load {
    [self registerPropertyName:@"categoryString" withCategoryName:@"TestCategory"];
}

- (void)setCategoryString:(NSString *)categoryString {
    objc_setAssociatedObject(self, "categoryString", categoryString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)categoryString {
    return objc_getAssociatedObject(self, "categoryString");
}

@end


@implementation SubFooObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.number = @123;
    }
    return self;
}

- (void)dealloc {
    NSLog(@"subfoo dealloc!");
}

@end
