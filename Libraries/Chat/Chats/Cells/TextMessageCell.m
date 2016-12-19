//
//  TextMessageCell.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "TextMessageCell.h"
#import "UIView+Coordinate.h"
#import "UIImageView+WebCache.h"
#import "HTTPClient.h"
#import "User.h"


@implementation TextMessageCell

NSString *const stringPadding = @"             "; //13 space

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return nil;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    self.bubbleImage = [[UIImageView alloc] init];
    self.bubbleImage.backgroundColor = [UIColor clearColor];
    self.bubbleImage.userInteractionEnabled = YES;
    
    self.bodyLabel = [[PasteboardLabel alloc] init];
    self.bodyLabel.userInteractionEnabled = YES;
    self.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    self.bodyLabel.numberOfLines = 0;
    self.bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizer:)];
    [self.bodyLabel addGestureRecognizer:gestureRecognizer];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:11];

    [self.contentView addSubview:self.bubbleImage];
    [self.bubbleImage addSubview:self.bodyLabel];
    [self.bubbleImage addSubview:self.timeLabel];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self initNameAndSeparate];
    
    self.layer.speed = 1.5;
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    BOOL messsageIsOut;
    
    User* user = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    NSInteger userID = [user.username intValue];
    if (self.bindedMessage.user_data.id == userID) { //current_user_id
        
        messsageIsOut = YES;
        
    } else {
        
        messsageIsOut = NO;
    }
    
    ////
    
    CGRect textRect = [self getRectOfBody];
    
    ////
    CGRect nameRect = !messsageIsOut ? [self getRectOfName] : CGRectZero;
    
    ////
    NSArray *suitValue;
    if (([self.bindedMessage.local_photo CGImage] != nil) || (self.bindedMessage.photo_url.length > 0)) {
            suitValue = @[@120, @(nameRect.size.width), @(textRect.size.width)];

    } else {
        suitValue= @[@(nameRect.size.width), @(textRect.size.width)];
        
    }
    float maximumValue = [[suitValue valueForKeyPath: @"@max.self"] floatValue];
    
    ////
    CGFloat mainRect = maximumValue < 235 ? maximumValue : 235;
    

    if (messsageIsOut == NO) {
        NSLog(@"Content view height ===== %f",self.contentView.height);
        self.bubbleImage.frame = CGRectMake(12, 5, ceil(mainRect)+24, self.contentView.height-15);
        
        self.nameLabel.textColor = self.nameLabel.textColor = [UIColor colorWithRed:46.0/255.0 green:162.0/255.0 blue:253.0/255.0 alpha:1.0];
        
        self.separateView.backgroundColor = self.timeLabel.textColor = [UIColor colorWithRed:201.0/255.0 green:201.0/255.0 blue:205.0/255.0 alpha:1.0];
        self.bodyLabel.textColor = [UIColor blackColor];
        
        self.timeLabel.frame = CGRectMake(self.bubbleImage.width - 50, self.bubbleImage.height - 25, 32, 15);
        self.nameLabel.frame = CGRectMake(18, 5, mainRect, 20);
        self.separateView.frame = CGRectMake(18, self.nameLabel.bottom, nameRect.size.width, 0.5);
        self.bodyLabel.frame = CGRectMake(18, 25, ceil(mainRect), self.bubbleImage.height-45);
        
        if ([self.bindedMessage.local_photo CGImage] != nil) {
            
            UIImageView *imageInMessage = [[UIImageView alloc] init];
            imageInMessage.contentMode = UIViewContentModeScaleAspectFit;
            imageInMessage.tag = 111;
            imageInMessage.userInteractionEnabled = YES;
            [self.bubbleImage addSubview:imageInMessage];
            
            imageInMessage.frame = CGRectMake(self.bubbleImage.width - 110, 30, 100, 100);
            imageInMessage.image = self.bindedMessage.local_photo;
            
            //------------------------------------------------------------------------
            
            UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRemoteImage)];
            [imageInMessage addGestureRecognizer:tapOnImage];
            
            //------------------------------------------------------------------------
            
            self.bodyLabel.frame = CGRectMake(26, imageInMessage.bottom + 5, ceil(mainRect) - 5, self.bubbleImage.height - imageInMessage.bottom - 15);
            
            
            
        } else if (self.bindedMessage.photo_url.length > 0) {
            
            UIImageView *imageInMessage = [[UIImageView alloc] init];
            imageInMessage.contentMode = UIViewContentModeScaleAspectFit;
            imageInMessage.tag = 111;
            imageInMessage.userInteractionEnabled = YES;
            [self.bubbleImage addSubview:imageInMessage];
            
            imageInMessage.frame = CGRectMake(self.bubbleImage.width - 110, 30, 100, 100);
            [imageInMessage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, self.bindedMessage.photo_url]]];
            
            //------------------------------------------------------------------------
            
            UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRemoteImage)];
            [imageInMessage addGestureRecognizer:tapOnImage];
            
            //------------------------------------------------------------------------
            
            self.bodyLabel.frame = CGRectMake(18, imageInMessage.bottom+5, ceil(mainRect)-15, self.bubbleImage.height-5-imageInMessage.bottom);
        }
        
    } else {
        
        self.bubbleImage.frame = CGRectMake(self.contentView.width-ceil(mainRect)-35, 5, ceil(mainRect)+23, self.contentView.height-25);
        
        self.bodyLabel.textColor = self.timeLabel.textColor = [UIColor whiteColor];
        
        self.timeLabel.frame = CGRectMake(self.bubbleImage.width - 50, self.bubbleImage.height - 25, 32, 15);
        self.nameLabel.frame = CGRectZero;
        self.bodyLabel.frame = CGRectMake(10, 0, ceil(mainRect)-10, self.bubbleImage.height-10);
        
        if ([self.bindedMessage.local_photo CGImage] != nil) {
            
            UIImageView *imageInMessage = [[UIImageView alloc] init];
            imageInMessage.contentMode = UIViewContentModeScaleAspectFit;
            imageInMessage.tag = 111;
            imageInMessage.userInteractionEnabled = YES;
            [self.bubbleImage addSubview:imageInMessage];
            
            imageInMessage.frame = CGRectMake(10, 20, 100, 100);
            imageInMessage.image = self.bindedMessage.local_photo;
            
            //------------------------------------------------------------------------
            
            UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRemoteImage)];
            [imageInMessage addGestureRecognizer:tapOnImage];
            
            //------------------------------------------------------------------------
            
            self.bodyLabel.frame = CGRectMake(18, imageInMessage.bottom - 5, ceil(mainRect)-15, self.bubbleImage.height-5-imageInMessage.bottom);
            
        } else if (self.bindedMessage.photo_url.length > 0) {
            
            UIImageView *imageInMessage = [[UIImageView alloc] init];
            imageInMessage.contentMode = UIViewContentModeScaleAspectFit;
            imageInMessage.tag = 111;
            imageInMessage.userInteractionEnabled = YES;
            [self.bubbleImage addSubview:imageInMessage];
            
            imageInMessage.frame = CGRectMake(10, 20, 100, 100);
            [imageInMessage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, self.bindedMessage.photo_url]]];
            imageInMessage.clipsToBounds = YES;
            
            //------------------------------------------------------------------------
            
            UITapGestureRecognizer *tapOnImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openRemoteImage)];
            [imageInMessage addGestureRecognizer:tapOnImage];
            
            //------------------------------------------------------------------------
            
            self.bodyLabel.frame = CGRectMake(18, imageInMessage.bottom - 5, ceil(mainRect)-5, self.bubbleImage.height-5-imageInMessage.bottom);
            
        }
        
    }
    
}

