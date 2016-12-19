//
//  DSPF_TourStopTransportGroups.m
//  Hermes
//
//  Created by Lutz on 03.10.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_TourStopTransportGroups.h"
#import "DSPF_TourStopTransportGroupsCell.h"
#import "DSPF_LoadTransportItem.h"
#import "DSPF_Activity.h"
#import "DSPF_Suspend.h"
#import "DSPF_Customer.h"

#import "SVR_GoogleFetcher.h"

#import "Tour.h"
#import "Location.h"
#import "Tour_Exception.h"
#import "Transport_Group.h"
#import "Transport.h"

@implementation DSPF_TourStopTransportGroups

@synthesize subTitle;
@synthesize tableView;
@synthesize tourTask;
@synthesize showOptionalTransport_Groups;
@synthesize departure;
@synthesize isFirstTourDeparture;
@synthesize isLastTourDeparture;
@synthesize transportGroups;
@synthesize didItOnce;
@synthesize toolbarHiddenBackup;
@synthesize hidesBackButton;
@synthesize delegate;

#pragma mark - Initialization

- (NSArray *)transportGroups {
    if (!transportGroups) {
        if ([tourTask isEqualToString:TourTaskLoadingOnly]) {
            transportGroups = [[[[self.departure.location_id.transport_group_addressee_id allObjects]
                                 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                    @"pickUpAction = nil AND (0 != SUBQUERY(transport_id, $t, "
                                     " $t.item_id.itemCategoryCode = \"2\").@count)"]]
                                sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                    [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_name" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"sender_id.zip" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"sender_id.city" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_id" ascending:YES], nil]] retain];
        } else {
            if (self.isLastTourDeparture) {
                transportGroups = [[[Transport_Group withPredicate:[NSPredicate predicateWithFormat:
                                        @"(0 != SUBQUERY(transport_id, $t, "
                                         " $t.item_id.itemCategoryCode = \"2\" AND "
                                         "$t.trace_type_id.code = %@).@count)", @"LOAD"] sortDescriptors:nil
                                     inCtx:self.departure.managedObjectContext]
                                   sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_name" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.zip" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.city" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_id" ascending:YES], nil]] retain];
            } else if (self.isFirstTourDeparture && [self.departure.currentTourStatus intValue] == 45) {
                transportGroups = [[[Transport_Group withPredicate:[NSPredicate predicateWithFormat:
                                        @"pickUpAction = nil AND (0 != SUBQUERY(transport_id, $t, "
                                         " $t.item_id.itemCategoryCode = \"2\" AND "
                                         " $t.trace_type_id = nil).@count) AND "
                                         "(0  = SUBQUERY(transport_id, $r, "
                                         " $r.trace_type_id.trace_type_id > 90 && "
                                         " %lld = $r.from_departure_id.departure_id).@count)",
                                         [self.departure.departure_id longLongValue]] sortDescriptors:nil
                                     inCtx:self.departure.managedObjectContext]
                                    sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_name" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.zip" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.city" ascending:YES],
                                        [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_id" ascending:YES], nil]] retain];
            } else {
                if ([self.departure.currentTourStatus intValue] == 45) {
                    transportGroups = [[[[[self.departure.location_id.transport_group_addressee_id allObjects]
                                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                            @"deliveryAction != nil AND (0 != SUBQUERY(transport_id, $t, "
                                             " $t.item_id.itemCategoryCode = \"2\").@count)"]]
                                         sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_name" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.zip" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.city" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_id" ascending:YES], nil]]
                                        arrayByAddingObjectsFromArray:
                                        [[[self.departure.location_id.transport_group_sender_id allObjects]
                                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                            @"pickUpAction != nil AND transport_id.@count != 0"]]
                                         sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_name" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.zip" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.city" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_id" ascending:YES], nil]]] retain];
                } else {
                    transportGroups = [[[[[self.departure.location_id.transport_group_addressee_id allObjects]
                                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                            @"deliveryAction != nil AND (0 != SUBQUERY(transport_id, $t, "
                                             "($t.trace_type_id.code = %@ || $t.trace_type_id.code = %@) && "
                                             " $t.item_id.itemCategoryCode = \"2\").@count)", @"LOAD", @"UNLOAD"]]
                                         sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_name" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.zip" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.city" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_id" ascending:YES], nil]]
                                        arrayByAddingObjectsFromArray:
                                        [[[self.departure.location_id.transport_group_sender_id allObjects]
                                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                            @"pickUpAction != nil AND transport_id.@count != 0"]]
                                         sortedArrayUsingDescriptors:[NSArray arrayWithObjects:
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_name" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.zip" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.city" ascending:YES],
                                            [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_id" ascending:YES], nil]]] retain];
                }
            }
        }
    }
    return transportGroups;
}

