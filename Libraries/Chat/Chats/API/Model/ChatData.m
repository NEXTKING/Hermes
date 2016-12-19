//
//  ChatData.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "ChatData.h"
#import "ChatMessageData.h"

@implementation ChatData

- (ChatData *)init {
    self = [super init];
    if (self) {
        _chat_id = @"";
        _messages = @[].mutableCopy;
    }
    return self;
}

- (ChatData *)initWithJSON:(NSDictionary *)json {
    self = [self init];
    if (self) {
        _chat_id = string(json[@"chat_id"]);
        NSArray *chat_array = array(json[@"chat"]);
        _messages = [ChatMessageData dataArrayWithJSON:chat_array].mutableCopy;
        
    }
    return self;
}

@end
