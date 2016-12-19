//
//  DSPF_Menu.m
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Menu.h"
#import "DSPF_Tour.h"
#import "DSPF_TourStopTransportGroups.h"
#import "User.h"
#import "Departure.h"
#import "DSPF_QuitLoading.h"
#import "DSPF_Finish.h"
#import "DSPF_TransportUnitItem.h"
#import "DSPF_LoadTransportItem.h"
#import "DSPF_Synchronisation.h"
#import "DSPF_evoViewer.h"
#import "DSPF_Suspend.h"
#import "DSPF_Error.h"

NSString * const MenuUserKey = @"MenuUserKey";

@interface DSPF_Menu()
@property (nonatomic, retain) User *currentUser;
@end

@implementation DSPF_Menu

@synthesize menuItems;
@synthesize menuGroups;
@synthesize menuForDriver;
@synthesize currentTruck;
@synthesize currentTour;
@synthesize currentUser;
@synthesize jumpThroughOption;
@synthesize navigationController;

#pragma mark - Jump Through Logic

- (void) jumpThrough
{
    if ([jumpThroughOption isEqualToString:@"Drive"])
    {
        DSPF_Tour *dspf_Tour = [[[DSPF_Tour alloc] init] autorelease];
        dspf_Tour.title      = NSLocalizedString(@"TITLE_009", @"Fahren");
        dspf_Tour.subTitle   = [NSString stringWithFormat:@"%@ (%@)", self.currentTour.code,
                                [NSUserDefaults currentStintDayOfWeekName]];
        dspf_Tour.tourTask   = TourTaskNormalDrive;
        [self.navigationController pushViewController:dspf_Tour animated:YES];
    }
}

#pragma mark - Initialization

- (Truck *)currentTruck {
    if (!currentTruck) {
        if ([[NSUserDefaults currentUserID] intValue] == 0) return currentTruck; // nil
        if ([[NSUserDefaults currentTruckId] intValue] != 0) {
            NSArray *tmpTrucks = [Truck withPredicate:[Truck withTruckId:[NSUserDefaults currentTruckId]] inCtx:ctx()];
            if (tmpTrucks && tmpTrucks.count > 0) {
                currentTruck = [[tmpTrucks objectAtIndex:0] retain];
            } else {
                // there must be a problem with [NSUserDefaults currentTruckId]
                // if it is fixable here then everything works correctly
                currentTruck = [[[Truck withPredicate:[Truck withDeviceId:PFDeviceId()] inCtx:ctx()] lastObject] retain];
                [NSUserDefaults setCurrentTruckId:currentTruck.truck_id];
            }
        } else {
            currentTruck = [[[Truck withPredicate:[Truck withDeviceId:PFDeviceId()] inCtx:ctx()] lastObject] retain];
            [NSUserDefaults setCurrentTruckId:currentTruck.truck_id];
        }
    }
	return currentTruck;
}

