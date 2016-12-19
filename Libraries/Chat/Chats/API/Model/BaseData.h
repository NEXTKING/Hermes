//
//  BaseData.h
//  ChatModule
//
//  Created by Виктория on 27.04.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>

#define number(v) (([v isKindOfClass:[NSNumber class]]) ? v : ([v isKindOfClass:[NSString class]]) ? @([v floatValue]) : @(0))

#define string(v) ((v == nil) ? @"" : ([v isKindOfClass:[NSNull class]]) ? @"" : ([v isKindOfClass:[NSString class]]) ? v : ([v isKindOfClass:[NSNumber class]]) ? [NSString stringWithFormat:@"%@", v] : @"")

#define array(v) ((v == nil) ? @[] : ([v isKindOfClass:[NSNull class]]) ? @[] : ([v isKindOfClass:[NSArray class]]) ? v : @[])

// Scalar values

#define boolean(v) ((v == nil) ? NO : [v boolValue])
#define integer(v) ( ((v == nil) || [v isKindOfClass:[NSNull class]] )? 0 : [v integerValue])
#define _double(v) ((v == nil) ? 0 : [v doubleValue])

@interface BaseData : NSObject


@property (nonatomic, strong) NSMutableDictionary *json;

+ (NSArray *)dataArrayWithJSON:(NSArray *)json;

@end
