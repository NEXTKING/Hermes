//
//  tourDeparturesAtWorkDSPF_Tour.m
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Tour.h"
#import "DSPF_TourTableViewCell.h"
#import "DSPF_TourTableViewCell_biopartner.h"
#import "DSPF_TourTableViewCell_viollier.h"
#import "DSPF_TourTableViewCell_CCC.h"
#import "DSPF_TourTableViewCell_technopark.h"
#import "DSPF_Activity.h"
#import "DSPF_Suspend.h"
#import "DSPF_Customer.h"
#import "DSPF_QuitLoading.h"
#import "DSPF_Finish.h"
#import "DSPF_SwitcherView.h"
#import "DSPF_SegmentedControl_technopark.h"

#import "SVR_GoogleFetcher.h"

#import "Tour.h"
#import "Location.h"
#import "Tour_Exception.h"
#import "Transport_Group.h"
#import "Transport.h"

@interface DSPF_Tour() <SwitcherViewDelegate>
{
    BOOL hasReorderChanges;
}
@property (nonatomic, retain) NSManagedObjectContext     *ctx;
@property (nonatomic, retain) NSFetchedResultsController *transportsFetchResultsController;
@property (nonatomic, retain) UIView *customHeader;
@end

@implementation DSPF_Tour {
    BOOL userDrivenDataModelChange;
}

@synthesize svr_LocationManager;
@synthesize subTitle;
@synthesize tableView;
@synthesize mapView;
@synthesize tourTask;
@synthesize showOptionalDepartures;
@synthesize transportsFetchResultsController;

@synthesize ctx;
@synthesize tourMapPoints;
@synthesize tourMapPointsDidLoad;
@synthesize	tourDeparturesAtWork;
@synthesize tourMapLines;
@synthesize pinForTruck;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSFetchRequest *request = [[[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Transport class])] autorelease];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
        request.fetchBatchSize = 5;
        transportsFetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.ctx
                                                                                 sectionNameKeyPath:nil cacheName:nil];
        [transportsFetchResultsController performFetch:nil];
        transportsFetchResultsController.delegate = self;
    }
    return self;
}

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (NSMutableArray *)tourMapPoints {
    if (!tourMapPoints) {
        tourMapPoints = [[NSMutableArray alloc] init];
    }
    return tourMapPoints;
}


- (MKPolyline *)tourMapLines {
    if (!tourMapLines) {
        tourMapLines = [[MKPolyline alloc] init];
    }
    return tourMapLines;
}

- (MKMapView *)mapView {
    if (!mapView) {
        mapView = [[MKMapView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        mapView.delegate = self;
    }
    return mapView;
}

- (void)drawAllMapPoints {	
    [self.mapView removeAnnotations:self.tourMapPoints];
	[self.mapView removeOverlay:self.tourMapLines];
	[self.tourMapPoints removeAllObjects];
    [self updatePinForTruck];
	for (Departure *tmpTourDeparture in [[[NSArray arrayWithArray:[self.tourDeparturesAtWork fetchedObjects]] reverseObjectEnumerator] allObjects]) { 
        CLLocationCoordinate2D location;
		location.longitude  = [tmpTourDeparture.location_id.longitude doubleValue];
		location.latitude   = [tmpTourDeparture.location_id.latitude  doubleValue];
        [self.tourMapPoints addObject:[DSPF_TourMapAnnotation annotationWithCoordinate:location item:[tmpTourDeparture objectID] title:@"" subtitle:@""]];
	}
    NSUInteger      maxIndex     = [self.tourMapPoints count];
    NSUInteger      tmpIndex     =  maxIndex;
    NSMutableArray *googleRoute;
    if (self.pinForTruck && self.pinForTruck.title == NSLocalizedString(@"TITLE_005", @"Fahrzeug")) {
        if (tmpIndex > 9) {
            tmpIndex = 9;
        }
        CLLocationCoordinate2D location = self.pinForTruck.coordinate;
        googleRoute  = [SVR_GoogleFetcher googlePolylineFrom:location withMapPoints:
                        [self.tourMapPoints objectsAtIndexes:
                         [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tmpIndex)]]];
        NSUInteger tmpLength = 10;
        tmpIndex -= 1;
        while ((maxIndex - tmpIndex) > 1) {
            if ((maxIndex - tmpIndex) < 10) {
                tmpLength = (maxIndex - tmpIndex);
            }
            [googleRoute addObjectsFromArray:[SVR_GoogleFetcher googlePolylineWithMapPoints:
                                              [self.tourMapPoints objectsAtIndexes:
                                               [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(tmpIndex, tmpLength)]]]];
            tmpIndex += tmpLength - 1;
        }
    } else {
        if (tmpIndex > 10) {
            tmpIndex = 10;
        }
        googleRoute  = [SVR_GoogleFetcher googlePolylineWithMapPoints:
                        [self.tourMapPoints objectsAtIndexes:
                         [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tmpIndex)]]];
        NSUInteger tmpLength = 10;
        tmpIndex -= 1;
        while ((maxIndex - tmpIndex) > 1) {
            if ((maxIndex - tmpIndex) < 10) {
                tmpLength = (maxIndex - tmpIndex);
            }
            [googleRoute addObjectsFromArray:[SVR_GoogleFetcher googlePolylineWithMapPoints:
                                              [self.tourMapPoints objectsAtIndexes:
                                               [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(tmpIndex, tmpLength)]]]];
            tmpIndex += tmpLength - 1;
        }
    }
    MKMapPoint *googleRoutePoints  = (MKMapPoint *) malloc(sizeof(MKMapPoint) * [googleRoute  count]);
    tmpIndex = 0;
    for (NSArray *googleRoutePoint in googleRoute) {
		CLLocationCoordinate2D location;
		location.longitude = [[googleRoutePoint objectAtIndex:1] doubleValue];
		location.latitude  = [[googleRoutePoint objectAtIndex:0] doubleValue];
        googleRoutePoints[tmpIndex] = MKMapPointForCoordinate(location);
        tmpIndex ++;
    }
    
	self.tourMapLines = [MKPolyline polylineWithPoints:googleRoutePoints count:tmpIndex];
	[self.mapView addOverlay:tourMapLines];
	[self.mapView addAnnotations:self.tourMapPoints];
	free(googleRoutePoints);
    self.tourMapPointsDidLoad = YES;
}

