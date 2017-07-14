//
//  ViewController.m
//  HMCacheDemo
//
//  Created by 李宪 on 6/2/2017.
//  Copyright © 2017 lxian1988@gmail.com. All rights reserved.
//

#import "ViewController.h"

#import "HMCache.h"
#import "FooObject.h"
#import "BarObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testCache];
//    [self testDescription];
//    [self testKVO];
//    [self testClassKVO];
    [self testBind];
    
//    [[HMCacheManager sharedManager] enumerateCachesInGroup:@"HMObjectRootCacheGroup" block:^(NSString *name, BOOL isSubGroup, BOOL *stop) {
//        NSLog(@"name is: %@, is subgroup: %@", name, isSubGroup ? @"YES" : @"NO");
//    }];
}

- (void)testCache {
    
    NSLog(@"Testing cache ... \n\n");
    
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
}

- (void)testDescription {
    
    NSLog(@"Testing description ... \n\n");
    
    FooObject *foo = [FooObject new];
    NSLog(@"new foo is: %@", foo);
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        FooObject *object = [FooObject new];
        [mutableArray addObject:object];
    }
    
    NSLog(@"array is: %@", mutableArray.description);
    
    NSDictionary *dictionary = @{@"1" : [FooObject new],
                                 @"2" : [SubFooObject new]};
    NSLog(@"dictionary is: %@", dictionary.description);
}

- (void)testKVO {
    
    static FooObject *foo;
    
    foo = [FooObject new];
    
    [foo connectKeyPathValueChange:@"integer"
                        toObserver:self
                         withBlock:^(HMObject *object, id oldValue, id newValue, BOOL *stop) {
                             
        NSLog(@"observed keyPath %@, oldValue = %@, newValue = %@", @"integer", oldValue, newValue);
        
        
//        if ([newValue integerValue] == 10) {
//            *stop = YES;
//        }
    }];
    
    [foo connectKeyPathValueChange:@"string" toObserver:self withBlock:^(HMObject *object, id oldValue, id newValue, BOOL *stop) {
        NSLog(@"observed keyPath %@, oldValue = %@, newValue = %@", @"string", oldValue, newValue);
        
    }];
    
    foo.integer = foo.integer;
    
    for (int i = 0; i < 20; i++) {
        foo.integer++;
        foo.string = [foo.string stringByAppendingString:@"string"];
        
        NSLog(@"foo.integer is: %d", (int)foo.integer);
        
        if (i == 15) {
//            [foo disconnectKeyPathValueChange:@"integer" fromObserver:self];
            break;
        }
    }
    
    foo = nil;
}

- (void)testClassKVO {

    SubFooObject *sub = [SubFooObject new];
    
    FooObject *foo1 = [FooObject new];
    foo1.string = @"foo1";
    
    BarObject *bar1 = [BarObject new];
    
    [FooObject connectKeyPathValueChange:@"integer"
                              toObserver:self
                               withBlock:^(HMObject *object, id oldValue, id newValue, BOOL *stop) {
                                   NSLog(@"observed keyPath %@, object: %@, oldValue = %@, newValue = %@", @"integer", object, oldValue, newValue);
                               }];
    
    sub = nil;
    
    FooObject *foo2 = [FooObject new];
    foo2.string = @"foo2";
    
    foo2 = nil;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"aaa");
        for (int i = 0; i < 1; i++) {
            foo1.integer++;
            foo2.integer = i * 2;
            
            bar1.integer++;
            bar1.date = [[NSDate date] dateByAddingTimeInterval:i];
        }
        NSLog(@"bbb");
    });
}

- (void)testBind {
    
    FooObject *foo = [FooObject new];
    foo.string = @"";
    
    UILabel *label = [UILabel new];
    
    HMBind(label, text, foo, string);
    
    for (int i = 0; i < 10; i++) {
        foo.string = [NSString stringWithFormat:@"%d", i];
        
        NSLog(@"foo.string is: %@", foo.string);
        NSLog(@"label.text is: %@", label.text);
    }
    
}

@end
