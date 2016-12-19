//
//  TextMessageCell.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PasteboardLabel.h"
#import "ChatMessageData.h"

@protocol TextMessageCellDelegate <NSObject>

@required
- (void) openImageFromURL:(NSString *) imageURL;

@end

@interface TextMessageCell : UITableViewCell

@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UIView *separateView;
@property (nonatomic) PasteboardLabel *bodyLabel;
@property (nonatomic) UILabel *nameLabel;
@property (nonatomic,weak) ChatMessageData *bindedMessage;
@property (nonatomic) UIImageView *bubbleImage;
@property (nonatomic) UIImageView *avatarImage;
@property (nonatomic) UIImageView *imageInMessage;

@property (nonatomic, weak) id <TextMessageCellDelegate> delegate;

@end
