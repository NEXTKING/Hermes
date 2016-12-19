//
//  DSPF_Finish.m
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Finish.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"

#import "Location.h"
#import "Tour_Exception.h"
#import "Transport.h"
#import "Transport_Box.h"
#import "Trace_Log.h"

@implementation DSPF_Finish

@synthesize tourStartLabel;
@synthesize tourEndeLabel;
@synthesize pauseLabel;
@synthesize abmeldenButton;
@synthesize abschliessenButton;


@synthesize currentStintStart;
@synthesize currentStintPauseTime;
@synthesize currentStintEnd;
@synthesize tourIsDone;
@synthesize tourDeparturesAtWork;

@synthesize jumpThroughOption;
@synthesize navigationController;


#pragma mark - Initialization


- (NSArray *)tourDeparturesAtWork { 
    if (!tourDeparturesAtWork) {
        tourDeparturesAtWork = [[Departure departuresOfCurrentlyDrivenTourInCtx:ctx()] retain];
    }
    return tourDeparturesAtWork;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tourStartLabel.text    = NSLocalizedString(@"MESSAGE_034", @"Tour Start");
    self.tourEndeLabel.text     = NSLocalizedString(@"MESSAGE_035", @"Tour Ende");
    self.pauseLabel.text        = NSLocalizedString(@"MESSAGE_036", @"Pause");
    [self.abmeldenButton setTitle:NSLocalizedString(@"TITLE_017", @"abmelden") forState:UIControlStateNormal];
    [self.abmeldenButton setHidden:YES];
    [self.abschliessenButton setTitle:NSLocalizedString(@"TITLE_010", @"abschliessen") forState:UIControlStateNormal];

	if (self.tourDeparturesAtWork && [self.tourDeparturesAtWork lastObject]) {
		self.currentStintStart.text		= [NSUserDefaults currentStintStart];
		self.currentStintPauseTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d", 
										   ([[NSUserDefaults currentStintPauseTime] intValue] / 3600), 
										   (([[NSUserDefaults currentStintPauseTime] intValue] / 60) % 60), 
										   ([[NSUserDefaults currentStintPauseTime] intValue] % 60)];
	}
}

- (void)viewDidAppear:(BOOL)animated { 
	[super viewDidAppear:animated];
    NSArray	*sortDescriptors  = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"to_location_id.zip"    ascending:YES],
								 [NSSortDescriptor sortDescriptorWithKey:@"to_location_id.city"   ascending:YES],
								 [NSSortDescriptor sortDescriptorWithKey:@"to_location_id.street" ascending:YES],
								 [NSSortDescriptor sortDescriptorWithKey:@"to_location_id.location_name"   ascending:YES],
								 nil];
	NSArray *loadedTransports = [Transport transportsWithPredicate:
								 [NSPredicate predicateWithFormat:@"trace_type_id.code = %@", @"LOAD"] 
												   sortDescriptors:sortDescriptors inCtx:ctx()];
	if (loadedTransports && [loadedTransports count] != 0) {
        NSMutableArray *stillOnBoardCodes = [NSMutableArray array];
        for (Transport *tmpTransport in loadedTransports) {
            if (PFBrandingSupported(BrandingCCC_Group, nil)) {
                NSString *code = tmpTransport.deliveryDocumentNumber;
                if (!code || code.length == 0) {
                    code = tmpTransport.pickUpDocumentNumber;
                }
                if (!code || code.length == 0) {
                    code = tmpTransport.code;
                }
                [stillOnBoardCodes addObject:code];
            } else {
                [stillOnBoardCodes addObject:tmpTransport.code];
            }
        }
        NSString *stillOnBoard = [stillOnBoardCodes componentsJoinedByString:@", "];
        if ([[NSUserDefaults tourFinishCheckValue] isEqualToString:TourFinishCheckErr]) {
            [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status")
                         messageText:[NSString stringWithFormat:NSLocalizedString(@"MESSAGE_014", @"Aktuell noch geladen:\n%@"), stillOnBoard]
                            delegate:nil];
            [self.navigationController popViewControllerAnimated:YES];
        } else if ([[NSUserDefaults tourFinishCheckValue] isEqualToString:TourFinishCheckMSG]) {
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status") 
                           messageText:[NSString stringWithFormat:NSLocalizedString(@"MESSAGE_014", @"Aktuell noch geladen:\n%@"), stillOnBoard]
                                  item:@"confirmToFinish"
                              delegate:self];
        }
	}    
}

