//
//  HMKeyMaker.h
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#ifndef HMKeyMaker_h
#define HMKeyMaker_h

/**
 * String Key Maker
 */
#define HMStringKeyMaker(key)                       NSString * const key = @#key;
#define HMCustomStringKeyMaker(key, value)          NSString * const key = value;
#define HMExternStringKeyMaker(key)                 FOUNDATION_EXPORT NSString * const key;

/**
 * Integer Key Maker
 */

#define HMIntegerKeyMaker(key, value)               NSInteger const key = value;
#define HMExternIntegerKeyMaker(key)                FOUNDATION_EXPORT NSInteger const key;

/**
 * UInteger Key Maker
 */

#define HMUIntegerKeyMaker(key, value)              NSUInteger const key = value;
#define HMExternUIntegerKeyMaker(key)               FOUNDATION_EXPORT NSUInteger const key;

/**
 * Float Key Maker
 */

#define HMFloatKeyMaker(key, value)                 CGFloat const key = value;
#define HMExternFloatKeyMaker(key)                  FOUNDATION_EXPORT CGFloat const key;

#endif /* HMKeyMaker_h */
