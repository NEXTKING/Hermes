//
//  BubbleFactoryController.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#import "ChatMessageData.h"

@protocol BubbleFactoryControllerDelegate <NSObject>

- (ChatMessageData *) messageAtIndexPath:(NSIndexPath *) indexPath;

@end

@interface BubbleFactoryController : NSObject

@property (nonatomic) id <BubbleFactoryControllerDelegate> chatControllerDelegate;
@property (nonatomic) NSArray *messageGroupIndexPaths;

@property (nonatomic, strong) UIImageView *incomingDefaultMessageBubble;
@property (nonatomic, strong) UIImageView *outgoingDefaultMessageBubble;

@property (nonatomic, strong) UIColor *incomingMessageBubbleColor;
@property (nonatomic, strong) UIColor *outgoingMessageBubbleColor;


- (instancetype)initWithChatController:(id) controller; //ChatViewController
- (UIImageView *) messageBubbleForIndexPath:(NSIndexPath *) indexPath;

@end
