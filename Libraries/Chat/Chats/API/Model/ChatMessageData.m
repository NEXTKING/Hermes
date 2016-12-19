//
//  ChatMessageData.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "ChatMessageData.h"

@implementation ChatMessageData

- (ChatMessageData *)initWithJSON:(NSDictionary *)json {
    self = [self init];
    if (self) {
        _text = string(json[@"message"]);
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        _date = [dateFormat dateFromString:string(json[@"date"])];
        
        _photo_url = string(json[@"photo_url"]);
        _user_data = [[ChatUserData alloc] initWithJSON:json[@"user"]];
        
    }
    return self;
}

@end
