//
//  DSPF_Login.h
//  Hermes
//
//  Created by Lutz  Thalmann on 03.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Warning.h"
#import "User.h"

@interface DSPF_Login : UIViewController <UITextFieldDelegate, DSPF_WarningDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate> {

@private
    IBOutlet UIView				 *logonView;
	IBOutlet UIView              *infoView;
    IBOutlet UIView              *flagView;
    IBOutlet UILabel             *languageSupportLabel;
    IBOutlet UITextView			 *versionView;
    IBOutlet UITextView			 *copyrightView;
	IBOutlet UITextField	     *usrprf;
	IBOutlet UITextField		 *password;
    IBOutlet UIImageView         *brandingImageView;
    IBOutlet UIImageView         *truckImageView;
    IBOutlet UIImageView         *flippedTruckImageView;
    IBOutlet UIImageView         *truckInfoImageView;
    IBOutlet UIImageView         *flippedTruckInfoImageView;
                                              
    UILabel                      *useEitherGermanOrEnglishLabel;
}

@property (nonatomic, retain)    IBOutlet UIView		*logonView;
@property (nonatomic, retain)    IBOutlet UIView        *infoView;
@property (nonatomic, retain)    IBOutlet UIView        *flagView;
@property (nonatomic, retain)    IBOutlet UILabel       *languageSupportLabel;
@property (nonatomic, retain)    IBOutlet UITextView	*versionView;
@property (nonatomic, retain)    IBOutlet UITextView	*copyrightView;
@property (nonatomic, retain)    IBOutlet UITextField	*usrprf;
@property (nonatomic, retain)    IBOutlet UITextField	*password;
@property (nonatomic, retain)    IBOutlet UIImageView   *brandingImageView;
@property (nonatomic, retain)    IBOutlet UIImageView   *truckImageView;
@property (nonatomic, retain)    IBOutlet UIImageView   *flippedTruckImageView;
@property (nonatomic, retain)    IBOutlet UIImageView   *truckInfoImageView;
@property (nonatomic, retain)    IBOutlet UIImageView   *flippedTruckInfoImageView;
@property (nonatomic, retain)    IBOutlet UIImageView   *fullTruckImageView;
@property (retain, nonatomic)    IBOutlet UIView *passScanContainer;

@property (nonatomic, retain)             UILabel       *useEitherGermanOrEnglishLabel;
@property (retain, nonatomic) IBOutlet UIButton *scanButtonDefault;

@end
