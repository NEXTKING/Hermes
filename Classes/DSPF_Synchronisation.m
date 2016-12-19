//
//  DSPF_Synchronisation.m
//  Hermes
//
//  Created by Attila Teglas on 03/19/12
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <dispatch/dispatch.h>

#import "HermesAppDelegate.h"
#import "DSPF_Synchronisation.h"
#import "DSPF_Suspend.h"
#import "DSPF_Error.h"

#import "User.h"
#import "Trace_Type.h"
#import "Truck.h"
#import "Truck_Type.h"
#import "Location.h"
#import "Location_Alias.h"
#import "Location_Group.h"
#import "Departure.h"
#import "Transport_Group.h"
#import "Transport.h"
#import "Tour.h"
#import "Tour_Exception.h"

#import "Store.h"
#import "Item.h"
#import "ItemDescription.h"
#import "ItemCode.h"
#import "ItemProductInformation.h"
#import "InventoryHead.h"
#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"
#import "TemplateOrderHead.h"
#import "TemplateOrderLine.h"
#import "LocalizedDescription.h"
#import "FaQ.h"
#import "Newsletter.h"
#import "Promotion.h"
#import "BasketAnalysis.h"

#import "ZipFile.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"
#import "ZipException.h"

@interface DSPF_Synchronisation()
@property (nonatomic, retain) NSError *syncError;
@property (nonatomic, assign) NSInteger errorResponseCode;
@end

@implementation DSPF_Synchronisation

static BOOL _isTourLoaded = YES;

@synthesize downloadBuffer;
@synthesize downloadCacheControl;
@synthesize standVomSyncLabel;
@synthesize abholauftraegeSyncLabel;
@synthesize fahrplanSyncLabel;
@synthesize sonderzieleSyncLabel;
@synthesize orteSyncLabel;
@synthesize tourenSyncLabel;
@synthesize unsynchronizedLabel;
@synthesize buttons;

@synthesize lastUpdateOfUsers;
@synthesize lastUpdateOfTruckTypes;
@synthesize lastUpdateOfTrucks;
@synthesize lastUpdateOfLocationGroups;
@synthesize lastUpdateOfLocationAliases;
@synthesize lastUpdateOfLocations;
@synthesize lastUpdateOfTours;
@synthesize lastUpdateOfDepartures;
@synthesize lastUpdateOfTransportGroups;
@synthesize lastUpdateOfTransports;
@synthesize countOfUnsynchronizedLabel;
@synthesize ctx;
@synthesize savedIdleTimerStatus;
@synthesize syncERR;
@synthesize newsletterAlert;
@synthesize udid;
@synthesize taskControl;
@synthesize syncError;
@synthesize errorResponseCode;


#pragma mark - Initialization

#define TMP_AUTORELEASEPOOL_SWAP_LIMIT  128

+ (BOOL) isLoading
{
    @synchronized(self) {
        return !_isTourLoaded;
    }
}

- (NSString *)udid {
    if (!udid) { 
        udid = [PFDeviceId() retain];
    }
    return udid;
}

- (NSMutableArray *)taskControl {
    if (!taskControl) { 
		taskControl = [[NSMutableArray array] retain];
    }
    return taskControl;
}

#pragma mark - View lifecycle

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = NSLocalizedString(@"TITLE_030", @"Synchronisation");
        self.ctx = [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx];
        // Custom initialization
        UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
        [tapToSuspend setNumberOfTapsRequired:2];
        [tapToSuspend setNumberOfTouchesRequired:2];
        [self.view	  addGestureRecognizer:tapToSuspend];
        
        UILongPressGestureRecognizer *tapToForceSync = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(triggerSynchronisation)] autorelease];
        [tapToForceSync setMinimumPressDuration:3];
        [tapToForceSync setNumberOfTouchesRequired:2];
        [self.view	  addGestureRecognizer:tapToForceSync];
        self.downloadBuffer       = [NSMutableDictionary dictionary];
        self.downloadCacheControl = [NSMutableDictionary dictionaryWithDictionary:
                                     [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"downloadCacheControl"]];
        importQueue = dispatch_queue_create("DSPF_Synchronisation_ImportQueue", NULL);
        _isTourLoaded = YES;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.standVomSyncLabel.text                     = NSLocalizedString(@"MESSAGE_019", @"Stand vom:");
    self.abholauftraegeSyncLabel.text               = NSLocalizedString(@"MESSAGE_020", @"Abholaufträge");
    self.fahrplanSyncLabel.text                     = NSLocalizedString(@"MESSAGE_021", @"Fahrplan");
    self.sonderzieleSyncLabel.text                  = NSLocalizedString(@"MESSAGE_022", @"Sonderziele");
    self.orteSyncLabel.text                         = NSLocalizedString(@"MESSAGE_023", @"Orte");
    self.tourenSyncLabel.text                       = NSLocalizedString(@"MESSAGE_024", @"Touren");
    self.unsynchronizedLabel.text                   = NSLocalizedString(@"MESSAGE_055", @"Zum hochladen:");
    
    UIButton *syncAllButton = [DPHButtonsView grayButtonWithTitle:NSLocalizedString(@"TITLE_078", @"Alles")];
    UIButton *syncTransports = [DPHButtonsView grayButtonWithTitle:NSLocalizedString(@"TITLE_079", @"Fahraufträge")];
    syncAllButton.hidden = ![self syncAllButtonVisible];
    syncTransports.hidden = ![self syncTransportRequestsButtonVisible];
    
    [syncAllButton addTarget:self action:@selector(syncALL) forControlEvents:UIControlEventTouchUpInside];
    [syncTransports addTarget:self action:@selector(syncTOUR) forControlEvents:UIControlEventTouchUpInside];
    
    self.buttons.buttons = [NSArray arrayWithObjects:syncAllButton, syncTransports, nil];
}

- (BOOL) syncAllButtonVisible {
    BOOL visible = YES;
    if (PFTourTypeSupported(@"0X0", nil) || (PFTourTypeSupported(@"0X1", nil) && PFBrandingSupported(BrandingUnilabs, nil))) {
        visible = NO;
    }
    if ([[NSUserDefaults currentUserID] integerValue] == 0) {
        visible = YES;
    }
    
    return visible;
}

- (BOOL) syncTransportRequestsButtonVisible {
    BOOL visible = YES;
    if (PFTourTypeSupported(@"0X0", nil) || (PFTourTypeSupported(@"0X1", nil) && PFBrandingSupported(BrandingUnilabs, nil))) {
        visible = NO;
    }
    
    if ([[NSUserDefaults currentUserID] integerValue] == 0) {
        visible = YES;
    }
    return visible;
}

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void) triggerSynchronisation {
    [SVR_SyncDataManager triggerSendingTraceLogDataWithUserInfo:nil];
    [[MTStatusBarOverlay sharedInstance] postImmediateMessage:NSLocalizedString(@"TITLE_139", @"Synchronisation ausgelöst") duration:3 animated:YES];
}

