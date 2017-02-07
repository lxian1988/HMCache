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
    [self testKVO];
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

@end
