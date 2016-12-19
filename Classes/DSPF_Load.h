//
//  DSPF_Load.h
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_ImagePicker.h"
#import "DSPF_Warning.h"
#import "DSPF_StatusReady.h"
#import "DSPF_Destination.h"

#import "Departure.h"
#import "Transport_Box.h"

@class DPHButtonsView;

extern NSString * const LoadParameterTransportBox;


@protocol LoadDelegate;

@interface DSPF_Load : UITableViewController   <UITextFieldDelegate,
                                                DSPF_WarningDelegate,
                                                DSPF_StatusReadyDelegate,
                                                DSPF_DestinationDelegate,
                                                DSPF_ImagePickerDelegate> {
    IBOutlet UIView					*scanView;
	IBOutlet UITableView			*tableView;
    IBOutlet UIView					*textView;
    
    IBOutlet UILabel                *palettenLabel;
    IBOutlet UILabel                *rollcontainerLabel;
    IBOutlet UILabel                *paketeLabel;
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
             BOOL					scanDeviceShouldReturnPalletBarcode;
	IBOutlet UILabel				*currentPalletCount;
    IBOutlet UILabel				*currentRollcontainerCount;
    IBOutlet UILabel				*currentRollcontainer_tourTask;
	IBOutlet UILabel				*currentUnitCount;
    IBOutlet UILabel				*currentUnit_tourTask;
    IBOutlet UIToolbar              *currentTCbar;
    IBOutlet UIBarButtonItem        *currentTCbarTitle;
    IBOutlet UIBarButtonItem        *currentTCbarSpace01;
    IBOutlet UIBarButtonItem        *currentTCbarCamera;
             BOOL                    itemIsTransportGroup;
    IBOutlet DPHButtonsView          *buttons;
@private
             NSArray                 *transportCodesAtWork;
             DSPF_ImagePicker        *dspf_ImagePicker;
}
@property (nonatomic, assign) id<LoadDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView					*scanView;
@property (nonatomic, retain) IBOutlet UITableView				*tableView;
@property (nonatomic, retain) IBOutlet UIView					*textView;
@property (nonatomic, retain) IBOutlet UILabel					*palettenLabel;
@property (nonatomic, retain) IBOutlet UILabel					*rollcontainerLabel;
@property (nonatomic, retain) IBOutlet UILabel					*paketeLabel;
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
@property (nonatomic, retain)		   Location					*currentTCDestination;
@property (nonatomic, retain)		   NSString					*scanInputTC;
@property (nonatomic, retain) IBOutlet UILabel					*currentPalletCount;
@property (nonatomic, retain) IBOutlet UILabel					*currentRollcontainerCount;
@property (nonatomic, retain) IBOutlet UILabel					*currentRollcontainer_tourTask;
@property (nonatomic, retain) IBOutlet UILabel					*currentUnitCount;
@property (nonatomic, retain) IBOutlet UILabel					*currentUnit_tourTask;
@property (nonatomic, retain) IBOutlet UIToolbar                *currentTCbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarTitle;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarSpace01;
@property (nonatomic, retain) IBOutlet UIBarButtonItem          *currentTCbarCamera;
@property (nonatomic, retain)		   NSArray					*transportCodesAtWork;
@property (nonatomic, retain)		   DSPF_ImagePicker			*dspf_ImagePicker;
@property (nonatomic, assign)          BOOL                     cancellationMode;

@property (nonatomic, retain, readonly)          id                        item;            // remove me from header please!
@property (nonatomic, retain, readonly)          NSString                 *tourTask;        // remove me from header please!

- (IBAction)scanDown:(UIButton *)aButton;
- (IBAction)scanUp:(UIButton *)aButton;
- (IBAction)showTransportGroupSummary;
- (void)storeTransportItemData;

- (void) processBarcode:(NSString *) barcode validate:(BOOL) validationEnabled;

- (instancetype)initWithParameters:(NSDictionary *) parameters;

+ (Location *) destinationLocationForTransportBarcode:(NSString *)transportCode userInfo:(NSDictionary *) userInfo error:(NSError **) error;
+ (NSPredicate *)tourToLocationPredicateForTransportBarcode:(NSString *)barcode tourLocation:(Location *)tourLocation userInfo:(NSDictionary *) userInfo;

@end


@protocol LoadDelegate <NSObject>
@required
- (void) loadController:(DSPF_Load *) loadController didLoadTransportsWithCodes:(NSArray *) transportCodes;
@end