- (NSFetchedResultsController *)tourDeparturesAtWork { 
    if (!tourDeparturesAtWork) { 
        NSError *error = nil;
        NSFetchRequest *selectTourDeparturesAtWork = [[[NSFetchRequest alloc] init] autorelease];
        [selectTourDeparturesAtWork setEntity:[NSEntityDescription entityForName:@"Departure" inManagedObjectContext:self.ctx]];
        if ([self.tourTask isEqualToString:TourTaskAdjustingOnly]) { 
            [selectTourDeparturesAtWork setPredicate:[NSPredicate predicateWithFormat:@"currentTourBit = YES && currentTourStatus = 00"]];
        } else if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
            [selectTourDeparturesAtWork setPredicate:[NSPredicate predicateWithFormat:@"currentTourBit = YES && currentTourStatus < 40 &&"
                                    "(transport_group_id = nil OR transport_group_id.isPickup = nil OR transport_group_id.isPickup = NO)"]];
        } else if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
            [selectTourDeparturesAtWork setPredicate:[NSPredicate predicateWithFormat:@"currentTourBit = YES && currentTourStatus < 70 && (canceled = nil || canceled = NO)"]];
        }
        [selectTourDeparturesAtWork setReturnsObjectsAsFaults:NO];
        [selectTourDeparturesAtWork setFetchBatchSize:20];
        BOOL ascendingSort = YES;
        if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
            ascendingSort = NO;
        }
        [selectTourDeparturesAtWork setSortDescriptors:[self departureSortDescriptorsAscending:ascendingSort]];
        tourDeparturesAtWork = [[NSFetchedResultsController alloc] initWithFetchRequest:selectTourDeparturesAtWork
                                                                   managedObjectContext:self.ctx 
                                                                     sectionNameKeyPath:nil 
                                                                              cacheName:nil];
        tourDeparturesAtWork.delegate = self; 
        if (![tourDeparturesAtWork performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
    return tourDeparturesAtWork;
}

- (void) switcherView:(DSPF_SwitcherView *)switcher didSwitchToStateWithOptions:(NSDictionary *)options
{
    self.editButtonItem.enabled = (switcher.currentState == 0);
    
    void (^actionBlock)(void) = [options objectForKey:@"actionBlock"];
    if (actionBlock)
        actionBlock();
}

- (void)switchFilterForTourDeparturesAtWork {
    if ([self.tourTask isEqualToString:TourTaskNormalDrive] || PFTourTypeSupported(@"1X1", nil)) {
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            DSPF_Customer *dspf_Customer = [[DSPF_Customer alloc] init];
            [self.navigationController pushViewController:dspf_Customer animated:YES];
            [dspf_Customer release];
        } else {
            // ensure the process sequence because "didFinishTourForItem:" needs a consistent predicate at its runtime
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateTour" object:nil];
                [self.ctx saveIfHasChanges];
                if (!self.showOptionalDepartures) {
                    if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
                        [self.tourDeparturesAtWork.fetchRequest setPredicate:
                         [NSPredicate predicateWithFormat:@"tour_id.tour_id  = %i && dayOfWeek = %i && (currentTourStatus = nil || currentTourStatus < 40)",
                          [[NSUserDefaults currentTourId] intValue],
                          [[NSUserDefaults currentStintDayOfWeek] intValue]]];
                    } else {
                        [self.tourDeparturesAtWork.fetchRequest setPredicate:
                         [NSPredicate predicateWithFormat:@"tour_id.tour_id  = %i && dayOfWeek = %i && currentTourStatus < 70",
                          [[NSUserDefaults currentTourId] intValue],
                          [[NSUserDefaults currentStintDayOfWeek] intValue]]];
                    }
                    self.showOptionalDepartures = YES;
                } else {
                    [self.tourDeparturesAtWork.fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES && currentTourStatus < 70"]];
                    self.showOptionalDepartures = NO;
                }
                NSError *error = nil;
                if (![self.tourDeparturesAtWork performFetch:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                self.tourMapPointsDidLoad = NO;
                [self.tableView reloadData];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTour)
                                                             name:@"updateTour"
                                                           object:nil];
            });
        }
    }
}

- (void)createNewTour {
    for (Departure *tmpTourDeparture in [Departure withPredicate:
                                         [NSPredicate predicateWithFormat:@"tour_id.tour_id  = %i && dayOfWeek = %i",
                                          [[NSUserDefaults currentTourId] intValue],
                                          [[NSUserDefaults currentStintDayOfWeek] intValue]] 
                                                           sortDescriptors:nil inCtx:self.ctx]) {
        if ([tmpTourDeparture.onDemand isEqualToNumber:[NSNumber numberWithBool:NO]]) {
            // mark all obligatory departures
            tmpTourDeparture.currentTourBit    = [NSNumber numberWithBool:YES];
            tmpTourDeparture.currentTourStatus = [NSNumber numberWithInt:00];
        }
        if (!tmpTourDeparture.predefinedOrder) {
            // older Versions did not have a "predefinedOrder" - just a "sequence"
            tmpTourDeparture.predefinedOrder = tmpTourDeparture.sequence; 
        } else {
            if (![NSUserDefaults isRunningWithTourAdjustment] || PFTourTypeSupported(@"0X1", nil)) {
                // apply the servers sequence from the last import
                tmpTourDeparture.sequence = tmpTourDeparture.predefinedOrder;
            }
        }
    }
    [self.ctx saveIfHasChanges];
}

- (void)updateOptionalTourStops {
    NSArray		   *sortDescriptors = [self departureSortDescriptorsAscending:YES];
	for (Departure *optional           in [Departure withPredicate:
                                           [NSPredicate predicateWithFormat:@"tour_id.tour_id = %i && dayOfWeek = %i && onDemand = YES && "
                                            "currentTourBit = NO && (confirmed = YES || "
                                            "(0 == SUBQUERY(location_id.departure_id, $d, $d.currentTourBit = YES && $d.currentTourStatus < 50).@count))",
                                            [[NSUserDefaults currentTourId] intValue],
                                            [[NSUserDefaults currentStintDayOfWeek] intValue]]
                                                             sortDescriptors:sortDescriptors inCtx:self.ctx])
    {
        NSNumber *locationId = [NSNumber numberWithInt:[optional.location_id.location_id intValue]];
        NSNumber *transportGroup = optional.transport_group_id.transport_group_id;
        
        if ([Transport countOf:Pallet|Unit|Pick forTourLocation:locationId transportGroup:transportGroup ctx:self.ctx] > 0 || [optional.confirmed boolValue]) {
            NSArray *thisLoop = [Departure withPredicate:
                                 [NSPredicate predicateWithFormat:@"tour_id.tour_id = %i && dayOfWeek = %i && location_id.location_id = %i && "
                                  "(0 == SUBQUERY(location_id.departure_id, $d, $d.currentTourBit = YES && $d.currentTourStatus < 50).@count)",
                                  [[NSUserDefaults currentTourId] intValue],
                                  [[NSUserDefaults currentStintDayOfWeek] intValue],
                                  [optional.location_id.location_id intValue]]
                                                   sortDescriptors:nil inCtx:self.ctx];
            if ((thisLoop && thisLoop.count != 0) || [optional.confirmed boolValue]) {
                optional.currentTourBit    = [NSNumber numberWithBool:YES];
                optional.currentTourStatus = [NSNumber numberWithInt:00];
                if (!optional.predefinedOrder) {
                    optional.predefinedOrder = optional.sequence;
                }
            }
		}
	}
    [self.ctx saveIfHasChanges];
}


#pragma mark - View lifecycle

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)quitLoadingForTour {
    DSPF_QuitLoading *dspf_QuitLoading = [[[DSPF_QuitLoading alloc] init] autorelease];
    dspf_QuitLoading.tourTitle  = self.subTitle;
    dspf_QuitLoading.title      = NSLocalizedString(@"TITLE_114", @"Laden beenden");
    [self.navigationController pushViewController:dspf_QuitLoading animated:YES];
}

