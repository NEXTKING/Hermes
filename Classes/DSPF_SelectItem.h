//
//  DSPF_SelectItem.h
//  Hermes
//
//  Created by Lutz  Thalmann on 05.01.12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Confirm.h"
#import "ItemCode.h"

@protocol DSPF_SelectItemDelegate;

@interface DSPF_SelectItem : UIViewController <UIPickerViewDelegate,
                                               UIPickerViewDataSource,
                                               DSPF_ConfirmDelegate> {
    id	<DSPF_SelectItemDelegate>    delegate;

    NSString                        *barcode;
	
@private
    IBOutlet UILabel                *currently;
    IBOutlet UILabel                *itemIDLabel;
    IBOutlet UILabel                *itemIDCountLabel;
	NSManagedObjectContext			*ctx;
    NSArray							*itemCodes;
	IBOutlet UIPickerView			*pickerView;
    IBOutlet UIToolbar              *pickerViewToolbar;
	ItemCode						*currentSelection;
    NSSet                           *currentUsersGroupProfiles;
}

@property (assign)    id <DSPF_SelectItemDelegate>               delegate;
@property (nonatomic, retain)          NSString                 *barcode;

@property (nonatomic, retain) IBOutlet UIToolbar                *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UILabel                  *currently;
@property (nonatomic, retain) IBOutlet UILabel                  *itemIDLabel;
@property (nonatomic, retain) IBOutlet UILabel                  *itemIDCountLabel;
@property (nonatomic, retain)		   NSManagedObjectContext	*ctx;
@property (nonatomic, retain)		   NSArray					*itemCodes;
@property (nonatomic, retain) IBOutlet UIPickerView				*pickerView;
@property (nonatomic, retain)		   ItemCode                 *currentSelection;
@property (nonatomic, retain)          NSSet                    *currentUsersGroupProfiles;

- (IBAction)didConfirmStore;

@end

@protocol DSPF_SelectItemDelegate

- (void) dspf_SelectItemDelegate:(DSPF_SelectItem *)sender didSelect:(Item *)item forBarcode:(NSString *)barcode;

@end
