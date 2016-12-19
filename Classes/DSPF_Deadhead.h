//
//  DSPF_Deadhead.h
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Trace_Type.h"
#import "Departure.h"

extern NSString * const DeadHeadParameterCurrentDeparture;

@protocol DSPF_DeadheadDelegate <NSObject>
@optional
- (void) deadheadDidConfirm;
- (void) deadheadDidDismiss;
@end

@interface DSPF_Deadhead : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
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
	IBOutlet UIPickerView			*pickerView;
	Trace_Type						*currentSelection;
    Departure                       *currentDeparture;
    BOOL                             pickerViewDetailMode;
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
@property (nonatomic, retain) IBOutlet UIPickerView				*pickerView;
@property (nonatomic, retain)		   Trace_Type				*currentSelection;
@property (nonatomic, retain)		   Departure				*currentDeparture;
@property (nonatomic, retain)          NSArray                  *currentDepartures;
@property (nonatomic)                  BOOL                      pickerViewDetailMode;

- (IBAction)didConfirmDeadhead;

- (instancetype)initWithParameters:(NSDictionary *) parameters;

@end
