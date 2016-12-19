//
//  DSPF_Suspend.h
//  Hermes
//
//  Created by Lutz  Thalmann on 29.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPF_Suspend : UIActionSheet <UIActionSheetDelegate> {

@private
	BOOL			  pause;
	NSInteger		  suspendingSeconds;
	NSTimer			 *suspendingLoop;
	UIViewController *caller;
}

+ (DSPF_Suspend *)suspendWithDefaultsOnViewController:(UIViewController *)aViewController;

@property (nonatomic,assign)	BOOL			  pause;
@property (nonatomic,assign)	NSInteger		  suspendingSeconds;
@property (nonatomic,assign)	NSTimer			 *suspendingLoop;
@property (nonatomic,retain)	UIViewController *caller;

- (id) showOptionButtons:(UIViewController *)aViewController;

@end