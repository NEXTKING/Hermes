//
//  DSPF_Warning.h
//  Hermes
//
//  Created by Lutz  Thalmann on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DSPF_ColoredAlert.h"

extern NSString const * WarningConfirmToUnloadItem;

@protocol DSPF_WarningDelegate;
@class Location;

@interface DSPF_Warning : NSObject <DSPF_ColoredAlertDelegate,
                                    UIAlertViewDelegate> {
	id <DSPF_WarningDelegate> delegate;

@private
    id alertView;
	id item;
    AVAudioPlayer *audioPlayer;
}

+ (DSPF_Warning *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate;
+ (DSPF_Warning *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate
             cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitle:(NSString *) otherButtonTitle;

@property (nonatomic, assign) id <DSPF_WarningDelegate> delegate;
@property (nonatomic, retain) id alertView;
@property (nonatomic, retain) id item;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@end


@interface DSPF_Warning(StandardMessages)

+ (DSPF_Warning *) messageForSwitchingToUnloadingForTransportCode:(NSString *) transport delegate:(id) delegate;
+ (DSPF_Warning *) messageForConfirmingUnloadingTransportCode:(NSString *) transport initiallyIntendedDestination:(Location *)destination delegate:(id) delegate;

@end

@protocol DSPF_WarningDelegate

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex;

@end