- (void)finishTour {
    DSPF_Finish *dspf_Finish = [[[DSPF_Finish alloc] init] autorelease];
    dspf_Finish.title = self.subTitle;
    [self.navigationController pushViewController:dspf_Finish animated:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    self.svr_LocationManager = [[[SVR_LocationManager alloc] init] autorelease];
    DSPF_Activity  *showActivity   = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_023", @"Tour wird geladen") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
    if (![[Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES && onDemand = NO"] inCtx:self.ctx] lastObject]) {
        [self createNewTour];
        NSError *error = nil;
        if (![self.tourDeparturesAtWork performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [self updateOptionalTourStops];
	if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
        if (PFBrandingSupported(BrandingViollier, nil)) {
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.91 alpha:1.0] autorelease];
        }
        else if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            HermesAppDelegate *appDelegate = (HermesAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.workspace updateSideBar];
            
            UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"technoparkBackground.png"]];
            self.tableView.backgroundView = backgroundImage;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [backgroundImage release];
            
            self.navigationItem.hidesBackButton = YES;
            
            
            UIImage *listImageNotRendered = [UIImage imageNamed:@"segmented_list_normal.png"];
            UIImage *listImage = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            listImageNotRendered = [UIImage imageNamed:@"segmented_map_normal.png"];
            UIImage *mapImage = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            listImageNotRendered = [UIImage imageNamed:@"segmented_list_selected.png"];
            UIImage *listSelectedImage = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            listImageNotRendered = [UIImage imageNamed:@"segmented_map_selected.png"];
            UIImage *mapSelectedImage = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
            DSPF_SegmentedControl_technopark *segmentedControl = [[DSPF_SegmentedControl_technopark alloc] initWithItems:@[
                                        listImage,
                                        mapImage]];
            
            [segmentedControl setDividerImage:[UIImage imageNamed:@"segmented_divider.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [segmentedControl setDividerImage:[UIImage imageNamed:@"segmented_divider.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
            
            [segmentedControl setSelectedImage:listSelectedImage forSegment:0];
            [segmentedControl setSelectedImage:mapSelectedImage forSegment:1];
            
            [segmentedControl setSelectedSegmentIndex:0];
            [segmentedControl addTarget:self action:@selector(switchViews) forControlEvents:UIControlEventValueChanged];
            UIBarButtonItem *segItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
            [segmentedControl release];
            UIBarButtonItem *spaceItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL] autorelease];
            self.toolbarItems = @[spaceItem, segItem, spaceItem];
            
            CGRect segmentedFrame = segmentedControl.frame;
            segmentedFrame.origin.x = 0;
            segmentedFrame.origin.y = 0;
            segmentedFrame.size.height = self.navigationController.toolbar.frame.size.height;
            segmentedFrame.size.width  = self.navigationController.toolbar.frame.size.width;
            segmentedControl.frame = self.navigationController.toolbar.frame;
            segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            self.navigationItem.leftBarButtonItem = self.editButtonItem;
        }
        else {
            self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.96 alpha:1.0] autorelease];
        }
        if (PFTourTypeSupported(@"0X0", nil) || PFBrandingSupported(BrandingCCC_Group, nil)) {
            UIView   *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 96.0)];
            UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnDone setFrame:CGRectMake(20.0, 24.0, 280.0, 48.0)];
            [btnDone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [btnDone setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [btnDone setContentMode:UIViewContentModeScaleToFill];
            [btnDone.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:24]];
            [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [btnDone setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [[NSBundle mainBundle] pathForResource:@"b280x48_n" ofType:@"png"]]
                               forState:UIControlStateNormal];
            [btnDone setBackgroundImage:[UIImage imageWithContentsOfFile:
                                         [[NSBundle mainBundle] pathForResource:@"b280x48_h" ofType:@"png"]]
                               forState:UIControlStateHighlighted];
            if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
                [btnDone setTitle:NSLocalizedString(@"TITLE_114", @"Laden beenden") forState:UIControlStateNormal];
                [btnDone addTarget:self action:@selector(quitLoadingForTour) forControlEvents:UIControlEventTouchUpInside];
            } else {
                [btnDone setTitle:NSLocalizedString(@"TITLE_010", @"Abschliessen") forState:UIControlStateNormal];
                [btnDone addTarget:self action:@selector(finishTour) forControlEvents:UIControlEventTouchUpInside];
            }
            [footerView addSubview:btnDone];
            self.tableView.tableFooterView = [footerView autorelease];
        }
    }
	self.view			  = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
    
    self.tableView.frame  = self.view.bounds;
	UITapGestureRecognizer *tapToSuspend_front = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend_front setNumberOfTapsRequired:2];
	[tapToSuspend_front setNumberOfTouchesRequired:2];
	[self.tableView	addGestureRecognizer:tapToSuspend_front];
    [self.view addSubview:self.tableView];
    
	self.mapView.frame    = self.view.bounds;
	UITapGestureRecognizer *tapToSuspend_back = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend_back setNumberOfTapsRequired:2];
	[tapToSuspend_back setNumberOfTouchesRequired:2];
	[mapView	  addGestureRecognizer:tapToSuspend_back];
    [self.view addSubview:self.mapView];
    
    self.mapView.hidden      = YES;
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (!PFBrandingSupported(BrandingTechnopark, nil))
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"map_white"
                                                                                                                                                      ofType:@"png"]]
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(switchViews)] autorelease];
    [showActivity closeActivityInfo];
    [showActivity release];
    if ([self.tourDeparturesAtWork fetchedObjects].count == 0) { 
        if ([self.tourTask isEqualToString:TourTaskAdjustingOnly] || 
            [self.tourTask isEqualToString:TourTaskLoadingOnly] ) { 
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status") 
                           messageText:NSLocalizedString(@"ERROR_MESSAGE_006", @"Die gewählte Funktion kann jetzt nicht mehr durchgeführt werden.")
                                  item:@"NO DATA FOUND"
                              delegate:self]; 
        } else if ([self.tourTask isEqualToString:TourTaskNormalDrive]) { 
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status") 
                           messageText:NSLocalizedString(@"ERROR_MESSAGE_007", @"Für diese Tour gibt es aktuell keine Daten.")
                                  item:@"NO DATA FOUND"
                              delegate:self]; 
        }
    } else {
        if ([self.tourTask isEqualToString:TourTaskAdjustingOnly]) { 
            self.tableView.editing = YES;
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTour) name:@"updateTour" object:nil];
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        DSPF_SwitcherView *switcherView = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SwitcherView_technopark" owner:nil options:nil]objectAtIndex:0];
        self.customHeader = switcherView;
        
        void (^fetchCurrentOrders)(void) = ^{
            [self.tourDeparturesAtWork.fetchRequest setPredicate:
             [NSPredicate predicateWithFormat:@"currentTourBit = YES && (currentTourStatus = nil || currentTourStatus != 70 ) && (canceled = nil || canceled = NO)"]];
              //[[NSUserDefaults currentTourId] intValue],
              //[[NSUserDefaults currentStintDayOfWeek] intValue]]];
            
            NSError *error;
            if (![self.tourDeparturesAtWork performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self.tableView reloadData];
        };
        void (^fetchDoneOrders)(void) = ^{
            [self.tourDeparturesAtWork.fetchRequest setPredicate:
             [NSPredicate predicateWithFormat:@"currentTourBit = YES && currentTourStatus = 70"]];
              //[[NSUserDefaults currentTourId] intValue],
              //[[NSUserDefaults currentStintDayOfWeek] intValue]]];
            
            NSError *error;
            if (![self.tourDeparturesAtWork performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self.tableView reloadData];
        };
        void (^fetchRejectedOrders)(void) = ^{
            [self.tourDeparturesAtWork.fetchRequest setPredicate:
             [NSPredicate predicateWithFormat:@"currentTourBit = YES && (currentTourStatus = nil || currentTourStatus != 70 ) && canceled = YES"]];
              //[[NSUserDefaults currentTourId] intValue],
              //[[NSUserDefaults currentStintDayOfWeek] intValue]]];
            
            NSError *error;
            if (![self.tourDeparturesAtWork performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            
            [self.tableView reloadData];
        };
        
        
        [switcherView addStateWithTitle:@"Текущие заказы" options:@{@"actionBlock":[[fetchCurrentOrders copy] autorelease]}];
        [switcherView addStateWithTitle:@"Выполненные заказы" options:@{@"actionBlock":[[fetchDoneOrders copy] autorelease]}];
        [switcherView addStateWithTitle:@"Отклоненные заказы" options:@{@"actionBlock":[[fetchRejectedOrders copy] autorelease]}];
        
        switcherView.delegate = self;
        
    }
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectSelectedRowAnimated:animated];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterForTourDeparturesAtWork)] autorelease];
    [tr setNumberOfTapsRequired:2];
    [tr setNumberOfTouchesRequired:1];
    [self.navigationController.navigationBar addGestureRecognizer:tr];
}

- (void)viewWillDisappear:(BOOL)animated {
    for (UIGestureRecognizer *gestureRecognizer in self.navigationController.navigationBar.gestureRecognizers) {
        [self.navigationController.navigationBar removeGestureRecognizer:gestureRecognizer];
    }
    [super viewWillDisappear:animated];
}

- (Departure *)tourDeparture:(NSIndexPath *)indexPath { 
    // Return the object from this indexPath
	return (Departure *)[self.tourDeparturesAtWork objectAtIndexPath:indexPath];
}

