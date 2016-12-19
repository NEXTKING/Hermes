//
//  MAUIImage+Ext.m
//  ModelAlliance
//
//  Created by Kio on 11/25/15.
//  Copyright © 2015 Mac. All rights reserved.
//

#import "MAUIImage+Ext.h"

@implementation UIImage (Ext)

//func imageWithColor(color1: UIColor) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
//    
//    let context  = UIGraphicsGetCurrentContext()
//    CGContextTranslateCTM(context, 0, self.size.height)
//    CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextSetBlendMode(context, CGBlendMode.Normal)
//    
//    let rect     = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
//    CGContextClipToMask(context, rect, self.CGImage)
//    color1.setFill()
//    CGContextFillRect(context, rect)
//    
//    let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
//    UIGraphicsEndImageContext()
//    
//    return newImage
//}

- (UIImage *) imageWithColor:(UIColor *) color {
    
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;

}

@end