- (void) jumpThrough
{
    
}

+ (void) unbindTruckFromDevice
{
    NSLog(@"%@", PFDeviceId());
    NSArray *trucks = [Truck withPredicate:[NSPredicate predicateWithFormat:@"device_udid = %@", PFDeviceId()] inCtx:ctx()];
    for (Truck* truck in trucks) {
        truck.device_udid = nil;
    }
    [NSUserDefaults setCurrentTruckId:nil];
    [NSUserDefaults setCurrentTourId:nil];
    
    [ctx() saveIfHasChanges];
}

- (void)didFinishTour {
	self.navigationItem.hidesBackButton = YES;
    
    Departure *lastDepartureOnTour = [self.tourDeparturesAtWork lastObject];
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueEndOfTour
                                                            fromDeparture:lastDepartureOnTour toLocation:lastDepartureOnTour.location_id];
    
    [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
    [DSPF_Finish finishTourWithDepartures:self.tourDeparturesAtWork];
    
    [SVR_SyncDataManager triggerSendingRentalAndRestitutionDataWithUserInfo:nil];
    [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
	self.currentStintEnd.text = [NSDateFormatter localizedStringFromDate:[NSDate date]
															   dateStyle:NSDateFormatterMediumStyle 
															   timeStyle:NSDateFormatterMediumStyle];
    self.tourIsDone           = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *message = nil;
        if (PFBrandingSupported(BrandingTechnopark, nil))
            message = @"Маршрут успешно закрыт. Выйти на экран логина?";
        else
            message = [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_015", @"Die %@ wurde\nam %@\nabgeschlossen.\n\nJetzt abmelden ?"),
                       self.title,
                       self.currentStintEnd.text];
            
        
        [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information")
                           messageText:message
                                  item:@"confirmLogout"
                              delegate:self];
    });
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void) dspf_StatusReady:(DSPF_StatusReady *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if ([(NSString *)item isEqualToString:@"confirmLogout"]) {
			[self logout];
		}
	} else {
        if ([(NSString *)item isEqualToString:@"confirmLogout"]) {
            self.abmeldenButton.hidden = NO;
            self.abmeldenButton.center = self.abschliessenButton.center;
            self.abschliessenButton.hidden = YES;
        }
    }
}

