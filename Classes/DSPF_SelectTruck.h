//
//  DSPF_SelectTruck.h
//  Hermes
//
//  Created by Lutz  Thalmann on 23.10.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Truck.h"

@interface DSPF_SelectTruck : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIViewControllerJumpThrough> {
	
@private
    IBOutlet UILabel                *usrprf;
    IBOutlet UILabel                *neueTourLabel;
    IBOutlet UILabel                *benutzerLabel;
    IBOutlet UIButton               *truckButton;
	IBOutlet UIPickerView			*pickerView;
    IBOutlet UIToolbar              *pickerViewToolbar;
}

@property (nonatomic, retain) IBOutlet UILabel                  *usrprf;
@property (nonatomic, retain) IBOutlet UILabel                  *neueTourLabel;
@property (nonatomic, retain) IBOutlet UILabel                  *benutzerLabel;
@property (nonatomic, retain) IBOutlet UIButton                 *truckButton;
@property (nonatomic, retain) IBOutlet UIPickerView				*pickerView;
@property (nonatomic, retain) IBOutlet UIToolbar                *pickerViewToolbar;

- (IBAction)scanDown:(UIButton *)aButton;
- (IBAction)scanUp:(UIButton *)aButton;
- (IBAction)didConfirmTruck;

+ (NSPredicate *) predicateForShownTrucks;
- (void) didChooseTruck:(Truck *) truck;

+ (BOOL) shouldBeDisplayed;

@end
