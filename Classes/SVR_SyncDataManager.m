//
//  SVR_SyncDataManager.m
//  Hermes
//
//  Created by Lutz  Thalmann on 08.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "SVR_SyncDataManager.h"
#import "SVR_NetworkMonitor.h"
#import "DSPF_Activity.h"

#import "Trace_Type.h"
#import "Truck.h"
#import "Tour.h"
#import "User.h"
#import "Location.h"
#import "Departure.h"
#import "Transport_Group.h"
#import "Transport.h"
#import "Store.h"
#import "Item.h"

#import "Trace_Log.h"
#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"

#import "DSPF_Synchronisation.h"


#pragma mark -

NSString * const SVR_SyncDataManagerStatusKey = @"status";

@interface SVR_SyncDataManager()
@property (atomic, retain) NSMutableOrderedSet          *syncTasks;
@property (atomic, retain) NSMutableArray               *taskControl;
@property (atomic, retain) SyncTask                 *syncTask_PND;
@property (atomic)         NSUInteger                    syncTask_ERR_Count;
@property (atomic, retain) NSString                     *syncTask_ERR_Text;
@property (atomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (atomic, retain) NSString                     *udid;
@property (atomic, assign) SVR_SyncDataManagerStatus status;
@end

@implementation SVR_SyncDataManager {
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    dispatch_queue_t              downloadQueue;
    NSString                     *udid;
    UIBackgroundTaskIdentifier    myUploadTask;
    NSMutableArray               *taskControl;
    NSMutableOrderedSet          *syncTasks;
    SyncTask                 *syncTask_PND;
    NSUInteger                    syncTask_ERR_Count;
    NSString                     *syncTask_ERR_Text;
    NSURLConnection              *uploadConnection;
    NSMutableData                *uploadResponseData;
}

@synthesize persistentStoreCoordinator;
@synthesize udid;
@synthesize taskControl;
@synthesize syncTasks;
@synthesize syncTask_PND;
@synthesize syncTask_ERR_Count;
@synthesize syncTask_ERR_Text;
@synthesize status;

#pragma mark - Initialization

- (id) init {
    if ((self = [super init])) {
        self.status = SVR_SyncDataManagerStatusIdle;
        
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(sendTraceLogData:)       name:@"sendTraceLogData" object:nil];
        [notificationCenter addObserver:self selector:@selector(sendTraceLogDataOnly:)   name:@"sendTraceLogDataOnly" object:nil];
        [notificationCenter addObserver:self selector:@selector(sendRentalAndRestitutionData:) name:@"sendRentalAndRestitutionData" object:nil];
        [notificationCenter addObserver:self selector:@selector(sendApplePushnotificationID:) name:@"sendApplePushnotificationID" object:nil];
        [notificationCenter addObserver:self selector:@selector(sendRemoteNotificationResponse:) name:@"sendRemoteNotificationResponse" object:nil];
        [notificationCenter addObserver:self selector:@selector(sendSyncTask:) name:@"sendSyncTask" object:nil];
        // udid = @"9885bdf05e2945b69f99a41fe842cd7d0f0fbe35";
        udid = [PFDeviceId() retain];
        taskControl   = [[NSMutableArray array] retain];
        syncTasks     = [[NSMutableOrderedSet alloc] init];
        syncTask_ERR_Text = [[NSString string] retain];
        downloadQueue = dispatch_queue_create("TourTransportDownloadQueue", NULL);
        uploadResponseData = [[NSMutableData alloc] init];
        persistentStoreCoordinator = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] persistentStoreCoordinator] retain];
        [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkProblemIndicatorVisible:NO];
    }
    return self;
}

- (UIBackgroundTaskIdentifier )cancelBackgroundTask:(UIBackgroundTaskIdentifier )backgroundTask { 
    if (backgroundTask != UIBackgroundTaskInvalid) { 
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask]; 
        backgroundTask = UIBackgroundTaskInvalid;
    }
    return backgroundTask;
}

