//
//  OrderChatController.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "OrderChatController.h"
#import "ChatData.h"
#import "TextMessageCell.h"
#import "UIAlertController+DVAlert.h"

@interface OrderChatController ()

@end

@implementation OrderChatController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.typeOfChat = @"123456";
        [[HTTPClient sharedinstance] getChatByOrder:@"123456" forUser:1 onSuccess:^(ChatData *response) {
            self.chatData = response;
            [self.tableView reloadData];
        } onFailure:^(NSError *error) {
            [self presentViewController:[UIAlertController showErrorAlert:error] animated:YES completion:nil];
        }];
        
        
        
        self.messageBubbleController = [[BubbleFactoryController alloc] initWithChatController:self];
        
        [self.tableView registerClass:[TextMessageCell class] forCellReuseIdentifier:@"TextMessageCell"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}

@end