- (void)updateViewContent { 
	self.lastUpdateOfUsers.text			  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfUsers"];
	self.lastUpdateOfTruckTypes.text	  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfTruckTypes"];
	self.lastUpdateOfTrucks.text		  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfTrucks"];
	self.lastUpdateOfLocationGroups.text  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfLocationGroups"];
    self.lastUpdateOfLocationAliases.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfLocationAliases"];
	self.lastUpdateOfLocations.text		  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfLocations"];
	self.lastUpdateOfTours.text			  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfTours"];
	self.lastUpdateOfDepartures.text	  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfDepartures"];
    self.lastUpdateOfTransports.text	  = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdateOfTransports"];
    self.countOfUnsynchronizedLabel.text  = [NSString stringWithFormat:@"%u", [[AppDelegate() syncDataManager] unsynchronizedTraceLogsCount]];
    if (self.syncERR) {
        NSString *title = NSLocalizedString(@"TITLE__031", @"Daten-Synchronisation");
        NSString *message = NSLocalizedString(@"ERROR_MESSAGE__005", @"ACHTUNG: Die Verbindung zum Server ist abgebrochen. Dadurch sind nicht alle Daten auf dem aktuellen Stand.");
        if (errorResponseCode == 401 || ([[syncError domain] isEqualToString:NSURLErrorDomain] && [syncError code] == kCFURLErrorUserCancelledAuthentication)) {
            message = NSLocalizedString(@"ERROR_MESSAGE__021", @"Dieses Gerät ist nicht für die Daten-Synchronization aktiviert.");
        } else if ([[syncError localizedDescription] length] > 0) {
            message = [syncError localizedDescription];
        }
        self.errorResponseCode = 0;
        self.syncError = nil;
        self.syncERR = NO;
        [DSPF_Error messageTitle:title messageText:message delegate:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self  updateViewContent];
}

- (void)viewWillDisappear: (BOOL)animated{
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.
		// We know this is true because self is no longer in the navigation stack.
        if (![[Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES"] inCtx:self.ctx] lastObject]) {
            // try to load a newer tour
            [NSUserDefaults setCurrentStintStart:[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                           dateStyle:NSDateFormatterMediumStyle
                                                                                           timeStyle:NSDateFormatterMediumStyle]];
            [NSUserDefaults setCurrentStintPauseTime:[NSNumber numberWithInt:0]];
            if ((![NSUserDefaults isRunningWithTourAdjustment] && !PFTourTypeSupported(@"0X1", @"0X0", nil)) || [[NSUserDefaults currentTourId] intValue] == 0) {
                    [NSUserDefaults setCurrentTourId:nil];
                    [NSUserDefaults setCurrentStintDayOfWeek:nil];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
	}
    [super viewWillDisappear:animated];
}

- (UIBackgroundTaskIdentifier )cancelBackgroundTask:(UIBackgroundTaskIdentifier )backgroundTask { 
    if (backgroundTask != UIBackgroundTaskInvalid) { 
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask]; 
        backgroundTask = UIBackgroundTaskInvalid;
    }
    return backgroundTask;
}

- (NSArray *)serverDataForKey:(NSString *)aKey option:(NSString *)option {
    return [self serverDataForKey:aKey option:option forceFullSync:NO];
}

- (NSArray *)serverDataForKey:(NSString *)aKey option:(NSString *)option forceFullSync:(BOOL)forceFullSync {
    
    
    //self.udid = @"SIMULATOR";
    
    NSArray  *serverData = nil;
    NSError  *error      = nil;
    NSHTTPURLResponse    *response;
    NSData               *tmpData;
	//@"http://zhsrv-dev64.zh.dph.local:100/evoweb/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
	//@"https://zhsrv-dev64.zh.dph.local/eta/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    NSString *serverURL = [DSPF_Synchronisation hermesServerURL];
                 
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:240];
    [request setHTTPMethod:@"GET"];
    if ([self.downloadCacheControl valueForKey:aKey] && !forceFullSync) {
        if (PFHermesServerVersion() >= 2 || PFBrandingSupported(BrandingViollier, nil)) {
            [request setValue:[self.downloadCacheControl valueForKey:aKey] forHTTPHeaderField:@"If-Modified-Since"];
        }
    }
    BOOL flag = PFTourTypeSupported(@"1XX", nil)  && [NSUserDefaults isRunningWithTourAdjustment];
    
    if (flag && ([aKey isEqualToString:@"transport"] || [aKey isEqualToString:@"cargo"] || [aKey isEqualToString:@"schedule"])) {
            if ([[NSUserDefaults currentTourId] longLongValue] != 0 && [[NSUserDefaults currentTruckId] longLongValue] != 0) {
                
                if (!PFBrandingSupported(BrandingTechnopark, nil))
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&tour_id=%@&trid=%@",
                                                      serverURL, aKey, self.udid,
                                                      [NSUserDefaults currentTourId],
                                                      [NSUserDefaults currentTruckId]]]];
                else
                    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&tour_id=%@",
                                                          serverURL, aKey, self.udid,
                                                          [NSUserDefaults currentTourId]]]];
            }
        } else {
            if (!option || option.length == 0) {
                if ([aKey isEqualToString:@"user"]                       ||
                    [aKey isEqualToString:@"item"]                       ||
                    [aKey isEqualToString:@"itemprice"]                  ||
                    [aKey isEqualToString:@"itemassortment"]             ||
                    [aKey isEqualToString:@"archiveorderhead"]           ||
                    [aKey isEqualToString:@"archiveorderline"]           ||
                    [aKey isEqualToString:@"pricelistheaderdescription"] ||
                    [aKey isEqualToString:@"pricelistheader"]            ||
                    [aKey isEqualToString:@"pricelistline"])             {
                    /*
                     [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&store=%@",
                     serverURL, aKey, self.udid,
                     [[NSUserDefaults standardUserDefaults] valueForKey:@"currentStoreID"]]]];
                     */
                    
                    if ([aKey isEqualToString:@"item"] && PFBrandingSupported(BrandingTechnopark, nil))
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&store=%@&tour_id=%@",
                                                              serverURL, aKey, self.udid, @"100002", [NSUserDefaults currentTourId]]]];
                    else
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&store=%@truck",
                                                          serverURL, aKey, self.udid, @"100002"]]];
                } else {
                    
                    if ([aKey isEqualToString:@"truck"])
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&driver_id=%ld",
                                                          serverURL, aKey, self.udid, (long)[[NSUserDefaults currentUserID] integerValue]]]];
                    //else if ([aKey isEqualToString:@"departure"] || [aKey isEqualToString:@"location"])
                    //    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&tour_id=%@",
                    //                                          serverURL, aKey, self.udid, [NSUserDefaults currentTourId]]]];
                    else
                        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@",
                                                              serverURL, aKey, self.udid]]];
                }
            } else {
                [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/download/%@?returnType=xmlplist&zipped=true&sn=%@&%@",
                                                      serverURL, aKey, self.udid, option]]];
            }
        }
    NSLog(@"%@", request.URL.absoluteString);
    if ([NSURLConnection canHandleRequest:request]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        tmpData  = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error || [response statusCode] == 200) {
            [self.downloadCacheControl setValue:[[response allHeaderFields] valueForKey:@"Last-Modified"] forKey:aKey];
            if ([aKey isEqualToString:@"item_image"]) {
                serverData = [NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[NSData dataWithData:tmpData] forKey:@"itemImageZIP"]];
            } else {
                serverData = [DSPF_Synchronisation arrayFromDownloadedServerData:tmpData downloadingKey:aKey];
            }
        } else {
            NSString *exceptionCode = [[response allHeaderFields] valueForKey:@"X-Hermes-ServiceError"];
            if ([exceptionCode isEqualToString:@"TOUR_IS_ALREADY_DRIVEN_BY_OTHER_DEVICE"]) {
                NSString *message = NSLocalizedString(@"ERROR_MESSAGE_039", @"Diese Tour wird schon von dem anderen Benutzer gefahren");
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung") messageText:message delegate:nil cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK")];
            }
            self.errorResponseCode = [response statusCode];
            self.syncError = error;
        }
    }
    return serverData;
}

- (NSAutoreleasePool *)swapAutoreleasePool:(NSAutoreleasePool *)aPool {
    [self.ctx saveIfHasChanges];
    [aPool drain];
    aPool = [[NSAutoreleasePool alloc] init];
    return aPool;
}

- (void)syncUsersArray:(NSArray *)tmpUsersArray withActivityInfo:(DSPF_Activity *)showActivity {
    if (tmpUsersArray) {
        [self processEntityClass:User.class withServerArray:tmpUsersArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfUsersArray");
        self.syncERR = YES;
    }
}

- (void)syncLocationsArray:(NSArray *)tmpLocationsArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpLocationsArray) {
        [self processEntityClass:Location.class withServerArray:tmpLocationsArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfLocationsArray");
        self.syncERR = YES;
    }
}

- (void)syncLocationGroupsArray:(NSArray *)tmpLocationGroupsArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpLocationGroupsArray) {
        [self processEntityClass:Location_Group.class withServerArray:tmpLocationGroupsArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfLocationGroups");
        self.syncERR = YES;
    }
}

- (void)syncLocationAliasesArray:(NSArray *)tmpLocationAliasesArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpLocationAliasesArray) {
        [self processEntityClass:Location_Alias.class withServerArray:tmpLocationAliasesArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfLocationAliasesArray");
        self.syncERR = YES;
    }
}


- (void)syncTraceTypesArray:(NSArray *)tmpTraceTypesArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpTraceTypesArray) {
        [showActivity.alertView setMessage:[NSLocalizedString(@"TraceTypes", @"TraceTypes") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpTraceTypesArray) {
            if (PFBrandingSupported(BrandingViollier, nil)) {
                if ([[serverData valueForKey:@"id"] intValue] == 91) {
                    NSMutableDictionary *tmpAdjustment = [[NSMutableDictionary alloc] initWithDictionary:serverData];
                    [tmpAdjustment setValue:NSLocalizedString(@"Keine Probenabholung", @"Keine Probenabholung") forKey:@"description"];
                    serverData = [NSDictionary dictionaryWithDictionary:tmpAdjustment];
                    [tmpAdjustment release];
                }
            }
            [self.ctx refreshObject:
             [Trace_Type trace_TypeWithServerData:serverData inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) { 
                tmpAutoreleasePool = [self swapAutoreleasePool:tmpAutoreleasePool];
                [showActivity.alertView setMessage:[NSLocalizedString(@"TraceTypes", @"TraceTypes") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpTraceTypesArray.count]]]; 
                [DPHUtilities waitForAlertToShow:0.1f];
                swapCount = 0;
            }
        }
        [showActivity.alertView setMessage:[NSLocalizedString(@"TraceTypes", @"TraceTypes") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.236f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfTraceTypes"];
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain];
    } else {
        NSLog(@"syncERR: UpdateOfTraceTypesArray");
        self.syncERR = YES;
    }
}

- (void)syncTruckTypesArray:(NSArray *)tmpTruckTypesArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpTruckTypesArray) {
        [self processEntityClass:Truck_Type.class withServerArray:tmpTruckTypesArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfTruckTypesArray");
        self.syncERR = YES;
    }
}

- (void)syncTrucksArray:(NSArray *)tmpTrucksArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpTrucksArray) {
        [self processEntityClass:Truck.class withServerArray:tmpTrucksArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfTrucksArray");
        self.syncERR = YES;
    }
}

- (void)syncToursArray:(NSArray *)tmpToursArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpToursArray && tmpToursArray.count > 0) {
        [self processEntityClass:Tour.class withServerArray:tmpToursArray option:nil activityInfo:showActivity];
    } else {
        if (!PFBrandingSupported(BrandingCCC_Group, nil)) {
            NSLog(@"syncERR: UpdateOfToursArray");
            self.syncERR = YES;
        }
    }
}

- (void)syncDeparturesArray:(NSArray *)tmpDeparturesArray option:(NSString *)option withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpDeparturesArray) {
        [self processEntityClass:Departure.class withServerArray:tmpDeparturesArray option:option activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfDeparturesArray");
        self.syncERR = YES;
    }
}

- (void)syncSchedulesArray:(NSArray *)tmpSchedulesArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpSchedulesArray) {
        [self processEntityClass:Schedule.class withServerArray:tmpSchedulesArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfSchedulesArray");
        self.syncERR = YES;
    }
}

- (void)syncTransportGroupsArray:(NSArray *)tmpTransportGroupsArray withActivityInfo:(DSPF_Activity *)showActivity {
    if (tmpTransportGroupsArray) {
        [self processEntityClass:Transport_Group.class withServerArray:tmpTransportGroupsArray option:nil activityInfo:showActivity];
    } else {
        if (PFTourTypeSupported(@"1XX", nil) && [NSUserDefaults isRunningWithTourAdjustment]) {
            NSLog(@"syncERR: UpdateOfTransportGroupsArray");
            self.syncERR = YES;
        }
    }
}

- (void)syncCargosArray:(NSArray *)tmpCargosArray withActivityInfo:(DSPF_Activity *)showActivity {
    if (tmpCargosArray) {
        [self processEntityClass:Cargo.class withServerArray:tmpCargosArray option:nil activityInfo:showActivity];
    } else {
        NSLog(@"syncERR: UpdateOfCargosArray");
        self.syncERR = YES;
    }
}