- (void)didSelectTourLocationForDeparture:(Departure *)aDeparture {
    /* Not used anymore, but could become an optional feature in the future.
    if ([aDeparture.canceled boolValue] ||
        [Tour_Exception todaysTourExceptionForLocation:aDeparture.location_id]) {
        // clean up the list (70 = hidden)
        aDeparture.currentTourStatus = [NSNumber numberWithInt:70];
        [self.ctx saveIfHasChanges];
        [self.tableView reloadData];
        return;
    }
    */
    Departure *firstTourDeparture = [Departure firstTourDepartureInCtx:self.ctx];
    Departure *lastTourDeparture = [Departure lastTourDepartureInCtx:self.ctx];

    if ((PFBrandingSupported(BrandingCCC_Group, nil)) &&
        (![aDeparture isEqual:firstTourDeparture] || [firstTourDeparture.currentTourStatus isEqualToNumber:[NSNumber numberWithInt:45]]) &&
        (![aDeparture isEqual:lastTourDeparture] || [Transport withPredicate:[NSPredicate predicateWithFormat:
            @"trace_type_id.code = %@", @"LOAD"] inCtx:self.ctx].count > 0)) {
        DSPF_TourStopTransportGroups *dspf_TourStopTransportGroups = [[[DSPF_TourStopTransportGroups alloc] init] autorelease];
        dspf_TourStopTransportGroups.title      = self.subTitle;
        dspf_TourStopTransportGroups.tourTask   = self.tourTask;
        dspf_TourStopTransportGroups.departure  = aDeparture;
        dspf_TourStopTransportGroups.isFirstTourDeparture = [aDeparture isEqual:firstTourDeparture];
        dspf_TourStopTransportGroups.isLastTourDeparture  = [aDeparture isEqual:lastTourDeparture];
        dspf_TourStopTransportGroups.delegate   = self;
        [self.navigationController pushViewController:dspf_TourStopTransportGroups animated:YES];
    } else {
        DSPF_TourLocation *dspf_TourLocation;
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            NSDictionary *params = @{ControllerParameterItem:aDeparture};
            dspf_TourLocation = [[[DSPF_TourLocation alloc] initWithParameters:params] autorelease];
        }
        else
            dspf_TourLocation = [[[DSPF_TourLocation alloc] initWithNibName:@"DSPF_TourLocation" bundle:nil] autorelease];

        dspf_TourLocation.item                  = aDeparture;
        dspf_TourLocation.tourTask              = self.tourTask;
        dspf_TourLocation.delegate				= self;
        [self.navigationController pushViewController:dspf_TourLocation animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(DSPF_TourMapAnnotation *)aMapAnnotation {
	MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:aMapAnnotation reuseIdentifier:@"no_reuse"];
	if ([aMapAnnotation.title isEqualToString:NSLocalizedString(@"TITLE_005", @"Fahrzeug")]) {
		annotationView.pinColor       = MKPinAnnotationColorPurple;
		annotationView.canShowCallout = NO;
	}else { 
        NSString *timeKey;
        NSString *timeValue;
        NSString *timeSign;
        Departure *tourStop = (Departure *)[self.ctx objectWithID:(NSManagedObjectID *)aMapAnnotation.item];
        if (tourStop.departure) {
            timeKey   = @"🕑";
            timeValue = [NSDateFormatter localizedStringFromDate:tourStop.departure 
                                                       dateStyle:NSDateFormatterNoStyle 
                                                       timeStyle:NSDateFormatterShortStyle];
            timeSign  = NSLocalizedString(@"MESSAGE__103", @"Uhr");
        } else if (tourStop.arrival) {
            timeKey   = @"🕙";
            timeValue = [NSDateFormatter localizedStringFromDate:tourStop.arrival 
                                                       dateStyle:NSDateFormatterNoStyle 
                                                       timeStyle:NSDateFormatterShortStyle];
            timeSign  = NSLocalizedString(@"MESSAGE__103", @"Uhr");
        } else if (tourStop.location_id.location_code && 
                   tourStop.location_id.location_code.length > 0) {
            timeKey   = @"📝";
            timeValue = [NSString stringWithFormat:@"%@", tourStop.location_id.location_code];
            timeSign  = @"";
        } else if (tourStop.transport_group_id.task && 
                   tourStop.transport_group_id.task.length > 0) {
            timeKey   = @"📝";
            timeValue = [NSString stringWithFormat:@"%@", tourStop.transport_group_id.task];
            timeSign  = @"";
        } else {
            timeKey   = @"📝";
            timeValue = [NSString stringWithFormat:@"%@", tourStop.departure_id];
            timeSign  = @"";
        }
        if (PFBrandingSupported(BrandingViollier, nil)) {
            aMapAnnotation.title = [NSString stringWithFormat:@"%@",
                                    tourStop.location_id.location_name];
        } else {
            aMapAnnotation.title = [NSString stringWithFormat:@"%@: %@",
                                    tourStop.location_id.city ,
                                    tourStop.location_id.location_name];
        }
        NSMutableString *infoSigns = [NSMutableString string];
        if ([self.tourTask isEqualToString:TourTaskNormalDrive] ||
            PFTourTypeSupported(@"1X1", nil)) {
            if ([[Transport transportsPriceForTourLocation:tourStop.location_id.location_id
                                            transportGroup:tourStop.transport_group_id.transport_group_id
                                    inCtx:self.ctx] floatValue] != 0.00) { 
                [infoSigns appendFormat:@" %@", @"💰"];
            }
            if ((tourStop.infoText.length > 0) ||
                (PFTourTypeSupported(@"0X1", nil) && tourStop.location_id.location_code && tourStop.location_id.location_code.length > 0) ||
                ([[NSSet setWithArray:[[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                          @"transport_group_id.transport_group_id = %lld && "
                                                                          "to_location_id.location_id = %lld && (trace_type_id.code = %@ OR trace_type_id.code = %@) &&"
                                                                          "transport_group_id.info_text != nil && "
                                                                          "transport_group_id.info_text != %@ && "
                                                                          "transport_group_id.info_text != %@ && "
                                                                          "transport_group_id.info_text != %@ && "
                                                                          "transport_group_id.info_text != %@",
                                                                          [tourStop.transport_group_id.transport_group_id longLongValue],
                                                                          [tourStop.location_id.location_id longLongValue], 
                                                                          @"LOAD", @"UNLOAD", @"", @"\n\n\n\n", @"\r\n\r\n\r\n\r\n", @"\n\r\n\r\n\r\n\r"] 
                                                         sortDescriptors:nil 
                                                  inCtx:self.ctx] 
                                      valueForKeyPath:@"transport_group_id"]] count] != 0)) {
                [infoSigns appendFormat:@" %@", @"📲"];
            }
            aMapAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@ %@     ⬆ %i  ⬇ %i ▫ %i ☐ %@", 
                                       timeKey,timeValue, timeSign,
                                       [Transport countOf:Pick forTourDeparture:tourStop ctx:self.ctx],
                                       [Transport countOf:Unit forTourDeparture:tourStop ctx:self.ctx],
                                       [Transport countOf:Pallet forTourDeparture:tourStop ctx:self.ctx],
                                       infoSigns];
        } else { 
            if ([[Transport transportsOpenPriceForTourLocation:tourStop.location_id.location_id
                                                transportGroup:tourStop.transport_group_id.transport_group_id
                                        inCtx:self.ctx] floatValue] != 0.00) { 
                [infoSigns appendFormat:@" %@", @"💰"];
            }
            if ((tourStop.infoText.length > 0) ||
                (PFTourTypeSupported(@"0X1", nil) && tourStop.location_id.location_code && tourStop.location_id.location_code.length > 0) ||
                ([[NSSet setWithArray:[[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                          @"transport_group_id.transport_group_id = %lld && "
                                                                          "to_location_id.location_id = %lld && "
                                                                          "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80)) &&"
                                                                          "transport_group_id.info_text != nil && "
                                                                          "transport_group_id.info_text != %@ && "
                                                                          "transport_group_id.info_text != %@ && "
                                                                          "transport_group_id.info_text != %@ && "
                                                                          "transport_group_id.info_text != %@",
                                                                          [tourStop.transport_group_id.transport_group_id longLongValue],
                                                                          [tourStop.location_id.location_id longLongValue], 
                                                                          @"LOAD", @"UNLOAD", @"", @"\n\n\n\n", @"\r\n\r\n\r\n\r\n", @"\n\r\n\r\n\r\n\r"]  
                                                         sortDescriptors:nil 
                                                  inCtx:self.ctx] 
                                      valueForKeyPath:@"transport_group_id"]] count] != 0)) {
                [infoSigns appendFormat:@" %@", @"📲"];
            }
            TransportTypes pickTypes = Pick;
            TransportTypes leaveTypes = PFBrandingSupported(BrandingBiopartner, nil) ? TransportationUnit : OpenUnit;
            TransportTypes otherTypes = PFBrandingSupported(BrandingBiopartner, nil) ? TransportationPallet: OpenPallet;
            aMapAnnotation.subtitle = [NSString stringWithFormat:@"%@ %@ %@     ⬆ %i  ⬇ %i ▫ %i ☐ %@", 
                                       timeKey,timeValue, timeSign,
                                       [Transport countOf:pickTypes forTourDeparture:tourStop ctx:self.ctx],
                                       [Transport countOf:leaveTypes forTourDeparture:tourStop ctx:self.ctx],
                                       [Transport countOf:otherTypes forTourDeparture:tourStop ctx:self.ctx],
                                       infoSigns];
        }
        if ([tourStop.currentTourStatus intValue] == 50 || [tourStop.currentTourStatus intValue] == 60) {
			annotationView.pinColor       = MKPinAnnotationColorGreen;
		}else{
			annotationView.pinColor       = MKPinAnnotationColorRed;
		}
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		annotationView.canShowCallout = YES;
	}
	annotationView.annotation = aMapAnnotation;
	return [annotationView autorelease];
}

