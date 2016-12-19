//
//  ChatViewController.h
//  ChatModule
//
//  Created by Виктория on 06.04.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLKTextViewController.h"
#import "ChatMessageData.h"
#import "ChatData.h"
#import "BubbleFactoryController.h"
#import "HTTPClient.h"

#define number(v) (([v isKindOfClass:[NSNumber class]]) ? v : ([v isKindOfClass:[NSString class]]) ? @([v floatValue]) : @(0))
#define string(v) ((v == nil) ? @"" : ([v isKindOfClass:[NSNull class]]) ? @"" : ([v isKindOfClass:[NSString class]]) ? v : ([v isKindOfClass:[NSNumber class]]) ? [NSString stringWithFormat:@"%@", v] : @"")

// Scalar values

#define boolean(v) ((v == nil) ? NO : [v boolValue])
#define integer(v) ( ((v == nil) || [v isKindOfClass:[NSNull class]] )? 0 : [v integerValue])
#define _double(v) ((v == nil) ? 0 : [v doubleValue])

@interface ChatViewController : SLKTextViewController <BubbleFactoryControllerDelegate> {
    UISegmentedControl *_segmentedControl;
    NSMutableArray *_selections;
}


@property (nonatomic, strong) ChatData *chatData;
@property (nonatomic, strong) BubbleFactoryController *messageBubbleController;
@property (nonatomic, strong) NSString *typeOfChat;

- (ChatMessageData *) messageAtIndexPath:(NSIndexPath *) indexPath;

@end
