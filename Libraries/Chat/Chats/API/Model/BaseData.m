//
//  BaseData.m
//  ChatModule
//
//  Created by Виктория on 27.04.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "BaseData.h"

@implementation BaseData

+ (BaseData *)dataWithJSON:(NSDictionary *)json
{
    BaseData *data = [[[self class] alloc] initWithJSON:json];
    
    return data;
}

+ (NSArray *)dataArrayWithJSON:(NSArray *)json
{
    NSMutableArray *dataArray = [NSMutableArray new];
    for (id jsonData in json) {
        if ([jsonData isKindOfClass:[self class]]) {
            [dataArray addObject:jsonData];
        } else {
            [dataArray addObject:[[self class] dataWithJSON:jsonData]];
        }
    }
    
    return dataArray;
}

- (BaseData *)initWithJSON:(id)json
{
    self = [self init];
    if (self) {
        if ([json isKindOfClass:[self class]]) {
            json = [(BaseData *)json json];
        }
        [self updateWithJSON:json];
    }
    
    return self;
}

- (void)updateWithJSON:(id)json
{
    if (_json) {
        [_json setValuesForKeysWithDictionary:json];
    } else {
        _json = [json mutableCopy];
    }
}

@end