- (IBAction)finishTOUR {
	if (!self.tourDeparturesAtWork || [self.tourDeparturesAtWork count] == 0) { 
		[self didFinishTour];
	} else {
        DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_057", @"Tour abschliessen") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
        [DPHUtilities waitForAlertToShow:0.236f];
        for (Departure *tmpTourDeparture in [Departure departuresOfCurrentlyDrivenTourInCtx:ctx()]) {
            if (([tmpTourDeparture.currentTourStatus intValue] == 45 || [tmpTourDeparture.canceled boolValue] ||
                (![tmpTourDeparture.confirmed boolValue] && [Tour_Exception todaysTourExceptionForLocation:tmpTourDeparture.location_id]) ||
                [Transport hasTransportCodesFromDeparture:tmpTourDeparture.departure_id transportGroup:tmpTourDeparture.transport_group_id.transport_group_id inCtx:ctx()]) && [tmpTourDeparture.currentTourStatus intValue] != 70 )
            {
                tmpTourDeparture.currentTourStatus = @50;
                [ctx() saveIfHasChanges];
            }
        }
        NSError *error = nil;
        BOOL allDeparturesDone = [DSPF_Finish canCloseTourWithDepartures:[Departure departuresOfCurrentlyDrivenTourInCtx:ctx()] error:&error];
        [showActivity closeActivityInfo];
        [showActivity release];
        if (allDeparturesDone) {
            [self didFinishTour];
        } else {
            Departure *departure = [[error userInfo] valueForKey:NSErrorParameterDeparture];
            if (error.code == DPHErrorTourStopNotFulfilled) {
                
                NSDictionary *parameters = nil;
                if (PFBrandingSupported(BrandingTechnopark, nil))
                {
                    parameters = @{ DeadHeadParameterCurrentDeparture : objectOrNSNull([DSPF_Finish allUnfinishedDepartures]) };
                }
                else
                    parameters = @{ DeadHeadParameterCurrentDeparture : objectOrNSNull(departure) };
            
                DSPF_Deadhead *dspf_Deadhead   = [[[DSPF_Deadhead alloc] initWithParameters:parameters] autorelease];
                dspf_Deadhead.delegate = self;
                [self.navigationController pushViewController:dspf_Deadhead animated:YES];
            } else {
                NSString *msgTitle = NSLocalizedString(@"TITLE_024", @"Tour-Status");
                NSString *msgText = NSLocalizedString(@"MESSAGE_016",
                                                      @"ACHTUNG\nDiese Haltestelle wurde nicht angefahren!\nAuch Leerfahrten müssen erfasst werden.");
                if (error.code == DPHErrorDirectDeliveryNotLoaded || error.code == DPHErrorDeliveryNotLoaded || error.code == DPHErrorPickupNotPickedUpOrNotAllItemsUnloaded){
                    departure.currentTourStatus = @45;
                    [[departure managedObjectContext] saveIfHasChanges];
                    [self.navigationController popViewControllerAnimated:YES];
                    Transport_Group *transportGroup = [[error userInfo] objectForKey:NSErrorParameterTransportGroup];
                    msgText = [NSString stringWithFormat:@"%@\n%@\n%@", transportGroup.task, [departure.location_id formattedString],
                               NSLocalizedString(@"MESSAGE_051",
                                                 @"ACHTUNG\nDiese Sendung wurde nicht bearbeitet!\nAlle Sendungen müssen erfasst werden.")];
                }
                [DSPF_Error messageTitle:msgTitle messageText:msgText delegate:nil];
            }
        }
	}
}

- (void) deadheadDidConfirm
{
    if (PFBrandingSupported(BrandingTechnopark, nil))
        [self finishTOUR];
}

+ (NSArray*) allUnfinishedDepartures
{
    NSArray* allCurrentDepartures =  [Departure departuresOfCurrentlyDrivenTourInCtx:ctx()];
    NSMutableArray *unfinished = [[[NSMutableArray alloc] init] autorelease];;
    
    for (Departure* departure in allCurrentDepartures) {
        if (departure.currentTourStatus.intValue < 50)
            [unfinished addObject:departure];
    }
    
    return unfinished;
}

