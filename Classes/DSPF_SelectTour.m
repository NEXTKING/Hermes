//
//  DSPF_SelectTour.m
//  Hermes
//
//  Created by Lutz  Thalmann on 23.10.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_SelectTour.h"
#import "DSPF_Menu.h"
#import "DSPF_Tour.h"
#import "DSPF_Activity.h"
#import "DSPF_Synchronisation.h"
#import "DSPF_SelectTruck.h"
#import "DSPF_Finish.h"

#import "User.h"
#import "Truck.h"
#import "Transport.h"
#import "Transport_Group.h"

@implementation DSPF_SelectTour

@synthesize usrprf;
@synthesize truck;
@synthesize neueTour;
@synthesize benutzerLabel;
@synthesize fahrzeugLabel;
@synthesize tours;
@synthesize checkingWhetherItsDemoModeOrNot;
@synthesize task;
@synthesize pickerView;
@synthesize currentSelection;
@synthesize pickerViewToolbar;
@synthesize confirmTourButton;
@synthesize jumpThroughOption;
@synthesize navigationController;

- (void) jumpThrough
{
    NSArray* toursArray = self.tours;
    
    Tour *currentTour = [toursArray lastObject];
    if (currentTour)
    {
        self.currentSelection = currentTour;
        [self didChooseTour:currentTour];
    }
    else
    {
        [DSPF_Warning messageTitle:@"Внимание!" messageText:@"В данный момент для Вас нет доступных маршрутов" item:nil delegate:nil];
        [DSPF_Finish unbindTruckFromDevice];
    }
    
}

- (NSArray *)serverDataForKey:(NSString *)aKey {
    NSArray  *serverData = nil;
    NSError  *error      = nil;
    NSHTTPURLResponse    *response;
    NSData               *tmpData;
    //@"http://zhsrv-dev64.zh.dph.local:100/evoweb/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    //@"https://zhsrv-dev64.zh.dph.local/eta/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    NSString *serverURL  = [[DSPF_Synchronisation hermesServerURL] stringByAppendingFormat:@"/download/%@?returnType=xmlplist&zipped=true&sn=%@", aKey, PFDeviceId()];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:240];
    [request setHTTPMethod:@"GET"];
    if ((PFTourTypeSupported(@"1XX", nil) && [NSUserDefaults isRunningWithTourAdjustment] && [aKey isEqualToString:@"transport"]) ||
        (PFTourTypeSupported(@"1XX", nil) && [aKey isEqualToString:@"cargo"]) ||
        (PFTourTypeSupported(@"1XX", nil) && [aKey isEqualToString:@"schedule"]))
    {
        if ([[NSUserDefaults currentTourId] longLongValue] != 0 && [[NSUserDefaults currentTruckId] longLongValue] != 0) {
            serverURL = [serverURL stringByAppendingFormat:@"&tvid=%@&trid=%@", [NSUserDefaults currentTourId], [NSUserDefaults currentTruckId]];
        }
    } else if (PFBrandingSupported(BrandingCCC_Group, BrandingTechnopark, nil) && [aKey isEqualToString:@"tour"]) {
        serverURL = [serverURL stringByAppendingFormat:@"&truck_id=%@", [NSUserDefaults currentTruckId]];
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

- (void)syncTOUR {
	DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung")
                                                   messageText:NSLocalizedString(@"MESSAGE_001", @"Bitte warten Sie bis die Touren aktualisiert wurden.") 
                                             cancelButtonTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen") 
                                                      delegate:self] retain];
    NSArray *tmpToursArray = [self serverDataForKey:@"tour"];
    if (tmpToursArray && tmpToursArray.count != 0) {
        [Tour willProcessDataFromServer:tmpToursArray option:nil inCtx:ctx()];
        for (NSDictionary *serverData in tmpToursArray) {
            [Tour fromServerData:serverData inCtx:ctx()];
        }
        [Tour didProcessDataFromServer:tmpToursArray option:nil inCtx:ctx()];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDateFormatter localizedStringFromDate:[NSDate date] 
                                                                                       dateStyle:NSDateFormatterMediumStyle 
                                                                                       timeStyle:NSDateFormatterShortStyle] 
                                                 forKey:[Tour lastUpdatedNSDefaultsKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [ctx() saveIfHasChanges];
    }
    [showActivity closeActivityInfo];
    [showActivity release];
}

