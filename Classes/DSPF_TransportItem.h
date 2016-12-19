//
//  DSPF_TransportItem.h
//  Hermes
//
//  Created by Lutz  Thalmann on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSPF_Load.h"
#import "DSPF_Warning.h"
#import "DSPF_Confirm.h"

#import "Item.h"

@interface DSPF_TransportItem : UITableViewController <NSFetchedResultsControllerDelegate,
                                                        UISearchDisplayDelegate,
                                                        UISearchBarDelegate,
                                                        UIPickerViewDelegate,
                                                        UIPickerViewDataSource,
                                                        DSPF_WarningDelegate,
                                                        DSPF_ConfirmDelegate> {
    IBOutlet UIView                     *scanView;
	IBOutlet UITableView                *tableView;
    IBOutlet UIView                     *textView;
    DSPF_Load                           *dspf_Load;
    Item                                *item;
@private    
    BOOL                                 toolbarHiddenBackup;
    IBOutlet UIToolbar                  *pickerViewToolbar;
    IBOutlet UIBarButtonItem            *pickerViewToolbarText;
    IBOutlet UITextField                *pickerViewToolbarTextField;
    IBOutlet UIBarButtonItem            *pickerViewToolbarDone;
    IBOutlet UIPickerView               *pickerView;
    IBOutlet UILabel                    *itemDescriptionLabel;
    IBOutlet UILabel                    *locationName;
    IBOutlet UILabel                    *streetAddress;
    IBOutlet UILabel                    *zipCode;
    IBOutlet UILabel                    *city;
    BOOL                        hasConfirmedQTYWarning;
    NSNumberFormatter          *currencyFormatter;
    NSInteger                   tmpItemQTY;
    NSMutableDictionary        *tmpItemQTYs;
    BOOL                        hasTrademarkHolders;
    BOOL                        hasProductGroups;
    NSManagedObjectContext     *ctx;
    NSFetchedResultsController *filteredListContent;
    UIView                     *searchResultsCover;
}

@property (nonatomic, retain) IBOutlet UIView               *scanView;
@property (nonatomic, retain) IBOutlet UITableView          *tableView;
@property (nonatomic, retain) IBOutlet UIView               *textView;
@property (nonatomic, assign)          DSPF_Load            *dspf_Load;
@property (nonatomic, retain)          Item                 *item;
@property (nonatomic)         BOOL                           toolbarHiddenBackup;

@property (nonatomic, retain) IBOutlet UIToolbar            *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem      *pickerViewToolbarText;
@property (nonatomic, retain) IBOutlet UITextField          *pickerViewToolbarTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem      *pickerViewToolbarDone;
@property (nonatomic, retain) IBOutlet UIPickerView         *pickerView;
@property (nonatomic, retain) IBOutlet UILabel              *itemDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel              *locationName;
@property (nonatomic, retain) IBOutlet UILabel              *streetAddress;
@property (nonatomic, retain) IBOutlet UILabel              *zipCode;
@property (nonatomic, retain) IBOutlet UILabel              *city;
@property (nonatomic)                  BOOL					 hasConfirmedQTYWarning;

@property (nonatomic, retain)          NSNumberFormatter          *currencyFormatter;
@property (nonatomic)                  NSInteger                   tmpItemQTY;
@property (nonatomic, retain)          NSMutableDictionary        *tmpItemQTYs;
@property (nonatomic)                  BOOL                        hasTrademarkHolders;
@property (nonatomic)                  BOOL                        hasProductGroups;
@property (nonatomic, retain)		   NSManagedObjectContext     *ctx;
@property (nonatomic, retain)          NSFetchedResultsController *filteredListContent;
@property (nonatomic, retain)          UIView                     *searchResultsCover;

- (IBAction)itemQTYShouldReturn;

@end