+ (BOOL) canCloseTourWithDepartures:(NSArray *) departuresToCheck error:(NSError **) error {
    Departure *firstTourDeparture = [departuresToCheck objectAtIndex:0];
    Departure *lastTourDeparture  = [departuresToCheck lastObject];
    Departure *tourDeparture   = nil;
    Transport_Group *tourStopTransportGroup = nil;
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        // In this case per TourStopTransportGroup a separate DSPF_ShortDelivery is required
        for (tourDeparture in departuresToCheck) {
            if (![tourDeparture.canceled boolValue]) {
                NSPredicate *predicatePart = [NSPredicate predicateWithFormat:
                                              @"0 != SUBQUERY(transport_id, $t, ($t.trace_type_id = nil OR ($t.trace_type_id.trace_type_id != 9 AND $t.trace_type_id.trace_type_id < 80)) AND "
                                              "($t.item_id = nil OR $t.item_id.itemCategoryCode = \"2\")).@count"];
                NSPredicate *predicate1 = AndPredicates([NSPredicate predicateWithFormat:@"deliveryAction != nil"], predicatePart, nil);
                NSPredicate *predicate2 = AndPredicates([NSPredicate predicateWithFormat:@"deliveryAction = nil"], predicatePart, nil);
                NSArray *tg1 = [[tourDeparture.location_id.transport_group_addressee_id allObjects] filteredArrayUsingPredicate:predicate1];
                NSArray *tg2 = [[tourDeparture.location_id.transport_group_sender_id allObjects] filteredArrayUsingPredicate:predicate2];
                
                NSArray *tmpTourStopTransportGroups = [tg1 arrayByAddingObjectsFromArray:tg2];
                for (tourStopTransportGroup in tmpTourStopTransportGroups) {
                    if (![Transport hasTransportCodesFromDeparture:tourDeparture.departure_id
                                                    transportGroup:tourStopTransportGroup.transport_group_id inCtx:ctx()] &&
                        ![Transport hasTransportUloadCodesFromLocation:tourStopTransportGroup.addressee_id.location_id
                                                        transportGroup:tourStopTransportGroup.transport_group_id inCtx:ctx()] &&
                        ![Transport hasTransportUloadCodesFromLocation:lastTourDeparture.location_id.location_id
                                                        transportGroup:tourStopTransportGroup.transport_group_id inCtx:ctx()])
                    {
                        NSNumber *locationId = tourStopTransportGroup.addressee_id.location_id;
                        NSNumber *transportGroudId = tourStopTransportGroup.transport_group_id;
                        if (tourStopTransportGroup.deliveryAction &&
                            [Transport countOf:Pallet|RollContainer|Unit forTourLocation:locationId transportGroup:transportGroudId ctx:ctx()] == 0)
                        {
                            Departure *fromDeparture = ((Transport *)[[tourStopTransportGroup.transport_id allObjects] lastObject]).from_departure_id;
                            if (fromDeparture) {
                                // Direktlieferung nicht abgeholt
                                NSDictionary *userInfo = @{ NSErrorParameterDeparture : fromDeparture,
                                                            NSErrorParameterTransportGroup: tourStopTransportGroup };
                                SetError(error, [NSError errorWithDomain:DPHFinishTourDomain code:DPHErrorDirectDeliveryNotLoaded userInfo:userInfo]);
                            } else {
                                // Auslieferung nicht geladen
                                if ([Transport hasReasonCodesFromDeparture:firstTourDeparture.departure_id
                                                            transportGroup:tourStopTransportGroup.transport_group_id inCtx:ctx()])
                                {
                                    continue;
                                }
                                NSDictionary *userInfo = @{ NSErrorParameterDeparture : firstTourDeparture,
                                                            NSErrorParameterTransportGroup: tourStopTransportGroup };
                                SetError(error, [NSError errorWithDomain:DPHFinishTourDomain code:DPHErrorDeliveryNotLoaded userInfo:userInfo]);
                            }
                        } else {
                            // Abholung nicht abgeholt
                            // Auslieferung nicht abgeladen
                            // Direktlieferung nicht abgeladen
                            NSDictionary *userInfo = @{ NSErrorParameterDeparture : tourDeparture,
                                                        NSErrorParameterTransportGroup: tourStopTransportGroup };
                            SetError(error, [NSError errorWithDomain:DPHFinishTourDomain code:DPHErrorPickupNotPickedUpOrNotAllItemsUnloaded userInfo:userInfo]);
                        }
                        return NO;
                    }
                }
            }
        }
    } else {
        for (tourDeparture in departuresToCheck) {
            if ([tourDeparture.currentTourStatus intValue] < 50) {
                NSDictionary *userInfo = @{ NSErrorParameterDeparture : tourDeparture };
                SetError(error, [NSError errorWithDomain:DPHFinishTourDomain code:DPHErrorTourStopNotFulfilled userInfo:userInfo]);
                return NO;
            }
        }
    }
    return YES;
}

