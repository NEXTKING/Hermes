//
//  AppStyle.h
//  Hermes
//
//  Created by Attila Teglas on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface AppStyle : NSObject

+ (void) customizePickerView:(UIPickerView *) pickerView;
+ (void) customizeToolbar:(UIToolbar *) toolbar;
+ (void) customizePickerViewToolbar:(UIToolbar *) toolbar;
+ (void) customizePickerViewLabel:(UILabel *) label;
+ (void) customizeViewController:(UIViewController *) viewController;

+ (UIImage *)   truckImage;
+ (UIImage *)   reflectedTruckImage;
+ (UIImage *)   truckImageFull;

@end

@interface UIColor (AppStyle)
+(UIColor *) placeholderColor;
+(UIColor *) appStyleOrderColor;
+(UIColor *) appStyleOrderBadgeColor;
+(UIColor *) appStyleOrderBadgeTextColor;
+(UIColor *) appStyleOrderTemplateColor;
+(UIColor *) appStyleOrderTemplateBadgeColor;
+(UIColor *) appStyleOrderTemplateBadgeTextColor;
+(UIColor *) faqQuestionTextColor;
+(UIColor *) faqQuestionTextViewTextColor;
+(UIColor *) faqAnswerTextColor;
+(UIColor *) dspfWarningFillColor;
+(UIColor *) dspfWarningBorderColor;
+(UIColor *) dspfStatusReadyFillColor;
+(UIColor *) dspfStatusReadyBorderColor;
+(UIColor *) appMainFontColor;
+(UIColor *) appMainTintColor;

@end

@interface UIFont (AppStyle)
+(UIFont *) placeholderFont;
+(UIFont *) errorFont;
+(UIFont *) faqQuestionFont;
+(UIFont *) faqQuestionTextViewFont;
+(UIFont *) faqAnswerFont;
+(UIFont *) faqAnswerTextViewFont;
@end

@interface UIImage (AppStyle)
+(UIImage *) viollierLogo;  
@end
