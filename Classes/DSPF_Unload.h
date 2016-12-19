//
//  DSPF_Unload.h
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_ImagePicker.h"
#import "DSPF_Warning.h"
#import "DSPF_Error.h"
#import "DSPF_StatusReady.h"

#import "Departure.h"

extern NSString * const UnloadParameterProcessChangeForbidden;        // if yes, then after successfuly executing unload action, user will stay by unloading

@interface DSPF_Unload : UITableViewController <UITextFieldDelegate, 
												DSPF_WarningDelegate, 
												DSPF_StatusReadyDelegate,
                                                DSPF_ImagePickerDelegate,
                                                UIAlertViewDelegate> {
    IBOutlet UIView					*scanView;
	IBOutlet UITableView			*tableView;
    IBOutlet UIView					*textView;
                                                    
    IBOutlet UILabel                *palettenLabel;
    IBOutlet UILabel                *rollcontainerLabel;
    IBOutlet UILabel                *paketeLabel;
    IBOutlet UIButton               *paletteButton;
    IBOutlet UIButton               *paketButton;
    IBOutlet UIButton               *transportCodeButton;
    IBOutlet UIButton               *transportGroupSummaryButton;
                                                    
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
	IBOutlet UITextField			*textInputTC;	
	IBOutlet UILabel				*currentTC;
			 NSString				*scanInputTC;
             BOOL					 preventScanning;
	IBOutlet UILabel				*currentPalletCount;
    IBOutlet UILabel				*currentRollcontainerCount;
    IBOutlet UILabel				*currentRollcontainer_tourTask;
	IBOutlet UILabel				*currentUnitCount;
    IBOutlet UILabel				*currentUnit_tourTask;
    IBOutlet UIToolbar              *currentTCbar;
    IBOutlet UIBarButtonItem        *currentTCbarTitle;
    IBOutlet UIBarButtonItem        *currentTCbarSpace01;
    IBOutlet UIBarButtonItem        *currentTCbarCamera;
    IBOutlet UIBarButtonItem        *currentTCbarSpace02;
    IBOutlet UIBarButtonItem        *currentTCbarPrice;
    IBOutlet UIView                 *currentTCPriceBadge;
			 id                      item;
             BOOL                    itemIsTransportGroup;
             Departure              *transportGroupTourStop;
             NSString               *tourTask;
@private
		     NSManagedObjectContext *ctx;
			 NSArray				*transportCodesAtWork;
			 DSPF_ImagePicker		*dspf_ImagePicker;
}

@property (nonatomic, retain) IBOutlet UIView					*scanView;
@property (nonatomic, retain) IBOutlet UITableView				*tableView;
@property (nonatomic, retain) IBOutlet UIView					*textView;
@property (nonatomic, retain) IBOutlet UILabel					*palettenLabel;
@property (nonatomic, retain) IBOutlet UILabel					*rollcontainerLabel;
@property (nonatomic, retain) IBOutlet UILabel					*paketeLabel;
@property (nonatomic, retain) IBOutlet UIButton					*paletteButton;
@property (nonatomic, retain) IBOutlet UIButton					*paketButton;
@property (nonatomic, retain) IBOutlet UIButton					*transportCodeButton;
@property (nonatomic, retain) IBOutlet UIButton                 *transportGroupSummaryButton;
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
@property (nonatomic, retain) IBOutlet UITextField				*textInputTC;
@property (nonatomic, retain) IBOutlet UILabel					*currentTC;
@property (nonatomic, retain)		   NSString					*scanInputTC;
@property (nonatomic)                  BOOL                      preventScanning;
@property (nonatomic, retain) IBOutlet UILabel					*currentPalletCount;
@property (nonatomic, retain) IBOutlet UILabel					*currentRollcontainerCount;
@property (nonatomic, retain) IBOutlet UILabel					*currentRollcontainer_tourTask;
@property (nonatomic, retain) IBOutlet UILabel					*currentUnitCount;
@property (nonatomic, retain) IBOutlet UILabel					*currentUnit_tourTask;
@property (nonatomic, retain) IBOutlet UIToolbar                *currentTCbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarTitle;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarSpace01;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarCamera;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarSpace02;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarPrice;
@property (nonatomic, retain) IBOutlet UIView                   *currentTCPriceBadge;
@property (nonatomic, retain)          id                        item;
@property (nonatomic, retain)          Departure                *transportGroupTourStop;
@property (nonatomic, retain)          NSString                 *tourTask;

@property (nonatomic, retain)		   NSManagedObjectContext   *ctx;
@property (nonatomic, retain)		   NSArray					*transportCodesAtWork;
@property (nonatomic, retain)		   DSPF_ImagePicker			*dspf_ImagePicker;

- (IBAction)scanDown:(UIButton *)aButton;
- (IBAction)scanUp:(UIButton *)aButton;
- (IBAction)showTransportGroupSummary;

- (instancetype)initWithParameters:(NSDictionary *) parameters;

@end
