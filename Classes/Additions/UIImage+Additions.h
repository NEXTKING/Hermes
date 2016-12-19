//
//  UIImage.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 24.09.15.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (UIImage *)resizedImageWithOriginal:(UIImage *)original maxHeigt:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth keepRatio:(BOOL) keepRatio;
- (UIImage *)rotate:(UIImageOrientation)orient;

@end