- (NSArray *)serverDataForKey:(NSString *)aKey {
    NSArray  *serverData = nil;
    NSError  *error      = nil;
    NSHTTPURLResponse    *response;
    NSData               *tmpData;
    NSString *serverURL = [[DSPF_Synchronisation hermesServerURL] stringByAppendingFormat:@"/download/%@?returnType=xmlplist&zipped=true&sn=%@", aKey, self.udid];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"GET"];
    if ((PFTourTypeSupported(@"1XX", nil)  && [NSUserDefaults isRunningWithTourAdjustment] && [aKey isEqualToString:@"transport"]) ||
        (PFTourTypeSupported(@"1XX", nil)  && [aKey isEqualToString:@"cargo"]) ||
        (PFTourTypeSupported(@"1XX", nil)  && [aKey isEqualToString:@"schedule"]))
    {
        if ([[NSUserDefaults currentTourId] longLongValue] != 0 && [[NSUserDefaults currentTruckId] longLongValue] != 0) {
            serverURL = [serverURL stringByAppendingFormat:@"&tvid=%@&trid=%@", [NSUserDefaults currentTourId], [NSUserDefaults currentTruckId]];
        }
    }
    [request setURL:[NSURL URLWithString:serverURL]];
    if ([NSURLConnection canHandleRequest:request]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        tmpData  = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            serverData = [DSPF_Synchronisation arrayFromDownloadedServerData:tmpData downloadingKey:aKey];
        }
    }
    return serverData;
}

- (void)beginUpload {
    self.syncTask_PND = [self.syncTasks firstObject];
    UIApplication  *myApp = [UIApplication sharedApplication];
    myUploadTask = [myApp beginBackgroundTaskWithExpirationHandler:^{ 
        [myApp endBackgroundTask:myUploadTask];
        myUploadTask = UIBackgroundTaskInvalid;
        self.syncTask_PND = nil;
    }];
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendSyncTask" object:self userInfo:nil] postingStyle:NSPostASAP];
}

- (void)addTraceLogSyncTasks { 
    NSManagedObjectContext *uploadContext = [[NSManagedObjectContext alloc] init];
    [uploadContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [uploadContext setUndoManager:nil];
    [uploadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    NSArray *bufferedTraceLogs = [NSArray arrayWithArray:
                                  [Trace_Log withPredicate:[SVR_SyncDataManager predicateForTraceLogsToSynchronize]
                                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"trace_log_id" ascending:YES]] inCtx:uploadContext]];
    for (Trace_Log *tmpTrace_Log in bufferedTraceLogs) {
        NSDictionary *userInfo = [tmpTrace_Log userInfoDictionary];
        if (!tmpTrace_Log.transport_id.from_departure_id && userInfo == nil) {
            // bug in DSPF_Finish before 10.08.2011 inserted these records without a from_departure. 
            [uploadContext deleteObject:tmpTrace_Log];
            [uploadContext saveIfHasChanges];
            continue;
        }
        NSMutableDictionary *syncToServer = [[NSMutableDictionary alloc] initWithCapacity:12];
        [syncToServer setValue:tmpTrace_Log.user_id.user_id                                        forKey:@"user_id"];
        [syncToServer setValue:tmpTrace_Log.truck_id.truck_id			                           forKey:@"truck_id"];
        if ([tmpTrace_Log.trace_type_id isTypeInWorkingRange] || [tmpTrace_Log.trace_type_id.trace_type_id intValue] == TraceTypeValueReuseBox) {
            NSMutableString *borderedCode = [[[NSMutableString alloc] initWithString:tmpTrace_Log.transport_id.code] autorelease];
            NSRange plainRange = {.location = 1, .length = borderedCode.length -2};
            NSString *plainCode = [borderedCode substringWithRange:plainRange];
            [syncToServer setValue:plainCode                                  forKey:@"transport_code"];
            if (tmpTrace_Log.transport_id.transport_group_id && PFBrandingSupported(BrandingTechnopark, nil)) {
                [syncToServer setValue:tmpTrace_Log.transport_id.transport_group_id.task           forKey:@"task"];
            }
            
        } else {
            [syncToServer setValue:@""                                                             forKey:@"transport_code"];
            if (tmpTrace_Log.transport_id.transport_group_id) {
                [syncToServer setValue:tmpTrace_Log.transport_id.transport_group_id.task           forKey:@"task"];
            }
        }
        [syncToServer setValue:tmpTrace_Log.transport_id.isPallet                                  forKey:@"is_pallet"];
        [syncToServer setValue:tmpTrace_Log.transport_id.tour_id.tour_id                           forKey:@"tour_id"];
        [syncToServer setValue:tmpTrace_Log.trace_time					                           forKey:@"trace_time"];
        [syncToServer setValue:tmpTrace_Log.trace_type_id.trace_type_id                            forKey:@"trace_type_id"];
        [syncToServer setValue:tmpTrace_Log.transport_id.from_departure_id.departure_id            forKey:@"tracking_departure_id"];
        [syncToServer setValue:tmpTrace_Log.transport_id.from_departure_id.location_id.location_id forKey:@"tracking_location_id"];
        [syncToServer setValue:tmpTrace_Log.transport_id.to_location_id.location_id                forKey:@"destination_location_id"];
        if (tmpTrace_Log.receipt_data) {
            [syncToServer setValue:tmpTrace_Log.receipt_data                                       forKey:@"receipt_data"];
        }
        if (tmpTrace_Log.receipt_text) {
            [syncToServer setValue:tmpTrace_Log.receipt_text                                       forKey:@"receipt_text"];
        } else if ([tmpTrace_Log.trace_type_id.trace_type_id intValue] == 85) { 
            [syncToServer setValue:[tmpTrace_Log.transport_id.price stringValue]                   forKey:@"receipt_text"];
        }
        if (tmpTrace_Log.transport_id.item_id) {
            [syncToServer setValue:tmpTrace_Log.transport_id.item_id.itemID                        forKey:@"item_id"];
            [syncToServer setValue:tmpTrace_Log.transport_id.itemQTY                               forKey:@"item_qty"];
            [syncToServer setValue:tmpTrace_Log.transport_id.itemQTYUnit                           forKey:@"item_qty_unit"];
        }
        [syncToServer setValueOrSkip:tmpTrace_Log.transport_id.final_destination_id.location_id    forKey:@"final_destination_id"];
        [syncToServer addEntriesFromDictionary:userInfo];
        

        NSURL *urlToBeUsed = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/trace_log?sn=%@&userid=%@", [DSPF_Synchronisation hermesServerURL], self.udid,
                                                   [NSString stringWithFormat:@"%i", [tmpTrace_Log.user_id.user_id intValue]]]];
        SyncTask *task = [[SyncTask alloc] initWithURL:urlToBeUsed dataToTransfer:syncToServer managedObjectId:tmpTrace_Log.objectID];
        [self processSyncTask:task];
        [task release];
        [syncToServer release];
    }
    [uploadContext release];
}