- (Tour *)currentTour {
	if (!currentTour) {
        NSNumber *currentTourId = [NSUserDefaults currentTourId];
		if ([currentTourId intValue] != 0) {
            if ( ([NSUserDefaults isRunningWithTourAdjustment] || PFTourTypeSupported(@"0X1", @"0X0", nil)) && [currentTourId intValue] != 0) {
                NSArray *tmpTours = [Tour withPredicate:[Tour withTourId:currentTourId] inCtx:ctx()];
                if (tmpTours && tmpTours.count > 0) {
                    currentTour  = [[tmpTours objectAtIndex:0] retain];
                } else {
                    // there must be a problem with [NSUserDefaults currentTourId]
                    // if it is fixable here then everything works correctly
                    Departure *tmpDeparture = [[Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES"] inCtx:ctx()] lastObject];
                    [NSUserDefaults setCurrentTourId:tmpDeparture.tour_id.tour_id];
                    [NSUserDefaults setCurrentStintDayOfWeek:tmpDeparture.dayOfWeek];
                    currentTour  = [[[Tour withPredicate:[Tour withTourId:[NSUserDefaults currentTourId]] inCtx:ctx()] objectAtIndex:0] retain];
                }
            } else { 
                
                if (PFBrandingSupported(BrandingTechnopark, nil))
                {
                    Truck *currentTruckObj = [Truck truckWithTruckID:[NSUserDefaults currentTruckId] inCtx:ctx()];
                    NSManagedObjectID *yourManagedObjectID = [currentTruckObj objectID];
                    int truck_PK = [[[[[yourManagedObjectID URIRepresentation] absoluteString] lastPathComponent] substringFromIndex:1] intValue];
                    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tour_id" ascending:YES]];
                    NSArray* toursArray = [Tour withPredicate:[NSPredicate predicateWithFormat:@"truck_id == %d", truck_PK] sortDescriptors:sortDescriptors inCtx:ctx()];
                    currentTour = [toursArray lastObject];
                }
                else
                    currentTour  = [[[Tour withPredicate:[Tour withDeviceId:PFDeviceId()] inCtx:ctx()] lastObject] retain];
                
                // DSPF_Synchronisation should be able to switch the tour by clearing the depending NSUserDefaults.
                if (![NSUserDefaults currentStintDayOfWeek]) {
                    [NSUserDefaults setCurrentStintDayOfWeek:[DPHDateFormatter dayOfWeekFromDate:[NSDate date]]];
                    [NSUserDefaults setCurrentStintDayOfWeekName:[DPHDateFormatter dayOfWeekNameFromDate:[NSDate date]]];
				}
                [NSUserDefaults setCurrentTourId:currentTour.tour_id];
            }
		}
	}
	return currentTour;
}

- (NSMutableArray *)menuGroups {
    if (!menuGroups) {
        menuGroups = [[NSMutableArray array] retain];
	}
    return menuGroups;
}

- (NSMutableDictionary *)menuItems {
    // HermesApp_SYSVAL_RUN_withTourAdjustment
    if (!menuItems) {
        menuItems = [[NSMutableDictionary dictionary] retain];
        if ([[NSUserDefaults currentUserID] intValue] != 0 && PFTourTypeSupported(@"0X0", nil)) {
            // momentarily just used by ETA
            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_014", @"Versandeinheiten"), nil]
                          forKey:NSLocalizedString(@"TITLE_015", @"Verdichten")];
            [self.menuGroups addObject:NSLocalizedString(@"TITLE_015", @"Verdichten")];
        }
        if (self.menuForDriver) {
            if ([[NSUserDefaults currentUserID] intValue] != 0) { 
                if (PFTourTypeSupported(@"1XX", nil)) {
                    if ([NSUserDefaults isRunningWithTourAdjustment]) {
                        [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_007", @"Anpassen"),
                                                                       NSLocalizedString(@"TITLE_008", @"Laden"), 
                                                                       NSLocalizedString(@"TITLE_009", @"Fahren"), 
                                                                       NSLocalizedString(@"TITLE_010", @"Abschliessen"), nil] 
                                      forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                              [NSUserDefaults currentStintDayOfWeekName]]];
                    } else {
                        [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_009", @"Fahren"), 
                                                                       NSLocalizedString(@"TITLE_010", @"Abschliessen"), nil] 
                                      forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                              [NSUserDefaults currentStintDayOfWeekName]]];
                    }
                } else if (PFTourTypeSupported(@"1X1", nil)) {
                    if ([[NSUserDefaults currentStintDidQuitLoading] boolValue] != YES) {
                        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
                            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_008", @"Laden"), nil]
                                          forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                                  [NSUserDefaults currentStintDayOfWeekName]]];
                        } else {
                            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_008", @"Laden"),
                                                                           NSLocalizedString(@"TITLE_114", @"Laden beenden"), nil]
                                          forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                                  [NSUserDefaults currentStintDayOfWeekName]]];
                        }
                    } else {
                        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
                            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_009", @"Fahren"), nil]
                                          forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                                  [NSUserDefaults currentStintDayOfWeekName]]];
                        } else {
                            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_009", @"Fahren"),
                                                                           NSLocalizedString(@"TITLE_010", @"Abschliessen"), nil]
                                          forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                                  [NSUserDefaults currentStintDayOfWeekName]]];
                        }
                    }
                } else {
                    if ([NSUserDefaults isRunningWithTourAdjustment]) {
                        if (PFTourTypeSupported(@"0X1", nil)) {
                            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_009", @"Fahren"), 
                                                                           NSLocalizedString(@"TITLE_010", @"Abschliessen"), nil] 
                                          forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                                  [NSUserDefaults currentStintDayOfWeekName]]];
                        } else { 
                            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_007", @"Anpassen"), 
                                                                           NSLocalizedString(@"TITLE_009", @"Fahren"), 
                                                                           NSLocalizedString(@"TITLE_010", @"Abschliessen"), nil] 
                                          forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                                  [NSUserDefaults currentStintDayOfWeekName]]];
                        }
                    } else {
                        [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_009", @"Fahren"), 
                                                                       NSLocalizedString(@"TITLE_010", @"Abschliessen"), nil] 
                                      forKey:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                              [NSUserDefaults currentStintDayOfWeekName]]];
                    }
                }
                [self.menuGroups addObject:[NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                            [NSUserDefaults currentStintDayOfWeekName]]];
            }
            [menuItems setObject:[NSArray arrayWithObjects:NSLocalizedString(@"TITLE_012", @"Synchronisieren"), nil]
                          forKey:NSLocalizedString(@"TITLE_003", @"Datenübertragung")];
            [self.menuGroups addObject:NSLocalizedString(@"TITLE_003", @"Datenübertragung")];
        }
        if ([[NSUserDefaults currentUserID] intValue] != 0) {
            BOOL addMenuGroup = NO;
            if (  [[NSUserDefaults standardUserDefaults] stringForKey:@"LogisOnline_SYSVAL_HOST"] &&
                ![[[NSUserDefaults standardUserDefaults] stringForKey:@"LogisOnline_SYSVAL_HOST"] isEqualToString:@""]) { 
                [menuItems setObject:[NSArray arrayWithObjects:@"LogisOnline", nil]
                              forKey:NSLocalizedString(@"TITLE_013", @"Zusatzfunktionen")];
                addMenuGroup = YES;
                
            }
            if (addMenuGroup) {
                [self.menuGroups addObject:NSLocalizedString(@"TITLE_013", @"Zusatzfunktionen")];
            }
        }
	}
    return menuItems;
}

