//
//  ChatUserData.m
//  ChatModule
//
//  Created by Виктория on 27.04.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "ChatUserData.h"

@implementation ChatUserData

- (ChatUserData *)initWithJSON:(NSDictionary *)json {
    self = [self init];
    if (self) {
        _id = integer(json[@"id"]);
        _name = string(json[@"name"]);
        _position = string(json[@"position"]);
        
    }
    return self;
}

@end