- (void)mapView:(MKMapView *)aMapView annotationView:(MKAnnotationView *)aMapAnnotation calloutAccessoryControlTapped:(UIControl *)aControl {
    Departure *tourStop = (Departure *)[self.ctx objectWithID:(NSManagedObjectID *)((DSPF_TourMapAnnotation *)aMapAnnotation.annotation).item];
    if ([aMapAnnotation.annotation.subtitle rangeOfString:@"📲"].location != NSNotFound) {
        DSPF_LocationInfo *dspf_LocationInfo	= [[[DSPF_LocationInfo alloc] initWithNibName:@"DSPF_LocationInfo" bundle:nil] autorelease];
        if (PFBrandingSupported(BrandingViollier, nil)) {
            dspf_LocationInfo.title				= tourStop.location_id.code;
        } else {
            dspf_LocationInfo.title				= tourStop.location_id.location_name;
        }
        dspf_LocationInfo.location              = tourStop.location_id;
        dspf_LocationInfo.departure             = tourStop;
        dspf_LocationInfo.tourTask              = self.tourTask;
        dspf_LocationInfo.delegate              = self;
        [self.navigationController pushViewController:dspf_LocationInfo animated:YES];
    } else {
        if (self.svr_LocationManager.isRunning &&
            [self.tourTask isEqualToString:TourTaskNormalDrive] && 
            !(aMapAnnotation.annotation.coordinate.latitude  == 0.000000 && 
              aMapAnnotation.annotation.coordinate.longitude == 0.000000)) {
                CLLocation        *pinLocation = [[CLLocation alloc] 
                                                  initWithLatitude:aMapAnnotation.annotation.coordinate.latitude 
                                                  longitude:aMapAnnotation.annotation.coordinate.longitude];
                CLLocationDistance distance	   = [pinLocation distanceFromLocation:self.svr_LocationManager.rcvLocation];
                [pinLocation release];
                if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withDistanceCheck"] intValue] > 0) {
                    if (distance > [[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withDistanceCheck"] doubleValue]) { 
                        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_025", @"GPS-Koordinaten") 
                                       messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_008", @"%@\n%@\n%@ %@\n\nEntfernung: %4.3f km !"), 
                                                    tourStop.location_id.location_name, 
                                                    tourStop.location_id.street, 
                                                    tourStop.location_id.zip, 
                                                    tourStop.location_id.city,
                                                    (distance / 1000)]
                                              item:[tourStop objectID]
                                          delegate:self];
                        return;
                    }
                }
            }        
        [self didSelectTourLocationForDeparture:tourStop];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)aMapView viewForOverlay:(id )aOverlay {
	MKPolylineView *routeView = [[[MKPolylineView alloc] initWithPolyline:aOverlay] autorelease];
	routeView.fillColor   = [UIColor darkGrayColor];
	routeView.strokeColor = [UIColor darkGrayColor];
	routeView.lineWidth   = 5;
	return routeView;
}

- (void)updatePinForTruck { 
	if (self.svr_LocationManager.isRunning) { 
        if (self.pinForTruck) {
            [self.mapView removeAnnotation:self.pinForTruck];
        }
		CLLocationCoordinate2D location = self.svr_LocationManager.rcvLocation.coordinate;
		self.pinForTruck = [DSPF_TourMapAnnotation annotationWithCoordinate:location 
                                                                       item:[NSIndexPath indexPathForRow:0 inSection:0] 
                                                                      title:NSLocalizedString(@"TITLE_005", @"Fahrzeug")];
		[self.mapView addAnnotation:self.pinForTruck];
	}
}

- (void)switchViews {
    
    BOOL switchToMap = self.mapView.hidden;
    
    if (self.mapView.hidden) { 
        [self updatePinForTruck]; 
        if (!self.tourMapPointsDidLoad) {
            DSPF_Activity  *showActivity   = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_026", @"Route wird geladen") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
            [DPHUtilities waitForAlertToShow:0.236f];
            [self drawAllMapPoints]; 
            [showActivity closeActivityInfo];
            [showActivity release];
        } 
        if (self.svr_LocationManager.isRunning) {
            MKCoordinateRegion region;
            region.center = self.svr_LocationManager.rcvLocation.coordinate;
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withMapSpan"] intValue] > 0) { 
                double r = ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withMapSpan"] doubleValue] / 80.00);
                MKCoordinateSpan span = {r, r};
                region.span    = span;
            } else {
                MKCoordinateSpan span = {0.125, 0.125};
                region.span    = span;
            }
            [self.mapView setCenterCoordinate:region.center animated:NO];
            [self.mapView setRegion:region animated:NO];
        }
        [self.mapView setMapType:MKMapTypeStandard];
        
        if (!PFBrandingSupported(BrandingTechnopark, nil))
        self.navigationItem.rightBarButtonItem =
            [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"notepad_white" ofType:@"png"]]
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(switchViews)] autorelease];
    } else {
        
        if (!PFBrandingSupported(BrandingTechnopark, nil))
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"map_white" ofType:@"png"]]
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(switchViews)] autorelease];        
    }
    UIViewAnimationTransition transition = UIViewAnimationTransitionCurlUp;
    if (self.mapView.hidden) {
        transition = UIViewAnimationTransitionCurlDown;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.618];
    [UIView setAnimationTransition:transition forView:[self view] cache:NO];
    self.mapView.hidden   = !self.mapView.hidden;
    self.tableView.hidden = !self.tableView.hidden;
	[UIView commitAnimations];
    
    //Custom behavior implementation
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        if (switchToMap)
        {
            self.navigationItem.leftBarButtonItem = nil;
        }
        else
        {
            self.navigationItem.leftBarButtonItem = self.editButtonItem;
        }
    }
}

#pragma mark - Table view data source

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    HermesAppDelegate *appDelegate = (HermesAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.workspace.sideBarGestureEnabled = !editing;
    if (!editing)
        [self sendReorderToServer];
    else
        hasReorderChanges = NO;
    [super setEditing:editing animated:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.subTitle) {
        return 1;
    }
    return self.tourDeparturesAtWork.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.subTitle) {
        return self.tourDeparturesAtWork.fetchedObjects.count;
    }
    return [[self.tourDeparturesAtWork.sections objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section {
    
    if (_customHeader)
        return _customHeader.frame.size.height;
    
    if (self.subTitle) {
        return 24.0;
    }
    return 0.0;
}

- (UIView *)tableView:(UITableView *)aTableView viewForHeaderInSection:(NSInteger)aSection {
    
    if (_customHeader)
        return _customHeader;
    
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    customView.backgroundColor = [UIColor clearColor];
    if (!self.subTitle) {
        return customView;
    }
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, aTableView.frame.size.width, 24.0)] autorelease];
    headerLabel.opaque = YES;
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    headerLabel.alpha = self.navigationController.navigationBar.alpha;
    if (PFBrandingSupported(BrandingCCC_Group, BrandingBiopartner, BrandingViollier, nil)) {
        headerLabel.font  = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:16];
    } else {
        headerLabel.font  = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    }
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = self.subTitle;
    [customView setFrame: CGRectMake(0.0, 0.0, headerLabel.frame.size.width, headerLabel.frame.size.height)];
    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        return 0.0;
    
    return 1.0; // force a "separator" for the last cell
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)aSection {
    
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 1.0)] autorelease];
    [customView setBackgroundColor:self.tableView.separatorColor];
    return customView;
}

