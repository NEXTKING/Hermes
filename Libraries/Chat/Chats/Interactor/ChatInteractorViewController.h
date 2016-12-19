//
//  ChatInteractorViewController.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderChatController.h"
#import "CommonChatController.h"

@interface ChatInteractorViewController : NSObject

- (id)initWithOrderId:(NSInteger)orderId;
- (id)initCommon;

- (OrderChatController *)orderChat;
- (CommonChatController *)commonChat;

@end
