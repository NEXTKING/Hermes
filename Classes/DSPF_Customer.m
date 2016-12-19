//
//  DSPF_Customer.m
//  Hermes
//
//  Created by Lutz on 12.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Customer.h"
#import "DSPF_Order.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"
#import "DSPF_Suspend.h"

#import "Store.h"
#import "Location.h"
#import "ArchiveOrderHead.h"

@implementation DSPF_Customer

@synthesize tableView;

@synthesize toolbarHiddenBackup;
@synthesize ctx;
@synthesize	customersAtWork;
@synthesize filteredListContent;

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (NSFetchedResultsController *)customersAtWork { 
    if (!customersAtWork) { 
        NSError *error = nil;
        NSFetchRequest *selectCustomersAtWork = [[[NSFetchRequest alloc] init] autorelease];
        [selectCustomersAtWork setEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:self.ctx]];
        [selectCustomersAtWork setPredicate:[NSPredicate predicateWithFormat:@"0 == 0"]];
        [selectCustomersAtWork setFetchBatchSize:12];
        [selectCustomersAtWork setSortDescriptors:[NSArray arrayWithObjects:
                                                    [NSSortDescriptor sortDescriptorWithKey:@"storeName"    ascending:NO], 
                                                    nil]];
        if (PFBrandingSupported(BrandingBiopartner, nil)) { 
            [selectCustomersAtWork setFetchLimit:32];
        }
        customersAtWork = [[NSFetchedResultsController alloc] initWithFetchRequest:selectCustomersAtWork
                                                               managedObjectContext:self.ctx
                                                                 sectionNameKeyPath:nil 
                                                                          cacheName:nil];
        customersAtWork.delegate = self; 
        if (![customersAtWork performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    return customersAtWork;
}

- (NSFetchedResultsController *)filteredListContent { 
    if (!filteredListContent) { 
        NSError *error = nil;
        NSFetchRequest *filteredContent = [[[NSFetchRequest alloc] init] autorelease];
        [filteredContent setEntity:[NSEntityDescription entityForName:@"Store" inManagedObjectContext:self.ctx]];
        [filteredContent setPredicate:[NSPredicate predicateWithValue:NO]];
        [filteredContent setFetchBatchSize:12]; 
        [filteredContent setSortDescriptors:[NSArray arrayWithObjects:
                                             [NSSortDescriptor sortDescriptorWithKey:@"storeName"   ascending:NO],
                                             nil]];
        if (PFBrandingSupported(BrandingBiopartner, nil)) { 
            [filteredContent setFetchLimit:32];
        }
        filteredListContent = [[NSFetchedResultsController alloc] initWithFetchRequest:filteredContent 
                                                                  managedObjectContext:self.ctx 
                                                                    sectionNameKeyPath:nil 
                                                                             cacheName:nil];
        filteredListContent.delegate = self; 
        if (![filteredListContent performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    return filteredListContent;
}

#pragma mark - View lifecycle

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)toggleSearchBar { 
    if (!self.searchDisplayController.active) { 
        self.tableView.tableHeaderView = self.searchDisplayController.searchBar;
        [self.searchDisplayController setActive:YES animated:YES];
        [self.searchDisplayController.searchBar becomeFirstResponder];
    } else { 
        self.tableView.tableHeaderView = nil;
        [self.searchDisplayController setActive:NO animated:YES];
        [self.searchDisplayController.searchBar resignFirstResponder];
    }
}

- (void)viewDidLoad {
	[super viewDidLoad];
    self.toolbarHiddenBackup = self.navigationController.toolbarHidden;
    self.title = NSLocalizedString(@"Neue Haltestelle", @"Neue Haltestelle");
    DSPF_Activity  *showActivity   = [[DSPF_Activity messageTitle:NSLocalizedString(@"Daten werden geladen", @"Daten werden geladen") 
                                                      messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
	if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
        self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.96 alpha:1.0] autorelease];
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        [searchBar sizeToFit];
        searchBar.keyboardType = UIKeyboardTypeAlphabet;
        searchBar.delegate = self;
        self.tableView.tableHeaderView = nil;
        UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:[searchBar autorelease] contentsController:self];
        searchDisplayController.delegate = self;
        searchDisplayController.searchResultsDataSource = self;
        searchDisplayController.searchResultsDelegate   = self;
        // The above assigns self.searchDisplayController, but without retaining.
        // Force the read-only property to be set and retained.
        [self forceSetReadOnlyPropertyOfSearchDisplayController:[searchDisplayController autorelease]];
    }
	self.view			  = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    
    self.tableView.frame  = self.view.bounds;
	UITapGestureRecognizer *tapToSuspend_front = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend_front setNumberOfTapsRequired:2];
	[tapToSuspend_front setNumberOfTouchesRequired:2];
	[self.tableView	addGestureRecognizer:tapToSuspend_front];
    [self.view addSubview:self.tableView];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         [[[UIBarButtonItem alloc] initWithImage:
                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"magnifyingglass" ofType:@"png"]]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(toggleSearchBar)] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         nil];
    [showActivity closeActivityInfo];
    [showActivity release];
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = (!self.toolbarItems || self.toolbarItems.count == 0);
}

