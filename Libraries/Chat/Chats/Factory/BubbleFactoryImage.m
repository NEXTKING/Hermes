//
//  BubbleFactoryImage.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "BubbleFactoryImage.h"
#import "MAUIImage+Ext.h"

@implementation BubbleFactoryImage

+ (BubbleFactoryImage*) sharedInstanse
{
    static dispatch_once_t onceToken;
    static BubbleFactoryImage* sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BubbleFactoryImage alloc] init];
    });
    return sharedInstance;
}

- (UIImageView *) outgoingMessageBubbleImageWithColor:(UIColor*) color
                                       bubbleTemplate:(UIImage*) template {
    
    return [self bubbleImageWithColor:color flippedForIncoming:NO bubbleTemplate:template];
    
}


- (UIImageView *) incomingMessageBubbleImageWithColor:(UIColor*) color
                                       bubbleTemplate:(UIImage*) template {
    
    return [self bubbleImageWithColor:color flippedForIncoming:YES bubbleTemplate:template];
    
}

- (UIImageView *) bubbleImageWithColor:(UIColor *) color
                    flippedForIncoming:(BOOL) flipped
                        bubbleTemplate:(UIImage*) template {
    
    
    UIImage *bubble = template;
    UIImage *normalBubble = [bubble imageWithColor:color];
    
    if (flipped == NO) {
        normalBubble = [self horizontallyFlippedImageFromImage:normalBubble];
    }
    
    CGPoint center = CGPointMake(bubble.size.width / 2.0, bubble.size.height / 2.0);
    UIEdgeInsets capInsets = UIEdgeInsetsMake(center.y, center.x, center.y, center.x);
    
    normalBubble = [self stretchableImageFromImage:normalBubble capInsets:capInsets];
    
    UIImageView * imageView = [[UIImageView alloc] initWithImage:normalBubble];
    imageView.backgroundColor = [UIColor clearColor];
    
    return imageView;
    
}

- (UIImage *) horizontallyFlippedImageFromImage:(UIImage *) image {
    
    return [[UIImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUpMirrored];
    
}

- (UIImage *) stretchableImageFromImage:(UIImage*) image capInsets:(UIEdgeInsets) capInsets {
    
    return  [image resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch];
    
}

@end
