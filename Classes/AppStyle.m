//
//  AppStyle.m
//  Hermes
//
//  Created by Attila Teglas on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppStyle.h"

@implementation AppStyle

+ (void) customizePickerView:(UIPickerView *) pickerView {
    pickerView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.8f];
}

+ (void) customizeToolbar:(UIToolbar *) toolbar {
    toolbar.barStyle = UIBarStyleDefault;
    toolbar.backgroundColor = nil;
    toolbar.tintColor = nil;
    toolbar.translucent = NO;
//    [AppStyle customizePickerViewToolbar:toolbar];
}

+ (void) customizePickerViewToolbar:(UIToolbar *) toolbar {
    toolbar.alpha = 0.8f;
    NSString *keyPath = @"tintColor";
    if (iosVersion() >= 7.0f) {
        keyPath = @"barTintColor";
    }
    [toolbar setValue:[UIColor blackColor] forKeyPath:keyPath];
}

+ (void) customizePickerViewLabel:(UILabel *) label {
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    UIColor *color = [UIColor colorWithWhite:0.0f alpha:0.8f];
    if (iosVersion() >= 7.0f) {
        color = [UIColor whiteColor];
    }
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
}

+ (void) customizeViewController:(UIViewController *) viewController {
    
    viewController.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    viewController.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

+ (UIImage*) truckImageFull
{
    UIImage *truckImageFull = [UIImage imageNamed:FmtStr(@"%@_truckFull.png", [NSUserDefaults branding])];
    return truckImageFull;
}

+ (UIImage *) truckImage {
    
    UIImage *truckImage = [UIImage imageNamed:FmtStr(@"%@_truck.png", [NSUserDefaults branding])];
    
    if (truckImage == nil && ![AppStyle truckImageFull]) {
        truckImage = [UIImage imageNamed:@"truck.png"];
    }
    return truckImage;
}

+ (UIImage *) reflectedTruckImage {
    UIImage *truck = [AppStyle truckImage];
    UIImage *reflectedTruckImage = [truck rotate:UIImageOrientationDownMirrored];
    UIImage *reflectedUndScaledImage = [UIImage resizedImageWithOriginal:reflectedTruckImage maxHeigt:floorf(truck.size.height / 2.0f) maxWidth:truck.size.width keepRatio:NO];
    return reflectedUndScaledImage;
}

@end

@implementation UIColor (AppStyle)
+(UIColor *) placeholderColor
    {return [[UIColor alloc] initWithRed:23.0 / 255 green:48.0 / 255 blue:72.0 / 255 alpha: 1.0]; }
+(UIColor *) appStyleOrderColor                                     {
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        return [[UIColor alloc] initWithRed:220.0 / 255 green:254.0 / 255 blue:170.0 / 255 alpha: 1.00];
    }
    return [[UIColor alloc] initWithRed:250.0 / 255 green:250.0 / 255 blue:250.0 / 255 alpha:1.00];
}
+(UIColor *) appStyleOrderBadgeColor                                {
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        return [UIColor appStyleOrderColor];
    }
    return [[UIColor alloc] initWithRed:35.0 / 255 green:110.0 / 255 blue:216.0 / 255 alpha: 1.00];
}
+(UIColor *) appStyleOrderBadgeTextColor                                {
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        return [UIColor blackColor];
    }
    return [UIColor whiteColor];
}
+(UIColor *) appStyleOrderTemplateColor                             {
    return [[UIColor alloc] initWithRed:250.0 / 255 green:250.0 / 255 blue:250.0 / 255 alpha:1.00];
}
+(UIColor *) appStyleOrderTemplateBadgeColor                        {
    return [[UIColor alloc] initWithRed:35.0 / 255 green:110.0 / 255 blue:216.0 / 255 alpha: 1.00];
}

+(UIColor *) appStyleOrderTemplateBadgeTextColor                    {
    return [UIColor whiteColor];
}
+(UIColor *) faqQuestionTextColor
    {return [[UIColor alloc] initWithRed:111.0 / 255 green:157.0 / 255 blue:39.0 / 255 alpha: 0.9];}
+(UIColor *) faqQuestionTextViewTextColor
    {return [[UIColor alloc] initWithRed:111.0 / 255 green:157.0 / 255 blue:39.0 / 255 alpha: 0.9];}
+(UIColor *) faqAnswerTextColor
    {return [UIColor grayColor];}
+(UIColor *) dspfWarningFillColor
    {return [[UIColor alloc] initWithRed:250.0 / 255 green:239.0 / 255 blue:129.0 / 255 alpha: 1.0];}
+(UIColor *) dspfWarningBorderColor
    {return [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.8 alpha:0.8];}
+(UIColor *) dspfStatusReadyFillColor
    {return [[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0];}
+(UIColor *) dspfStatusReadyBorderColor
    {return [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.8 alpha:0.8];}
+(UIColor *) appMainFontColor
{
    if (PFBrandingSupported(BrandingTechnopark, nil))
        return [UIColor colorWithRed:96.0/255.0 green:155.0/255.0 blue:199.0/255.0 alpha:1.0];
    return [UIColor blackColor];
}
+(UIColor *) appMainTintColor
{
    return [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
}

@end

@implementation UIFont (AppStyle)
+(UIFont *) placeholderFont
    {return [UIFont fontWithName:@"Helvetica" size:14];}
+(UIFont *) errorFont
    {return [UIFont fontWithName:@"Helvetica-Bold" size:24];}
+(UIFont *) faqQuestionFont
    {return [UIFont fontWithName:@"Helvetica-Bold" size:16];}
+(UIFont *) faqQuestionTextViewFont
    {return [UIFont fontWithName:@"Helvetica-Bold" size:20];}
+(UIFont *) faqAnswerFont
    {return [UIFont fontWithName:@"HelveticaNeue" size:14];}
+(UIFont *) faqAnswerTextViewFont
    {return [UIFont fontWithName:@"HelveticaNeue" size:17];}
@end

@implementation UIImage (AppStyle)

+(UIImage *) viollierLogo {return [UIImage imageNamed:[NSString stringWithFormat:@"viollier_logo.png"]]; }

@end 