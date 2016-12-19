//
//  DSPF_Confirm.h
//  Hermes
//
//  Created by Lutz  Thalmann on 16.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSPF_ConfirmDelegate;

@interface DSPF_Confirm : UIViewController <UIActionSheetDelegate> {
	id			<DSPF_ConfirmDelegate> delegate;
	
@private
    NSObject        *item;
    UIActionSheet   *actionSheet;
}

+ (DSPF_Confirm *)question:(NSString *)question item:(NSObject *)item
            buttonTitleYES:(NSString *)buttonTitleYES
             buttonTitleNO:(NSString *)buttonTitleNO
                showInView:(UIView *)aView;
+ (DSPF_Confirm *)question:(NSString *)question item:(NSObject *)item
             buttonTitleOK:(NSString *)buttonTitleOK
            buttonTitleYES:(NSString *)buttonTitleYES
             buttonTitleNO:(NSString *)buttonTitleNO
                showInView:(UIView *)aView;

@property (assign)	id <DSPF_ConfirmDelegate> delegate;

@property (retain)	UIActionSheet   *actionSheet;
@property (retain)	NSObject        *item;

- (id) initWithQuestion:(NSString *)question item:(NSObject *)item
         buttonTitleYES:(NSString *)buttonTitleYES
          buttonTitleNO:(NSString *)buttonTitleNO
             showInView:(UIView *)aView;
- (id) initWithQuestion:(NSString *)aQuestion item:(NSObject *)item
          buttonTitleOK:(NSString *)aButtonTitleOK
         buttonTitleYES:(NSString *)aButtonTitleYES
          buttonTitleNO:(NSString *)aButtonTitleNO
             showInView:(UIView *)aView;

@end

@protocol DSPF_ConfirmDelegate

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)item withButtonTitle:(NSString *)buttonTitle;

@end