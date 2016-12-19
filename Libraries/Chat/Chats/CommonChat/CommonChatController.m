//
//  CommonChatController.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "CommonChatController.h"
#import "HTTPClient.h"
#import "ChatData.h"
#import "TextMessageCell.h"
#import "UIAlertController+DVAlert.h"
#import "User.h"


@implementation CommonChatController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        User* currentUser =  [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
        NSInteger userId =  [currentUser.username integerValue];
        
        self.typeOfChat = @"common";
        [[HTTPClient sharedinstance] getCommonChatForUser:userId onSuccess:^(ChatData *response) {
            self.chatData = response;
            [self.tableView reloadData];
        } onFailure:^(NSError *error) {
            [self presentViewController:[UIAlertController showErrorAlert:error] animated:YES completion:nil];
            self.chatData = [[ChatData alloc] initWithJSON:@{}];
        }];
        
        
        
        self.messageBubbleController = [[BubbleFactoryController alloc] initWithChatController:self];
        
        [self.tableView registerClass:[TextMessageCell class] forCellReuseIdentifier:@"TextMessageCell"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return self;
}

@end
