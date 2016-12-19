//
//  DSPF_ColoredAlert.h
//  Hermes
//
//  Created by Lutz  Thalmann on 29.08.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DSPF_ColoredAlert : UIAlertView {
    
@private
    id <UIAlertViewDelegate> delegate;
}

+ (DSPF_ColoredAlert *)coloredAlertWithTitle:(NSString *)title
                                     message:(NSString *)message
                             backgroundColor:(UIColor *)backgroundColor
                                 borderColor:(UIColor *)borderColor
                                    delegate:(id)delegate
                           cancelButtonTitle:(NSString *)cancelButtonTitle
                           otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@property (nonatomic, assign) id <UIAlertViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
    backgroundColor:(UIColor *)backgroundColor
        borderColor:(UIColor *)borderColor
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

@end

@protocol DSPF_ColoredAlertDelegate

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