- (instancetype)init {
    return [self initWithParameters:nil];
}

- (instancetype) initWithParameters:(NSDictionary *) parameters {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        self.title = NSLocalizedString(@"TITLE_016", @"Hauptmenü");
        self.tableView.backgroundColor = [[[UIColor alloc] initWithWhite:0.87 alpha:1.0] autorelease];
        
        self.currentUser = [parameters objectForKey:MenuUserKey];
        if (!self.currentUser) {
            self.currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
        }
        NSNumber *menuConfiguredForDriverOrNil = [self.currentUser menuConfiguredForDriver];
        if (menuConfiguredForDriverOrNil) {
            self.menuForDriver = [menuConfiguredForDriverOrNil boolValue];
        }
        
        
        if (PFBrandingSupported(BrandingTechnopark, nil) && ![self.currentUser.username isEqualToString:@"n/a"])
            jumpThroughOption = @"Drive";
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
    return [self initWithParameters:nil];
}


#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    // DSPF_Synchronisation should be able to switch the tour by clearing the depending NSUserDefaults.
    // So now it's time to clear and load the new or old values.
    if ([NSUserDefaults isRunningWithTourAdjustment] && self.currentTour && ![NSUserDefaults currentTourId]) {
        [NSUserDefaults setCurrentTourId:self.currentTour.tour_id];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
	[menuItems   release]; menuItems   = nil;
    [menuGroups  release]; menuGroups  = nil;
    [currentTour release]; currentTour = nil;
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    

    NSNumber *menuConfiguredForDriverOrNil = [self.currentUser menuConfiguredForDriver];
    if (menuConfiguredForDriverOrNil == nil) {
        [DSPF_Error messageForMissingDriverGoodsIssuePermissionsWithCancelButtonTitle:NSLocalizedString(@"TITLE_017", @"Abmelden") delegate:self];
    }
}

