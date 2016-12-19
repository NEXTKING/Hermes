//
//  DSPF_Order.h
//  Hermes
//
//  Created by Lutz on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Confirm.h"
#import "MKNumberBadgeView.h"

@interface DSPF_Order : UITableViewController <NSFetchedResultsControllerDelegate,
                                               UISearchDisplayDelegate,
                                               UISearchBarDelegate,
                                               UIPickerViewDelegate, 
                                               UIPickerViewDataSource, 
                                               UIActionSheetDelegate,
                                               DSPF_ConfirmDelegate> {
    NSString                   *subTitle;
    UITableView                *tableView;
    NSString                   *dataTask;
    id                          dataHeaderInfo;
    NSFetchedResultsController *orderLinesAtWork;
    NSFetchedResultsController *filteredListContent;
    id                          lastChangedLine;
    BOOL                        runsAsTakingBack;
    
@private
    BOOL                        toolbarHiddenBackup;
    BOOL                        wasSkippedOnce;
    BOOL                        wasPrintedOnce;
    MKNumberBadgeView          *numberBadgeView;
    UIActionSheet              *analysisPicker;
    UIDatePicker               *datePicker;
    UIView                     *datePickerView;
    UIPickerView               *shoppingCartPicker;
    UIView                     *shoppingCartPickerView;
    NSInteger                   shoppingCartPickerRow;
    BOOL                        modifyTemplateLine;
    BOOL                        moveTemplateLine;
    BOOL                        hasTrademarkHolders;
    BOOL                        hasProductGroups;
	NSManagedObjectContext     *ctx;
    UIView                     *searchResultsCover;
}

@property (nonatomic, retain) NSString                   *subTitle;
@property (nonatomic, retain) UITableView                *tableView;
@property (nonatomic, retain) NSString                   *dataTask;
@property (nonatomic, retain) id                          dataHeaderInfo;
@property (nonatomic, retain) NSFetchedResultsController *orderLinesAtWork;
@property (nonatomic, retain) NSFetchedResultsController *filteredListContent;
@property (nonatomic, retain) id                          lastChangedLine;
@property (nonatomic)         BOOL                        runsAsTakingBack;

@property (nonatomic)         BOOL                        toolbarHiddenBackup;
@property (nonatomic)		  BOOL                        wasSkippedOnce;
@property (nonatomic)		  BOOL                        wasPrintedOnce;
@property (nonatomic, retain) MKNumberBadgeView          *numberBadgeView;
@property (nonatomic, retain) UIActionSheet              *analysisPicker;
@property (nonatomic, retain) UIDatePicker               *datePicker;
@property (nonatomic, retain) UIView                     *datePickerView;
@property (nonatomic, retain) UIPickerView               *shoppingCartPicker;
@property (nonatomic, retain) UIView                     *shoppingCartPickerView;
@property (nonatomic)         NSInteger                   shoppingCartPickerRow;
@property (nonatomic)		  BOOL                        modifyTemplateLine;
@property (nonatomic)		  BOOL                        moveTemplateLine;
@property (nonatomic)         BOOL                        hasTrademarkHolders;
@property (nonatomic)         BOOL                        hasProductGroups;
@property (nonatomic, retain) NSManagedObjectContext     *ctx;
@property (nonatomic, retain) UIView                     *searchResultsCover;

@end