- (NSString *)subTitle {
    if (!subTitle) {
        subTitle = [self.departure.location_id.location_name copy];
    }
    return subTitle;
}

#pragma mark - View lifecycle

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)didFinish {
    [self.delegate dspf_TourStopTransportGroups:self didFinishTourStopForItem:self.departure];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadTransportItems {
    DSPF_LoadTransportItem *dspf_LoadTransportItem = [[[DSPF_LoadTransportItem alloc] initWithNibName:@"DSPF_LoadTransportItem" bundle:nil] autorelease];
    dspf_LoadTransportItem.departure = self.departure;
    dspf_LoadTransportItem.tourTask  = self.tourTask;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers addObject:dspf_LoadTransportItem];
    if (self.toolbarHiddenBackup) {
        [self.navigationController setToolbarHidden:YES animated:NO];
    }
    [self.delegate dspf_TourStopTransportGroups:self didFinishTourStopForItem:self.departure];
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
        if (PFBrandingSupported(BrandingViollier, nil)) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.91 alpha:1.0] autorelease];
        } else {
            self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.96 alpha:1.0] autorelease];
        }
    }
	self.view			  = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    
    self.tableView.frame  = self.view.bounds;
	UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend setNumberOfTapsRequired:2];
	[tapToSuspend setNumberOfTouchesRequired:2];
	[self.tableView	addGestureRecognizer:tapToSuspend];
    [self.view addSubview:self.tableView];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIButton *backButton = [UIButton buttonWithType:101];      // left-pointing shape!
	[backButton addTarget:self action:@selector(didFinish) forControlEvents:UIControlEventTouchUpInside];
	[backButton setTitle:@"DPH Hermes" forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    if (self.transportGroups.count == 0) {
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status")
                       messageText:NSLocalizedString(@"keine Fahraufträge", @"keine Fahraufträge")
                              item:@"NO DATA FOUND"
                          delegate:self];
    }
    self.toolbarItems = [NSArray arrayWithObjects:
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         [[[UIBarButtonItem alloc] initWithImage:
                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"exchange" ofType:@"png"]]
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(loadTransportItems)] autorelease],
                         [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                        target:self
                                                                        action:nil] autorelease],
                         nil];
    [AppStyle customizeToolbar:self.navigationController.toolbar];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView deselectSelectedRowAnimated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.didItOnce) {
        self.toolbarHiddenBackup = self.navigationController.toolbarHidden;
        self.didItOnce = YES;
    }
    if (self.hidesBackButton) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.hidesBackButton   = YES;
    }
    NSManagedObjectContext *ctx = [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx];
    BOOL returnablePackagesCount = [[Item itemsWithPredicate:[DSPF_LoadTransportItem predicateForShownTransportItems] sortDescriptors:nil
                                      inCtx:ctx] count];
    self.navigationController.toolbarHidden = returnablePackagesCount == 0 || ([self.tourTask isEqualToString:TourTaskLoadingOnly]);
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.
		// We know this is true because self is no longer in the navigation stack.
    }
    if (self.toolbarHiddenBackup) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
    [super viewWillDisappear:animated];
}

- (Transport_Group *)tourTransport_Group:(NSIndexPath *)indexPath {
    // Return the object from this indexPath
    return [self.transportGroups objectAtIndex:indexPath.row];
}

