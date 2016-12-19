//
//  DSPF_LoadBox.h
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_ImagePicker.h"
#import "DSPF_Warning.h"
#import "Location.h"
#import "Departure.h"
#import "DSPF_Load.h"

extern NSString const * LoadBoxParameterShowingLoadingForbidden;
extern NSString const * LoadBoxParameterConfirmingNewBoxesForbidden;

@class DPHButtonsView;

@interface DSPF_LoadBox : UIViewController   <UITextFieldDelegate, 
                                                DSPF_WarningDelegate,
                                                DSPF_ImagePickerDelegate,
                                                DSPF_DestinationDelegate> {
    IBOutlet UIView					*scanView;
    IBOutlet UIView					*textView;
    IBOutlet UILabel                *palettenLabel;
    IBOutlet UILabel                *paketeLabel;
    IBOutlet UILabel                *boxLabel;
    IBOutlet UILabel                *currentLocationDepartureLabel_F;
                                                    
    IBOutlet UILabel				*currentLocationDepartureTime_F;
    IBOutlet UILabel                *currentLocationDepartureExtension_F;
    IBOutlet UILabel				*currentLocationStreetAddress_F;
    IBOutlet UILabel				*currentLocationZipCode_F;
    IBOutlet UILabel				*currentLocationCity_F;
    IBOutlet UILabel                *currentLocationDepartureLabel_B;
    IBOutlet UILabel				*currentLocationDepartureTime_B;
    IBOutlet UILabel                *currentLocationDepartureExtension_B;
    IBOutlet UILabel				*currentLocationStreetAddress_B;
    IBOutlet UILabel				*currentLocationZipCode_B;
    IBOutlet UILabel				*currentLocationCity_B;
    IBOutlet UILabel				*currentPackage;
    IBOutlet UILabel				*currentBag;
	IBOutlet UITextField			*textInputTC;	
			 Location				*currentTCDestination;
			 NSString				*scanInputTC;
             BOOL					 preventScanning;
    IBOutlet UIToolbar              *currentTCbar;
    IBOutlet UIBarButtonItem        *currentTCbarTitle;
    IBOutlet UIBarButtonItem        *currentTCbarSpace01;
    IBOutlet UIBarButtonItem        *currentTCbarCamera;
			 id                      item;
             NSString               *tourTask;
    IBOutlet DPHButtonsView          *buttons;
@private
			 NSManagedObjectContext *ctx;
             DSPF_ImagePicker		*dspf_ImagePicker;
             BOOL                    wasSkippedOnce;
             NSString               *previousBoxCode;
}

@property (nonatomic, retain) IBOutlet UIView					*scanView;
@property (nonatomic, retain) IBOutlet UIView					*textView;
@property (nonatomic, retain) IBOutlet UILabel					*palettenLabel;
@property (nonatomic, retain) IBOutlet UILabel					*paketeLabel;
@property (nonatomic, retain) IBOutlet UILabel					*boxLabel;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationDepartureLabel_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationDepartureTime_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationDepartureExtension_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationStreetAddress_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationZipCode_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationCity_F;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationDepartureLabel_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationDepartureTime_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationDepartureExtension_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationStreetAddress_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationZipCode_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationCity_B;
@property (nonatomic, retain) IBOutlet UILabel					*currentPackage;
@property (nonatomic, retain) IBOutlet UILabel					*currentBag;
@property (nonatomic, retain) IBOutlet UITextField				*textInputTC;
@property (nonatomic, retain)		   Location					*currentTCDestination;
@property (nonatomic, retain)		   NSString					*scanInputTC;
@property (nonatomic)                  BOOL                      preventScanning;
@property (nonatomic, retain) IBOutlet UIToolbar                *currentTCbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarTitle;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarSpace01;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarCamera;
@property (nonatomic, retain)          id                        item;
@property (nonatomic, retain)          NSString                 *tourTask;


@property (nonatomic, retain)		   NSManagedObjectContext   *ctx;
@property (nonatomic, retain)		   DSPF_ImagePicker			*dspf_ImagePicker;
@property (nonatomic)                  BOOL                      wasSkippedOnce;
@property (nonatomic, retain)          NSString                 *previousBoxCode;

- (IBAction)scanUp:(UIButton *)aButton;

- (instancetype)initWithParameters:(NSDictionary *) parameters;

@end
