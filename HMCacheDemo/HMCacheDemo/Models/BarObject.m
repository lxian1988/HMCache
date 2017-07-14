//
//  BarObject.m
//  HMCacheDemo
//
//  Created by 李宪 on 6/2/2017.
//  Copyright © 2017 lxian1988@gmail.com. All rights reserved.
//

#import "BarObject.h"

@implementation BarObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.date = [NSDate date];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"bar dealloced!");
}

@end
