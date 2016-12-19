//
//  BubbleFactoryController.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "BubbleFactoryController.h"
#import "BubbleFactoryImage.h"
#import "ChatViewController.h"
#import "User.h"

@implementation BubbleFactoryController

- (instancetype)initWithChatController:(id) controller {
    
    self = [super init];
    if (self) {
        self.chatControllerDelegate = (ChatViewController *)controller;
        
        self.incomingMessageBubbleColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1.0];
        self.outgoingMessageBubbleColor = [UIColor colorWithRed:46.0/255.0 green:162.0/255.0 blue:253.0/255.0 alpha:1.0];
        
        
        self.incomingDefaultMessageBubble = [[BubbleFactoryImage sharedInstanse] incomingMessageBubbleImageWithColor:self.incomingMessageBubbleColor bubbleTemplate:[UIImage imageNamed:@"recipient"]];
        
        self.outgoingDefaultMessageBubble = [[BubbleFactoryImage sharedInstanse] outgoingMessageBubbleImageWithColor:self.outgoingMessageBubbleColor bubbleTemplate:[UIImage imageNamed:@"recipient"]];
        
        
    }
    
    return self;
}

- (UIImageView *) messageBubbleForIndexPath:(NSIndexPath *) indexPath {
    User* user = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    NSInteger userID = [user.username integerValue];
    ChatMessageData *messageAtIndexPath = [self.chatControllerDelegate messageAtIndexPath:indexPath];
    
    BOOL isOutgoing = messageAtIndexPath.user_data.id == userID ? YES : NO;
    return isOutgoing == YES ? self.outgoingDefaultMessageBubble : self.incomingDefaultMessageBubble;

}

@end