- (void)syncTransportsArray:(NSArray *)tmpTransportsArray withActivityInfo:(DSPF_Activity *)showActivity { 
    if (tmpTransportsArray) {
        [showActivity.alertView setMessage:[[NSLocalizedString(@"MESSAGE_020", @"Transports")
                                   stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpTransportsArray) {
            Transport *tmpTransport = [Transport fromServerData:serverData inCtx:self.ctx];
            if (tmpTransport) {
                [self.ctx refreshObject:tmpTransport mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) { 
                tmpAutoreleasePool = [self swapAutoreleasePool:tmpAutoreleasePool];
                [showActivity.alertView setMessage:[[NSLocalizedString(@"MESSAGE_020", @"Transports")
                                           stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpTransportsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                swapCount = 0;
            }
        }
        [showActivity.alertView setMessage:[[NSLocalizedString(@"MESSAGE_020", @"Transports")
                                   stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.236f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forClass:Transport.class];
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain];
    } else {
        NSLog(@"syncERR: UpdateOfTransportsArray");
        self.syncERR = YES;
    }
}

- (void)syncTransportsDeleteArray:(NSArray *)tmpTransportsDeleteArray withActivityInfo:(DSPF_Activity *)showActivity {
    if (tmpTransportsDeleteArray) {
        [showActivity.alertView setMessage:[[NSLocalizedString(@"MESSAGE_020", @"Transports")
                                             stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@" *DLT  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpTransportsDeleteArray) {
            NSMutableDictionary *serverDeleteData = [NSMutableDictionary dictionaryWithDictionary:serverData];
            [serverDeleteData setObject:@"*DLT" forKey:@"CRUD"];
            [Transport fromServerData:serverDeleteData inCtx:self.ctx];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                tmpAutoreleasePool = [self swapAutoreleasePool:tmpAutoreleasePool];
                [showActivity.alertView setMessage:[[NSLocalizedString(@"MESSAGE_020", @"Transports")
                                                     stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@" *DLT  (%@)",
                                                    [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpTransportsDeleteArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                swapCount = 0;
            }
        }
        [showActivity.alertView setMessage:[[NSLocalizedString(@"MESSAGE_020", @"Transports")
                                             stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@" *DLT  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.236f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forClass:Transport.class];
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain];
    } else {
        //        self.syncERR = YES;
    }
}

- (void)processEntityClass:(Class<DPHSynchronizable>)class withServerArray:(NSArray *)arrayWithObjects option:(NSString *)option activityInfo:(DSPF_Activity *)showActivity {
    NSString *entityName = [class synchronizationDisplayName];
    if (arrayWithObjects) {
        [showActivity.alertView setMessage:[[entityName stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        [class willProcessDataFromServer:arrayWithObjects option:option inCtx:self.ctx];
        for (NSDictionary *serverData in arrayWithObjects) {
            [self.ctx refreshObject:[class fromServerData:serverData inCtx:self.ctx] mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                tmpAutoreleasePool = [self swapAutoreleasePool:tmpAutoreleasePool];
                [showActivity.alertView setMessage:[[entityName stringByReplacingOccurrencesOfString:@":" withString:@" "] stringByAppendingFormat:@"  (%@)",
                                                    [NSString stringWithFormat:@"%i%%", loopCount * 100 / arrayWithObjects.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                swapCount = 0;
            }
        }
        [showActivity.alertView setMessage:[[entityName stringByReplacingOccurrencesOfString:@":" withString:@""] stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.236f];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                       dateStyle:NSDateFormatterMediumStyle
                                                                                       timeStyle:NSDateFormatterShortStyle]
                                                 forKey:[class lastUpdatedNSDefaultsKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain];
        [class didProcessDataFromServer:arrayWithObjects option:option inCtx:self.ctx];
    }
}

- (void)syncLocalizedDescriptonArray:(NSArray *)tmpLocalizedDescriptionArray withActivityInfo:(DSPF_Activity *)showActivity {
    if (tmpLocalizedDescriptionArray) {
        [self processEntityClass:LocalizedDescription.class withServerArray:tmpLocalizedDescriptionArray option:nil activityInfo:showActivity];
    } else {
        //        self.syncERR = YES;
    }
}

- (void)syncTourExceptionArray:(NSArray *)tmpTourExceptionArray withActivityInfo:(DSPF_Activity *)showActivity {
    if (tmpTourExceptionArray) {
        [self processEntityClass:Tour_Exception.class withServerArray:tmpTourExceptionArray option:nil activityInfo:showActivity];
    } else {
        if (PFTourTypeSupported(@"0X1", nil)) {
            NSLog(@"syncERR: UpdateOfTourException");
            self.syncERR = YES;
        }
    }
}

- (void)syncStoresArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpStoresArray = [self.downloadBuffer objectForKey:@"tmpStoresArray"];
    if (tmpStoresArray) {
        [tmpStoresArray retain];
        if (tmpStoresArray.count == 1 &&
            [[[NSUserDefaults standardUserDefaults]
              valueForKey:@"ApolloApp_SYSVAL_RUN_withInventoryMODE"] isEqualToString:@"EXCLUSIVE"] &&
            [[[tmpStoresArray objectAtIndex:0] valueForKey:@"storeid"] intValue] !=
            [[[NSUserDefaults standardUserDefaults] valueForKey:@"currentStoreID"] intValue]) {
            [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%05i",
                                                             [[[tmpStoresArray objectAtIndex:0] valueForKey:@"storeid"] intValue]]
                                                     forKey:@"currentStoreID"];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"downloadCacheControl"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__062", @"Bereinigung") stringByAppendingFormat:@"  (%@)", @"0%"]];
            [DPHUtilities waitForAlertToShow:0.1f];
            NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
            for (TemplateOrderHead *tmpTemplateHead in
                 [NSArray arrayWithArray:[TemplateOrderHead templateHeadsWithPredicate:nil sortDescriptors:nil
                                                                inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpTemplateHead];
            }
            [self.ctx saveIfHasChanges];
            [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
            [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__062", @"Bereinigung") stringByAppendingFormat:@"  (%@)", @"20%"]];
            [DPHUtilities waitForAlertToShow:0.1f];
            tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
            for (ArchiveOrderHead *tmpOrderHead in
                 [NSArray arrayWithArray:[ArchiveOrderHead orderHeadsWithPredicate:nil sortDescriptors:nil
                                                            inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpOrderHead];
            }
            [self.ctx saveIfHasChanges];
            [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
            [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__062", @"Bereinigung") stringByAppendingFormat:@"  (%@)", @"40%"]];
            [DPHUtilities waitForAlertToShow:0.1f];
            tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
            for (ItemCode *tmpItemCode in
                 [NSArray arrayWithArray:[ItemCode itemCodesWithPredicate:nil sortDescriptors:nil
                                                   inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpItemCode];
            }
            [self.ctx saveIfHasChanges];
            [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
            [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__062", @"Bereinigung") stringByAppendingFormat:@"  (%@)", @"60%"]];
            [DPHUtilities waitForAlertToShow:0.1f];
            tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
            for (ItemDescription *tmpItemDescription in
                 [NSArray arrayWithArray:[ItemDescription itemDescriptionsWithPredicate:nil sortDescriptors:nil
                                                                 inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpItemDescription];
            }
            [self.ctx saveIfHasChanges];
            [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
            [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__062", @"Bereinigung") stringByAppendingFormat:@"  (%@)", @"80%"]];
            [DPHUtilities waitForAlertToShow:0.1f];
            tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
            for (Item *tmpItem in
                 [NSArray arrayWithArray:[Item itemsWithPredicate:nil sortDescriptors:nil
                                           inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpItem];
            }
            [self.ctx saveIfHasChanges];
            [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
            [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__062", @"Bereinigung") stringByAppendingFormat:@"  (%@)", @"100%"]];
            [DPHUtilities waitForAlertToShow:0.1f];
        }
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__006", @"Filialstamm") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpStoresArray) {
            Store *tmpStore = [Store storeWithServerData:serverData inCtx:self.ctx];
            if (tmpStore) {
                [self.ctx refreshObject:tmpStore mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__006", @"Filialstamm") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpStoresArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpStoresArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__006", @"Filialstamm") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfStores"];
    } else {
        NSLog(@"syncERR: UpdateOfStores");
        self.syncERR = YES;
    }
}

- (void)syncItemsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemsArray = [self.downloadBuffer objectForKey:@"tmpItemsArray"];
    if (tmpItemsArray) {
        [tmpItemsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__008", @"Artikel") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemsArray) {
            [Item itemWithServerData:serverData inCtx:self.ctx];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__008", @"Artikel") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__008", @"Artikel") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItems"];
    } else {
        NSLog(@"syncERR: UpdateOfItems");
        self.syncERR = YES;
    }
}

- (void)syncItemDescriptionsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemDescriptionsArray = [self.downloadBuffer objectForKey:@"tmpItemDescriptionsArray"];
    if (tmpItemDescriptionsArray) {
        [tmpItemDescriptionsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__009", @"Artikeltexte") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        NSUInteger importCount = tmpItemDescriptionsArray.count;
        for (NSDictionary *serverData in tmpItemDescriptionsArray) {
            [ItemDescription itemDescriptionWithServerData:serverData inCtx:self.ctx];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__009", @"Artikeltexte") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / importCount]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemDescriptionsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__009", @"Artikeltexte") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemDescriptions"];
    } else {
        NSLog(@"syncERR: UpdateOfItemDescriptions");
        self.syncERR = YES;
    }
}

- (void)syncItemCodesArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemCodesArray = [self.downloadBuffer objectForKey:@"tmpItemCodesArray"];
    if (tmpItemCodesArray)  {
        [tmpItemCodesArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"ABBREVIATIONS_03_001", @"EAN") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemCodesArray) {
            [ItemCode itemCodeWithServerData:serverData inCtx:self.ctx];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"ABBREVIATIONS_03_001", @"EAN") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemCodesArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemCodesArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"ABBREVIATIONS_03_001", @"EAN") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemCodes"];
    } else {
        NSLog(@"syncERR: UpdateOfItemCodes");
        self.syncERR = YES;
    }
}

- (void)syncItemImagesWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemImageArray = [self.downloadBuffer objectForKey:@"tmpItemImages"];
    if(tmpItemImageArray && tmpItemImageArray.count > 0) {
        NSData *tmpItemImageData = [[tmpItemImageArray objectAtIndex:0] valueForKey:@"itemImageZIP"];
        NSString *zipName = [NSHomeDirectory()stringByAppendingPathComponent:@"Library/ItemImages.ZIP"];
        if([tmpItemImageData length] > 1024 && [tmpItemImageData writeToFile:zipName atomically:YES]) {
            // tmpItemImageData must be bigger than 1 KB if it contains an ItemImages.ZIP
            // tmpItemImageData is e.g. 29 B if it contains a String like "This download does not exist!"
            @try {
                ZipFile *tmpZIP = [[ZipFile alloc] initWithFileName:zipName mode:ZipFileModeUnzip];
                [showActivity.alertView setMessage:[@"ItemImages.ZIP" stringByAppendingFormat:@"  (%@)", @"0%"]];
                [DPHUtilities waitForAlertToShow:0.1f];
                NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                for (FileInZipInfo *tmpFileInfo in [tmpZIP listFileInZipInfos]) {
                    if (![[tmpFileInfo name] isEqualToString:@"[Content_Types].xml"]) {
                        [tmpZIP locateFileInZip:[tmpFileInfo name]];
                        NSMutableData *tmpData = [[NSMutableData alloc] initWithLength:[tmpFileInfo length]];
                        ZipReadStream *tmpStream = [tmpZIP readCurrentFileInZip];
                        int bytesRead = [tmpStream readDataWithBuffer:tmpData];
                        if (bytesRead > 0) {
                            [showActivity.alertView setMessage:tmpFileInfo.name];
                            [DPHUtilities waitForAlertToShow:0.1f];
                            [tmpData writeToFile:[NSHomeDirectory()stringByAppendingPathComponent:
                                                  [NSString stringWithFormat:@"Library/ItemImages/%@",
                                                   [tmpFileInfo.name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]
                                      atomically:YES];
                        }
                        [tmpData release];
                        [tmpStream finishedReading];
                    }
                }
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [tmpZIP close];
                [tmpZIP release];
                [showActivity.alertView setMessage:[@"ItemImages.ZIP" stringByAppendingFormat:@"  (%@)", @"100%"]];
                [DPHUtilities waitForAlertToShow:0.1f];
                [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemImages"];
                [[NSFileManager defaultManager] removeItemAtPath:zipName error:nil];
            } @catch (ZipException *ze) {
                NSLog(@"%@", @"Caught a ZipException (see logs), terminating...");
                NSLog(@"ZipException caught: %d - %@", ze.error, [ze reason]);
                NSLog(@"syncERR: UpdateOfItemImages");
                self.syncERR = YES;
            } @catch (id e) {
                NSLog(@"%@", @"Caught a generic exception (see logs), terminating...");
                NSLog(@"Exception caught: %@ - %@", [[e class] description], [e description]);
                NSLog(@"syncERR: UpdateOfItemImages");
                self.syncERR = YES;
            }
        }
    }
}

- (void)syncItemPricesArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemPricesArray = [self.downloadBuffer objectForKey:@"tmpItemPricesArray"];
    if (tmpItemPricesArray) {
        [tmpItemPricesArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__011", @"Preise") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemPricesArray) {
            [Item itemPriceWithServerData:serverData inCtx:self.ctx];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__011", @"Preise") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemPricesArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemPricesArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__011", @"Preise") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemPrices"];
    } else {
        NSLog(@"syncERR: UpdateOfItemPrices");
        self.syncERR = YES;
    }
}

- (void)syncItemAssortmentsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemAssortmentsArray = [self.downloadBuffer objectForKey:@"tmpItemAssortmentsArray"];
    if (tmpItemAssortmentsArray) {
        [tmpItemAssortmentsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__012", @"Sortimente") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        if (tmpItemAssortmentsArray.count > 0) {
            for (Item *tmpItem in [NSArray arrayWithArray:[Item itemsWithPredicate:nil sortDescriptors:nil
                                                            inCtx:self.ctx]]) {
                tmpItem.storeAssortmentBit  = [NSNumber numberWithBool:NO];
                tmpItem.storeAssortmentCode = nil;
                [self.ctx refreshObject:tmpItem mergeChanges:YES];
            }
            for (NSDictionary *serverData in tmpItemAssortmentsArray) {
                [Item itemAssortmentWithServerData:serverData inCtx:self.ctx];
                swapCount++;
                loopCount++;
                if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                    [self.ctx saveIfHasChanges];
                    [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                    [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__012", @"Sortimente") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemAssortmentsArray.count]]];
                    [DPHUtilities waitForAlertToShow:0.1f];
                    tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                    swapCount = 0;
                }
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemAssortmentsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__012", @"Sortimente") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemAssortments"];
    } else {
        NSLog(@"syncERR: UpdateOfItemAssortments");
        self.syncERR = YES;
    }
}

- (void)syncInventoryHeadsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpInventoryHeadsArray = [self.downloadBuffer objectForKey:@"tmpInventoryHeadsArray"];
    if (tmpInventoryHeadsArray) {
        [tmpInventoryHeadsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"Inventuraufträge", @"Inventuraufträge") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpInventoryHeadsArray) {
            [InventoryHead inventoryHeadWithServerData:serverData inCtx:self.ctx];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"Inventuraufträge", @"Inventuraufträge") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpInventoryHeadsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpInventoryHeadsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"Inventuraufträge", @"Inventuraufträge") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfInventoryHeads"];
    } else {
        //        self.syncERR = YES;
    }
}

- (void)syncArchiveOrderHeadsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpArchiveOrderHeadsArray = [self.downloadBuffer objectForKey:@"tmpArchiveOrderHeadsArray"];
    if (tmpArchiveOrderHeadsArray) {
        [tmpArchiveOrderHeadsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__013", @"Bestellhistorie") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpArchiveOrderHeadsArray) {
            [self.ctx refreshObject:
             [ArchiveOrderHead orderHeadWithServerData:serverData inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__013", @"Bestellhistorie") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpArchiveOrderHeadsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpArchiveOrderHeadsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__013", @"Bestellhistorie") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfArchiveOrderHeads"];
    } else {
        //        self.syncERR = YES;
    }
}

- (void)syncArchiveOrderLinesArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpArchiveOrderLinesArray = [self.downloadBuffer objectForKey:@"tmpArchiveOrderLinesArray"];
    if (tmpArchiveOrderLinesArray) {
        [tmpArchiveOrderLinesArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__014", @"Bestelldatenhistorie") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpArchiveOrderLinesArray) {
            [self.ctx refreshObject:
             [ArchiveOrderLine orderLineWithServerData:serverData inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__014", @"Bestelldatenhistorie") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpArchiveOrderLinesArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpArchiveOrderLinesArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__014", @"Bestelldatenhistorie") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfArchiveOrderLines"];
    } else {
        //        self.syncERR = YES;
    }
}

- (void)syncItemCategoriesArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemCategoriesArray = [self.downloadBuffer objectForKey:@"tmpItemCategoriesArray"];
    if (tmpItemCategoriesArray) {
        [tmpItemCategoriesArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__037", @"Warengruppen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemCategoriesArray) {
            [self.ctx refreshObject:
             [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                               withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                 forKey:@"ItemCategory"
                                             localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                 inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__037", @"Warengruppen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemCategoriesArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemCategoriesArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__037", @"Warengruppen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemCategories"];
    } else {
        NSLog(@"syncERR: UpdateOfItemCategories");
        self.syncERR = YES;
    }
}

- (void)syncItemCertificationsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemCertificationsArray = [self.downloadBuffer objectForKey:@"tmpItemCertificationsArray"];
    if (tmpItemCertificationsArray) {
        [tmpItemCertificationsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__038", @"Warenzertifizierungen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemCertificationsArray) {
            [self.ctx refreshObject:
             [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                               withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                 forKey:@"ItemCertification"
                                             localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                 inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__038", @"Warenzertifizierungen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemCertificationsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemCertificationsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__038", @"Warenzertifizierungen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemCertifications"];
    } else {
        NSLog(@"syncERR: UpdateOfItemCertifications");
        self.syncERR = YES;
    }
}

- (void)syncItemProductInformationsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemProductInformationsArray = [self.downloadBuffer objectForKey:@"tmpItemProductInformationsArray"];
    if (tmpItemProductInformationsArray) {
        [tmpItemProductInformationsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__039", @"Produktinformationen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemProductInformationsArray) {
            [self.ctx refreshObject:
             [ItemProductInformation itemProductInformationWithServerData:serverData inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__039", @"Produktinformationen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemProductInformationsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemProductInformationsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__039", @"Produktinformationen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemProductInformations"];
    } else {
        NSLog(@"syncERR: UpdateOfItemProductInformations");
        self.syncERR = YES;
    }
}

- (void)syncItemTrademarkHoldersArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemTrademarkHoldersArray = [self.downloadBuffer objectForKey:@"tmpItemTrademarkHoldersArray"];
    if (tmpItemTrademarkHoldersArray) {
        [tmpItemTrademarkHoldersArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__040", @"Hersteller/Marken") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemTrademarkHoldersArray) {
            LocalizedDescription *tmpLocalizedDescription =
            [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                              withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                forKey:@"ItemTrademarkHolder"
                                            localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                inCtx:self.ctx];
            if (tmpLocalizedDescription) {
                [self.ctx refreshObject:tmpLocalizedDescription
                                            mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__040", @"Hersteller/Marken") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemTrademarkHoldersArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemTrademarkHoldersArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__040", @"Hersteller/Marken") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemTrademarkHolders"];
    } else {
        NSLog(@"syncERR: UpdateOfItemTrademarkHolders");
        self.syncERR = YES;
    }
}

- (void)syncItemCountriesOfOriginArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemCountriesOfOriginArray = [self.downloadBuffer objectForKey:@"tmpItemCountriesOfOriginArray"];
    if (tmpItemCountriesOfOriginArray) {
        [tmpItemCountriesOfOriginArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__041", @"Produkherkunftsinformationen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemCountriesOfOriginArray) {
            [self.ctx refreshObject:
             [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                               withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"country"]]
                                                 forKey:@"ItemCountryOfOrigin"
                                             localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                 inCtx:self.ctx]
                                        mergeChanges:YES];
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__041", @"Produkherkunftsinformationen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemCountriesOfOriginArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemCountriesOfOriginArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__041", @"Produkherkunftsinformationen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemCountriesOfOrigin"];
    } else {
        NSLog(@"syncERR: UpdateOfItemCountriesOfOrigin");
        self.syncERR = YES;
    }
}

- (void)syncItemPackagesArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemPackagesArray = [self.downloadBuffer objectForKey:@"tmpItemPackagesArray"];
    if (tmpItemPackagesArray) {
        [tmpItemPackagesArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__042", @"Warenverpackungen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemPackagesArray) {
            LocalizedDescription *tmpLocalizedDescription =
            [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                              withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                forKey:@"ItemPackage"
                                            localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                inCtx:self.ctx];
            if (tmpLocalizedDescription) {
                [self.ctx refreshObject:tmpLocalizedDescription
                                            mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__042", @"Warenverpackungen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemPackagesArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemPackagesArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__042", @"Warenverpackungen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemPackages"];
    } else {
        NSLog(@"syncERR: UpdateOfItemPackages");
        self.syncERR = YES;
    }
}

- (void)syncItemUnitsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpItemUnitsArray = [self.downloadBuffer objectForKey:@"tmpItemUnitsArray"];
    if (tmpItemUnitsArray) {
        [tmpItemUnitsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__043", @"Verpackungseinheiten") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpItemUnitsArray) {
            LocalizedDescription *tmpLocalizedDescription =
            [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                              withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                forKey:@"ItemUnit"
                                            localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                inCtx:self.ctx];
            if (tmpLocalizedDescription) {
                [self.ctx refreshObject:tmpLocalizedDescription
                                            mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__043", @"Verpackungseinheiten") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpItemUnitsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpItemUnitsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__043", @"Verpackungseinheiten") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemUnits"];
    } else {
        NSLog(@"syncERR: UpdateOfItemUnits");
        self.syncERR = YES;
    }
}

- (void)syncPriceListDescriptionsArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpPriceListDescriptionsArray = [self.downloadBuffer objectForKey:@"tmpPriceListDescriptionsArray"];
    if (tmpPriceListDescriptionsArray) {
        [tmpPriceListDescriptionsArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__044", @"Preislistenbeschreibungen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpPriceListDescriptionsArray) {
            LocalizedDescription *tmpLocalizedDescription =
            [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"description"]]
                                              withCode:[NSString stringWithFormat:@"-%@-©-%@-", [serverData valueForKey:@"pricelisttype"],
                                                        [serverData valueForKey:@"pricelistno"]]
                                                forKey:@"PriceListDescription"
                                            localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                inCtx:self.ctx];
            if (tmpLocalizedDescription) {
                [self.ctx refreshObject:tmpLocalizedDescription
                                            mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__044", @"Preislistenbeschreibungen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpPriceListDescriptionsArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpPriceListDescriptionsArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__044", @"Preislistenbeschreibungen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfPriceListDescriptions"];
    } else {
        NSLog(@"syncERR: UpdateOfPriceListDescriptions");
        self.syncERR = YES;
    }
}

- (void)syncPriceListHeadersArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpPriceListHeadersArray = [self.downloadBuffer objectForKey:@"tmpPriceListHeadersArray"];
    if (tmpPriceListHeadersArray) {
        [tmpPriceListHeadersArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__045", @"Preislisten") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpPriceListHeadersArray) {
            // delete the old header and the lines via delete rule "cascade"
            [self.ctx deleteObject:[TemplateOrderHead templateHeadWithName:
                                                     [NSString stringWithFormat:@"-%@-©-%@-", [serverData valueForKey:@"pricelisttype"],
                                                      [serverData valueForKey:@"pricelistno"]]
                                                                                 clientData:[NSNumber numberWithInt:-1]
                                                                     inCtx:self.ctx]];
            id validTo = [serverData valueForKey:@"validto"];
            NSDate *validToDate = nil;
            if (validTo != nil) {
                validToDate = [DPHDateFormatter dateFromString:validTo withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
            }
            if (!validTo || ([validToDate compare:[NSDate date]] != NSOrderedAscending)) {
                // Insert the server data as new header. If the server sends a header it also has to send the related lines.
                TemplateOrderHead *priceListHeader = [TemplateOrderHead templateHeadWithName:
                                                      [NSString stringWithFormat:@"-%@-©-%@-", [serverData valueForKey:@"pricelisttype"],
                                                       [serverData valueForKey:@"pricelistno"]]
                                                                                  clientData:[NSNumber numberWithInt:-1]
                                                                      inCtx:self.ctx];
                if (priceListHeader) {
                    
                    if (![serverData valueForKey:@"validfrom"]) {
                        priceListHeader.templateValidFrom  = nil;
                    } else {
                        NSDate *date = [DPHDateFormatter dateFromString:[serverData valueForKey:@"validfrom"]
                                                          withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
                        priceListHeader.templateValidFrom  = date;
                    }
                    if (![serverData valueForKey:@"validto"]) {
                        priceListHeader.templateValidUntil = nil;
                    } else {
                        NSDate *date = [DPHDateFormatter dateFromString:[serverData valueForKey:@"validto"]
                                                          withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
                        priceListHeader.templateValidUntil = date;
                    }
                    if (![serverData valueForKey:@"deliveryfrom"]) {
                        priceListHeader.templateDeliveryFrom = nil;
                    } else {
                        NSDate *date = [DPHDateFormatter dateFromString:[serverData valueForKey:@"deliveryfrom"]
                                                          withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
                        priceListHeader.templateDeliveryFrom = date;
                    }
                    if (![serverData valueForKey:@"deliveryto"]) {
                        priceListHeader.templateDeliveryUntil = nil;
                    } else {
                        NSDate *date = [DPHDateFormatter dateFromString:[serverData valueForKey:@"deliveryto"]
                                                          withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
                        priceListHeader.templateDeliveryUntil = date;
                    }
                    [self.ctx refreshObject:priceListHeader mergeChanges:YES];
                }
                swapCount++;
                loopCount++;
            }
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__045", @"Preislisten") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpPriceListHeadersArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpPriceListHeadersArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__045", @"Preislisten") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfPriceListHeaders"];
    } else {
        NSLog(@"syncERR: UpdateOfPriceListHeaders");
        self.syncERR = YES;
    }
}

- (void)syncPriceListLinesArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpPriceListLinesArray = [self.downloadBuffer objectForKey:@"tmpPriceListLinesArray"];
    if (tmpPriceListLinesArray) {
        [tmpPriceListLinesArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__046", @"Preislisten-Details") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpPriceListLinesArray) {
            TemplateOrderLine *priceListLine =
            [TemplateOrderLine templateLineForTemplateHead:[TemplateOrderHead templateHeadWithName:
                                                            [NSString stringWithFormat:@"-%@-©-%@-", [serverData valueForKey:@"pricelisttype"],
                                                             [serverData valueForKey:@"pricelistno"]]
                                                                                        clientData:[NSNumber numberWithInt:-1]
                                                                            inCtx:self.ctx]
                                                withItemID:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]]
                                                   itemQTY:nil
                                                    userID:[NSNumber numberWithInt:-1]
                                    inCtx:self.ctx];
            if (priceListLine) {
                if (![serverData valueForKey:@"iteminfo"]) {
                    priceListLine.infoText = nil;
                } else {
                    priceListLine.infoText = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"iteminfo"]];
                }
                if (![serverData valueForKey:@"pricelistlineno"]) {
                    priceListLine.sortValue = nil;
                } else {
                    priceListLine.sortValue = [NSString stringWithFormat:@"%07ld", [[serverData valueForKey:@"pricelistlineno"] longValue]];
                }
                Item *tmpItem =
                [Item itemWithItemID:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"itemid"]] inCtx:self.ctx];
                if (tmpItem && (!tmpItem.storeAssortmentCode || ![tmpItem.storeAssortmentBit boolValue])) {
                    tmpItem.storeAssortmentBit  = [NSNumber numberWithBool:YES];
                    tmpItem.storeAssortmentCode = priceListLine.templateOrderHead.templateName;
                    [self.ctx refreshObject:tmpItem mergeChanges:YES];
                }
                [self.ctx refreshObject:priceListLine mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__046", @"Preislisten-Details") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpPriceListLinesArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        [TemplateOrderHead removeAllEmptyServerDomainTemplatesInCtx:self.ctx];
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpPriceListLinesArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__046", @"Preislisten-Details") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfPriceListLines"];
    } else {
        NSLog(@"syncERR: UpdateOfPriceListLines");
        self.syncERR = YES;
    }
}

- (void)syncProductGroupArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpProductGroupArray = [self.downloadBuffer objectForKey:@"tmpProductGroupArray"];
    if (tmpProductGroupArray) {
        [tmpProductGroupArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__047", @"Produktgruppen") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpProductGroupArray) {
            LocalizedDescription *tmpLocalizedDescription =
            [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                              withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                forKey:@"ItemProductGroup"
                                            localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                inCtx:self.ctx];
            if (tmpLocalizedDescription) {
                [self.ctx refreshObject:tmpLocalizedDescription
                                            mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__047", @"Produktgruppen") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpProductGroupArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpProductGroupArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__047", @"Produktgruppen") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemProductGroups"];
    } else {
        NSLog(@"syncERR: UpdateOfItemProductGroups");
        self.syncERR = YES;
    }
}

- (void)syncPriceListSortArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpPriceListSortArray = [self.downloadBuffer objectForKey:@"tmpPriceListSortArray"];
    if (tmpPriceListSortArray) {
        [tmpPriceListSortArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__048", @"Preislistensortierung") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpPriceListSortArray) {
            LocalizedDescription *tmpLocalizedDescription =
            [LocalizedDescription localizedDescription:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"text"]]
                                              withCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"code"]]
                                                forKey:@"ItemPriceListSort"
                                            localeCode:[NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]]
                                inCtx:self.ctx];
            if (tmpLocalizedDescription) {
                [self.ctx refreshObject:tmpLocalizedDescription
                                            mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__048", @"Preislistensortierung") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpPriceListSortArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpPriceListSortArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__048", @"Preislistensortierung") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfItemPriceListStort"];
    } else {
        NSLog(@"syncERR: UpdateOfItemPriceListSort");
        self.syncERR = YES;
    }
}

- (void)syncFaqArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpFaqArray = [self.downloadBuffer objectForKey:@"tmpFaqArray"];
    if (tmpFaqArray) {
        [tmpFaqArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__049", @"FAQ") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpFaqArray)
        {
            FaQ *tmpFaq = [FaQ faqWithServerData:serverData inCtx:self.ctx];
            if (tmpFaq) {
                [self.ctx refreshObject:tmpFaq mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__049", @"FAQ") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpFaqArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpFaqArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__049", @"FAQ") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfFaq"];
    } else {
        NSLog(@"syncERR: UpdateOfFaq");
        self.syncERR = YES;
    }
}


- (void)syncNewsletterArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpNewsletterArray = [self.downloadBuffer objectForKey:@"tmpNewsletterArray"];
    if (tmpNewsletterArray) {
        [tmpNewsletterArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__050", @"Newsletter") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        //NSLog(@"Hurra! Dies ist die tmpNewsletterArray: %@", tmpNewsletterArray);
        for (NSDictionary *serverData in tmpNewsletterArray)
        {
            Newsletter *tmpNewsletter = [Newsletter newsletterWithServerData:serverData inCtx:self.ctx];
            if (tmpNewsletter) {
                // hier erfolgt die Abfrage, ob es neue Newsletter gibt, und dies fragen wir per "alertBit" ab, welches ein BOOL ist
                if (tmpNewsletter.alertBit) {
                    self.newsletterAlert = YES;
                }
                [self.ctx refreshObject:tmpNewsletter mergeChanges:YES];
                //[Newsletter newsletterWithServerData:serverData inCtx:self.ctx]
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__050", @"Newsletter") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpNewsletterArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpNewsletterArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__050", @"Newsletter") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfNewsletter"];
    } else {
        NSLog(@"syncERR: UpdateOfNewsletter");
        self.syncERR = YES;
    }
}
- (void)syncPromotionArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpPromotionArray = [self.downloadBuffer objectForKey:@"tmpPromotionArray"];
    if (tmpPromotionArray) {
        [tmpPromotionArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__051", @"Promotion") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpPromotionArray) {
            Promotion *tmpPromotion = [Promotion promotionWithServerData:serverData inCtx:self.ctx];
            if (tmpPromotion) {
                [self.ctx refreshObject:tmpPromotion mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__051", @"Promotion") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpPromotionArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpPromotionArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__051", @"Promotion") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfPromotion"];
    } else {
        NSLog(@"syncERR: UpdateOfPromotion");
        self.syncERR = YES;
    }
}

- (void)syncBasketanalysisArrayWithActivityInfo:(DSPF_Activity *)showActivity {
    NSArray *tmpBasketanalysisArray = [self.downloadBuffer objectForKey:@"tmpBasketanalysisArray"];
    if (tmpBasketanalysisArray) {
        [tmpBasketanalysisArray retain];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__052", @"Warenkorbanalyse") stringByAppendingFormat:@"  (%@)", @"0%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        NSAutoreleasePool *tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
        NSUInteger swapCount = 0;
        NSUInteger loopCount = 0;
        for (NSDictionary *serverData in tmpBasketanalysisArray) {
            BasketAnalysis *tmpBasketAnalysis = [BasketAnalysis basketanalysisWithServerData:serverData
                                                                      inCtx:self.ctx];
            if (tmpBasketAnalysis) {
                [self.ctx refreshObject:tmpBasketAnalysis mergeChanges:YES];
            }
            swapCount++;
            loopCount++;
            if (swapCount == TMP_AUTORELEASEPOOL_SWAP_LIMIT) {
                [self.ctx saveIfHasChanges];
                [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
                [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__052", @"Warenkorbanalyse") stringByAppendingFormat:@"  (%@)",
                                          [NSString stringWithFormat:@"%i%%", loopCount * 100 / tmpBasketanalysisArray.count]]];
                [DPHUtilities waitForAlertToShow:0.1f];
                tmpAutoreleasePool = [[NSAutoreleasePool alloc] init];
                swapCount = 0;
            }
        }
        [self.ctx saveIfHasChanges];
        [tmpAutoreleasePool drain]; tmpAutoreleasePool = nil;
        [tmpBasketanalysisArray release];
        [showActivity.alertView setMessage:[NSLocalizedString(@"MESSAGE__052", @"Warenkorbanalyse") stringByAppendingFormat:@"  (%@)", @"100%"]];
        [DPHUtilities waitForAlertToShow:0.1f];
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forKey:@"lastUpdateOfBasketanalysis"];
    } else {
        NSLog(@"syncERR: UpdateOfBasketanalysis");
        self.syncERR = YES;
    }
}

- (IBAction)syncALL {
    [self syncALLWithUserInfo:nil];
}

- (IBAction)syncALLWithUserInfo:(NSDictionary *) userInfo {
	DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung") 
                                         messageText:NSLocalizedString(@"MESSAGE_012", @"Bitte warten Sie bis alle Daten geladen wurden.")
                                   cancelButtonTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen") 
                                            delegate:self] retain];
    self.syncERR = NO;
    dispatch_async(importQueue, ^{ 
        NSDate *tmpTask = [NSDate date];
        [self.taskControl addObject:tmpTask];
        __block UIBackgroundTaskIdentifier myDownloadTask;
        UIApplication    *myApp = [UIApplication sharedApplication];
        myDownloadTask = [myApp beginBackgroundTaskWithExpirationHandler:^{
            [myApp endBackgroundTask:myDownloadTask]; 
            myDownloadTask = UIBackgroundTaskInvalid;
        }];
        
        
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            NSArray *tmpUsersArray           = [self serverDataForKey:@"user" option:nil];           // done
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            NSArray *tmpTrucksArray          = [self serverDataForKey:@"truck" option:nil];          // done
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            NSArray *tmpTraceTypesArray      = [self serverDataForKey:@"trace_type" option:nil];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            //NSArray *tmpToursArray           = [self serverDataForKey:@"tour" option:nil];           // done
            //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self syncUsersArray:tmpUsersArray                                                      withActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{
                [self syncTrucksArray:tmpTrucksArray                                                    withActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{
                [self syncTraceTypesArray :tmpTraceTypesArray                                           withActivityInfo:showActivity];});
            //dispatch_async(dispatch_get_main_queue(), ^{
            //    [self syncToursArray:tmpToursArray                                                      withActivityInfo:showActivity];});
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [showActivity closeActivityInfo];
                [showActivity release];
                [self updateViewContent];
                [[NSUserDefaults standardUserDefaults] setObject:self.downloadCacheControl forKey:@"downloadCacheControl"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationQueue defaultQueue] enqueueNotification:
                 [NSNotification notificationWithName:@"syncALLdone" object:self userInfo:userInfo] postingStyle:NSPostNow];
            });
            [self.taskControl removeObject:tmpTask];
            myDownloadTask = [self cancelBackgroundTask:myDownloadTask];

            return;
        }
        
        NSArray *tmpUsersArray           = [self serverDataForKey:@"user" option:nil];           // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpLocationsArray       = [self serverDataForKey:@"location" option:nil];       // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
	    NSArray *tmpLocationGroupsArray  = [self serverDataForKey:@"location_group" option:nil]; // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpLocationAliasesArray = [self serverDataForKey:@"location_alias" option:nil]; // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpTrucksArray          = [self serverDataForKey:@"truck" option:nil];          // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpTruckTypesArray      = [self serverDataForKey:@"truck_type" option:nil];     // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpToursArray           = [self serverDataForKey:@"tour" option:nil];           // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
	    NSArray *tmpTourExceptionArray   = [self serverDataForKey:@"tour_exception" option:nil]; // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
    	NSArray *tmpDeparturesArray      = [self serverDataForKey:@"departure" option:nil];      // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpSchedulesArray       = [self serverDataForKey:@"schedule" option:nil];       // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpTransportsArray      = [self serverDataForKey:@"transport" option:nil];      // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpCargosArray          = [self serverDataForKey:@"cargo" option:nil];          // done
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
		NSArray *tmpTraceTypesArray      = [self serverDataForKey:@"trace_type" option:nil];
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpTransportGroupsArray = [self serverDataForKey:@"transport_group" option:nil];
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpLocalizedDescription = [self serverDataForKey:@"localized_description" option:nil];
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        if (PFTourTypeSupported(@"1X1", nil)) {
            [self.downloadBuffer setValue:[self serverDataForKey:@"item" option:nil]                        forKey:@"tmpItemsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemdescription" option:nil]             forKey:@"tmpItemDescriptionsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemcode" option:nil]                    forKey:@"tmpItemCodesArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"item_image" option:nil]                    forKey:@"tmpItemImages"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        }
        if (PFBrandingSupported(BrandingBiopartner, nil)) {
            [self.downloadBuffer setValue:[self serverDataForKey:@"store" option:nil]                       forKey:@"tmpStoresArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"item" option:nil]                        forKey:@"tmpItemsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemdescription" option:nil]             forKey:@"tmpItemDescriptionsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemcode" option:nil]                    forKey:@"tmpItemCodesArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self.downloadBuffer valueForKey:@"tmpItemsArray"]                forKey:@"tmpItemAssortmentsArray"];
            /*
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemprice" option:nil]                   forKey:@"tmpItemPricesArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemassortment" option:nil]              forKey:@"tmpItemAssortmentsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"inventoryhead" option:nil]               forKey:@"tmpInventoryHeadsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            // @"archiveorderhead";
            // @"archiveorderline";
            [self.downloadBuffer setValue:[self serverDataForKey:@"iteminfodescription" option:nil]         forKey:@"tmpItemProductInformationsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            // @"promotionitem";
            [self.downloadBuffer setValue:[self serverDataForKey:@"bundleitem" option:nil]                  forKey:@"tmpBasketanalysisArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"category" option:nil]                    forKey:@"tmpItemCategoriesArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"certification" option:nil]               forKey:@"tmpItemCertificationsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"trademarkholder" option:nil]             forKey:@"tmpItemTrademarkHoldersArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"countrydescription" option:nil]          forKey:@"tmpItemCountriesOfOriginArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"package" option:nil]                     forKey:@"tmpItemPackagesArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"unitofmeasure" option:nil]               forKey:@"tmpItemUnitsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"pricelistsort" option:nil]               forKey:@"tmpProductGroupArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"pricelistheaderdescription" option:nil]  forKey:@"tmpPriceListDescriptionsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"pricelistheader" option:nil]             forKey:@"tmpPriceListHeadersArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"pricelistline" option:nil]               forKey:@"tmpPriceListLinesArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"productgroup" option:nil]                forKey:@"tmpPriceListSortArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"faq" option:nil]                         forKey:@"tmpFaqArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            [self.downloadBuffer setValue:[self serverDataForKey:@"information" option:nil]                 forKey:@"tmpNewsletterArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            */
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [showActivity.alertView setTitle:NSLocalizedString(@"TITLE_039", @"Datenspeicherung")];
            [DPHUtilities waitForAlertToShow:0.1f];
            [showActivity setCancelButtonIndex: -1];
            [DPHUtilities waitForAlertToShow:0.236f];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncUsersArray:tmpUsersArray                                                      withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncLocationsArray :tmpLocationsArray                                             withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncLocationGroupsArray:tmpLocationGroupsArray                                    withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncLocationAliasesArray:tmpLocationAliasesArray                                  withActivityInfo:showActivity];}); 
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncTraceTypesArray :tmpTraceTypesArray                                           withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncTrucksArray:tmpTrucksArray                                                    withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncTruckTypesArray:tmpTruckTypesArray                                            withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncToursArray:tmpToursArray                                                      withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [self syncTourExceptionArray:tmpTourExceptionArray                                      withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncLocalizedDescriptonArray:tmpLocalizedDescription                              withActivityInfo:showActivity];});
        if (PFTourTypeSupported(@"1XX", nil)) {
            if ([NSUserDefaults isRunningWithTourAdjustment] || PFBrandingSupported(BrandingTechnopark, nil)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncTransportGroupsArray:tmpTransportGroupsArray                          withActivityInfo:showActivity];});
            } else {
                if ([NSUserDefaults currentTourId]) {
                    // All transportdata and cargodata are assigned to the current TourID !
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self syncCargosArray:tmpCargosArray                                        withActivityInfo:showActivity];});
                }
            }
            // CONSIDER IMPORT-SEQUENCE! Schedule/Departure could create a reference to TransportGroups
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!PFBrandingSupported(BrandingTechnopark, nil))
                    [self syncSchedulesArray:tmpSchedulesArray                                          withActivityInfo:showActivity];});
        }
        // CONSIDER IMPORT-SEQUENCE! Departure could create a reference to TransportGroups
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncDeparturesArray:tmpDeparturesArray        option:nil                          withActivityInfo:showActivity];});
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncTransportsArray:tmpTransportsArray                                            withActivityInfo:showActivity];});
        if (PFTourTypeSupported(@"1X1", nil)) {
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemDescriptionsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemCodesArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemImagesWithActivityInfo:showActivity];});
        }
        if (PFBrandingSupported(BrandingBiopartner, BrandingTechnopark, nil)) {
            if (!PFBrandingSupported(BrandingTechnopark, nil))
                dispatch_async(dispatch_get_main_queue(), ^{[self syncStoresArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemDescriptionsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemCodesArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemAssortmentsArrayWithActivityInfo:showActivity];});
            /*
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemPricesArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncInventoryHeadsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemProductInformationsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncBasketanalysisArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemCategoriesArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemCertificationsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemTrademarkHoldersArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemCountriesOfOriginArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemPackagesArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncItemUnitsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncProductGroupArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncPriceListDescriptionsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncPriceListHeadersArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncPriceListLinesArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncPriceListSortArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncFaqArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{[self syncNewsletterArrayWithActivityInfo:showActivity];});
            */
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [showActivity closeActivityInfo];
            [showActivity release];
            [self updateViewContent];
            [[NSUserDefaults standardUserDefaults] setObject:self.downloadCacheControl forKey:@"downloadCacheControl"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationQueue defaultQueue] enqueueNotification:
             [NSNotification notificationWithName:@"syncALLdone" object:self userInfo:userInfo] postingStyle:NSPostNow];
        });
        [self.taskControl removeObject:tmpTask];
        myDownloadTask = [self cancelBackgroundTask:myDownloadTask];
     });    
}

- (IBAction)syncTOUR {
    _isTourLoaded = NO;
	DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung") 
                                         messageText:NSLocalizedString(@"MESSAGE_013", @"Bitte warten Sie bis die Fahraufträge geladen wurden.") 
                                   cancelButtonTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen") 
                                            delegate:self] retain];
    self.syncERR = NO;
	dispatch_async(importQueue, ^{ 
        NSDate *tmpTask = [NSDate date];
        [self.taskControl addObject:tmpTask];
        __block UIBackgroundTaskIdentifier myDownloadTask;
        UIApplication    *myApp = [UIApplication sharedApplication];
        myDownloadTask = [myApp beginBackgroundTaskWithExpirationHandler:^{
            [myApp endBackgroundTask:myDownloadTask]; 
            myDownloadTask = UIBackgroundTaskInvalid;
        }];
        NSArray *tmpLocationsArray       = nil;
        NSArray *tmpDeparturesArray      = nil;
        NSArray *tmpTransportGroupsArray = nil;
        NSArray *tmpSchedulesArray       = nil;
        NSArray *tmpCargosArray          = nil;
        NSArray *tmpItemsArray           = nil;
        if (PFTourTypeSupported(@"1XX", nil)) {
            //tmpSchedulesArray            = [self serverDataForKey:@"schedule" option:nil];
            //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            if ([NSUserDefaults isRunningWithTourAdjustment]) {
                tmpTransportGroupsArray = [self serverDataForKey:@"transport_group" option:FmtStr(@"tour_id=%@", [NSUserDefaults currentTourId])];
                if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            } else {
                if ([NSUserDefaults currentTourId]) {
                    // All transportdata and cargodata are assigned to the current TourID !
                    tmpCargosArray          = [self serverDataForKey:@"cargo" option:nil];
                    if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
                }
            }
        } else if (PFTourTypeSupported(@"0X1", nil)) {
            tmpLocationsArray            = [self serverDataForKey:@"location"  option:nil];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            tmpDeparturesArray           = [self serverDataForKey:@"departure" option:nil];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        }
        
        NSArray *tmpTransportsArray      = nil;
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            
            tmpLocationsArray            = [self serverDataForKey:@"location"  option:FmtStr(@"tour_id=%@", [NSUserDefaults currentTourId])];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            tmpDeparturesArray           = [self serverDataForKey:@"departure" option:FmtStr(@"tour_id=%@", [NSUserDefaults currentTourId])];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [showActivity.alertView setTitle:NSLocalizedString(@"TITLE_039", @"Datenspeicherung")];
                [DPHUtilities waitForAlertToShow:0.1f];
                [showActivity setCancelButtonIndex: -1];
                [DPHUtilities waitForAlertToShow:0.236f];});
            if (tmpLocationsArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncLocationsArray:tmpLocationsArray              withActivityInfo:showActivity];});
            }
            if (tmpTransportGroupsArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncTransportGroupsArray:tmpTransportGroupsArray  withActivityInfo:showActivity];});
            }
            if (tmpDeparturesArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncDeparturesArray:tmpDeparturesArray option:nil withActivityInfo:showActivity];});
            }
            if (tmpSchedulesArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncSchedulesArray:tmpSchedulesArray              withActivityInfo:showActivity];});
            }
            if (tmpCargosArray) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self syncCargosArray:tmpCargosArray                    withActivityInfo:showActivity];});
            }
            
            /**** We can go further with UI here! *****/
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [showActivity closeActivityInfo];
                [showActivity release];
                [[NSNotificationQueue defaultQueue] enqueueNotification:
                 [NSNotification notificationWithName:@"syncTOURdone" object:self userInfo:nil] postingStyle:NSPostNow];
            });
            
            //[self.downloadBuffer setValue:[self serverDataForKey:@"store" option:nil]                       forKey:@"tmpStoresArray"];
            //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            
            tmpTransportsArray = [self serverDataForKey:@"transport" option:FmtStr(@"tour_id=%@", [NSUserDefaults currentTourId])];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            
            [self.downloadBuffer setValue:[self serverDataForKey:@"item" option:FmtStr(@"tour_id=%@", [NSUserDefaults currentTourId])]                        forKey:@"tmpItemsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            
            [self.downloadBuffer setValue:[self serverDataForKey:@"itemdescription" option:FmtStr(@"tour_id=%@", [NSUserDefaults currentTourId])]             forKey:@"tmpItemDescriptionsArray"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            
            //[self.downloadBuffer setValue:[self serverDataForKey:@"itemcode" option:nil]                    forKey:@"tmpItemCodesArray"];
            //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            //[self.downloadBuffer setValue:[self.downloadBuffer valueForKey:@"tmpItemsArray"]                forKey:@"tmpItemAssortmentsArray"];
            //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        }
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self syncItemsArrayWithActivityInfo:showActivity];});
            dispatch_async(dispatch_get_main_queue(), ^{
                [self syncItemDescriptionsArrayWithActivityInfo:showActivity];});
            //dispatch_async(dispatch_get_main_queue(), ^{[self syncItemCodesArrayWithActivityInfo:showActivity];});
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncTransportsArray:tmpTransportsArray                withActivityInfo:showActivity];});
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[showActivity closeActivityInfo];
            //[showActivity release];
            [self updateViewContent];
            [[NSUserDefaults standardUserDefaults] setObject:self.downloadCacheControl forKey:@"downloadCacheControl"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationQueue defaultQueue] enqueueNotification:
             [NSNotification notificationWithName:@"syncTOURdoneTotal" object:self userInfo:nil] postingStyle:NSPostNow];});
        [self.taskControl removeObject:tmpTask];
        myDownloadTask = [self cancelBackgroundTask:myDownloadTask];
        _isTourLoaded = YES;
    });
}

