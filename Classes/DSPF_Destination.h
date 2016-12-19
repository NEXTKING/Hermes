//
//  DSPF_Destination.h
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@protocol DSPF_DestinationDelegate;

@interface DSPF_Destination : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
			 id					<DSPF_DestinationDelegate> delegate;
	IBOutlet UILabel			*currentTC;
    IBOutlet UIBarButtonItem    *doneButton;
	
@private
    NSArray						*destinationGroup1;
    NSArray						*destinationGroup2;
	IBOutlet UISegmentedControl *segmentedControl;
    IBOutlet UILabel            *transportCodelabel;

    IBOutlet 
	IBOutlet UIPickerView		*pickerView;
    IBOutlet UIToolbar          *pickerViewToolbar;
	Location					*currentSelection;
}

@property (assign)	id <DSPF_DestinationDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIToolbar              *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UILabel				  *currentTC;
@property (nonatomic, retain) IBOutlet UIBarButtonItem        *doneButton;
@property (nonatomic, retain)          NSArray				  *destinationGroup1;
@property (nonatomic, retain)          NSArray				  *destinationGroup2;
@property (nonatomic, retain) IBOutlet UISegmentedControl	  *segmentedControl;
@property (nonatomic, retain) IBOutlet UILabel				  *transportCodeLabel;
@property (nonatomic, retain) IBOutlet UIPickerView			  *pickerView;
@property (retain)					   Location				  *currentSelection;

- (IBAction)changePickerView;
- (IBAction)destinationShouldReturn;

@end

@protocol DSPF_DestinationDelegate

- (void) dspf_Destination:(DSPF_Destination *)sender didSelectLocation:(Location *)location userInfo:(NSDictionary *) userInfo;

@end
