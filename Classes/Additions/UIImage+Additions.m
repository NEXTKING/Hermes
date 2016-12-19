//
//  UIImage.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 24.09.15.
//
//

#import "UIImage+Additions.h"


static CGRect swapWidthAndHeight(CGRect rect) {
    CGFloat  swap = rect.size.width;
    
    rect.size.width  = rect.size.height;
    rect.size.height = swap;
    return rect;
}

@implementation UIImage (Additions)

+ (UIImage *)resizedImageWithOriginal:(UIImage *)original maxHeigt:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth keepRatio:(BOOL) keepRatio {
    if (original == nil) return nil;
    
    CGSize originalSize = original.size;
    CGSize newSize;
    BOOL wasChanged = NO;
    UIImage *resizedImage;
    
    // Scale the image if necessary
    if (originalSize.height > maxHeight) {
        newSize.height = maxHeight;
        CGFloat newWidth = originalSize.width;
        if (keepRatio) {
            newWidth = floorf((maxHeight / originalSize.height) * originalSize.width);
        }
        newSize.width = newWidth;
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
        [original drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        wasChanged = YES;
        originalSize = newSize;
    }
    
    if (originalSize.width > maxWidth) {
        newSize.width = maxWidth;
        CGFloat newHeight = originalSize.height;
        if (keepRatio) {
            newHeight = floorf((maxWidth / originalSize.width) * originalSize.height);
        }
        newSize.height = newHeight;
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0f);
        [original drawInRect:CGRectMake(0.0f, 0.0f, newSize.width, newSize.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        wasChanged = YES;
    }
    
    if(wasChanged){
        return resizedImage;
    } else {
        return original;
    }
}

- (UIImage *) rotate:(UIImageOrientation)orient {
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGImageRef         imag = self.CGImage;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    rect.size.width  = CGImageGetWidth(imag);
    rect.size.height = CGImageGetHeight(imag);
    
    bnds = rect;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            // would get you an exact copy of the original
            assert(false);
            return nil;
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, M_PI);
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRight:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored:
            bnds = swapWidthAndHeight(bnds);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, M_PI / 2.0);
            break;
            
        default:
            // orientation value supplied is invalid
            assert(false);
            return nil;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient){
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}


@end