- (void)viewWillDisappear: (BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.
		// We know this is true because self is no longer in the navigation stack.
        if (self.toolbarHiddenBackup) {
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
    }
    [super viewWillDisappear:animated];
}

- (void)didSelectCustomer:(id )aCustomer {
    for (ArchiveOrderHead *tmpOrderHead in [NSArray arrayWithArray:
          [ArchiveOrderHead orderHeadsWithPredicate:[NSPredicate predicateWithFormat:@"orderState = 00"]
                                    sortDescriptors:nil
                             inCtx:self.ctx]]) {
        [self.ctx deleteObject:tmpOrderHead];
    }
    [self.ctx saveIfHasChanges];
    DSPF_Order *dspf_Order    = [[[DSPF_Order alloc] init] autorelease];
    dspf_Order.title          = ((Store *)aCustomer).storeName;
    dspf_Order.dataTask       = @"WRKACTDTA";
    if (((Store *)aCustomer).associatedLocation) {
        Location *storeLocation = [Location withID:[NSNumber numberWithInt:[((Store *)aCustomer).associatedLocation intValue]]
                                inCtx:self.ctx];
        if (storeLocation) {
            dspf_Order.dataHeaderInfo = [ArchiveOrderHead orderHeadWithClientData:[NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]]
                                                                         forLocation:storeLocation
                                                           inCtx:self.ctx];
        } else {
            dspf_Order.dataHeaderInfo = [ArchiveOrderHead orderHeadWithClientData:[NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]]
                                                                         forStore:[NSNumber numberWithInt:abs([((Store *)aCustomer).store_id intValue])]
                                                           inCtx:self.ctx];
        }
    } else {
        dspf_Order.dataHeaderInfo = [ArchiveOrderHead orderHeadWithClientData:[NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]]
                                                                     forStore:[NSNumber numberWithInt:abs([((Store *)aCustomer).store_id intValue])]
                                                       inCtx:self.ctx];
    }
    dspf_Order.runsAsTakingBack = YES;
    if (self.searchDisplayController.active) {
        [self.searchDisplayController.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
        self.tableView.tableHeaderView = nil;
    }
    [self.navigationController pushViewController:dspf_Order animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [[self.filteredListContent sections] count];
    }
    return [[self.customersAtWork sections] count];
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [[[self.filteredListContent sections] objectAtIndex:section] numberOfObjects];
    }
    return [[[self.customersAtWork sections] objectAtIndex:section] numberOfObjects];
}

/*
- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
	return [NSString stringWithFormat:@"%@: %@", [[self.listGroups objectAtIndex:aSection] valueForKey:@"city"],
            [[self.listGroups objectAtIndex:aSection] valueForKey:@"location_name"]];
}
*/