- (NSArray *)tours {
    if (!tours) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]];
        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:NO selector:@selector(localizedStandardCompare:)]];
        }
        else if (PFBrandingSupported(BrandingTechnopark, nil))
            sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tour_id" ascending:YES]];
        
        NSPredicate *filter = nil;
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            Truck *currentTruckObj = [Truck truckWithTruckID:[NSUserDefaults currentTruckId] inCtx:ctx()];
            NSManagedObjectID *yourManagedObjectID = [currentTruckObj objectID];
            int truck_PK = [[[[[yourManagedObjectID URIRepresentation] absoluteString] lastPathComponent] substringFromIndex:1] intValue];
            filter = [NSPredicate predicateWithFormat:@"truck_id == %d", truck_PK];
        }
        
        if ([self.task isEqualToString:TourTaskTourAbbruch]) {
            filter = NotPredicate([Tour withTourId:[NSUserDefaults currentTourId]]);
        } else {
            if ([NSUserDefaults isRunningWithTourAdjustment] || PFTourTypeSupported(@"0X0", nil) || PFBrandingSupported(BrandingCCC_Group, BrandingNONE, BrandingTechnopark, nil)) {
                if ([DSPF_SelectTour shouldDownloadLatestTours]) {
                    [self syncTOUR];
                }
            } else {
                filter = [Tour withDeviceId:PFDeviceId()];
            }
        }
        tours = [[Tour withPredicate:filter sortDescriptors:sortDescriptors inCtx:ctx()] retain];
    }
    return tours;
}

+ (BOOL) shouldDownloadLatestTours {
    
        if (PFBrandingSupported(BrandingTechnopark, nil) && [NSUserDefaults currentTourId])
            return NO;
    
        return !PFCurrentModeIsDemo() && (PFTourTypeSupported(@"0X0", @"1XX", nil) || PFBrandingSupported(BrandingCCC_Group, BrandingUnilabs, BrandingNONE, nil));
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"TITLE_006", @"Tour");
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
            self.jumpThroughOption = @"Drive";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if ([self.task isEqualToString:TourTaskTourAbbruch]) {
        self.title = NSLocalizedString(@"TITLE_117", @"Tourabbruch");
        self.neueTour.text = NSLocalizedString(@"TITLE_118", @"Haltestellen übergeben");
        self.fahrzeugLabel.text = NSLocalizedString(@"TITLE_006", @"Tour");
        self.truck.text = ((Tour *)[[Tour withPredicate:[Tour withTourId:[NSUserDefaults currentTourId]]
                                               inCtx:ctx()] objectAtIndex:0]).code;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.pickerView selectRow:[self preselectedRow] inComponent:0 animated:NO];
    self.currentSelection = [self tourForRow:[self preselectedRow] forComponent:0];

    self.neueTour.text      = NSLocalizedString(@"MESSAGE_018", @"neue Tour");
    self.benutzerLabel.text = NSLocalizedString(@"MESSAGE_029", @"Benutzer");
    self.fahrzeugLabel.text = NSLocalizedString(@"MESSAGE_030", @"Fahrzeug");
    
    User *tmpUser           = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    self.usrprf.text = [tmpUser firstAndLastName];
    if (self.usrprf.text.length == 0) {
        self.usrprf.text	 = tmpUser.username;
    }
    
    NSPredicate *predicate = [Truck withTruckId:[NSUserDefaults currentTruckId]];
    if ([NSUserDefaults isRunningWithTourAdjustment] == NO && !PFTourTypeSupported(@"0X0", nil) && !PFBrandingSupported(BrandingUnilabs, nil)) {
        predicate = [Truck withDeviceId:PFDeviceId()];
    }
    self.truck.text = ((Truck *)[[Truck withPredicate:predicate inCtx:ctx()] firstObject]).code;
    
    self.confirmTourButton.enabled = [self.tours count] > 0;
    
    [AppStyle customizePickerView:self.pickerView];
    [AppStyle customizePickerViewToolbar:self.pickerViewToolbar];
}

+ (BOOL) shouldBeDisplayed {
    return YES;
}

