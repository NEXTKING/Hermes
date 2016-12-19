//
//  DSPF_OrderItem.h
//  Hermes
//
//  Created by Lutz  Thalmann on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DSPF_Warning.h"

#import "Item.h"

@interface DSPF_OrderItem : UITableViewController <NSFetchedResultsControllerDelegate,
                                                   UISearchDisplayDelegate,
                                                   UISearchBarDelegate,
                                                   UIPickerViewDelegate,
                                                   UIPickerViewDataSource,
                                                   DSPF_WarningDelegate> {
    IBOutlet UIView                     *scanView;
	IBOutlet UITableView                *tableView;
    IBOutlet UIView                     *textView;
			 Item                       *item;
             id                          dataHeaderInfo;
             NSString                   *dataTask;
@private
    IBOutlet UILabel                    *artikelOrderItemLabel;
    IBOutlet UILabel                    *preisOrderItemLabel;
    IBOutlet UILabel                    *historieOrderItemLabel;
                                           
    IBOutlet UIToolbar                  *pickerViewToolbar;
    IBOutlet UIBarButtonItem            *pickerViewToolbarText;
    IBOutlet UITextField                *pickerViewToolbarTextField;
    IBOutlet UIBarButtonItem            *pickerViewToolbarDone;
    IBOutlet UIPickerView               *pickerView;
    IBOutlet UILabel                    *itemDescriptionLabel;
    IBOutlet UILabel                    *itemIDLabel;
    IBOutlet UILabel                    *itemPriceLabel;
    IBOutlet UILabel                    *itemOrderLineLabel;
    IBOutlet UIButton                   *currentQTY;
             BOOL                        hasConfirmedQTYWarning;
             NSNumberFormatter          *currencyFormatter;
             NSInteger                   tmpItemQTY;
             BOOL                        hasTrademarkHolders;
             BOOL                        hasProductGroups;
		     NSManagedObjectContext     *ctx;
             NSFetchedResultsController *filteredListContent;
             UIView                     *searchResultsCover;
             id                          pushedFromViewController;
             BOOL                        hasMinusSign;
             UIColor                    *hasPlusSignColor;
}
@property (nonatomic, retain) IBOutlet UILabel              *artikelOrderItemLabel;
@property (nonatomic, retain) IBOutlet UILabel              *preisOrderItemLabel;
@property (nonatomic, retain) IBOutlet UILabel              *historieOrderItemLabel;



@property (nonatomic, retain) IBOutlet UIView               *scanView;
@property (nonatomic, retain) IBOutlet UITableView          *tableView;
@property (nonatomic, retain) IBOutlet UIView               *textView;
@property (nonatomic, retain)          Item                 *item;
@property (nonatomic, retain)          id                    dataHeaderInfo;
@property (nonatomic, retain)          NSString             *dataTask;

@property (nonatomic, retain) IBOutlet UIToolbar            *pickerViewToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem      *pickerViewToolbarText;
@property (nonatomic, retain) IBOutlet UITextField          *pickerViewToolbarTextField;
@property (nonatomic, retain) IBOutlet UIBarButtonItem      *pickerViewToolbarDone;
@property (nonatomic, retain) IBOutlet UIPickerView         *pickerView;
@property (nonatomic, retain) IBOutlet UILabel              *itemDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel              *itemIDLabel;
@property (nonatomic, retain) IBOutlet UILabel              *itemPriceLabel;
@property (nonatomic, retain) IBOutlet UILabel              *itemOrderLineLabel;
@property (nonatomic, retain) IBOutlet UIButton             *currentQTY;
@property (nonatomic)                  BOOL					 hasConfirmedQTYWarning;

@property (nonatomic, retain)          NSNumberFormatter          *currencyFormatter;
@property (nonatomic)                  NSInteger                   tmpItemQTY;
@property (nonatomic)                  BOOL                        hasTrademarkHolders;
@property (nonatomic)                  BOOL                        hasProductGroups;
@property (nonatomic, retain)		   NSManagedObjectContext     *ctx;
@property (nonatomic, retain)          NSFetchedResultsController *filteredListContent;
@property (nonatomic, retain)          UIView                     *searchResultsCover;
@property (nonatomic, retain)          id                          pushedFromViewController;
@property (nonatomic)                  BOOL                        hasMinusSign;
@property (nonatomic, retain)          UIColor                    *hasPlusSignColor;

- (IBAction)scanDown;
- (IBAction)scanUp;
- (IBAction)itemQTYShouldReturn;

@end
