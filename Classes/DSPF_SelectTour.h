//
//  DSPF_SelectTour.h
//  Hermes
//
//  Created by Lutz  Thalmann on 23.10.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tour.h"

@interface DSPF_SelectTour : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIViewControllerJumpThrough> {
	
@private
    IBOutlet UILabel                *usrprf;
    IBOutlet UILabel                *truck;
    IBOutlet UILabel                *neueTour;
    IBOutlet UILabel                *benutzerLabel;
    IBOutlet UILabel                *fahrzeugLabel;
    NSArray							*tours;
    NSString                        *checkingWhetherItsDemoModeOrNot;
    NSString                        *task;
	IBOutlet UIPickerView			*pickerView;
    IBOutlet UIToolbar              *pickerViewToolbar;
	Tour                            *currentSelection;
}
@property (nonatomic, retain) IBOutlet UIToolbar                *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UILabel                  *usrprf;
@property (nonatomic, retain) IBOutlet UILabel                  *truck;
@property (nonatomic, retain) IBOutlet UILabel                  *neueTour;
@property (nonatomic, retain) IBOutlet UILabel                  *benutzerLabel;
@property (nonatomic, retain) IBOutlet UILabel                  *fahrzeugLabel;
@property (nonatomic, retain)		   NSArray					*tours;
@property (nonatomic, retain)		   NSString					*checkingWhetherItsDemoModeOrNot;
@property (nonatomic, retain)          NSString                 *task;
@property (nonatomic, retain) IBOutlet UIPickerView				*pickerView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem			*confirmTourButton;
@property (nonatomic, retain)		   Tour                     *currentSelection;

- (IBAction)didConfirmTour;

+ (BOOL) shouldBeDisplayed;

@end
