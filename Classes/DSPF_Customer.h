//
//  DSPF_Customer.h
//  Hermes
//
//  Created by Lutz on 12.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPF_Customer : UITableViewController <NSFetchedResultsControllerDelegate,
                                                  UISearchDisplayDelegate,
                                                  UISearchBarDelegate> {
    UITableView                *tableView;
@private
    BOOL                        toolbarHiddenBackup;
	NSManagedObjectContext     *ctx;
	NSFetchedResultsController *customersAtWork;
    NSFetchedResultsController *filteredListContent;
}

@property (nonatomic, retain) UITableView                *tableView;

@property (nonatomic)         BOOL                        toolbarHiddenBackup;
@property (nonatomic, retain) NSManagedObjectContext     *ctx;
@property (nonatomic, retain) NSFetchedResultsController *customersAtWork;
@property (nonatomic, retain) NSFetchedResultsController *filteredListContent;

@end