- (IBAction)logout {
    if (self.tourIsDone) {
        [NSUserDefaults clearTourDataCache];
    }
    //  every logon replaces the value for key                    @"currentUserID"
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (void)viewDidUnload {
    [super viewDidUnload];

	self.currentStintStart			= nil;
	self.currentStintPauseTime		= nil;
	self.currentStintEnd			= nil;
    self.tourStartLabel             = nil;
    self.tourEndeLabel              = nil;
    self.pauseLabel                 = nil;
    self.abmeldenButton             = nil;
    self.abschliessenButton         = nil;
}


- (void)dealloc {
    [tourDeparturesAtWork       release];
	[currentStintEnd		    release];
	[currentStintPauseTime		release];
	[currentStintStart			release];
    [tourStartLabel             release];
    [tourEndeLabel              release];
    [pauseLabel                 release];
    [abmeldenButton			    release];
    [abschliessenButton			release];
    [navigationController       release];
    [jumpThroughOption          release];
    [super dealloc];
}


#pragma mark - Tour finishing

+ (void) finishTourWithDepartures:(NSArray *) departures {
    if (departures && [departures count] != 0) {
        Departure *lastDepartureOnTour = [departures lastObject];
        if (PFTourTypeSupported(@"1XX", nil)) {
            NSArray *transports = [NSArray arrayWithArray:[Transport withPredicate:[NSPredicate predicateWithFormat:@"trace_type_id = nil && trace_log_id.@count = 0"]
                                                                             inCtx:ctx()]];
            for (Transport *tmpTourTransport in transports) {
                NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:tmpTourTransport.code traceType:TraceTypeValueUntouched
                                                                        fromDeparture:lastDepartureOnTour toLocation:lastDepartureOnTour.location_id];
                
                [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
                [ctx() saveIfHasChanges];
            }
        }
        for (Departure *tmpTourDeparture in departures) {
            tmpTourDeparture.currentTourBit    = [NSNumber numberWithBool:NO];
            tmpTourDeparture.currentTourStatus = nil;
            tmpTourDeparture.canceled          = [NSNumber numberWithBool:NO];
            tmpTourDeparture.confirmed         = [NSNumber numberWithBool:NO];
        }
        /* new Transport (trace_type_id 90) and updated departures must exist before the next steps */
        [ctx() saveIfHasChanges];
        
        [DSPF_Finish deleteAllLocalTourEntries];
    }
    
    [DSPF_Finish unbindTruckFromDevice];
}

+ (void)deleteAllLocalTourEntries {
    [ctx() deleteObjects:[Transport withPredicate:[Transport deletableOnEndOfTour] inCtx:ctx()]];
    [ctx() saveIfHasChanges];
    [ctx() deleteObjects:[Transport_Box withPredicate:[Transport_Box deletableOnEndOfTour] inCtx:ctx()]];
    [ctx() saveIfHasChanges];
    [ctx() deleteObjects:[Transport_Group withPredicate:[Transport_Group deletableOnEndOfTour] inCtx:ctx()]];
    [ctx() saveIfHasChanges];
    
    if (PFCurrentModeIsDemo()) {
        // uncomment subsequent for loop for demo mode
        [ctx() deleteObjects:[Trace_Log withPredicate:nil inCtx:ctx()]];
        for (Transport *tmpTourTransport in [Transport withPredicate:nil inCtx:ctx()]) {
            tmpTourTransport.trace_type_id = nil;
        }
        // use leading digit of shipping note ID
        [ctx() deleteObjects:[Transport withPredicate:[NSPredicate predicateWithFormat:@"NOT(code beginswith[c] '6')"] inCtx:ctx()]];
    }
}


@end