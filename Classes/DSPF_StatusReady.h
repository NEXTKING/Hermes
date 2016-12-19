//
//  DSPF_StatusReady.h
//  Hermes
//
//  Created by Lutz  Thalmann on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_ColoredAlert.h"

@protocol DSPF_StatusReadyDelegate;

extern NSString const * StatusReadySwitchToLoadItem;
extern NSString const * StatusReadySwitchToTourLocationItem;
extern NSString const * StatusReadyConfirmUnloadAtFinalDestination;

@interface DSPF_StatusReady : NSObject <DSPF_ColoredAlertDelegate,
                                        UIAlertViewDelegate> {
	id <DSPF_StatusReadyDelegate> delegate;

@private
    id alertView;
	id item;
}

+ (DSPF_StatusReady *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate;
+ (DSPF_StatusReady *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitle:(NSString *) otherButtonTitle;

@property (nonatomic, assign) id <DSPF_StatusReadyDelegate> delegate;
@property (nonatomic, retain) id alertView;
@property (nonatomic, retain) id item;

@end

@protocol DSPF_StatusReadyDelegate

- (void) dspf_StatusReady:(DSPF_StatusReady *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) clickedButtonIndex;

@end