- (void)confirmLogout {
	[[DSPF_Confirm question:nil item:@"confirmLogout" buttonTitleYES:NSLocalizedString(@"TITLE_017", @"Abmelden") buttonTitleNO:NSLocalizedString(@"TITLE_004", @"Abbrechen") showInView:self.view] setDelegate:self];
}

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend setNumberOfTapsRequired:2];
	[tapToSuspend setNumberOfTouchesRequired:2];
	[self.view	  addGestureRecognizer:tapToSuspend];
    self.clearsSelectionOnViewWillAppear = NO;
	UIButton *backButton = [UIButton buttonWithType:101];      // left-pointing shape!
	[backButton addTarget:self action:@selector(confirmLogout) forControlEvents:UIControlEventTouchUpInside];
	[backButton setTitle:@"DPH Hermes" forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        self.navigationItem.leftBarButtonItem = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.menuItems allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)aSection {
    return [[self.menuItems objectForKey:[self.menuGroups objectAtIndex:aSection]] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
	if (self.menuItems) {
        // menuGroups depends on menuItems 
    }
    return [self.menuGroups objectAtIndex:aSection]; 
}


- (NSString *)menuItem:(NSIndexPath *)indexPath {
    return [[self.menuItems objectForKey:[self.menuGroups objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DSPF_Menu";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text  = [self menuItem:indexPath];
    cell.accessoryType   = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_007", @"Anpassen")].location  != NSNotFound)) {
		if (self.currentTour && self.currentTruck) {
			DSPF_Tour *dspf_Tour = [[[DSPF_Tour alloc] init] autorelease];
            dspf_Tour.title      = NSLocalizedString(@"TITLE_007", @"Anpassen");
            dspf_Tour.subTitle   = [NSString stringWithFormat:@"%@ %@", self.currentTour.code,
                                    [NSUserDefaults currentStintDayOfWeekName]];
            dspf_Tour.tourTask   = TourTaskAdjustingOnly;
			[self.navigationController pushViewController:dspf_Tour animated:YES];
		}
    } else if (([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_114", @"Laden beenden")].location != NSNotFound)) {
		if (self.currentTour && self.currentTruck) {
            DSPF_QuitLoading *dspf_QuitLoading = [[[DSPF_QuitLoading alloc] init] autorelease];
            dspf_QuitLoading.title      = NSLocalizedString(@"TITLE_114", @"Laden beenden");
            dspf_QuitLoading.tourTitle  = [NSString stringWithFormat:@"%@ %@", self.currentTour.code,
                                           [NSUserDefaults currentStintDayOfWeekName]];
            [self.navigationController pushViewController:dspf_QuitLoading animated:YES];
		}
    } else if (([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_008", @"Laden")].location != NSNotFound)) {
		if (self.currentTour && self.currentTruck) {
            if (NO && PFBrandingSupported(BrandingCCC_Group, nil)) {
                DSPF_LoadTransportItem *dspf_LoadTransportItem = [[[DSPF_LoadTransportItem alloc] initWithNibName:@"DSPF_LoadTransportItem" bundle:nil] autorelease];
                dspf_LoadTransportItem.departure = nil;
                dspf_LoadTransportItem.tourTask  = TourTaskLoadingOnly;
                [self.navigationController pushViewController:dspf_LoadTransportItem animated:YES];
                
                DSPF_TourStopTransportGroups *dspf_TourStopTransportGroups = [[[DSPF_TourStopTransportGroups alloc] init] autorelease];
                dspf_TourStopTransportGroups.title      = NSLocalizedString(@"TITLE_008", @"Laden");
                dspf_TourStopTransportGroups.subTitle   = [NSString stringWithFormat:@"%@ %@", self.currentTour.code,
                                               [NSUserDefaults currentStintDayOfWeekName]];
                dspf_TourStopTransportGroups.tourTask   = TourTaskLoadingOnly;
                [self.navigationController pushViewController:dspf_TourStopTransportGroups animated:NO];
                
            } else {
                DSPF_Tour *dspf_Tour = [[[DSPF_Tour alloc] init] autorelease];
                dspf_Tour.title      = NSLocalizedString(@"TITLE_008", @"Laden");
                dspf_Tour.subTitle   = [NSString stringWithFormat:@"%@ (%@)", self.currentTour.code,
                                        [NSUserDefaults currentStintDayOfWeekName]];
                dspf_Tour.tourTask   = TourTaskLoadingOnly;
                [self.navigationController pushViewController:dspf_Tour animated:YES];
            }
		}
    } else if (([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_009", @"Fahren")].location != NSNotFound)) {
		if (self.currentTour && self.currentTruck) {
			DSPF_Tour *dspf_Tour = [[[DSPF_Tour alloc] init] autorelease];
            dspf_Tour.title      = NSLocalizedString(@"TITLE_009", @"Fahren");
            dspf_Tour.subTitle   = [NSString stringWithFormat:@"%@ (%@)", self.currentTour.code,
                                    [NSUserDefaults currentStintDayOfWeekName]];
            dspf_Tour.tourTask   = TourTaskNormalDrive;
			[self.navigationController pushViewController:dspf_Tour animated:YES];
		}
    } else if (([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_010", @"Abschliessen")].location != NSNotFound)) {
		if (self.currentTour && self.currentTruck) {
			DSPF_Finish *dspf_Finish = [[[DSPF_Finish alloc] init] autorelease];
            dspf_Finish.title = [NSString stringWithFormat:NSLocalizedString(@"TITLE_011", @"Tour %@ (%@)"), self.currentTour.code,
                                    [NSUserDefaults currentStintDayOfWeekName]];
			[self.navigationController pushViewController:dspf_Finish animated:YES];
		}
    } else if ([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_014", @"Versandeinheiten")].location != NSNotFound) {
        DSPF_TransportUnitItem *dspf_TransportUnitItem = [[[DSPF_TransportUnitItem alloc] init] autorelease];
        dspf_TransportUnitItem.title = NSLocalizedString(@"TITLE_022", @"Versand");
        [self.navigationController pushViewController:dspf_TransportUnitItem animated:YES];
    }  else if ([[self menuItem:indexPath] rangeOfString:@"Bahnverlad"].location != NSNotFound) {
        DSPF_TransportUnitItem *dspf_TransportUnitItem = [[[DSPF_TransportUnitItem alloc] init] autorelease];
        dspf_TransportUnitItem.title = @"Bahnverlad";
        [self.navigationController pushViewController:dspf_TransportUnitItem animated:YES];
    } else if ([[self menuItem:indexPath] rangeOfString:NSLocalizedString(@"TITLE_012", @"Synchronisieren")].location != NSNotFound) {
        DSPF_Synchronisation *dspf_Synchronisation = [[[DSPF_Synchronisation alloc] init] autorelease];
        dspf_Synchronisation.title = NSLocalizedString(@"TITLE_012", @"Synchronisieren");
        [self.navigationController pushViewController:dspf_Synchronisation animated:YES];
    } else if ([[self menuItem:indexPath] rangeOfString:@"LogisOnline"].location != NSNotFound) {
        DSPF_evoViewer *dspf_evoViewer = [[[DSPF_evoViewer alloc] init] autorelease];
        dspf_evoViewer.title = @"LogisOnline";
        [self.navigationController pushViewController:dspf_evoViewer animated:YES];
    }
}


- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)item withButtonTitle:(NSString *)buttonTitle {
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
		if ([(NSString *)item isEqualToString:@"confirmLogout"]) {
            [self logout];
		}
	}
}

- (void) logout {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewNoDriverGoodIssuePermissionsTag) {
        [self logout];
    }
}

#pragma mark - Memory management


- (void)dealloc {
    [currentUser          release];
	[currentTour		  release];
	[currentTruck		  release];
    [menuGroups			  release];
    [menuItems			  release];
    [jumpThroughOption    release];
    [super dealloc];
}

@end