- (void) processSyncTask:(SyncTask *) task {
    [self.syncTasks addObject:task];
    if (self.syncTask_PND == nil && self.syncTasks.count > 0) {
        [self beginUpload];
    }
}

#pragma mark - Sending

- (void)sendTraceLogData:(NSNotification *)aNotification {
    NSString *activityMessage = [[aNotification userInfo] valueForKey:SyncTaskActivityMessageKey];
    BOOL shouldShowActivity = activityMessage == nil || ![activityMessage isEqualToString:@""];
    if (activityMessage == nil) {
        activityMessage = NSLocalizedString(@"MESSAGE_002", @"Bitte warten.");
    }
    DSPF_Activity *showActivity = nil;
    if (shouldShowActivity) {
        showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_070", @"Datenübermittlung") messageText:activityMessage delegate:self] retain];
        [DPHUtilities waitForAlertToShow:0.618];
    }
    
    //
    // DOWNLOAD THREAD
    // 
    dispatch_async(downloadQueue, ^{ 
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
        if ([NSUserDefaults isRunningWithTourType:@"???"]) { 
            tmpLocationsArray            = [self serverDataForKey:@"location"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
            tmpDeparturesArray           = [self serverDataForKey:@"departure"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        }
        NSArray *tmpSchedulesArray       = [self serverDataForKey:@"ä"]; // "ä" = nothing
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpTransportGroupsArray = [self serverDataForKey:@"transport_group"];
        if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        NSArray *tmpTransportsArray      = nil;
        if ([NSUserDefaults currentTourId]) { 
            /* All transportdata and cargodata are assigned to the current TourID ! */
            tmpTransportsArray      = [self serverDataForKey:@"transport"];
            if ([self.taskControl indexOfObject:tmpTask] == NSNotFound) {myDownloadTask = [self cancelBackgroundTask:myDownloadTask]; return;};
        }
        NSManagedObjectContext *downloadContext = [[NSManagedObjectContext alloc] init]; 
        [downloadContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
        [downloadContext setUndoManager:nil];
        [downloadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        if (tmpLocationsArray) { 
            for (NSDictionary *serverData in tmpLocationsArray) {
                [downloadContext refreshObject:[Location fromServerData:serverData inCtx:downloadContext] mergeChanges:YES];
            }
            [downloadContext saveIfHasChanges];
        }
        if (tmpDeparturesArray) { 
            for (NSDictionary *serverData in tmpDeparturesArray) {
                [downloadContext refreshObject:[Departure fromServerData:serverData inCtx:downloadContext] mergeChanges:YES];
            }
            [downloadContext saveIfHasChanges];
        }
        if (PFTourTypeSupported(@"1XX", nil) && 
            tmpSchedulesArray && tmpSchedulesArray.count != 0) {
            NSPredicate *transportPredicate = [NSPredicate predicateWithFormat:@"(trace_type_id.code = %@ OR trace_type_id.code = %@ OR "
                                               "trace_type_id.trace_type_id >= 80) && "
                                               "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count)", @"UNLOAD", @"UNTOUCHED"];
            for (Transport *tmpTourTransport in [NSArray arrayWithArray:[Transport withPredicate:transportPredicate inCtx:downloadContext]]) {
                [downloadContext deleteObject:tmpTourTransport];
            }
            NSPredicate *departurePredicate = [NSPredicate predicateWithFormat:@"transport_id.@count = 0 && "
                                               "location_id.transport_origin_id.@count = 0 && location_id.transport_destination_id.@count = 0"];
            for (Departure *unchained in [NSArray arrayWithArray:[Departure withPredicate:departurePredicate inCtx:downloadContext]]) {
                [downloadContext deleteObject:unchained];
            }
            [downloadContext saveIfHasChanges];
            for (NSDictionary *serverData in tmpSchedulesArray) { 
                [downloadContext refreshObject:[Departure fromServerData:serverData inCtx:downloadContext] mergeChanges:YES];
            }
            [downloadContext saveIfHasChanges];
            [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forClass:Departure.class];
        }
        if (tmpTransportGroupsArray && tmpTransportGroupsArray.count != 0) {
            for (NSDictionary *serverData in tmpTransportGroupsArray) { 
                [downloadContext refreshObject:[Transport_Group fromServerData:serverData inCtx:downloadContext] mergeChanges:YES];
            }
            [downloadContext saveIfHasChanges];
            [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forClass:Transport_Group.class];
        }
        if (tmpTransportsArray && tmpTransportsArray.count != 0) { 
            for (NSDictionary *serverData in tmpTransportsArray) { 
                [downloadContext refreshObject:[Transport fromServerData:serverData inCtx:downloadContext] mergeChanges:YES];
            }
            [downloadContext saveIfHasChanges];
            [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forClass:Transport.class];
        }
        [downloadContext release];
        [self.taskControl removeObject:tmpTask];
        myDownloadTask = [self cancelBackgroundTask:myDownloadTask];
    });
    //
    // UPLOAD PROCESS
    //
    [self performSelectorOnMainThread:@selector(addTraceLogSyncTasks) withObject:nil waitUntilDone:NO];
    if (shouldShowActivity) {
        [showActivity closeActivityInfo];
        [showActivity release];
    }
}

- (void)sendTraceLogDataOnly:(NSNotification *)aNotification {
    NSString *activityMessage = [[aNotification userInfo] valueForKey:SyncTaskActivityMessageKey];
    BOOL shouldShowActivity = activityMessage == nil || ![activityMessage isEqualToString:@""];
    if (activityMessage == nil) {
        activityMessage = NSLocalizedString(@"MESSAGE_002", @"Bitte warten.");
    }
    DSPF_Activity *showActivity = nil;
    if (shouldShowActivity) {
        showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_070", @"Datenübermittlung") messageText:activityMessage delegate:self] retain];
        [DPHUtilities waitForAlertToShow:0.618];
    }
    //
    // UPLOAD PROCESS
    //
    [self performSelectorOnMainThread:@selector(addTraceLogSyncTasks) withObject:nil waitUntilDone:NO];
    if (shouldShowActivity) {
        [showActivity closeActivityInfo];
        [showActivity release];
    }
}

- (void)sendApplePushnotificationID:(NSNotification *)aNotification { 
    NSDictionary *syncToServer = [NSDictionary dictionaryWithObject:[[aNotification userInfo] valueForKey:@"apnsid"] forKey:@"devicetoken"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/devicetoken?sn=%@", [DSPF_Synchronisation hermesServerURL], self.udid]];
    SyncTask *task = [[SyncTask alloc] initWithURL:url dataToTransfer:syncToServer managedObjectId:nil];
    [self processSyncTask:task];
    [task release];
}

- (void)sendRemoteNotificationResponse:(NSNotification *)aNotification { 
    NSDictionary *syncToServer = [aNotification userInfo];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/notificationanswer?sn=%@", [DSPF_Synchronisation hermesServerURL], self.udid]];
    SyncTask *task = [[SyncTask alloc] initWithURL:url dataToTransfer:syncToServer managedObjectId:nil];
    [self processSyncTask:task];
    [task release];
}

- (void)sendRentalAndRestitutionData:(NSNotification *)aNotification {
    NSManagedObjectContext *uploadContext = [[NSManagedObjectContext alloc] init];
    [uploadContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [uploadContext setUndoManager:nil];
    [uploadContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSArray *bufferedOrderHeads = [NSArray arrayWithArray:[ArchiveOrderHead pendingOrderHeadsToSyncInCtx:uploadContext]];
    
    for (ArchiveOrderHead *tmpOrderHead in bufferedOrderHeads) {
        NSMutableDictionary *tmpOrderHeadDictionary = [NSMutableDictionary dictionary];
        if ([tmpOrderHead.store_id intValue] < 0) {
            Location *tmpLocation = [Location locationID:[NSNumber numberWithInt:(0 - [tmpOrderHead.store_id intValue])] inCtx:tmpOrderHead.managedObjectContext];
            [tmpOrderHeadDictionary setValue:[NSString stringWithFormat:@"%8@", tmpLocation.code] forKey:@"storeid"];
        } else {
            /* First check for a payable account (Kreditor) */
            Store *tmpStore = [Store storeID:[NSNumber numberWithInt:0 - [tmpOrderHead.store_id intValue]] inCtx:tmpOrderHead.managedObjectContext];
            if (!tmpStore) {
                /* Alternatively check for a receivable account (Debitor)*/
                [tmpOrderHeadDictionary setValue:[NSString stringWithFormat:@"R:%06i", [tmpOrderHead.store_id intValue]] forKey:@"storeid"];
            } else {
                [tmpOrderHeadDictionary setValue:[NSString stringWithFormat:@"P:%06i", [tmpOrderHead.store_id intValue]] forKey:@"storeid"];
            }
        }
        [tmpOrderHeadDictionary setValue:tmpOrderHead.user.user_id forKey:@"userid"];
        [tmpOrderHeadDictionary setValue:@" "                      forKey:@"promocode"];
        NSString *dateString = [DPHDateFormatter stringFromDate:tmpOrderHead.deliveryDate
                                                  withDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle locale:de_CH_Locale()];
        [tmpOrderHeadDictionary setValue:dateString forKey:@"deliverydate"];
        NSArray *orderLinesToSync = [ArchiveOrderLine orderLinesWithPredicate:[NSPredicate predicateWithFormat:@"archiveOrderHead.order_id = %ld",
                                                                               [tmpOrderHead.order_id longValue]]
                                                              sortDescriptors:[NSArray arrayWithObjects:
                                                                               [NSSortDescriptor sortDescriptorWithKey:@"itemInserted" ascending:YES],
                                                                               nil]
                                                       inCtx:uploadContext];
        NSMutableArray *tmpOrderPos = [NSMutableArray array];
        [tmpOrderHeadDictionary setValue:[((ArchiveOrderLine *)[orderLinesToSync lastObject]).templateName
                                          stringByReplacingOccurrencesOfString:@"©"
                                          withString:@"-"]
                                  forKey:@"pricelist"];
        NSNumberFormatter *priceFormatter = [[[NSNumberFormatter alloc] init] autorelease];
        [priceFormatter  setNumberStyle:NSNumberFormatterDecimalStyle];
        [priceFormatter  setPositiveFormat:@"######0.00"];
        [priceFormatter  setNegativePrefix:@" "];
        [priceFormatter  setGeneratesDecimalNumbers:YES];
        [priceFormatter  setAlwaysShowsDecimalSeparator:YES];
        [priceFormatter  setDecimalSeparator:[priceFormatter.locale objectForKey:NSLocaleDecimalSeparator]];
        [priceFormatter  setGroupingSeparator:@""];
        [priceFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
        for (ArchiveOrderLine *tmpOrderLine in orderLinesToSync) {
            NSMutableDictionary *tmpOrderPosDictionary = [NSMutableDictionary dictionary];
            [tmpOrderPosDictionary setValue:tmpOrderLine.item.itemID                                        forKey:@"itemid"];
            if ([tmpOrderLine.item.orderUnitCode isEqualToString:@"KG"] ||
                [tmpOrderLine.item.orderUnitCode isEqualToString:@"LT"]) {
                [tmpOrderPosDictionary setValue:[[NSDecimalNumber decimalNumberWithString:
                                                  [NSString stringWithFormat:@"%i", [tmpOrderLine.itemQTY intValue]]]
                                                 decimalNumberByDividingBy:
                                                 [NSDecimalNumber decimalNumberWithString:@"1000"]]         forKey:@"qty"];
            } else {
                [tmpOrderPosDictionary setValue:tmpOrderLine.itemQTY                                        forKey:@"qty"];
            }
            [tmpOrderPosDictionary setValue:[priceFormatter stringFromNumber:tmpOrderLine.item.buyingPrice] forKey:@"price"];
            [tmpOrderPosDictionary setValue:tmpOrderLine.item.orderUnitCode                                 forKey:@"oucode"];
            [tmpOrderPosDictionary setValue:tmpOrderLine.item.itemPackageCode                               forKey:@"package"];
            [tmpOrderPos addObject:[NSDictionary dictionaryWithDictionary:tmpOrderPosDictionary]];
        }
        NSMutableDictionary *syncToServer = [[NSMutableDictionary alloc] initWithCapacity:2];
        [syncToServer setObject:[NSDictionary dictionaryWithDictionary:tmpOrderHeadDictionary] forKey:@"head"];
        [syncToServer setObject:[NSArray arrayWithArray:tmpOrderPos]                           forKey:@"pos"];


        NSURL *urlToBeUsed = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/order?sn=%@&store=%@", [DSPF_Synchronisation hermesServerURL],
                                                   PFDeviceId(),
                                                   [tmpOrderHeadDictionary valueForKey:@"storeid"]]];

        SyncTask *task = [[SyncTask alloc] initWithURL:urlToBeUsed dataToTransfer:syncToServer managedObjectId:tmpOrderHead.objectID];
        [self processSyncTask:task];
        [task release];
        [syncToServer release];
    }
    [uploadContext release];
}

- (void)sendSyncTaskRetry:(NSTimer *)aTimer { 
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendSyncTask" object:self userInfo:nil] postingStyle:NSPostASAP];
}

- (void)sendSyncTask:(NSNotification *)aNotification {
    SyncTask *syncTask = self.syncTask_PND;
    if (syncTask == nil) {
        return;
    }
    if (self.status != SVR_SyncDataManagerStatusSending) {
        self.status = SVR_SyncDataManagerStatusSending;
    }
    
    NSMutableURLRequest *syncTask_ERR = [SVR_SyncDataManager requestFromDictionary:[syncTask transferData] url:[syncTask targetURL]];
    if ([NSURLConnection canHandleRequest:syncTask_ERR]) { 
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        NSDictionary *userInfo = @{ @"syncTask_PND" : syncTask,
                                    @"syncTask_ERR_Count": [NSNumber numberWithUnsignedInteger:self.syncTask_ERR_Count] };
        
        [NSTimer scheduledTimerWithTimeInterval:(syncTask_ERR.timeoutInterval + 7) target:self selector:@selector(checkConnectionResponse:) userInfo:userInfo repeats:NO];
        uploadConnection = [[NSURLConnection alloc] initWithRequest:syncTask_ERR delegate:self startImmediately:NO];
        [uploadConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [uploadConnection start];
    } else {
        [self syncTaskDidFailWithInfo:@"cannotHandleRequest"];
    }
}

#pragma mark - Handling Response

- (void) postProcessSuccessfullySentSyncTask:(SyncTask *) aSyncTask {
    // move it to the object itself?
    
    NSManagedObjectID *synchronizedObjectId = [aSyncTask managedObjectId];
    if (!synchronizedObjectId) {
        return;
    }
    
    NSManagedObjectContext *tmpContext = [[NSManagedObjectContext alloc] init];
    [tmpContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    [tmpContext setUndoManager:nil];
    [tmpContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    NSManagedObject *object = [tmpContext existingObjectWithID:synchronizedObjectId error:nil];
    if ([object isKindOfClass:[Trace_Log class]]) {
        Trace_Log *tmpTraceLog = (Trace_Log *)object;
        [tmpContext deleteObject:tmpTraceLog];
    } else if ([object isKindOfClass:[ArchiveOrderHead class]]) {
        ArchiveOrderHead *tmpOrderHead = (ArchiveOrderHead *)object;
        tmpOrderHead.orderState       = [NSNumber numberWithInt:50];
        tmpOrderHead.transmissionDate = [NSDate date];
        [tmpContext refreshObject:tmpOrderHead mergeChanges:YES];
    }
    [tmpContext saveIfHasChanges];
    [tmpContext release];
}

- (void) didFinishUploadingSyncTask:(SyncTask *) aSyncTask {
    [self postProcessSuccessfullySentSyncTask:aSyncTask];
    
    if (!aSyncTask) {
        // backgroundHandler stop the pending task by timeout
        if (self.syncTask_PND == nil && self.syncTasks.count > 0) {
            [self beginUpload];
        }
    } else {
        [self.syncTasks removeObject:aSyncTask];
        if (self.syncTasks.count != 0) {
            self.syncTask_PND = [self.syncTasks firstObject];
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendSyncTask" object:self userInfo:nil]
                                                       postingStyle:NSPostASAP];
        } else {
            // the handler block will not be called so set self.syncTask_PND = nil;
            self.syncTask_PND = nil;
            myUploadTask = [self cancelBackgroundTask:myUploadTask];
            self.status = SVR_SyncDataManagerStatusIdle;
        }
    }
}

- (void)syncTaskDidFailWithInfo:(NSString *)info {
    NSString *tmpTask_ERR_Text = self.syncTask_ERR_Text;
    NSTimeInterval retry_delay = (arc4random() % 30);
    self.syncTask_ERR_Count = self.syncTask_ERR_Count + 1;
    if (self.syncTask_ERR_Count % 10 == 0 || [info isEqualToString:@"cannotHandleRequest"]) {
        retry_delay = (arc4random() % 90);
        if ([info isEqualToString:@"cannotHandleRequest"]) { 
            tmpTask_ERR_Text = [NSString stringWithFormat:@"Aktuell ist keine Verbindung möglich.\nDer Verbindungsaufbau wird in %.0fs wiederholt.", retry_delay];
        }
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkProblemIndicatorVisible:YES];
        });
    }
    NSLog(@"\n*ERR SVR_SyncDataManager-%@:\n\tRetryCount: %i\n\t%@", self.syncTask_PND.targetURL.lastPathComponent, self.syncTask_ERR_Count, tmpTask_ERR_Text);
    
    [NSTimer scheduledTimerWithTimeInterval:retry_delay target:self selector:@selector(sendSyncTaskRetry:)
                                   userInfo:[NSDictionary dictionaryWithObject:info forKey:@"delayReason"] repeats:NO];
}

#pragma mark - connection

- (void)checkConnectionResponse:(NSTimer *)aTimer {
    SyncTask *syncTask = [aTimer.userInfo valueForKey:@"syncTask_PND"];
    if ([[syncTask transferData] isEqualToDictionary:[self.syncTask_PND transferData]] && [aTimer.userInfo valueForKey:@"syncTask_ERR_Count"] &&
        [(NSNumber *)[aTimer.userInfo valueForKey:@"syncTask_ERR_Count"] unsignedIntegerValue] == self.syncTask_ERR_Count)
    {
        dispatch_async(dispatch_get_main_queue(), ^{ 
            [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkProblemIndicatorVisible:YES];
        });
        [uploadConnection cancel];
        [uploadConnection release];   uploadConnection   = nil;
        [uploadResponseData release]; uploadResponseData = [[NSMutableData alloc] init];
        self.syncTask_ERR_Text  = @"";
        self.syncTask_ERR_Count =   0;
        [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendSyncTask" object:self userInfo:nil] postingStyle:NSPostASAP];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {    
    // This can be called multiple times, for example in the case of a redirect, 
    // so each time we reset the data.
    [uploadResponseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [uploadResponseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error { 
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [connection release];
    [uploadResponseData release]; uploadResponseData = [[NSMutableData alloc] init];
    //FIXME: report an entire error
    self.syncTask_ERR_Text = [NSString stringWithFormat:@"%@", [error localizedDescription]];
    if ([error localizedFailureReason]) { 
        self.syncTask_ERR_Text = [self.syncTask_ERR_Text stringByAppendingFormat:@"\n%@", [error localizedFailureReason]];
    }
    if ([error localizedRecoverySuggestion]) { 
        self.syncTask_ERR_Text = [self.syncTask_ERR_Text stringByAppendingFormat:@"\n%@", [error localizedRecoverySuggestion]];
    }
    [self syncTaskDidFailWithInfo:@"didFailWithError"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection { 
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString *returnString = [[NSString alloc] initWithData:uploadResponseData encoding:NSUTF8StringEncoding];
    [connection release];
    [uploadResponseData release]; uploadResponseData = [[NSMutableData alloc] init];
    if (returnString && ([returnString isEqualToString:@"OK"] || [returnString isEqualToString:@""])) {
        [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkProblemIndicatorVisible:NO];
        self.syncTask_ERR_Text  = @"";
        self.syncTask_ERR_Count =   0;
        [self didFinishUploadingSyncTask:self.syncTask_PND];
    } else {
        self.syncTask_ERR_Text     = [NSString stringWithFormat:@"Server-Info: %@", returnString];
        [self syncTaskDidFailWithInfo:@"returnStringERR"];
    }
    [returnString release];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    // At the moment this info will be ignored
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    // Return the request unmodified to allow the redirect.
    return request;
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)dealloc {
    [taskControl        removeAllObjects];
    [taskControl        release];
    [uploadResponseData release];
    [syncTask_ERR_Text  release];
    [syncTask_PND       release];
    [syncTasks          release];
    dispatch_release(downloadQueue);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendSyncTask"                   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendRemoteNotificationResponse" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendApplePushnotificationID"    object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendRentalAndRestitutionData"   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendTraceLogDataOnly"           object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendTraceLogData"               object:nil];
    [udid                                  release];
	[persistentStoreCoordinator            release];
    [super dealloc];
}


@end

/*  uncomment this or install the certificates */

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)aHost {
	return YES;
}

@end


@implementation SVR_SyncDataManager (Additions)

+ (NSMutableURLRequest *) requestFromDictionary:(nullable NSDictionary *) dictionary url:(nonnull NSURL *) url {
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setTimeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"keep-live" forHTTPHeaderField:@"Connection"];
    [request setValue:@"60"        forHTTPHeaderField:@"Keep-Alive"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    [request setURL:url];
    NSString *error = nil;
    if (dictionary != nil) {
        NSData *body = [NSPropertyListSerialization dataFromPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
        if (body == nil) {
            NSLog(@"Could not generate plist from dictionary: %@\nReason: %@", dictionary, error);
        }
        [request setHTTPBody:body];
    }
    return request;
}

+ (NSPredicate *) predicateForTraceLogsToSynchronize {
    NSMutableArray *omitTraceTypeIds = [[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:-1] , nil] autorelease];
    if (![SVR_NetworkMonitor reachabilityForLocalWiFi]) {
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"HermesApp_SYSVAL_RUN_withProofOfDeliverySyncMode"] isEqualToString:@"FALSE"]) {
            [omitTraceTypeIds addObject:@81];
            [omitTraceTypeIds addObject:@82];
        }
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"HermesApp_SYSVAL_RUN_withImageSyncMode"] isEqualToString:@"FALSE"]) {
            [omitTraceTypeIds addObject:@88];
            [omitTraceTypeIds addObject:@89];
        }
    }
    return NotPredicate([Trace_Log withTraceTypes:omitTraceTypeIds]);
}

+ (void) saveLastSyncedTimeStamp:(NSDate *) date forClass:(Class<DPHSynchronizable>) clz {
    [SVR_SyncDataManager saveLastSyncedTimeStamp:date forKey:[clz lastUpdatedNSDefaultsKey]];
}

+ (void) saveLastSyncedTimeStamp:(NSDate *) date forKey:(NSString *) key {
    [[NSUserDefaults standardUserDefaults] setValue:[NSDateFormatter localizedStringFromDate:date
                                                                                   dateStyle:NSDateFormatterMediumStyle
                                                                                   timeStyle:NSDateFormatterShortStyle]
                                             forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger) unsynchronizedTraceLogsCount {
    return [[Trace_Log withPredicate:[SVR_SyncDataManager predicateForTraceLogsToSynchronize] inCtx:ctx()] count];
}

+ (void) triggerSendingTraceLogDataWithUserInfo:(NSDictionary *) userInfo {
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendTraceLogData" object:nil userInfo:userInfo]
                                               postingStyle:NSPostASAP];
}

+ (void) triggerSendingTraceLogDataOnlyWithUserInfo:(NSDictionary *) userInfo {
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendTraceLogDataOnly" object:nil userInfo:userInfo]
                                               postingStyle:NSPostASAP];
}

+ (void) triggerSendingRentalAndRestitutionDataWithUserInfo:(NSDictionary *)userInfo {
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendRentalAndRestitutionData" object:self userInfo:userInfo]
                                               postingStyle:NSPostASAP];
}

@end