- (BOOL) allowsDrivingWithoutFreshData {
    BOOL allows = NO;
    if (PFTourTypeSupported(@"0X0", nil) || (PFTourTypeSupported(@"0X1", nil) && PFBrandingSupported(BrandingUnilabs, nil))) {
        allows = YES;
    }
    return allows;
}

- (IBAction)syncTOURwithOption:(NSString *)option {
    self.savedIdleTimerStatus = [UIApplication sharedApplication].idleTimerDisabled;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung") 
                                                   messageText:NSLocalizedString(@"MESSAGE_013", @"Bitte warten Sie bis die Fahraufträge geladen wurden.") 
                                             cancelButtonTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen") 
                                                      delegate:self] retain];
    self.syncERR = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [showActivity setCancelButtonIndex: -1];
        [DPHUtilities waitForAlertToShow:0.236f];
    });
    NSArray *tmpLocationsArray  = nil;
    NSArray *tmpDeparturesArray = nil;
    NSArray *tmpTransportGroupsArray = nil;
    NSArray *tmpTransportsArray = nil;
    NSArray *tmpTransportsDeleteArray = nil;
    NSArray *tmpCargoArray = nil;
    BOOL forceFullSync = NO;
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        forceFullSync = YES;
    }
    if (option.length > 0) {
        NSString *syncLocationOption = nil;
        if (PFTourTypeSupported(@"0X0", nil) || PFBrandingSupported(BrandingCCC_Group,BrandingTechnopark, BrandingNONE, nil) || (PFTourTypeSupported(@"0X1", nil) && PFBrandingSupported(BrandingUnilabs, nil))) {
            syncLocationOption = option;
        }
        while (!tmpLocationsArray) {
            tmpLocationsArray  = [self serverDataForKey:@"location"  option:syncLocationOption forceFullSync:forceFullSync];
            if ([self allowsDrivingWithoutFreshData]) break;
            if (!tmpLocationsArray) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
            }
        }
        while (!tmpDeparturesArray) {
            tmpDeparturesArray = [self serverDataForKey:@"departure" option:option forceFullSync:forceFullSync];
            if ([self allowsDrivingWithoutFreshData]) break;
            if (!tmpDeparturesArray) {
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
            }
        }
        if (PFBrandingSupported(BrandingCCC_Group, BrandingTechnopark, nil)) {
            while (!tmpTransportGroupsArray) {
                tmpTransportGroupsArray = [self serverDataForKey:@"transport_group" option:option forceFullSync:forceFullSync];
                if (!tmpTransportGroupsArray) {
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
                }
            }
            while (!tmpTransportsArray) {
                tmpTransportsArray = [self serverDataForKey:@"transport" option:option forceFullSync:forceFullSync];
                if (!tmpTransportsArray) {
                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
                }
            }
            
            if (!PFBrandingSupported(BrandingTechnopark, nil))
            {
            
                tmpCargoArray = [self serverDataForKey:@"cargo" option:option forceFullSync:forceFullSync];
                while (!tmpTransportsDeleteArray) {
                    tmpTransportsDeleteArray = [self serverDataForKey:@"transport_delete" option:option forceFullSync:  forceFullSync];
                    if (!tmpTransportsDeleteArray) {
                        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
                    }
                }
            }
            
            NSDate *tmpTask = [NSDate date];
            [self.taskControl addObject:tmpTask];
            __block UIBackgroundTaskIdentifier myDownloadTask;
            UIApplication    *myApp = [UIApplication sharedApplication];
            myDownloadTask = [myApp beginBackgroundTaskWithExpirationHandler:^{
                [myApp endBackgroundTask:myDownloadTask];
                myDownloadTask = UIBackgroundTaskInvalid;
            }];
            
            if (PFBrandingSupported(BrandingTechnopark, nil))
            {
                //[self.downloadBuffer setValue:[self serverDataForKey:@"store" option:nil]                       forKey:@"tmpStoresArray"];
                //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
                [self.downloadBuffer setValue:[self serverDataForKey:@"item" option:nil]                        forKey:@"tmpItemsArray"];
                if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
                //[self.downloadBuffer setValue:[self serverDataForKey:@"itemdescription" option:nil]             forKey:@"tmpItemDescriptionsArray"];
                //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
                //[self.downloadBuffer setValue:[self serverDataForKey:@"itemcode" option:nil]                    forKey:@"tmpItemCodesArray"];
                //if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
                //[self.downloadBuffer setValue:[self.downloadBuffer valueForKey:@"tmpItemsArray"]                forKey:@"tmpItemAssortmentsArray"];
            }
        }
    } else {
        tmpLocationsArray  = [self serverDataForKey:@"location"  option:option forceFullSync:forceFullSync];
        tmpDeparturesArray = [self serverDataForKey:@"departure" option:option forceFullSync:forceFullSync];
    }
    
    
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:self.savedIdleTimerStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        [showActivity.alertView setTitle:NSLocalizedString(@"TITLE_039", @"Datenspeicherung")];
        [DPHUtilities waitForAlertToShow:0.1f];});
    if (tmpLocationsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncLocationsArray:tmpLocationsArray                 withActivityInfo:showActivity];});
    }
    if (tmpTransportGroupsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncTransportGroupsArray:tmpTransportGroupsArray     withActivityInfo:showActivity];});
    }
    // CONSIDER IMPORT-SEQUENCE! Departure could create a reference to TransportGroups
    if (tmpDeparturesArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncDeparturesArray:tmpDeparturesArray option:option withActivityInfo:showActivity];});
    }
    if (tmpTransportsArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncTransportsArray:tmpTransportsArray               withActivityInfo:showActivity];});
    }
    if (tmpCargoArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncCargosArray:tmpCargoArray               withActivityInfo:showActivity];});
    }
    if (tmpTransportsDeleteArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncTransportsDeleteArray:tmpTransportsDeleteArray   withActivityInfo:showActivity];});
    }
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syncItemsArrayWithActivityInfo:showActivity];});
        //dispatch_async(dispatch_get_main_queue(), ^{
        //    [self syncItemDescriptionsArrayWithActivityInfo:showActivity];});
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [showActivity closeActivityInfo];
        [showActivity release];
        [self updateViewContent];
        [[NSUserDefaults standardUserDefaults] setObject:self.downloadCacheControl forKey:@"downloadCacheControl"];
        [[NSUserDefaults standardUserDefaults] synchronize];});
}