- (void)accessoryButtonTapped:(id)sender event:(id)event {
    NSIndexPath *indexPath = [self.tableView
                              indexPathForRowAtPoint:[[[event allTouches] anyObject] locationInView:self.tableView]];
    if (indexPath != nil) {
        [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    Departure *tmpDeparture = [self tourDeparture:indexPath];
    NSNumber *dLocationId = tmpDeparture.location_id.location_id;
    NSNumber *dTransportGroupId = tmpDeparture.transport_group_id.transport_group_id;
    
    [cell setTourTask:self.tourTask];
    if (self.showOptionalDepartures && [tmpDeparture.currentTourBit isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        ((UITableViewCell *)cell).accessoryType = UITableViewCellAccessoryNone;
        UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeContactAdd]; 
        [accessoryButton addTarget:self action:@selector(accessoryButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        ((UITableViewCell *)cell).accessoryView = accessoryButton;
    } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withSwitchToApp"] boolValue] &&
               [self.tourTask isEqualToString:TourTaskNormalDrive] && !PFBrandingSupported(BrandingTechnopark, nil)) {
        ((UITableViewCell *)cell).accessoryView = nil;
        ((UITableViewCell *)cell).accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        ((UITableViewCell *)cell).accessoryView = nil;
        ((UITableViewCell *)cell).accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setPickCountForTourLocation:[Transport countOf:Pick forTourDeparture:tmpDeparture ctx:self.ctx]];
    
    if ([self.tourTask isEqualToString:TourTaskNormalDrive] || PFTourTypeSupported(@"1X1", nil)) {
        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            [cell setPickCountForTourLocation:[Transport countOf:Pick forTourDeparture:tmpDeparture ctx:self.ctx]];
            [cell setUnitCountForTourLocation:[Transport countOf:RollContainer|Unit|Pallet forTourDeparture:tmpDeparture ctx:self.ctx]];
            [cell setPalletCountForTourLocation:0];
            [cell setHasPaymentOnDelivery:([[Transport transportsPriceForTourLocation:dLocationId transportGroup:dTransportGroupId
                                                               inCtx:self.ctx] floatValue] != 0.00)];
        } else {
            [cell setUnitCountForTourLocation:[Transport countOf:RollContainer|Unit forTourDeparture:tmpDeparture ctx:self.ctx]];
            [cell setPalletCountForTourLocation:[Transport countOf:Pallet forTourDeparture:tmpDeparture ctx:self.ctx]];
            [cell setHasPaymentOnDelivery:([[Transport transportsPriceForTourLocation:dLocationId transportGroup:dTransportGroupId inCtx:self.ctx] floatValue] != 0.00)];
        }
        if (tmpDeparture.infoText && tmpDeparture.infoText.length > 0) {
            [cell setHasTransportGroupInfos:YES];
        } else {
            if (PFTourTypeSupported(@"0X1", nil)) {
                [cell setHasTransportGroupInfos:(tmpDeparture.location_id.location_code && tmpDeparture.location_id.location_code.length > 0)];
            } else {
                [cell setHasTransportGroupInfos:([[NSSet setWithArray:
                                                   [[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                                        @"transport_group_id.transport_group_id = %lld && "
                                                                                        "to_location_id.location_id = %lld && (trace_type_id.code = %@ OR trace_type_id.code = %@) "
                                                                                        "&& transport_group_id.info_text != nil && "
                                                                                        "transport_group_id.info_text != %@ && "
                                                                                        "transport_group_id.info_text != %@ && "
                                                                                        "transport_group_id.info_text != %@ && "
                                                                                        "transport_group_id.info_text != %@",
                                                                                        [dTransportGroupId longLongValue],
                                                                                        [dLocationId longLongValue],
                                                                                        @"LOAD", @"UNLOAD", @"", @"\n\n\n\n", @"\r\n\r\n\r\n\r\n", @"\n\r\n\r\n\r\n\r"]
                                                                       sortDescriptors:nil
                                                                inCtx:self.ctx]
                                                    valueForKeyPath:@"transport_group_id"]] count] != 0)];
            }
        }
    } else {
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            [cell setUnitCountForTourLocation:[Transport countOf:TransportationUnit forTourDeparture:tmpDeparture ctx:self.ctx]];
            [cell setPalletCountForTourLocation:[Transport countOf:Pallet forTourDeparture:tmpDeparture ctx:self.ctx]];
        } else {
            [cell setUnitCountForTourLocation:[Transport countOf:OpenUnit forTourDeparture:tmpDeparture ctx:self.ctx]];
            [cell setPalletCountForTourLocation:[Transport countOf:OpenPallet forTourDeparture:tmpDeparture ctx:self.ctx]];
        }
        [cell setHasPaymentOnDelivery:([[Transport transportsOpenPriceForTourLocation:dLocationId
                                                                       transportGroup:dTransportGroupId
                                                               inCtx:self.ctx] floatValue] != 0.00)];
        if (tmpDeparture.infoText && tmpDeparture.infoText.length > 0) {
            [cell setHasTransportGroupInfos:YES];
        } else {
            if (PFTourTypeSupported(@"0X1", nil)) {
                [cell setHasTransportGroupInfos:(tmpDeparture.location_id.location_code && tmpDeparture.location_id.location_code.length > 0)];
            } else {
                [cell setHasTransportGroupInfos:([[NSSet setWithArray:
                                                   [[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                                        @"transport_group_id.transport_group_id = %lld && "
                                                                                        "to_location_id.location_id = %lld && "
                                                                                        "(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80)) &&"
                                                                                        "transport_group_id.info_text != nil && "
                                                                                        "transport_group_id.info_text != %@ && "
                                                                                        "transport_group_id.info_text != %@ && "
                                                                                        "transport_group_id.info_text != %@ && "
                                                                                        "transport_group_id.info_text != %@",
                                                                                        [dTransportGroupId longLongValue],
                                                                                        [dLocationId longLongValue],
                                                                                        @"LOAD", @"UNLOAD", @"", @"\n\n\n\n", @"\r\n\r\n\r\n\r\n", @"\n\r\n\r\n\r\n\r"]
                                                                       sortDescriptors:nil
                                                                inCtx:self.ctx]
                                                    valueForKeyPath:@"transport_group_id"]] count] != 0)];
            }
        }
    }
    // [DSPF_TourTableViewCell setTourDeparture] sets up all subviews ...
    [cell setTourDeparture:tmpDeparture];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell  = (DSPF_TourTableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"DSPF_TourList"];
    if (!cell) {
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            cell = [[[DSPF_TourTableViewCell_biopartner alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_TourList"] autorelease];
        } else if (PFBrandingSupported(BrandingViollier, nil)) {
            cell = [[[DSPF_TourTableViewCell_viollier alloc]   initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_TourList"] autorelease];
        } else if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            cell = [[[DSPF_TourTableViewCell_CCC alloc]        initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_TourList"] autorelease];
        } else if (PFBrandingSupported(BrandingTechnopark, nil)) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_TourTableViewCell_technopark" owner:self options:nil] objectAtIndex:0];
        } else {
            cell = [[[DSPF_TourTableViewCell alloc]            initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DSPF_TourList"] autorelease];
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (PFBrandingSupported(BrandingViollier,BrandingTechnopark, nil)) {
        return 88;
    }
    return aTableView.rowHeight;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	DSPF_LocationInfo *dspf_LocationInfo	= [[[DSPF_LocationInfo alloc] initWithNibName:@"DSPF_LocationInfo" bundle:nil] autorelease];
    if (PFBrandingSupported(BrandingViollier, nil)) {
        dspf_LocationInfo.title             = [self tourDeparture:indexPath].location_id.code;
    } else {
        dspf_LocationInfo.title             = [self tourDeparture:indexPath].location_id.location_name;
    }
	dspf_LocationInfo.location              = [self tourDeparture:indexPath].location_id;
    dspf_LocationInfo.departure             = [self tourDeparture:indexPath];
    dspf_LocationInfo.tourTask              = self.tourTask;
    dspf_LocationInfo.delegate              = self;
	[self.navigationController pushViewController:dspf_LocationInfo animated:YES];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Departure *tourStop = [self tourDeparture:indexPath];
	if (self.svr_LocationManager.isRunning && [self.tourTask isEqualToString:TourTaskNormalDrive] && 
        !([tourStop.location_id.latitude doubleValue]  == 0.000000 && [tourStop.location_id.longitude doubleValue] == 0.000000)) {
            CLLocation *selectedLocation = [[CLLocation alloc] 
                                            initWithLatitude:[tourStop.location_id.latitude  doubleValue] 
                                            longitude:[tourStop.location_id.longitude doubleValue]];
            CLLocationDistance distance	 = [selectedLocation distanceFromLocation:self.svr_LocationManager.rcvLocation];
            [selectedLocation release]; 
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withDistanceCheck"] intValue] > 0) {
                if (distance > [[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withDistanceCheck"] doubleValue] && !PFBrandingSupported(BrandingTechnopark, nil)) {
                    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_025", @"GPS-Koordinaten") 
                                   messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_008", @"%@\n%@\n%@ %@\n\nEntfernung: %4.3f km !"), 
                                                NotNullString(tourStop.location_id.location_name),
                                                NotNullString(tourStop.location_id.street),
                                                NotNullString(tourStop.location_id.zip),
                                                NotNullString(tourStop.location_id.city),
                                                (distance / 1000)]
                                          item:[tourStop objectID]
                                      delegate:self];
//                  ((UITableViewCell *)[aTableView cellForRowAtIndexPath:indexPath]).selected = NO;
                    return;
                }
            }
        }
	[self didSelectTourLocationForDeparture:tourStop];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        if (self.tourDeparturesAtWork.fetchedObjects.count < 1)
            return YES;
        
        if (indexPath.row == 0)
        {
            Departure *firstDeparture = self.tourDeparturesAtWork.fetchedObjects.firstObject;
            if ([firstDeparture.transport_group_id.task isEqualToString:@"START01"])
                return NO;
        }
        else if (indexPath.row == [self.tableView numberOfRowsInSection:0] - 1)
        {
            Departure *lastDeparture = self.tourDeparturesAtWork.fetchedObjects.lastObject;
            if ([lastDeparture.transport_group_id.task isEqualToString:@"END01"])
                return NO;
        }
        
        return YES;
    }
    
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]] ||
        [indexPath isEqual:[NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0] - 1) inSection:0]]) {
        return NO;
    }
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    // Moves are only allowed for intermediate wayPoints 
    if (proposedDestinationIndexPath.row < 1 && (![self.tableView.dataSource tableView:self.tableView canMoveRowAtIndexPath:proposedDestinationIndexPath])) {
        return [NSIndexPath indexPathForRow:1 
                                  inSection:proposedDestinationIndexPath.section];
    } else if (proposedDestinationIndexPath.row > ([self.tableView numberOfRowsInSection:proposedDestinationIndexPath.section] - 2) && (![self.tableView.dataSource tableView:self.tableView canMoveRowAtIndexPath:proposedDestinationIndexPath]))  {
        return [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:proposedDestinationIndexPath.section] - 2)
                                  inSection:proposedDestinationIndexPath.section];
    }    
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath { 
    if (fromIndexPath.section == toIndexPath.section) { 
        userDrivenDataModelChange = YES;
        NSMutableArray *selectedArray  = [NSMutableArray arrayWithArray:[self.tourDeparturesAtWork fetchedObjects]];
        Departure      *selectedObject = (Departure *)[self.tourDeparturesAtWork objectAtIndexPath:fromIndexPath];
        [selectedArray removeObjectAtIndex:fromIndexPath.row];
        [selectedArray insertObject:selectedObject atIndex:toIndexPath.row];
        for (NSInteger i = 0; i < selectedArray.count; i++) { 
            ((Departure *)[selectedArray objectAtIndex:i]).sequence = [NSNumber numberWithInt:i];
        }
        [self.ctx saveIfHasChanges];
        self.tourMapPointsDidLoad = NO;
        userDrivenDataModelChange = NO;
        hasReorderChanges = YES;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath { 
    return NO; 
}


#pragma mark - Fetched results controller delegate

/*
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if (userDrivenDataModelChange) return;
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if (userDrivenDataModelChange) return;
    UITableViewRowAnimation    rowAnimation = UITableViewRowAnimationNone;
    if (self.tableView.window) rowAnimation = UITableViewRowAnimationFade;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (userDrivenDataModelChange) return;
    
    if (type == NSFetchedResultsChangeUpdate && [((Departure *)anObject).currentTourStatus intValue] > 65) {
            type = NSFetchedResultsChangeDelete;
    }
    
    UITableViewRowAnimation    rowAnimation = UITableViewRowAnimationNone;
    if (self.tableView.window) rowAnimation = UITableViewRowAnimationFade;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:rowAnimation];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:rowAnimation];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:rowAnimation];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:rowAnimation];
            break;
    }
}*/

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSError *error = nil;
    if (self.tourDeparturesAtWork == controller && ![controller performFetch:&error]) {
        NSLog(@"Could not update the list of tour stops");
    };
    [self.tableView reloadData];
    self.tourMapPointsDidLoad = NO;
}


- (void)dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex { 
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) { 
        if ([item isKindOfClass:[NSManagedObjectID class]]) {
            [self didSelectTourLocationForDeparture:(Departure *)[self.ctx objectWithID:item]];
        } else if ([item isKindOfClass:[NSString class]]) {
            if ([item isEqualToString:@"NO DATA FOUND"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
	}
}

- (void)dspf_TourStopTransportGroups:(DSPF_TourStopTransportGroups *)sender didFinishTourStopForItem:(id)item {
    [self dspf_TourLocation:nil didFinishTourForItem:(id )item];
}

- (void)dspf_LocationInfo:(DSPF_LocationInfo *)sender didFinishTourForItem:(id )item {
    [self dspf_TourLocation:nil didFinishTourForItem:(id )item];
}

- (void)updateTourWithOptionalDeparturesFollowingDeparture:(Departure *)aDeparture { 
    Departure *tmpReference = [[self.tourDeparturesAtWork fetchedObjects] lastObject];
    if (tmpReference) { 
        NSArray		   *sortDescriptors = [self departureSortDescriptorsAscending:YES];
        for (Departure *optional in [Departure withPredicate:
                                     [NSPredicate predicateWithFormat:@"tour_id.tour_id = %i && dayOfWeek = %i && onDemand = YES && "
                                      "currentTourBit = NO && (confirmed = YES || sequence > %i && " 
                                      "(0 == SUBQUERY(location_id.departure_id, $d, $d.currentTourBit = YES && $d.currentTourStatus < 50).@count))",
                                      [tmpReference.tour_id.tour_id intValue],
                                      [tmpReference.dayOfWeek intValue],
                                      [((Departure *)aDeparture).sequence intValue]] 
                                                       sortDescriptors:sortDescriptors inCtx:self.ctx]) {
            if ([Transport countOf:Pallet|Unit|Pick forTourDeparture:optional ctx:self.ctx] > 0 || [optional.confirmed boolValue]) {
                NSArray *thisLoop = [Departure withPredicate:
                                     [NSPredicate predicateWithFormat:@"tour_id.tour_id = %i && dayOfWeek = %i && location_id.location_id = %i && "
                                      "(0 == SUBQUERY(location_id.departure_id, $d, $d.currentTourBit = YES && $d.currentTourStatus < 50).@count)",
                                      [optional.tour_id.tour_id intValue],
                                      [optional.dayOfWeek intValue],
                                      [optional.location_id.location_id intValue]] 
                                                       sortDescriptors:nil inCtx:self.ctx];
                if ((thisLoop && thisLoop.count != 0) || [optional.confirmed boolValue]) {
                    optional.currentTourBit    = [NSNumber numberWithBool:YES];
                    optional.currentTourStatus = [NSNumber numberWithInt:00];
                }
            }
        }
        [self.ctx saveIfHasChanges]; 
    }
}

- (void)updateTour {
    [self updateTourWithOptionalDeparturesFollowingDeparture:nil];
    [self.tableView reloadData];
    if (self.mapView.window && !self.mapView.hidden) {
        [self drawAllMapPoints];
    }
}

- (void)dspf_TourLocation:(DSPF_TourLocation *)sender didFinishTourForItem:(Departure *)departure {
    // ensure the process sequence because "switchFilterForTourDeparturesAtWork" could change the predicate for "tourDeparturesAtWork"
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tourMapPointsDidLoad = NO;
        if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
            NSNumber *locationId = departure.location_id.location_id;
            if ((PFBrandingSupported(BrandingCCC_Group, nil) &&
                 [Transport countOf:OpenUnit|OpenPallet forTourLocation:locationId transportGroup:nil ctx:self.ctx] > 0) ||
                (!PFBrandingSupported(BrandingCCC_Group, nil) && [Transport countOf:Pick forTourDeparture:departure ctx:self.ctx] > 0))
            {
                if ([departure.currentTourStatus intValue] != 15) {
                    departure.currentTourStatus = [NSNumber numberWithInt:15];
                    [self.ctx saveIfHasChanges];
                }
            } else {
                for (Departure *ready in [NSArray arrayWithArray:[self.tourDeparturesAtWork fetchedObjects]]) {
                    if ([ready.currentTourStatus intValue] == 15) {
                        NSNumber *locationId = ready.location_id.location_id;
                        if ((PFBrandingSupported(BrandingCCC_Group, nil) &&
                             [Transport countOf:OpenUnit|OpenPallet forTourLocation:locationId transportGroup:nil ctx:self.ctx] == 0) ||
                            (!(PFBrandingSupported(BrandingCCC_Group, nil)) &&
                             [Transport countOf:Pick forTourDeparture:ready ctx:self.ctx] == 0))
                        {
                            ready.currentTourStatus = [NSNumber numberWithInt:30];
                        }
                    } else if ([ready.currentTourStatus intValue] == 20) {
                        ready.currentTourStatus = [NSNumber numberWithInt:30];
                    }
                }
                if ([departure.currentTourStatus intValue] != 20) {
                    departure.currentTourStatus = [NSNumber numberWithInt:20];
                }
                [self.ctx saveIfHasChanges];
            }
            [self updateTourWithOptionalDeparturesFollowingDeparture:nil];
        } else if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
            NSNumber *locationId = departure.location_id.location_id;
            NSNumber *transportGroupId = departure.transport_group_id.transport_group_id;
            if ([Transport countOf:Pallet|Unit|Pick forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx] > 0){
                if ([departure.currentTourStatus intValue] != 45) {
                    departure.currentTourStatus = [NSNumber numberWithInt:45];
                    if (PFBrandingSupported(BrandingTechnopark, nil))
                        departure.canceled = @YES;
                    [self.ctx saveIfHasChanges];
                }
            } else {
                Departure *lastTourDeparture = [Departure lastTourDepartureInCtx:self.ctx];
                for (Departure *ready in [NSArray arrayWithArray:[self.tourDeparturesAtWork fetchedObjects]]) {
                    if (![ready isEqual:lastTourDeparture] && [ready.currentTourStatus intValue] == 60) {
                        ready.currentTourStatus = [NSNumber numberWithInt:65];
                    } else if ([ready.currentTourStatus intValue] == 50) {
                        ready.currentTourStatus = [NSNumber numberWithInt:60];
                    } else if ([ready.currentTourStatus intValue] == 45) {
                        if ([Transport countOf:Pallet|Unit|Pick forTourLocation:ready.location_id.location_id
                                transportGroup:ready.transport_group_id.transport_group_id ctx:self.ctx] == 0) {
                            ready.currentTourStatus = [NSNumber numberWithInt:60];
                        }
                    }
                }
                if ([departure.currentTourStatus intValue] != 50) {
                    if (PFBrandingSupported(BrandingTechnopark, nil))
                        departure.currentTourStatus = [NSNumber numberWithInt:70];
                    else
                        departure.currentTourStatus = [NSNumber numberWithInt:50];
                }
                [self.ctx saveIfHasChanges];
            }
            [self updateTourWithOptionalDeparturesFollowingDeparture:departure];
        }
        if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
            for (Departure *ready in [NSArray arrayWithArray:[self.tourDeparturesAtWork fetchedObjects]]) {
                // prevent TourTaskAdjustingOnly after loading started
                if ([ready.currentTourStatus intValue] < 10) {
                    ready.currentTourStatus = [NSNumber numberWithInt:10];
                }
            }
            [self.ctx saveIfHasChanges];
        } else if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
            for (Departure *ready in [NSArray arrayWithArray:[self.tourDeparturesAtWork fetchedObjects]]) {
                // clean up the list (70 = hidden)
                if ([ready.currentTourStatus intValue] == 65) {
                    ready.currentTourStatus = [NSNumber numberWithInt:70];
                } 
                // prevent TourTaskLoadingOnly after the tour has started
                else if ([ready.currentTourStatus intValue] < 40) {
                    ready.currentTourStatus = [NSNumber numberWithInt:40];
                }
            }
            [self.ctx saveIfHasChanges];
        }
        [self.tableView reloadData];
        if (self.mapView.window && !self.mapView.hidden) {
            [self drawAllMapPoints];
        }
    });
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateTour" object:nil];
}


