//
//  DSPF_TransportUnitItem.h
//  Hermes
//
//  Created by Lutz  Thalmann on 15.02.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_TransportUnit.h"

@interface DSPF_TransportUnitItem : UIViewController <UITextFieldDelegate, DSPF_TransportUnitDelegate> {
    IBOutlet UIView					*scanView;
    IBOutlet UIView					*textView;
    IBOutlet UILabel                *geladenLabel;
    IBOutlet UILabel                *geladenLabel2;
    IBOutlet UIButton               *transportCodeButton;
	IBOutlet UILabel				*currentLocationStreetAddress_F;
	IBOutlet UILabel				*currentLocationZipCode_F;
	IBOutlet UILabel				*currentLocationCity_F;
	IBOutlet UITextField			*textInputTC;
	IBOutlet UILabel				*currentTC_F;
	IBOutlet UILabel				*currentTU_F;
	IBOutlet UILabel				*currentTC_B;
	IBOutlet UILabel				*currentTU_B;
			 NSString				*scanInputTC;
			 BOOL					scanDeviceShouldReturnPalletBarcode;
}

@property (nonatomic, retain) IBOutlet UIView					*scanView;
@property (nonatomic, retain) IBOutlet UIView					*textView;
@property (nonatomic, retain) IBOutlet UILabel					*geladenLabel;
@property (nonatomic, retain) IBOutlet UILabel					*geladenLabel2;
@property (nonatomic, retain) IBOutlet UIButton				    *transportCodeButton;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationStreetAddress_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationZipCode_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationCity_F;
@property (nonatomic, retain) IBOutlet UITextField				*textInputTC;
@property (nonatomic, retain) IBOutlet UILabel					*currentTC_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentTU_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentTC_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentTU_B;
@property (nonatomic, retain)		   NSString					*scanInputTC;

- (IBAction)scanDown:(UIButton *)aButton;
- (IBAction)scanUp:(UIButton *)aButton;

@end
