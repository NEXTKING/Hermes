//
//  ChatInteractorViewController.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "ChatInteractorViewController.h"

@interface ChatInteractorViewController ()

@property (nonatomic) NSInteger orderId;

@end

@implementation ChatInteractorViewController

- (id)initWithOrderId:(NSInteger)orderId {
    self = [super init];
    if (self) {
        _orderId = orderId;
    }
    return self;
}

- (id)initCommon {
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (OrderChatController *)orderChat {
    OrderChatController *orderChat = [[OrderChatController alloc] initWithNibName:@"OrderChatController" bundle:nil];
    orderChat.orderId = self.orderId;
    return orderChat;
}

- (CommonChatController *)commonChat {
    CommonChatController *commonChat = [[CommonChatController alloc] initWithNibName:@"CommonChatController" bundle:nil];
    return commonChat;
}
@end