- (void)dealloc {
    mapView.delegate = nil;
    
    [transportsFetchResultsController release];
	[ctx	release];
	[tourMapLines			release];
    [tourMapPoints			release];
    [tourDeparturesAtWork	release];
    [tourTask               release];
    [pinForTruck            release];
	[mapView				release];
    [subTitle               release];
	[svr_LocationManager	release];
    [tableView				release];
    [_customHeader          release];
    [super dealloc];
}

#pragma mark -

- (NSArray *) departureSortDescriptorsAscending:(BOOL) ascendingSort {
    // synchronize the sorting with Control Center and tour management
    return @[[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:ascendingSort],
             [NSSortDescriptor sortDescriptorWithKey:@"arrivalDate" ascending:ascendingSort],
             [NSSortDescriptor sortDescriptorWithKey:@"arrival" ascending:ascendingSort],
             [NSSortDescriptor sortDescriptorWithKey:@"departureDate" ascending:ascendingSort],
             [NSSortDescriptor sortDescriptorWithKey:@"departure" ascending:ascendingSort],
             [NSSortDescriptor sortDescriptorWithKey:@"location_id.zip" ascending:ascendingSort],
             [NSSortDescriptor sortDescriptorWithKey:@"location_id.location_id" ascending:ascendingSort]];
}

- (void) sendReorderToServer
{
    if (hasReorderChanges)
    {
        Departure *lastDepartureOnTour = [self.tourDeparturesAtWork.fetchedObjects lastObject];
        
        NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:@"reorder" traceType:TraceTypeValueReorder
                                                                fromDeparture:lastDepartureOnTour toLocation:lastDepartureOnTour.location_id];
        
        NSMutableDictionary *reorderDict = [NSMutableDictionary new];
        NSArray *departures = self.tourDeparturesAtWork.fetchedObjects;
        for (int i = 0; i< departures.count; ++i) {
            Departure* currentDeparture = departures[i];
            [reorderDict setObject:[NSNumber numberWithInt:i] forKey:currentDeparture.transport_group_id.task];
        }
        
        [currentTransport setValue:[@{@"reorder":reorderDict} dictionaryByAddingEntriesFromDictionary:[currentTransport valueForKey:@"userInfo"]] forKey:@"userInfo"];
        
        [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
        [self.ctx saveIfHasChanges];
        
        [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
    }
}


@end

