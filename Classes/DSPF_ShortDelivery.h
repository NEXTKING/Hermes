//
//  DSPF_ShortDelivery.h
//  Hermes
//
//  Created by Lutz  Thalmann on 21.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_ImagePicker.h"
#import "DSPF_TourLocation.h"

#import "Trace_Type.h"
#import "Departure.h"
#import "Transport_Group.h"
#import "DSPF_Deadhead.h"

@interface DSPF_ShortDelivery : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    IBOutlet UIToolbar              *pickerViewToolbar;
    IBOutlet UILabel                *departureLabel;
	IBOutlet UILabel                *departureTime;
    IBOutlet UILabel                *departureExtension;
	IBOutlet UILabel				*currentLocationStreetAddress;
	IBOutlet UILabel				*currentLocationZipCode;
	IBOutlet UILabel				*currentLocationCity;
	
@private
	NSManagedObjectContext			*ctx;
    NSArray							*traceTypes;
    NSString						*traceTypeDescription;
	IBOutlet UIPickerView			*pickerView;
	Trace_Type						*currentSelection;
    Departure                       *currentDeparture;
    Transport_Group                 *currentTransportGroup;
    BOOL                             pickerViewDetailMode;
    BOOL                             isShortPickup;
}

@property (nonatomic, assign) id<DSPF_DeadheadDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIToolbar                *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UILabel                  *departureLabel;
@property (nonatomic, retain) IBOutlet UILabel                  *departureTime;
@property (nonatomic, retain) IBOutlet UILabel                  *departureExtension;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationStreetAddress;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationZipCode;
@property (nonatomic, retain) IBOutlet UILabel					*currentLocationCity;

@property (nonatomic, retain)		   NSManagedObjectContext	*ctx;
@property (nonatomic, retain)		   NSArray					*traceTypes;
@property (nonatomic, retain)		   NSString					*traceTypeDescription;
@property (nonatomic, retain) IBOutlet UIPickerView				*pickerView;
@property (nonatomic, retain)		   Trace_Type				*currentSelection;
@property (nonatomic, retain)		   Departure				*currentDeparture;
@property (nonatomic, retain)		   Transport_Group          *currentTransportGroup;
@property (nonatomic)                  BOOL                      pickerViewDetailMode;
@property (nonatomic)                  BOOL                      isShortPickup;

- (IBAction)didConfirmShortDelivery;

@end
