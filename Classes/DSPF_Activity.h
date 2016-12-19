//
//  DSPF_Activity.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSPF_ActivityDelegate;

@interface DSPF_Activity : NSObject <UIAlertViewDelegate> {
	id			<DSPF_ActivityDelegate> cancelDelegate;
@private
    UIAlertView *alertView;
    UIAlertView *alertViewBackup;
    int          cancelButtonIndex;
}

+ (DSPF_Activity *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate;
+ (DSPF_Activity *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(id)delegate;

@property (assign)	id <DSPF_ActivityDelegate> cancelDelegate;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) UIAlertView *alertViewBackup;
@property (nonatomic)         int          cancelButtonIndex;

- (void) closeActivityInfo;

@end

@protocol DSPF_ActivityDelegate

- (void) dspf_Activity:(DSPF_Activity *)sender didCancelActivity:(NSString *)messageTitle;

@end
