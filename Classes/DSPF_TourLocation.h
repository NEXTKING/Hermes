//
//  DSPF_TourLocation.h
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "DSPF_SignatureForName.h"
#import "DSPF_ImagePicker.h"
#import "DSPF_Payment.h"
#import "DSPF_Warning.h"
#import "DSPF_Confirm.h"

#import "Departure.h"
#import "Transport_Group.h"
#import "Location.h"
#import "DSPF_Deadhead.h"

@protocol DSPF_TourLocationDelegate;

@interface DSPF_TourLocation : UIViewController <DSPF_WarningDelegate,
                                                 DSPF_ConfirmDelegate,
                                                 DSPF_SignatureForNameDelegate, 
                                                 DSPF_ImagePickerDelegate,
                                                 DSPF_PaymentDelegate,
                                                 DSPF_DeadheadDelegate> {
			 id                     <DSPF_TourLocationDelegate> delegate;
    IBOutlet UILabel                *departureLabel;
    IBOutlet UILabel                *palettenLabel;
    IBOutlet UILabel                *rollcontainerLabel;
    IBOutlet UILabel                *paketeLabel;                                                                                                            
	IBOutlet UILabel                *departureTime;
    IBOutlet UILabel                *departureExtension;
	IBOutlet UILabel                *streetAddress;
	IBOutlet UILabel                *zipCode;
	IBOutlet UILabel                *city;
    IBOutlet UILabel                *price;
	IBOutlet UILabel                *pallets;
    IBOutlet UILabel                *pallets_tourTask;
	IBOutlet UILabel                *rollcontainer;
    IBOutlet UILabel                *rollcontainer_tourTask;
    IBOutlet UILabel                *units;
    IBOutlet UILabel                *units_tourTask;
    IBOutlet UIButton               *transportGroupSummaryButton;
    IBOutlet UIButton               *button_UNLOAD;
	IBOutlet UIButton               *button_LOAD;
    IBOutlet UIButton               *button_PROOF;
    IBOutlet UIButton               *button_FINISH;
             NSString               *tourTask;
			 id                      item;
             BOOL                    itemIsTransportGroup;
             Departure              *transportGroupTourStop; 
@private
			 NSManagedObjectContext	*ctx;
             BOOL                    didItOnce;
             BOOL                    didShowCallCenterInfo;
             BOOL				     withReceiptRequirement;
             BOOL				     withImageAsReceipt;
             BOOL				     hasImageAsReceipt;
             BOOL				     withSignatureAsReceipt;
             BOOL				     hasSignatureAsReceipt;
             BOOL				     hasConfirmedIncompleteLOAD;
             BOOL				     hasConfirmedIncompleteUNLOAD;
             BOOL                    boxWithArticle;
			 DSPF_ImagePicker		*dspf_ImagePicker;
}

@property (assign)            id		   <DSPF_TourLocationDelegate> delegate;
@property (retain, nonatomic) IBOutlet     UILabel       *departureLabel;
@property (retain, nonatomic) IBOutlet     UILabel       *departureTime;
@property (retain, nonatomic) IBOutlet     UILabel       *palettenLabel;
@property (retain, nonatomic) IBOutlet     UILabel       *rollcontainerLabel;
@property (retain, nonatomic) IBOutlet     UILabel       *paketeLabel;
@property (retain, nonatomic) IBOutlet     UILabel       *departureExtension;
@property (retain, nonatomic) IBOutlet     UILabel       *streetAddress;
@property (retain, nonatomic) IBOutlet     UILabel       *zipCode;
@property (retain, nonatomic) IBOutlet     UILabel       *city;
@property (retain, nonatomic) IBOutlet     UILabel       *price;
@property (retain, nonatomic) IBOutlet     UILabel       *pallets;
@property (retain, nonatomic) IBOutlet     UILabel       *pallets_tourTask;
@property (retain, nonatomic) IBOutlet     UILabel       *rollcontainer;
@property (retain, nonatomic) IBOutlet     UILabel       *rollcontainer_tourTask;
@property (retain, nonatomic) IBOutlet     UILabel       *units;
@property (retain, nonatomic) IBOutlet     UILabel       *units_tourTask;
@property (retain, nonatomic) IBOutlet     UIButton      *transportGroupSummaryButton;
@property (retain, nonatomic) IBOutlet     UIButton      *button_UNLOAD;
@property (retain, nonatomic) IBOutlet     UIButton      *button_LOAD;
@property (retain, nonatomic) IBOutlet     UIButton      *button_PROOF;
@property (retain, nonatomic) IBOutlet     UIButton      *button_FINISH;
@property (retain, nonatomic)              NSString      *tourTask;
@property (retain, nonatomic)              id             item; //TransportGroup or Departure
@property (retain, nonatomic)              Departure     *transportGroupTourStop;

@property (nonatomic, retain)   NSManagedObjectContext   *ctx;
@property (nonatomic)			BOOL                      didItOnce;
@property (nonatomic)			BOOL                      didShowCallCenterInfo;
@property (nonatomic)			BOOL                      withReceiptRequirement;
@property (nonatomic)			BOOL                      withImageAsReceipt;
@property (nonatomic)			BOOL					  hasImageAsReceipt;
@property (nonatomic)			BOOL					  withSignatureAsReceipt;
@property (nonatomic)			BOOL					  hasSignatureAsReceipt;
@property (nonatomic)			BOOL					  hasConfirmedIncompleteLOAD;
@property (nonatomic)			BOOL					  hasConfirmedIncompleteUNLOAD;
@property (nonatomic)			BOOL					  boxWithArticle;
@property (nonatomic, retain)   DSPF_ImagePicker		 *dspf_ImagePicker;

//Technopark customisation

@property (retain, nonatomic) IBOutlet UITableView *technoparkTableView;

- (instancetype)initWithParameters:(NSDictionary *) parameters;

- (IBAction)getImageForProofOfDelivery:(NSDictionary *)parameters;
- (IBAction)getImageForProofOfDelivery;
- (IBAction)transportCodesShouldBeginUnloading;
- (IBAction)transportCodesShouldBeginLoading;
- (IBAction)getSignatureForProofOfDelivery;
- (IBAction)shouldLeaveTourLocation;
- (IBAction)showTransportGroupSummary;

@end

@protocol DSPF_TourLocationDelegate

- (void) dspf_TourLocation:(DSPF_TourLocation *)sender didFinishTourForItem:(id )item;

@end