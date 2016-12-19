//
//  BubbleFactoryImage.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BubbleFactoryImage : NSObject

+ (BubbleFactoryImage*) sharedInstanse;

- (UIImageView *) outgoingMessageBubbleImageWithColor:(UIColor*) color
                                       bubbleTemplate:(UIImage*) template;

- (UIImageView *) incomingMessageBubbleImageWithColor:(UIColor*) color
                                       bubbleTemplate:(UIImage*) template;

- (UIImageView *) bubbleImageWithColor:(UIColor *) color
                    flippedForIncoming:(BOOL) flipped
                        bubbleTemplate:(UIImage*) template;

- (UIImage *) horizontallyFlippedImageFromImage:(UIImage *) image;

- (UIImage *) stretchableImageFromImage:(UIImage*) image capInsets:(UIEdgeInsets) capInsets;

@end