- (void) dspf_Activity:(DSPF_Activity *)sender didCancelActivity:(NSString *)messageTitle {
    [self.taskControl removeAllObjects];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[UIApplication sharedApplication] setIdleTimerDisabled:self.savedIdleTimerStatus];
    self.downloadCacheControl = [NSMutableDictionary dictionaryWithDictionary:
                                 [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"downloadCacheControl"]];
}

+ (NSString *) hermesServerURL {
    NSString *savedPort = [NSUserDefaults hermesServerPort];
    NSString *portToUse = @"";
    if (savedPort && ![savedPort isEqualToString:@""] && ![savedPort isEqualToString:@"80"]) {
        portToUse = [NSString stringWithFormat:@":%@", savedPort];
    }
    return [NSString stringWithFormat:@"%@://%@%@/%@", [NSUserDefaults hermesServerScheme], [NSUserDefaults hermesServerHost], portToUse, [NSUserDefaults hermesServerPath]];
}

+ (NSArray *) arrayFromDownloadedServerData:(NSData *) data downloadingKey:(NSString *) aKey {
    NSError *error = nil;
    NSDictionary *serverData = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!serverData && [aKey isEqualToString:@"trace_type"]) {
        serverData = [NSDictionary dictionaryWithContentsOfFile:
                      [[[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"] stringByAppendingPathComponent:@"adm_Trace_Type.plist"]];
    }
    NSArray *array = [serverData valueForKey:aKey];
    //if (PFDeviceIsSimulator()) {
        NSLog(@"Downloaded %@ (%d)", aKey, [array count]);
    //}
    return array;
}

- (void)viewDidUnload {
    [super viewDidUnload];

    
    self.standVomSyncLabel 			 = nil;
    self.abholauftraegeSyncLabel  	 = nil;    
    self.fahrplanSyncLabel  		 = nil;      
    self.sonderzieleSyncLabel   	 = nil; 
    self.orteSyncLabel  			 = nil;
    self.tourenSyncLabel  			 = nil;
    self.lastUpdateOfUsers			 = nil;
	self.lastUpdateOfTruckTypes		 = nil;
	self.lastUpdateOfTrucks			 = nil;
	self.lastUpdateOfLocationGroups  = nil;
    self.lastUpdateOfLocationAliases = nil;
	self.lastUpdateOfLocations		 = nil;
	self.lastUpdateOfTours			 = nil;
	self.lastUpdateOfDepartures		 = nil;
    self.lastUpdateOfTransportGroups = nil;
    self.lastUpdateOfTransports		 = nil;
    self.unsynchronizedLabel         = nil;
    self.countOfUnsynchronizedLabel  = nil;
}


- (void)dealloc {
    //FIXME: dealloc from this class is never called!
    [taskControl removeAllObjects];
    [taskControl release];
    dispatch_release(importQueue);
    [buttons release];
    [unsynchronizedLabel         release];
    [standVomSyncLabel           release];    
    [abholauftraegeSyncLabel     release];     
    [fahrplanSyncLabel           release];     
    [sonderzieleSyncLabel        release]; 
    [orteSyncLabel               release];    
    [tourenSyncLabel             release];
    [downloadBuffer              release];
    [downloadCacheControl        release];
	[ctx		 release];
	[udid						 release];
	[lastUpdateOfUsers		     release];
	[lastUpdateOfTruckTypes		 release];
	[lastUpdateOfTrucks			 release];
	[lastUpdateOfLocationGroups  release];
    [lastUpdateOfLocationAliases release];
	[lastUpdateOfLocations		 release];
	[lastUpdateOfTours			 release];
	[lastUpdateOfDepartures		 release];
    [lastUpdateOfTransportGroups release];
    [lastUpdateOfTransports		 release];
    [countOfUnsynchronizedLabel  release];
    [syncError                   release];
    [_notifyObject               release];
    [super dealloc];
}


@end

/*  uncomment this or install the certificates */
 
@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)aHost {
	return YES;
}

@end