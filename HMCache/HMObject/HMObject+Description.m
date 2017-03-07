//
//  HMObject+Description.m
//  HMCache
//
//  Created by 李宪 on 19/1/2017.
//  Copyright © 2017 李宪. All rights reserved.
//

#import "HMObject.h"

#import <objc/runtime.h>

@implementation HMObject (Description)

#pragma mark - Grow a tree

+ (NSDictionary *)treeWithObject:(HMObject *)object {

    NSMutableDictionary *root = [NSMutableDictionary new];
    
    NSMutableDictionary *subclassTree = root;
    
    Class subclass = [object class];
    while (subclass != [HMObject class]) {
        
        NSMutableDictionary *tree = [NSMutableDictionary new];
        
        NSMutableArray *keys = [NSMutableArray array];
        
        // scan properties
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(subclass, &propertyCount);
        
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
                    [keys addObject:key];
                }
                free(ivar);
            }
        }
        free(properties);
        
        // add category properties
        NSSet *categoryProperties = [subclass categoryPropertyNames];
        [keys addObjectsFromArray:categoryProperties.allObjects];
        
        // grow tree
        for (NSString *key in keys) {
            
            NSString *stripKey = key;
            
            NSRange range = [key rangeOfString:@")"];
            if (range.length > 0) {
                stripKey = [key substringFromIndex:range.location + 1];
            }
            
            id value = [object valueForKey:stripKey];
            
            if (!value) {
                tree[key] = [NSNull null];
            }
            else if ([value isKindOfClass:[HMObject class]]) {
                tree[key] = [self treeWithObject:value];
            }
            else if ([value isKindOfClass:[NSArray class]]) {
                tree[key] = [self treeWithArray:value];
            }
            else if ([value isKindOfClass:[NSDictionary class]]) {
                tree[key] = [self treeWithDictionary:value];
            }
            else if ([value isKindOfClass:[NSNumber class]]) {
                tree[key] = value;
            }
            else if ([value isKindOfClass:[NSString class]]) {
                tree[key] = value;
            }
            else {
                tree[key] = [NSString stringWithFormat:@"%@", value];
            }
        }
        
        NSString *className = NSStringFromClass(subclass);
        NSString *keyName = [@"*" stringByAppendingString:className];
        if (subclass != [object class]) {
            keyName = [@"*" stringByAppendingString:keyName];
        }
        
        subclassTree[keyName] = tree;
        subclassTree = tree;
        
        subclass = [subclass superclass];
    }
    
    return root;
}

+ (NSArray *)treeWithArray:(NSArray *)array {
    
    NSMutableArray *tree = [NSMutableArray array];
    
    for (id value in array) {
        if ([value isKindOfClass:[HMObject class]]) {
            [tree addObject:[self treeWithObject:value]];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            [tree addObject:[self treeWithArray:value]];
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            [tree addObject:[self treeWithDictionary:value]];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            [tree addObject:value];
        }
        else if ([value isKindOfClass:[NSString class]]) {
            [tree addObject:value];
        }
        else {
            [tree addObject:[NSString stringWithFormat:@"%@", value]];
        }
    }
    
    return tree;
}

+ (NSDictionary *)treeWithDictionary:(NSDictionary *)dictionary {
    
    NSMutableDictionary *tree = [NSMutableDictionary dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        
        if (![key isKindOfClass:[NSString class]]) {
            NSString *className = NSStringFromClass([key class]);
            key = [NSString stringWithFormat:@"%@<%p>", className, key];
        }
        
        if ([value isKindOfClass:[HMObject class]]) {
            tree[key] = [self treeWithObject:value];
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            tree[key] = [self treeWithArray:value];
        }
        else if ([value isKindOfClass:[NSDictionary class]]) {
            tree[key] = [self treeWithDictionary:value];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            tree[key] = value;
        }
        else if ([value isKindOfClass:[NSString class]]) {
            tree[key] = value;
        }
        else {
            tree[key] = [NSString stringWithFormat:@"%@", value];
        }
    }];
    
    return tree;
}

- (NSString *)description {
    
    NSDictionary *tree = [HMObject treeWithObject:self];
    
    NSError *error = NULL;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tree options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"parse json failed with error: %@", error.localizedFailureReason);
        return @"";
    }
    
    NSString *description = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    description = [@"\n" stringByAppendingString:description];

    return description;
}

- (NSString *)debugDescription {
    return self.description;
}

@end


@implementation NSArray (HMObjectDescription)

- (NSString *)description {
    
    NSArray *tree = [HMObject treeWithArray:self];
    
    NSError *error = NULL;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tree options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"parse json failed with error: %@", error.localizedFailureReason);
        return @"";
    }
    
    NSString *description = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    description = [@"\n" stringByAppendingString:description];
    
    return description;
}

- (NSString *)debugDescription {
    return self.description;
}

@end


@implementation NSDictionary (HMObjectDescription)

- (NSString *)description {
    
    NSDictionary *tree = [HMObject treeWithDictionary:self];
    
    NSError *error = NULL;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tree options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"parse json failed with error: %@", error.localizedFailureReason);
        return @"";
    }
    
    NSString *description = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    description = [@"\n" stringByAppendingString:description];
    
    return description;
}

- (NSString *)debugDescription {
    return self.description;
}

@end