- (void)didSelectTourLocationForTransport_Group:(Transport_Group *)aTransport_Group {
    DSPF_TourLocation *dspf_TourLocation = [[[DSPF_TourLocation alloc] initWithNibName:@"DSPF_TourLocation" bundle:nil] autorelease];
    dspf_TourLocation.item               = aTransport_Group;
    dspf_TourLocation.transportGroupTourStop = self.departure;
    dspf_TourLocation.tourTask           = self.tourTask;
    dspf_TourLocation.delegate           = self;
    [self.navigationController pushViewController:dspf_TourLocation animated:YES];
    if (![self.tourTask isEqualToString:TourTaskLoadingOnly] &&
        !self.isFirstTourDeparture && !self.isLastTourDeparture && [self.departure.currentTourStatus intValue] != 45) {
        self.hidesBackButton = YES;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.transportGroups.count;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section {
    if (self.subTitle && section == 0) {
        return 48.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)aSection {
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    customView.backgroundColor = [UIColor clearColor];
    if (!self.subTitle || aSection != 0) {
        return customView;
    }
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:
                             CGRectMake(0.0,
                                        0.0,
                                        aTableView.frame.size.width,
                                        48.0)] autorelease];
    headerLabel.opaque = YES;
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    headerLabel.alpha = self.navigationController.navigationBar.alpha;
    if (PFBrandingSupported(BrandingCCC_Group, BrandingViollier, BrandingBiopartner, nil)) {
        headerLabel.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
    } else {
        headerLabel.font  = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    }
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = self.subTitle;
    headerLabel.numberOfLines = 2;
    headerLabel.lineBreakMode = UILineBreakModeWordWrap;
    [customView setFrame: CGRectMake(0.0,
                                     0.0,
                                     headerLabel.frame.size.width,
                                     headerLabel.frame.size.height)];
    [customView addSubview:headerLabel];
    return customView;
}

- (void)accessoryButtonTapped:(id)sender event:(id)event {
    NSIndexPath *indexPath = [self.tableView
                              indexPathForRowAtPoint:[[[event allTouches] anyObject] locationInView:self.tableView]];
    if (indexPath != nil) {
        [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id   cell  = (DSPF_TourStopTransportGroupsCell *)[aTableView dequeueReusableCellWithIdentifier:@"DSPF_TransportGroupsList"];
    if (!cell) {
        cell = [[[DSPF_TourStopTransportGroupsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_TransportGroupsList"] autorelease];
    }
    // Configure the cell...
    [cell setTourTask:self.tourTask];
    [cell setTransportGroupTourStop:self.departure];
    // [DSPF_TourStopTransportGroupsCell setTransportGroup] sets up all subviews ...
    [cell setTransportGroup:[self tourTransport_Group:indexPath]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
//  return aTableView.rowHeight;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//  dspf_TransportGroupInfo
//
//	[self.navigationController pushViewController:dspf_LocationInfo animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self didSelectTourLocationForTransport_Group:[self tourTransport_Group:indexPath]];
}

- (void)dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex { 
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) { 
        if ([item isKindOfClass:[Transport_Group class]]) {
            [self didSelectTourLocationForTransport_Group:(Transport_Group *)item];
        } else if ([item isKindOfClass:[NSString class]]) {
            if ([item isEqualToString:@"NO DATA FOUND"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
	}
}

- (void)dspf_LocationInfo:(DSPF_LocationInfo *)sender didFinishTourForItem:(id )item {
//  [self dspf_TourLocation:nil didFinishTourForItem:(id )item];
}

- (void)dspf_TourLocation:(DSPF_TourLocation *)sender didFinishTourForItem:(id )aTransportGroup {
    [transportGroups release]; transportGroups = nil; // force a new "get" for this array
    [self.tableView reloadData];
}


#pragma mark - Memory management


- (void)dealloc {
    [transportGroups            release];
    [departure                  release];
    [tourTask                   release];
    [subTitle                   release];
    [tableView                  release];
    [super dealloc];
}


@end