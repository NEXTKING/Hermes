//
//  DSPF_SelectStore.h
//  Hermes
//
//  Created by Lutz  Thalmann on 05.01.12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"

@interface DSPF_SelectStore : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	
@private
    IBOutlet UILabel                *currently;
    IBOutlet UILabel                *storeIDLabel;
    IBOutlet UILabel                *storeNameLabel;
    IBOutlet UILabel                *storeLocaleCodeLabel;
	NSManagedObjectContext			*ctx;
    NSArray							*stores;
	IBOutlet UIPickerView			*pickerView;
	IBOutlet UIToolbar              *pickerViewToolbar;
	Store						    *currentSelection;
}
@property (nonatomic, retain) IBOutlet UIToolbar                *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UILabel                  *currently;
@property (nonatomic, retain) IBOutlet UILabel                  *storeIDLabel;
@property (nonatomic, retain) IBOutlet UILabel                  *storeNameLabel;
@property (nonatomic, retain) IBOutlet UILabel                  *storeLocaleCodeLabel;
@property (nonatomic, retain)		   NSManagedObjectContext	*ctx;
@property (nonatomic, retain)		   NSArray					*stores;
@property (nonatomic, retain) IBOutlet UIPickerView				*pickerView;
@property (nonatomic, retain)		   Store                    *currentSelection;

- (IBAction)didConfirmStore;

@end