- (void) openRemoteImage {
    
    [self.delegate openImageFromURL:self.bindedMessage.photo_url];
    
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    self.bodyLabel.text = nil;
    self.bubbleImage.image = nil;
    self.bubbleImage.highlightedImage = nil;
    
    for (id view in self.bubbleImage.subviews) {
        
        if ([view isKindOfClass:[UIImageView class]]) {
            
            UIImageView* imageId = (UIImageView*)view;
            if (imageId.tag == 111) {
                [view removeFromSuperview];
            }
            
        }
    }
    
}

#pragma mark - Gestures
- (void)longPressGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    
    UIMenuItem *removeItem = [self.bodyLabel menuItemRemove];
    UIMenuItem *copyItem = [self.bodyLabel menuItemCopy];
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    menuController.menuItems = @[ removeItem, copyItem ];
    
    [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
    [menuController setMenuVisible:YES animated:YES];
    [recognizer.view becomeFirstResponder];
}

- (void)initNameAndSeparate {
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    
    self.separateView = [[UIView alloc] init];
    
    [self.bubbleImage addSubview:self.nameLabel];
    [self.bubbleImage addSubview:self.separateView];
}

- (CGRect)getRectOfBody {
    
    CGSize size = CGSizeMake(235-2, CGFLOAT_MAX);
    
    NSString *bodyString = self.bindedMessage.text.length > 0 ? [NSString stringWithFormat:@"%@ %@", self.bindedMessage.text, stringPadding] : @"";
    
    NSAttributedString *atrBodyString = [[NSAttributedString alloc] initWithString:bodyString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15]}];
    
    CGRect textRect = [atrBodyString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return textRect;
}

- (CGRect)getRectOfName {
    
    CGSize size = CGSizeMake(235-2, CGFLOAT_MAX);
    
    NSString *nameString = [NSString stringWithFormat:@"%@   ", self.bindedMessage.user_data.name];
    NSAttributedString *atrNameString = [[NSAttributedString alloc] initWithString:nameString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:14]}];
    
    CGRect nameRect = [atrNameString boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return nameRect;
}
@end