- (NSString *)tableView:(UITableView *)aTableView titleForFooterInSection:(NSInteger)aSection {
    NSError *error = nil;
    NSUInteger fetchLimit;
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        fetchLimit = self.filteredListContent.fetchRequest.fetchLimit;
        if (fetchLimit > 0) {
            NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
            fetchRequest.entity = self.filteredListContent.fetchRequest.entity;
            fetchRequest.predicate = self.filteredListContent.fetchRequest.predicate;
            NSUInteger fetchTotal = [self.ctx countForFetchRequest:fetchRequest error:&error];
            if (fetchTotal > fetchLimit)
                return [NSString stringWithFormat:@"... (%i)", fetchTotal];
        }
    } else {
        fetchLimit = self.customersAtWork.fetchRequest.fetchLimit;
        if (fetchLimit > 0) {
            NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
            fetchRequest.entity = self.customersAtWork.fetchRequest.entity;
            fetchRequest.predicate = self.customersAtWork.fetchRequest.predicate;
            NSUInteger fetchTotal = [self.ctx countForFetchRequest:fetchRequest error:&error];
            if (fetchTotal > fetchLimit)
                return [NSString stringWithFormat:@"... (%i)", fetchTotal];
        }
    }
    return nil;
}

- (id )customerAtIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)aTableView {
    // Return the object from this indexPath
    if (aTableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredListContent objectAtIndexPath:indexPath];
    }
	return [self.customersAtWork objectAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id tmpCustomer = [self customerAtIndexPath:indexPath forTableView:(UITableView *)aTableView];
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"DSPF_CustomerList"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"DSPF_CustomerList"] autorelease];
    }
    // Configure the cell...
    
    cell.selectionStyle      = UITableViewCellSelectionStyleBlue;
    cell.accessoryType       = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font      = [UIFont  fontWithName:@"Helvetica-Bold" size:17];
    cell.textLabel.text      = [NSString stringWithFormat:@"%06i %@",
                                 [[tmpCustomer valueForKey:@"store_id"] intValue],
                                 [tmpCustomer valueForKey:@"storeName"]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectCustomer:[self customerAtIndexPath:indexPath forTableView:aTableView]];
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath { 
    [self didSelectCustomer:[self customerAtIndexPath:indexPath forTableView:aTableView]];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
    return NO; 
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.ctx deleteObject:[self customerAtIndexPath:indexPath forTableView:aTableView]];
        [self.ctx saveIfHasChanges];
    }   
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope { 
    NSError *error = nil;
    [self.filteredListContent.fetchRequest
     setPredicate:[NSPredicate predicateWithFormat:
                   @"storeName CONTAINS[cd] %@ OR (0 < %i AND store_id.stringValue CONTAINS %@)",
                   searchText, [searchText intValue], [NSExpression expressionForConstantValue:searchText]]];
    if (![self.filteredListContent performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self tableView:self.searchDisplayController.searchResultsTableView titleForFooterInSection:0];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller { 
    self.tableView.tableHeaderView = controller.searchBar; 
    self.navigationController.toolbarHidden = YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller { 
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {  
    self.tableView.tableHeaderView = nil;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    [self.navigationController setToolbarHidden:NO animated:YES];
}


#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller { 
    if (controller == self.filteredListContent) {
        [self.searchDisplayController.searchResultsTableView beginUpdates];
    } else {
        [self.tableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (controller == self.filteredListContent) {
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.searchDisplayController.searchResultsTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.searchDisplayController.searchResultsTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    } else { 
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    if (controller == self.filteredListContent) { 
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
                break;
            case NSFetchedResultsChangeMove:
                [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    } else { 
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView cellForRowAtIndexPath:indexPath];
                break;
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller { 
    if (controller == self.filteredListContent) { 
        [self.searchDisplayController.searchResultsTableView endUpdates];
        [self.searchDisplayController.searchResultsTableView reloadData];
    } else {
        [self.tableView endUpdates];
        [self.tableView reloadData];
    }
}


#pragma mark - Memory management



- (void)viewDidUnload {
    [super viewDidUnload];

}


- (void)dealloc {
	[ctx       release];
    [filteredListContent        release];
    [customersAtWork            release];
	[tableView                  release];
    [super dealloc];
}


@end

