//
//  FooObject.h
//  HMCacheDemo
//
//  Created by 李宪 on 6/2/2017.
//  Copyright © 2017 lxian1988@gmail.com. All rights reserved.
//

#import "HMObject.h"

@class BarObject;

@interface FooObject : HMObject

@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, copy) NSString *string;
//@property (nonatomic, strong) BarObject *barObject;
@property (nonatomic, strong) NSString *barObjectDate;

@end


@interface FooObject (TestCategory)

@property (nonatomic, strong) NSString *categoryString;

@end

@interface SubFooObject : FooObject

@property (nonatomic, strong) NSNumber *number;

@end
