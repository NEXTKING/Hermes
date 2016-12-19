//
//  DSPF_TransportUnit.h
//  Hermes
//
//  Created by Lutz  Thalmann on 15.02.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@protocol DSPF_TransportUnitDelegate;

@interface DSPF_TransportUnit : UIViewController <UITextFieldDelegate, DSPF_WarningDelegate> {
				 id					<DSPF_TransportUnitDelegate> delegate;
    IBOutlet UIView					*scanView;
	IBOutlet UIView					*textView;
	IBOutlet UITextField			*textInputTC;
	IBOutlet UILabel				*currentTC_F;
    IBOutlet UILabel				*textLabelTC_F;
	IBOutlet UILabel				*currentTC_B;
    IBOutlet UILabel				*textLabelTC_B;
    IBOutlet UIButton               *transportUnitButton;
			 Location				*currentTCDestination;
			 NSString				*scanInputTC;
			 BOOL					scanDeviceShouldReturnPalletBarcode;

@private
			 NSManagedObjectContext *ctx;
}
@property (assign)	id <DSPF_TransportUnitDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView					*scanView;
@property (nonatomic, retain) IBOutlet UIView					*textView;
@property (nonatomic, retain) IBOutlet UITextField				*textInputTC;
@property (nonatomic, retain) IBOutlet UILabel					*currentTC_F;
@property (nonatomic, retain) IBOutlet UILabel					*textLabelTC_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentTC_B;
@property (nonatomic, retain) IBOutlet UILabel					*textLabelTC_B;
@property (nonatomic, retain) IBOutlet UIButton                 *transportUnitButton;
@property (nonatomic, retain)		   NSString					*scanInputTC;
@property (nonatomic, retain)		   NSManagedObjectContext   *ctx;

- (IBAction)scanDown:(UIButton *)aButton;
- (IBAction)scanUp:(UIButton *)aButton;

@end

@protocol DSPF_TransportUnitDelegate

- (void) dspf_TransportUnit:(DSPF_TransportUnit *)sender didReturnTransportUnit:(NSString *)transportUnit withLocation:(Location *)location forTransportCode:(NSString *)transportCode;

@end