- (void)cancelTour {
    NSArray *departureSortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]];
    Departure *lastTourDeparture = [Departure lastTourDepartureInCtx:ctx()];
    
    NSInteger cancelCounter = 0;
    for (Departure *tmpTourDeparture in [NSArray arrayWithArray:[Departure withPredicate:
                                                                 [NSPredicate predicateWithFormat:@"currentTourBit == YES && currentTourStatus < 50"]
                                                                                   sortDescriptors:departureSortDescriptors inCtx:ctx()]])
    {
        if (![tmpTourDeparture.departure_id isEqualToNumber:lastTourDeparture.departure_id]) {
            NSString *code = [[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                             dateStyle:NSDateFormatterShortStyle
                                                             timeStyle:NSDateFormatterLongStyle]
                              stringByAppendingFormat:@"-%@", tmpTourDeparture.departure_id];
            
            NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueTourStopCancelled
                                                                    fromDeparture:tmpTourDeparture toLocation:tmpTourDeparture.location_id];
            [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
            tmpTourDeparture.currentTourStatus = [NSNumber numberWithInt:70];
            cancelCounter++;
        }
    }
    [ctx() saveIfHasChanges];
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueTourCancelled
                                                            fromDeparture:lastTourDeparture toLocation:lastTourDeparture.location_id];
    [currentTransport setValue:[NSString stringWithFormat:@"%@:%i", self.currentSelection.tour_id, cancelCounter] forKey:@"receipt_text"];
    [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
    [ctx() saveIfHasChanges];
    [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        [viewControllers addObject:viewController];
        if ([viewController isKindOfClass:[DSPF_Tour class]])
            break;
    }
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (IBAction)didConfirmTour {
    if ([self.task isEqualToString:TourTaskTourAbbruch]) {
        [self cancelTour];
        return;
    }
    
    [self didChooseTour:self.currentSelection];
}

- (void) didChooseTour:(Tour *) tour {
    if (tour == nil) {
        return;
    }
    [NSUserDefaults setCurrentTourId:tour.tour_id];
    [NSUserDefaults setCurrentStintStart:[NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle
                                                                        timeStyle:NSDateFormatterMediumStyle]];
    [NSUserDefaults setCurrentStintDayOfWeek:[DPHDateFormatter dayOfWeekFromDate:[NSDate date]]];
    [NSUserDefaults setCurrentStintDayOfWeekName:[DPHDateFormatter dayOfWeekNameFromDate:[NSDate date]]];
    [NSUserDefaults setCurrentStintPauseTime:[NSNumber numberWithInt:0]];
    [NSUserDefaults setCurrentStintDidQuitLoading:[NSNumber numberWithBool:NO]];
    
    NSArray *departuresWithCurrentBit = [Departure withPredicate:[Departure withCurrentBitSet:YES] inCtx:ctx()];
    
    if ((PFTourTypeSupported(@"0X0", nil) || PFBrandingSupported(BrandingCCC_Group, BrandingUnilabs, BrandingNONE, nil) || (PFBrandingSupported(BrandingTechnopark, nil) && departuresWithCurrentBit.count < 1))
        && !PFCurrentModeIsDemo())
    {
        //if (PFBrandingSupported(BrandingTechnopark, nil))
        //{
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncTourDone) name:@"syncTOURdone" object:nil];
        DSPF_Synchronisation *dspf_Sync = [[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease];
        dspf_Sync.notifyObject = self;
        [dspf_Sync performSelector:@selector(syncTOUR) withObject:nil];
        return;
        //}
        /*else
            [[[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease]
         performSelectorOnMainThread:@selector(syncTOUR) withObject:nil waitUntilDone:NO];*/
        
    }
    
    DSPF_Menu *dspf_Menu = [[[DSPF_Menu alloc] initWithParameters:nil] autorelease];
    [self.navigationController pushViewController:dspf_Menu animated:YES];
}

- (void) syncTourDone
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DSPF_Menu *dspf_Menu = [[[DSPF_Menu alloc] initWithParameters:nil] autorelease];
        [self.navigationController pushViewController:dspf_Menu animated:YES];
    });
}

#pragma mark - PickerView delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.tours.count;
}

- (UIView *)pickerView:(UIPickerView *)aPickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    //TODO: auslagern
    UILabel *label = (id)view;
    if (!label || ([label class] != [UILabel class])) {
        label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [aPickerView rowSizeForComponent:component].width, [aPickerView rowSizeForComponent:component].height)] autorelease];
    }
    label.text = [self tourForRow:row forComponent:component].code;
    
    /* Checking whether we are in demo mode or not, and if we are in demo mode, we will center the string 'DEMO' by introducing more whitespace; if we are not in demo mode, we just use 3x whitespace in order to have some margin on the left hand */
    
    if (PFCurrentModeIsDemo()) {
        label.textAlignment = UITextAlignmentCenter;
    } else {
        label.text = [NSString stringWithFormat:@"   %@", label.text];
    }
    
    [AppStyle customizePickerViewLabel:label];
    return label;
}

- (void)pickerView:(UIPickerView *)aPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.currentSelection = [self tourForRow:row forComponent:component];
}

- (NSInteger) preselectedRow {
    NSPredicate *assignedToursPredicate = [NSManagedObject predicateForObjectsWithValue:PFDeviceId() forProperty:TruckAttributeDeviceUdid];
    Tour *preselectedTour = [[self.tours filteredArrayUsingPredicate:assignedToursPredicate] lastObject];
    NSInteger rowToReturn = 0;
    NSUInteger truckIndex = [self.tours indexOfObject:preselectedTour];
    if (truckIndex != NSNotFound) {
        rowToReturn = truckIndex;
    }
    return rowToReturn;
}

- (Tour *)tourForRow:(NSInteger)row forComponent:(NSInteger)component {
    Tour *tour = nil;
    if (row < [self.tours count]) {
        tour = [self.tours objectAtIndex:row];
    }
    return tour;
}

#pragma mark -

- (void)viewDidUnload {
    [super viewDidUnload];

	self.pickerView					  = nil;
    self.truck                        = nil;
    self.usrprf                       = nil;
    self.neueTour                     = nil;
    self.benutzerLabel                = nil;
    self.fahrzeugLabel                = nil;
    self.pickerViewToolbar            = nil;
    self.confirmTourButton            = nil;
}


- (void)dealloc {
    [confirmTourButton               release];
    [pickerViewToolbar               release];
	[currentSelection                release];
	[tours                           release];
    [task                            release];
    [checkingWhetherItsDemoModeOrNot release];
	[pickerView                      release];
    [truck                           release];
    [usrprf                          release];
    [neueTour                        release];
    [benutzerLabel                   release];
    [jumpThroughOption release];
    [fahrzeugLabel                   release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


@end
