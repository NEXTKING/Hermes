//
//  DSPF_Unload.m
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Load.h"
#import "DSPF_LoadBox.h"
#import "DSPF_Unload.h"
#import "DSPF_Suspend.h"
#import "DSPF_Activity.h"
#import "DSPF_Order.h"
#import "DSPF_TransportGroupSummary.h"
#import "DSPF_SwitcherView.h"
#import "DSPF_TransportCell_technopark.h"

#import "Location.h"
#import "Transport_Group.h"
#import "Transport.h"
#import "ArchiveOrderHead.h"


static NSString * const UnloadItemsAsInFinalDestination = @"UnloadItemsAsInFinalDestination";
NSString * const UnloadParameterProcessChangeForbidden = @"UnloadParameterProcessChangeForbidden";

@interface DSPF_Unload () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) UIView* customHeader;
@property (nonatomic, retain) NSArray* serviceCodesAtWork;
@property (nonatomic, retain) NSArray* pickupCodesAtWork;
@property (nonatomic, retain) NSIndexPath* indexPathToUpdate;

@end

@implementation DSPF_Unload {
    BOOL processChangeForbidden;
    BOOL shouldTriggerSyncOnExit;
    BOOL unloadedByFinger;
}

@synthesize scanView;
@synthesize tableView;
@synthesize textView;
@synthesize palettenLabel;
@synthesize rollcontainerLabel;
@synthesize paketeLabel;
@synthesize paletteButton;
@synthesize paketButton;
@synthesize transportGroupSummaryButton;
@synthesize transportCodeButton;
@synthesize currentLocationDepartureLabel_F;
@synthesize currentLocationDepartureTime_F;
@synthesize currentLocationDepartureExtension_F;
@synthesize currentLocationStreetAddress_F;
@synthesize currentLocationZipCode_F;
@synthesize currentLocationCity_F;
@synthesize currentLocationDepartureLabel_B;
@synthesize currentLocationDepartureTime_B;
@synthesize currentLocationDepartureExtension_B;
@synthesize currentLocationStreetAddress_B;
@synthesize currentLocationZipCode_B;
@synthesize currentLocationCity_B;
@synthesize textInputTC;
@synthesize currentTC;
@synthesize scanInputTC;
@synthesize preventScanning;
@synthesize currentPalletCount;
@synthesize currentRollcontainerCount;
@synthesize currentRollcontainer_tourTask;
@synthesize currentUnitCount;
@synthesize currentUnit_tourTask;
@synthesize currentTCbar;
@synthesize currentTCbarTitle;
@synthesize currentTCbarSpace01;
@synthesize currentTCbarCamera;
@synthesize currentTCbarSpace02;
@synthesize currentTCbarPrice;
@synthesize currentTCPriceBadge;
@synthesize item;
@synthesize transportGroupTourStop;
@synthesize tourTask;
@synthesize ctx;
@synthesize	transportCodesAtWork;
@synthesize dspf_ImagePicker;

- (instancetype)init {
    return [self initWithParameters:nil];
}

- (instancetype)initWithParameters:(NSDictionary *) parameters {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.item = nilOrObject([parameters objectForKey:ControllerParameterItem]);
        self.tourTask = nilOrObject([parameters objectForKey:ControllerParameterTourTask]);
        self.preventScanning = [nilOrObject([parameters objectForKey:ControllerParameterPreventScanning]) boolValue];
        processChangeForbidden = [[parameters objectForKey:UnloadParameterProcessChangeForbidden] boolValue];
        shouldTriggerSyncOnExit = [[parameters objectForKey:ControllerTriggerSynchronisationOnExit] boolValue];
        
        self.transportGroupTourStop = nilOrObject([parameters objectForKey:ControllerTransportGroupTourStop]);
        
        self.title = NSLocalizedString(@"TITLE_027", @"Abladen");
        unloadedByFinger = NO;
    }
    return self;
}

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) {
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (NSArray *)transportCodesAtWork {
    if (!transportCodesAtWork) {
        transportCodesAtWork = [[NSArray alloc] init];
    }
    return transportCodesAtWork;
}

#pragma mark - View lifecycle

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)setTCbar { 
    //  -- Payment will be done at DFPF_TourLocation, but the "old" procedure is now planned for the weight check
    [self.currentTCPriceBadge removeFromSuperview];
    //  ---------------------------------------------------------------------------------------------------------
    NSMutableArray *tmpTCbar = [NSMutableArray arrayWithArray:self.currentTCbar.items];
    [tmpTCbar removeAllObjects]; 
    if ([self.currentTC.text length] > 0) { 
        //  -- Payment will be done at DFPF_TourLocation, but the "old" procedure is now planned for the weight check
        self.currentTCPriceBadge.hidden = YES;
        if ([[NSUserDefaults standardUserDefaults] boolForKey: @"HermesApp_SYSVAL_RUN_withImageForTransPortCodes"]) { 
            [self.currentTCbarCamera setAction:@selector(getImageForTransportCode)]; 
            [tmpTCbar insertObject:self.currentTCbarCamera  atIndex:0];
            [tmpTCbar insertObject:self.currentTCbarSpace02 atIndex:0];
        } 
    } else {
        self.currentTCPriceBadge.hidden = YES;
    }
    [tmpTCbar insertObject:self.currentTCbarSpace01 atIndex:0];
    [tmpTCbar insertObject:self.currentTCbarTitle   atIndex:0];
    [self.currentTCbar setItems:tmpTCbar animated:NO]; 
    [self.scanView addSubview:self.currentTCPriceBadge];
} 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *locationId = nil;
    NSNumber *transportGroupId = nil;
    locationId = ((Departure *)self.item).location_id.location_id;
    transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
    
    self.currentLocationDepartureExtension_F.text = @"🕙";
    self.currentLocationDepartureExtension_B.text = @"🕙";
    if (PFBrandingSupported(BrandingViollier, nil)) {
        NSMutableDictionary *barButtonAttributes = [NSMutableDictionary dictionaryWithDictionary: [self.currentTCbarTitle titleTextAttributesForState:UIControlStateNormal]];
        [barButtonAttributes setValue:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17] forKey:UITextAttributeFont];
        [self.currentTCbarTitle setTitleTextAttributes:barButtonAttributes forState:UIControlStateNormal];
    }
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        self.palettenLabel.text = NSLocalizedString(@"MESSAGE_043", @"Ladehilfsmittel");
        self.currentUnitCount.center = self.currentPalletCount.center;
        self.currentPalletCount.hidden = YES;
        self.currentUnit_tourTask.hidden = YES;
        self.rollcontainerLabel.hidden            = YES;
        self.currentRollcontainerCount.hidden     = YES;
        self.currentRollcontainer_tourTask.hidden = YES;
        self.transportGroupSummaryButton.hidden   = YES;
    } else {
        if ([NSUserDefaults isRunningWithBoxWithArticle]) {
            self.palettenLabel.text = NSLocalizedString(@"TITLE_109", @"Labor");
        } else {
            self.palettenLabel.text = NSLocalizedString(@"MESSAGE_028", @"Paletten");
        }
        if (!PFBrandingSupported(BrandingCCC_Group, nil)) {
            self.paketeLabel.center = self.rollcontainerLabel.center;
            self.currentUnitCount.center = self.currentRollcontainerCount.center;
            self.currentUnit_tourTask.center = self.currentRollcontainer_tourTask.center;
            self.rollcontainerLabel.hidden            = YES;
            self.currentRollcontainerCount.hidden     = YES;
            self.currentRollcontainer_tourTask.hidden = YES;
            self.transportGroupSummaryButton.hidden   = YES;
        } else {
            self.rollcontainerLabel.text = NSLocalizedString(@"MESSAGE_049", @"RollContainer");
        }
    }
    self.paketeLabel.text            = NSLocalizedString(@"MESSAGE_027", @"Pakete:");
    self.currentTCbarTitle.title     = NSLocalizedString(@"MESSAGE_033", @"abgeladen:");
    self.textInputTC.placeholder     = NSLocalizedString(@"PLACEHOLDER_003", @"transport code"); 
    [self.transportCodeButton setTitle:NSLocalizedString(@"MESSAGE_032", @"Transportcode") forState:UIControlStateNormal];
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        [self.paletteButton setTitle:NSLocalizedString(@"LHM", @"LHM") forState:UIControlStateNormal];
        [self.paketButton setTitle:NSLocalizedString(@"Gebinde", @"Gebinde") forState:UIControlStateNormal];
        [self.transportCodeButton setHidden:YES];
        [self.paletteButton setHidden:NO];
        [self.paketButton setHidden:NO];
    } else if (PFBrandingSupported(BrandingUnilabs, nil)) {
        [self.transportCodeButton setTitle:NSLocalizedString(@"TITLE_125", @"Scan bag") forState:UIControlStateNormal];
        self.palettenLabel.text = NSLocalizedString(@"TITLE_127", @"Transport bag");
        self.paketeLabel.text = NSLocalizedString(@"TITLE_128", @"Specimen bag");
    }
	if (!self.tableView && [self.view isKindOfClass:[UITableView class]]) {
        self.tableView = (UITableView *)(self.view);
		UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
		[tapToSuspend	setNumberOfTapsRequired:2];
		[tapToSuspend	setNumberOfTouchesRequired:2];
		[self.tableView	addGestureRecognizer:tapToSuspend];
    }
	self.view = self.textView;
	self.textInputTC.delegate = self;
	UITapGestureRecognizer *tapToSuspend_back = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend_back setNumberOfTapsRequired:2];
	[tapToSuspend_back setNumberOfTouchesRequired:2];
	[self.textView	   addGestureRecognizer:tapToSuspend_back];
	UITapGestureRecognizer *tapToSuspend_front = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend_front setNumberOfTapsRequired:2];
	[tapToSuspend_front setNumberOfTouchesRequired:2];
	[self.scanView		addGestureRecognizer:tapToSuspend_front];
	[self.view addSubview:self.tableView];
	[self.view addSubview:self.scanView]; 
    [self setTCbar];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:
                                               [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"png"]]
                                                                               style:UIBarButtonItemStyleBordered
                                                                              target:self
                                                                              action:@selector(switchViews)] autorelease];
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.currentLocationStreetAddress_F.frame = CGRectMake(self.currentLocationStreetAddress_F.frame.origin.x,
                                              self.currentLocationStreetAddress_F.frame.origin.y,
                                              self.currentLocationStreetAddress_F.frame.size.width,
                                              self.currentLocationCity_F.frame.origin.y - self.currentLocationStreetAddress_F.frame.origin.y +
                                              self.currentLocationCity_F.frame.size.height);
        self.currentLocationStreetAddress_F.numberOfLines = 3;
        self.currentLocationStreetAddress_F.lineBreakMode = UILineBreakModeWordWrap;
        [self.currentLocationStreetAddress_F setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        self.currentLocationStreetAddress_F.minimumFontSize = 8.0;
        self.currentLocationStreetAddress_F.textAlignment   = UITextAlignmentCenter;
        self.currentLocationCity_F.frame         = CGRectZero;
        self.currentLocationZipCode_F.frame      = CGRectZero;
        self.currentLocationStreetAddress_B.frame = CGRectMake(self.currentLocationStreetAddress_B.frame.origin.x,
                                                               self.currentLocationStreetAddress_B.frame.origin.y,
                                                               self.currentLocationStreetAddress_B.frame.size.width,
                                                               self.currentLocationCity_B.frame.origin.y - self.currentLocationStreetAddress_B.frame.origin.y +
                                                               self.currentLocationCity_B.frame.size.height);
        self.currentLocationStreetAddress_B.numberOfLines = 3;
        self.currentLocationStreetAddress_B.lineBreakMode = UILineBreakModeWordWrap;
        [self.currentLocationStreetAddress_B setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        self.currentLocationStreetAddress_B.minimumFontSize = 8.0;
        self.currentLocationStreetAddress_B.textAlignment   = UITextAlignmentCenter;
        self.currentLocationCity_B.frame         = CGRectZero;
        self.currentLocationZipCode_B.frame      = CGRectZero;
    }
    itemIsTransportGroup = ([self.item isKindOfClass:[Transport_Group class]]);
    
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        self.tableView.estimatedRowHeight = 44.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"technoparkBackground.png"]];
        self.tableView.backgroundView = backgroundImage;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [backgroundImage release];
        
        DSPF_SwitcherView *switcherView = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SwitcherView_technopark" owner:nil options:nil]objectAtIndex:0];
        [switcherView addStateWithTitle:@"Разгрузка" options:nil];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelButton setTitle:@"Отменить" forState:UIControlStateNormal];
        cancelButton.frame = CGRectMake(switcherView.frame.size.width - 90, switcherView.frame.size.height/2 - 22, 80, 44);
        [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        //switcherView.nextButton = cancelButton;
        [switcherView addSubview:cancelButton];
        //switcherView.nextButton.hidden = NO;
        
        self.customHeader = switcherView;
        
        
        [self.scanView removeFromSuperview];
        self.navigationItem.rightBarButtonItem = nil;
        CGRect tableFrame = self.tableView.frame;
        tableFrame.origin.x = 0;
        tableFrame.origin.y = 0;
        tableFrame.size = self.view.bounds.size;
        self.tableView.frame = tableFrame;
        self.view = self.tableView;
        
        self.transportCodesAtWork = [Transport transportsWithPredicate:
                                     [NSPredicate predicateWithFormat:
                                      @"transport_group_id.transport_group_id = %lld && (trace_type_id = nil || trace_type_id.trace_type_id <= 80) && (requestType = 1 || requestType = 3 || requestType = 5 || requestType = 6) && itemQTY > 0",
                                      [((Departure *)self.item).transport_group_id.transport_group_id longLongValue]] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
        self.serviceCodesAtWork = [Transport transportsWithPredicate:
                                   [NSPredicate predicateWithFormat:
                                    @"transport_group_id.transport_group_id = %lld && (trace_type_id = nil || trace_type_id.trace_type_id <= 80) && requestType = 2",
                                    [((Departure *)self.item).transport_group_id.transport_group_id longLongValue]] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
        self.pickupCodesAtWork = [Transport transportsWithPredicate:
                                   [NSPredicate predicateWithFormat:
                                    @"transport_group_id.transport_group_id = %lld && (trace_type_id = nil || trace_type_id.trace_type_id <= 80) && (requestType = 1 || requestType = 3 || requestType = 6) && itemQTY < 0",
                                    [((Departure *)self.item).transport_group_id.transport_group_id longLongValue]] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
        
        
        [self.tableView reloadData];
    }
}

- (void) cancelAction
{
    NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                  ControllerParameterItem : objectOrNSNull(self.item),
                                  ControllerParameterPreventScanning : @(preventScanning),
                                  ControllerTransportGroupTourStop: objectOrNSNull(self.transportGroupTourStop),
                                  @"CancellationMode":@YES };
    DSPF_Load *dspf_Load = [[[DSPF_Load alloc] initWithParameters:parameters] autorelease];
    [self.navigationController pushViewController:dspf_Load animated:YES];
    
    //NSNotification *notification = [NSNotification notificationWithName:@"123" object:nil userInfo:@{@"barcodeData":@"2H008P12345MA7_3"}];
    //[self didReturnBarcode:notification];
}


- (void)switchViews {
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.618];
    if (self.scanView.window) {
        if (itemIsTransportGroup) {
            self.transportCodesAtWork = [Transport transportsWithPredicate:
                                         [NSPredicate predicateWithFormat:
                                          @"to_location_id.location_id = %lld && "
                                          "trace_type_id.code = %@ && "
                                          "transport_group_id.transport_group_id = %lld",
                                          [self.transportGroupTourStop.location_id.location_id longLongValue], @"LOAD",
                                          [((Transport_Group *)self.item).transport_group_id longLongValue]]
                                                           sortDescriptors:nil inCtx:self.ctx];
        } else {
            if (PFBrandingSupported(BrandingTechnopark, nil))
            {
                self.transportCodesAtWork = [Transport transportsWithPredicate:
                                             [NSPredicate predicateWithFormat:
                                              @"transport_group_id.transport_group_id = %lld && (trace_type_id = nil || trace_type_id.trace_type_id <= 80) && code != ',,'",
                                              [((Departure *)self.item).transport_group_id.transport_group_id longLongValue]] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
                self.serviceCodesAtWork = [Transport transportsWithPredicate:
                                           [NSPredicate predicateWithFormat:
                                            @"transport_group_id.transport_group_id = %lld && (trace_type_id = nil || trace_type_id.trace_type_id <= 80) && code = ',,'",
                                            [((Departure *)self.item).transport_group_id.transport_group_id longLongValue]] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
            }
            else
                self.transportCodesAtWork = [Transport transportsWithPredicate:
                                         [NSPredicate predicateWithFormat:
                                          @"to_location_id.location_id = %lld && "
                                          "trace_type_id.code = %@",
                                          [((Departure *)self.item).location_id.location_id longLongValue], @"LOAD"]
                                                           sortDescriptors:nil inCtx:self.ctx];
        }
		[self.scanView  removeFromSuperview];
		[self.tableView reloadData];
		[self.textInputTC becomeFirstResponder];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self view] cache:NO];
    } else {
		self.textInputTC.text	   = nil;
		self.textInputTC.textColor = [UIColor blackColor];
		self.textInputTC.font	   = [UIFont fontWithName:@"Helvetica" size:18];
		[self.textInputTC resignFirstResponder];
		[self.view addSubview:self.scanView];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self view] cache:NO];
    }
	[UIView commitAnimations];
    if (self.scanView.window) {
        if (!self.preventScanning) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didReturnBarcode:)
                                                         name:@"barcodeData" object:nil];
        }
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"png"]]
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(switchViews)] autorelease];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
        self.navigationItem.rightBarButtonItem = 
        [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"barcode_white" ofType:@"png"]]
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(switchViews)] autorelease];
    }
}

- (void)commitUnloadTransport {
    [self.ctx saveIfHasChanges];
	self.currentTC.text			 = [NSUserDefaults currentTC];
    if (!itemIsTransportGroup && PFBrandingSupported(BrandingBiopartner, nil)) {
        NSNumber *locationId = ((Departure *)self.item).location_id.location_id;
        NSNumber *transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
        
        self.currentUnitCount.text = FmtStr(@"%i", [Transport countOf:Unit|RollContainer|Pallet forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
    } else {
        NSNumber *locationId = nil;
        NSNumber *transportGroupId = nil;
        if (itemIsTransportGroup) {
            locationId = ((Transport_Group *)self.item).addressee_id.location_id;
            transportGroupId = ((Transport_Group *)self.item).transport_group_id;
        } else {
            locationId = ((Departure *)self.item).location_id.location_id;
            transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
        }
        self.currentPalletCount.text = FmtStr(@"%i", [Transport countOf:Pallet forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
        self.currentRollcontainerCount.text = FmtStr(@"%i", [Transport countOf:RollContainer forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
        self.currentUnitCount.text	 = FmtStr(@"%i", [Transport countOf:Unit forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
    }
    [self setTCbar];
    
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSArray* allTransports = [Transport transportsWithPredicate:
         [NSPredicate predicateWithFormat:
          @"transport_group_id.transport_group_id = %lld && trace_type_id.code = %@ && requestType != 2",
          [((Departure *)self.item).transport_group_id.transport_group_id longLongValue], TraceTypeStringLoad] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
        NSInteger itemsLeft = allTransports.count;
        
        if (itemsLeft == 0)
            [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information")
                               messageText:NSLocalizedString(@"ERROR_MESSAGE_014", @"Für diese Ziel-Adresse\nist jetzt\nalles abgeladen.\n\nAbladen beenden ?")
                                      item:StatusReadySwitchToTourLocationItem
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
    }
    else if (([self.currentPalletCount.text intValue] + [self.currentRollcontainerCount.text intValue] + [self.currentUnitCount.text intValue]) == 0 && !processChangeForbidden) {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withSwitchToLoad"] isEqualToString:@"TRUE"]) {
            [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information")
                               messageText:NSLocalizedString(@"ERROR_MESSAGE_013", @"Für diese Ziel-Adresse\nist jetzt\nalles abgeladen.\n\nZum Laden wechseln ?")
                                      item:StatusReadySwitchToLoadItem
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
        } else {
            [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information")
                               messageText:NSLocalizedString(@"ERROR_MESSAGE_014", @"Für diese Ziel-Adresse\nist jetzt\nalles abgeladen.\n\nAbladen beenden ?")
                                      item:StatusReadySwitchToTourLocationItem
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
        }
	}
}

- (void)storeTransportCodeData:(NSDictionary *) userInfo {
    NSString *possibleBoxCode  = [Transport transportCodeFromBarcode:[NSUserDefaults currentTC]];
    if (PFBrandingSupported(BrandingUnilabs, nil) && [Transport_Box hasBoxWithCode:possibleBoxCode inCtx:self.ctx] &&
        [userInfo valueForKey:UnloadItemsAsInFinalDestination] == nil)
    {
        [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_137", @"Weiteres Vorgehen")
                           messageText:NSLocalizedString(@"MESSAGE_054", @"Werden Waren immer noch in Transit?")
                                  item:StatusReadyConfirmUnloadAtFinalDestination
                              delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
        return;
    }
    
    Departure *fromDeparture = nil;
    Location *toLocation = nil;
    TraceTypeValue traceType = TraceTypeValueMissing;
    if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
        traceType = TraceTypeValueMissing;
        fromDeparture = [Departure firstTourDepartureInCtx:self.ctx];
        if (itemIsTransportGroup) {
            toLocation = ((Transport_Group *)self.item).addressee_id;
        } else {
            toLocation = ((Departure *)self.item).location_id;
        }
    } else {
        traceType = TraceTypeValueUnload;
        if (itemIsTransportGroup) {
            fromDeparture = self.transportGroupTourStop;
        } else {
            fromDeparture = ((Departure *)self.item);
        }
        toLocation = fromDeparture.location_id;
    }
    
    NSString *transportCode = [NSUserDefaults currentTC];
    Transport_Box *transportBox = [[Transport_Box withPredicate:[Transport_Box withCode:transportCode] inCtx:self.ctx] lastObject];
    if (transportBox == nil) {
        NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:transportCode traceType:traceType fromDeparture:fromDeparture toLocation:toLocation];
        if (PFBrandingSupported(BrandingViollier, nil) && [transportCode hasPrefix:@"V001:"]) {
            [currentTransport setValue:[NSNumber numberWithInt:-1]                                           forKey:@"occurrences"];
        }
    
        [currentTransport setValue:@NO forKey:@"loading_operation"];
        [currentTransport setValue:[@{@"finger":[NSNumber numberWithInt:unloadedByFinger]} dictionaryByAddingEntriesFromDictionary:[currentTransport valueForKey:@"userInfo"]] forKey:@"userInfo"];
        
        Transport * transport = [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
        if (traceType == TraceTypeValueUnload) {
            Transport_Group *transportGroup = [Transport_Group transportGroupForItem:self.item ctx:self.ctx createWhenNotExisting:YES];
            [transportGroup addTransport_idObject:transport];
        }
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            
            NSUInteger index = NSNotFound;
            for (Transport *currentTransport in transportCodesAtWork) {
                
                NSString *borderedCode = [NSString stringWithFormat:@",%@,",[NSUserDefaults currentTC]];
                if ([currentTransport.code rangeOfString:borderedCode].location != NSNotFound && [currentTransport.trace_type_id.code isEqualToString:TraceTypeStringUnload] && currentTransport.requestType.intValue != 2)
                {
                    index = [transportCodesAtWork indexOfObject:currentTransport];
                    break;
                }
            }
            
            if (index != NSNotFound)
                [self updateIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            else
            {
                for (Transport *currentTransport in _pickupCodesAtWork) {
                    
                    NSString *borderedCode = [NSString stringWithFormat:@",%@,",[NSUserDefaults currentTC]];
                    if ([currentTransport.code rangeOfString:borderedCode].location != NSNotFound && [currentTransport.trace_type_id.code isEqualToString:TraceTypeStringUnload])
                    {
                        index = [_pickupCodesAtWork indexOfObject:currentTransport];
                        break;
                    }
                }
                
                if (index != NSNotFound)
                    [self updateIndexPath:[NSIndexPath indexPathForRow:index inSection:1]];

            }
        }
        
        
    } else {
        NSPredicate *transportsWithBoxToUnload = AndPredicates([Transport withTraceLogCodes:@[TraceTypeStringLoad]], [Transport withBoxCode:transportCode], nil);
        for (Transport *transportInBox in [Transport withPredicate:transportsWithBoxToUnload inCtx:self.ctx]) {
            NSMutableDictionary *transport = [Transport dictionaryWithCode:transportInBox.code traceType:TraceTypeValueUnload fromDeparture:fromDeparture toLocation:toLocation finalDestination:nil isPallet:nil];
            [Transport addTransportBox:transportBox toTraceLogDict:transport];
            [Transport addLocation:[[AppDelegate() locationManager] rcvLocation] toTraceLogDict:transport];
            [Transport transportWithDictionaryData:transport inCtx:self.ctx];
        }
        // unload box
        if (PFBrandingSupported(BrandingUnilabs, nil)) {
            NSMutableDictionary *transport = [Transport dictionaryWithCode:transportCode traceType:TraceTypeValueUnload fromDeparture:fromDeparture toLocation:toLocation];
            [Transport addLocation:[[AppDelegate() locationManager] rcvLocation] toTraceLogDict:transport];
            [Transport transportWithDictionaryData:transport inCtx:self.ctx];
            Transport_Box *transportBox = [Transport_Box transport_boxWithBarCode:transportCode inCtx:self.ctx];
            [self.ctx deleteObject:transportBox];
            if ([[userInfo valueForKey:UnloadItemsAsInFinalDestination] boolValue]) {
                NSString *boxCode  = [Transport transportCodeFromBarcode:transportCode];
                NSMutableDictionary *transport = [Transport dictionaryWithCode:boxCode traceType:TraceTypeValueReuseBox fromDeparture:fromDeparture toLocation:toLocation];
                [Transport transportWithDictionaryData:transport inCtx:self.ctx];
            }
        }
    }
    NSString *rememberedBoxCode = [Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]];
    if ([rememberedBoxCode isEqualToString:transportCode]) {
        [NSUserDefaults setBoxBarcode:nil];
    }
    [self commitUnloadTransport];
}

- (void) updateIndexPath:(NSIndexPath*) indexPath
{
    Transport* transport = indexPath.section == 0 ? transportCodesAtWork[indexPath.row]:_pickupCodesAtWork[indexPath.row];
    if (transport.itemQTY.intValue > 1)
    {
        self.indexPathToUpdate = indexPath;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Укажите количество товаров"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Выгрузить"
                                              otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert textFieldAtIndex:0].text = [NSString stringWithFormat:@"%d", transport.itemQTY.intValue];
        [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
        [alert show];
        [alert release];
    }
    else
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    Transport* transport = _indexPathToUpdate.section == 0 ? transportCodesAtWork[_indexPathToUpdate.row]:_pickupCodesAtWork[_indexPathToUpdate.row];
    NSInteger inputQuantity = [alertView textFieldAtIndex:0].text.intValue;
    NSInteger itemsQuantity = MAX(1, inputQuantity);
    transport.itemQTY = [NSNumber numberWithInt:itemsQuantity];
    [transport.managedObjectContext saveIfHasChanges];
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPathToUpdate] withRowAnimation:UITableViewRowAnimationNone];
    self.indexPathToUpdate = nil;
}

- (void)storeTransportItemData {
    // used by Oerlikon only
    Transport_Group *transportGroup = [Transport_Group transportGroupForItem:self.item ctx:self.ctx createWhenNotExisting:YES];
    
    Departure *fromDeparture = nil;
    if (itemIsTransportGroup) {
        fromDeparture = self.transportGroupTourStop;
    } else {
        fromDeparture = ((Departure *)self.item);
    }
    Location *toLocation = fromDeparture.location_id;
    
    for (Transport *tmpTransport in
         [NSArray arrayWithArray:[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                     @"code >= %@ AND code <= %@  AND trace_type_id.code = %@",
                                                                     [NSExpression expressionForConstantValue:[[NSUserDefaults currentTC] stringByAppendingString:@"-"]],
            [NSExpression expressionForConstantValue:[[[NSUserDefaults currentTC] stringByAppendingString:@"-"]
                                                      stringByAppendingString:[NSString stringWithUTF8String:"\uffff"]]], @"LOAD"]
                                                    sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES]]
                                             inCtx:self.ctx]])
    {
        NSInteger numberOfItems = 0;
        if (!tmpTransport.occurrences)
            numberOfItems = 1;
        else
            numberOfItems += [tmpTransport.occurrences integerValue];
        for (int i = 0; i < numberOfItems; i++) {
            NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:tmpTransport.code traceType:TraceTypeValueUnload
                                                                    fromDeparture:fromDeparture toLocation:toLocation];
            if (tmpTransport.occurrences) {
                [currentTransport setValue:[NSNumber numberWithInt:-1]                                        forKey:@"occurrences"];
            }
            Transport *transport = [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
            [transportGroup addTransport_idObject:transport];
        }
    }
    [self commitUnloadTransport];
}

- (void)checkForTransportData {
    if (!itemIsTransportGroup && PFTourTypeSupported(@"1X1", nil) && PFBrandingSupported(BrandingOerlikon, nil) &&
        [Transport shouldUnloadTransportItems:[NSUserDefaults currentTC] atLocation:((Departure *)self.item).location_id.location_id
                               transportGroup:((Departure *)self.item).transport_group_id.transport_group_id inCtx:self.ctx]) {
            [self storeTransportItemData];
            return;
    }
    NSRange  barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:[NSUserDefaults currentTC]];
	if (barCodeTrailerRange.location != NSNotFound) {
        [NSUserDefaults setCurrentTC:[[NSUserDefaults currentTC]  substringToIndex:barCodeTrailerRange.location]];
	}
    
    Location *unloadingLocation = nil;
    Transport_Group *transportGroup = nil;
    if (itemIsTransportGroup) {
        unloadingLocation = self.transportGroupTourStop.location_id;
        transportGroup = ((Transport_Group *)self.item);
    } else {
        unloadingLocation = ((Departure *)self.item).location_id;
        transportGroup = ((Departure *)self.item).transport_group_id;
    }
    BOOL transportNotOnTheTruck = [Transport shouldLoadTransportCode:[NSUserDefaults currentTC] transportGroup:transportGroup.transport_group_id inCtx:self.ctx];
    BOOL transportIsBox = [Transport_Box hasBoxWithCode:[NSUserDefaults currentTC] inCtx:self.ctx];
    BOOL shouldUnloadTransportHere = [Transport shouldUnloadTransportCode:[NSUserDefaults currentTC] atLocation:unloadingLocation.location_id
                                                           transportGroup:transportGroup.transport_group_id inCtx:self.ctx];
    
    if (!shouldUnloadTransportHere && (!transportIsBox || (PFBrandingSupported(BrandingUnilabs, nil) && transportIsBox && !shouldUnloadTransportHere))) {
        if (transportNotOnTheTruck) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
            if (processChangeForbidden) {
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_038", @"%@\nist aktuell\nnicht\nauf dem Fahrzeug!"),
                                     [NSUserDefaults currentTC]];
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_035", @"Transport-Code") messageText:message
                                delegate:nil cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK")];
            } else {
                [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_035", @"Transport-Code")
                               messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_015", @"%@\nist aktuell\nnicht\nauf dem Fahrzeug.\n\nZum Laden wechseln ?"), [NSUserDefaults currentTC]]
                                      item:StatusReadySwitchToLoadItem
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
            }
        } else {
            Location *transportDestination = [Transport destinationForTransportCode:[NSUserDefaults currentTC] inCtx:self.ctx];
            if (PFBrandingSupported(BrandingRegent, nil)) {
                [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_036", @"Ziel-Adresse")
                             messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_016", @"%@\n\n%@\nabladen ?"),
                                          [transportDestination formattedString], [NSUserDefaults currentTC]]
                                delegate:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
                [DSPF_Warning messageForConfirmingUnloadingTransportCode:[NSUserDefaults currentTC] initiallyIntendedDestination:transportDestination delegate:self];
            }
        }
        return;
    }
    
    [self storeTransportCodeData:nil];
}

- (IBAction)showTransportGroupSummary {
    if (itemIsTransportGroup) {
        DSPF_TransportGroupSummary *dspf_TransportGroupSummary = [[[DSPF_TransportGroupSummary alloc] init] autorelease];
        dspf_TransportGroupSummary.transportGroup = self.item;
        [self.navigationController pushViewController:dspf_TransportGroupSummary animated:YES];
    }
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )aItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
    if (!self.preventScanning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
    }
    if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
        if (aItem == WarningConfirmToUnloadItem) {
            //FIXME: here we need userInfo passed as well
            [self storeTransportCodeData:nil];
        } else if (aItem == StatusReadySwitchToLoadItem) {
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [viewControllers removeLastObject];
            if ([NSUserDefaults isRunningWithBoxWithArticle]) {
                NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                              ControllerParameterItem : objectOrNSNull(self.item) };
                DSPF_LoadBox *dspf_LoadBox = [[[DSPF_LoadBox alloc] initWithParameters:parameters] autorelease];
                [viewControllers addObject:dspf_LoadBox];
            } else {
                NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                              ControllerParameterItem : objectOrNSNull(self.item),
                                              ControllerTransportGroupTourStop : objectOrNSNull(self.transportGroupTourStop) };
                DSPF_Load *dspf_Load = [[[DSPF_Load alloc] initWithParameters:parameters] autorelease];
                [viewControllers addObject:dspf_Load];
            }
            [self.navigationController setViewControllers:viewControllers animated:YES];
		}
	}
}

- (void) dspf_StatusReady:(DSPF_StatusReady *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )aItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if (aItem == StatusReadySwitchToLoadItem) {
            NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
			[viewControllers removeLastObject];
            if ([NSUserDefaults isRunningWithBoxWithArticle]) {
                NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                              ControllerParameterItem : objectOrNSNull(self.item) };
                DSPF_LoadBox *dspf_LoadBox = [[[DSPF_LoadBox alloc] initWithParameters:parameters] autorelease];
                [viewControllers addObject:dspf_LoadBox];
            } else {
                NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                              ControllerParameterItem : objectOrNSNull(self.item),
                                              ControllerTransportGroupTourStop : objectOrNSNull(self.transportGroupTourStop) };
                DSPF_Load *dspf_Load = [[[DSPF_Load alloc] initWithParameters:parameters] autorelease];
                [viewControllers addObject:dspf_Load];
            }
			[self.navigationController setViewControllers:viewControllers animated:YES];
		} else if (aItem == StatusReadySwitchToTourLocationItem) {
			[self.navigationController popViewControllerAnimated:YES];
        } else if (aItem == StatusReadyConfirmUnloadAtFinalDestination) {
            BOOL isItFinalDestination = [[sender alertView] cancelButtonIndex] == buttonIndex;
            NSDictionary *userInfo = @{ UnloadItemsAsInFinalDestination : @(isItFinalDestination) };
            [self storeTransportCodeData:userInfo];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    
    if (self.preventScanning) {
        if (!PFBrandingSupported(BrandingBiopartner, nil)) {
            self.paketButton.enabled = NO;
        }
        self.paletteButton.enabled = NO;
        self.transportCodeButton.enabled = NO;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self   name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBarcode:) name:@"barcodeData" object:nil];
    }
    if (PFBrandingSupported(BrandingViollier, nil)) {
        if (itemIsTransportGroup) {
            self.currentLocationStreetAddress_F.text = ((Transport_Group *)self.item).addressee_id.location_name;
            self.currentLocationStreetAddress_B.text = ((Transport_Group *)self.item).addressee_id.location_name;
        } else {
            self.currentLocationStreetAddress_F.text = ((Departure *)self.item).location_id.location_name;
            self.currentLocationStreetAddress_B.text = ((Departure *)self.item).location_id.location_name;
        }
    } else {
        if (itemIsTransportGroup) {
            self.currentLocationCity_F.text          = self.transportGroupTourStop.location_id.city;
            self.currentLocationZipCode_F.text       = self.transportGroupTourStop.location_id.zip;
            self.currentLocationCity_B.text          = self.transportGroupTourStop.location_id.city;
            self.currentLocationZipCode_B.text       = self.transportGroupTourStop.location_id.zip;
            
            self.currentLocationStreetAddress_F.text = self.transportGroupTourStop.location_id.location_name;
            CGFloat actualLocationNameFontSize;
            [self.currentLocationStreetAddress_F.text sizeWithFont:self.currentLocationStreetAddress_F.font
                                                       minFontSize:self.currentLocationStreetAddress_F.minimumFontSize
                                                    actualFontSize:&actualLocationNameFontSize
                                                          forWidth:(self.currentLocationStreetAddress_F.frame.size.width - 10)
                                                     lineBreakMode:LineBreakModeByTruncatingTail];
            self.currentLocationStreetAddress_F.text = self.transportGroupTourStop.location_id.street;
            CGFloat actualStreetAddressFontSize;
            [self.currentLocationStreetAddress_F.text sizeWithFont:self.currentLocationStreetAddress_F.font
                                                       minFontSize:self.currentLocationStreetAddress_F.minimumFontSize
                                                    actualFontSize:&actualStreetAddressFontSize
                                                          forWidth:(self.currentLocationStreetAddress_F.frame.size.width - 10)
                                                     lineBreakMode:LineBreakModeByTruncatingTail];
            actualStreetAddressFontSize = MIN(actualLocationNameFontSize, actualStreetAddressFontSize);
            if (actualLocationNameFontSize > 15.00) actualLocationNameFontSize = 15.00;
            self.currentLocationStreetAddress_F.font = [self.currentLocationStreetAddress_F.font fontWithSize:
                                                        actualLocationNameFontSize];
            self.currentLocationStreetAddress_B.font = [self.currentLocationStreetAddress_B.font fontWithSize:
                                                        actualLocationNameFontSize];
            self.currentLocationStreetAddress_F.text = [NSString stringWithFormat:@"%@\n%@",
                                                        self.transportGroupTourStop.location_id.location_name,
                                                        self.transportGroupTourStop.location_id.street];
            self.currentLocationStreetAddress_B.text = [NSString stringWithFormat:@"%@\n%@",
                                                        self.transportGroupTourStop.location_id.location_name,
                                                        self.transportGroupTourStop.location_id.street];
            self.currentLocationStreetAddress_F.numberOfLines = 2;
            self.currentLocationStreetAddress_B.numberOfLines = 2;
            self.currentLocationStreetAddress_F.lineBreakMode = UILineBreakModeTailTruncation;
            self.currentLocationStreetAddress_B.lineBreakMode = UILineBreakModeTailTruncation;
            self.currentLocationStreetAddress_F.frame = CGRectMake(self.currentLocationStreetAddress_F.frame.origin.x,
                                                                   self.currentLocationStreetAddress_F.frame.origin.y,
                                                                   self.currentLocationStreetAddress_F.frame.size.width,
                                                                   self.currentLocationCity_F.frame.origin.y -
                                                                   self.currentLocationStreetAddress_F.frame.origin.y + 7);
            self.currentLocationStreetAddress_B.frame = CGRectMake(self.currentLocationStreetAddress_B.frame.origin.x,
                                                                   self.currentLocationStreetAddress_B.frame.origin.y,
                                                                   self.currentLocationStreetAddress_B.frame.size.width,
                                                                   self.currentLocationCity_B.frame.origin.y -
                                                                   self.currentLocationStreetAddress_B.frame.origin.y + 7);
            [self.currentLocationStreetAddress_F.superview bringSubviewToFront:self.currentLocationStreetAddress_F];
            [self.currentLocationStreetAddress_B.superview bringSubviewToFront:self.currentLocationStreetAddress_B];
        } else {
            self.currentLocationCity_F.text          = ((Departure *)self.item).location_id.city;
            self.currentLocationZipCode_F.text       = ((Departure *)self.item).location_id.zip;
            self.currentLocationStreetAddress_F.text = ((Departure *)self.item).location_id.street;
            self.currentLocationCity_B.text          = ((Departure *)self.item).location_id.city;
            self.currentLocationZipCode_B.text       = ((Departure *)self.item).location_id.zip;
            self.currentLocationStreetAddress_B.text = ((Departure *)self.item).location_id.street;
        }
    }
    if (!itemIsTransportGroup && PFTourTypeSupported(@"1X1", nil) && PFBrandingSupported(BrandingOerlikon, nil) &&
             ((Departure *)self.item).location_id.code && ((Departure *)self.item).location_id.code.length > 0) {
        self.currentLocationDepartureLabel_F.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).location_id.location_name];
        self.currentLocationDepartureLabel_F.numberOfLines = 2;
        self.currentLocationDepartureLabel_F.lineBreakMode = UILineBreakModeWordWrap;
        self.currentLocationDepartureLabel_F.font = [UIFont fontWithName:self.currentLocationDepartureLabel_F.font.familyName size:15];
        self.currentLocationDepartureLabel_F.frame       = CGRectMake(self.currentLocationDepartureLabel_F.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_F.frame.origin.y,
                                                                      self.currentLocationDepartureExtension_F.frame.origin.x
                                                                      + self.currentLocationDepartureExtension_F.frame.size.width
                                                                      - self.currentLocationDepartureLabel_F.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_F.frame.size.height);
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).location_id.location_name];
        self.currentLocationDepartureLabel_B.numberOfLines = 2;
        self.currentLocationDepartureLabel_B.lineBreakMode = UILineBreakModeWordWrap;
        self.currentLocationDepartureLabel_B.font = [UIFont fontWithName:self.currentLocationDepartureLabel_B.font.familyName size:15];
        self.currentLocationDepartureLabel_B.frame       = CGRectMake(self.currentLocationDepartureLabel_B.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_B.frame.origin.y,
                                                                      self.currentLocationDepartureExtension_B.frame.origin.x
                                                                      + self.currentLocationDepartureExtension_B.frame.size.width
                                                                      - self.currentLocationDepartureLabel_B.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_B.frame.size.height);
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (itemIsTransportGroup) {
        if ([self.transportGroupTourStop.location_id.location_id isEqualToNumber:
             ((Transport_Group *)self.item).addressee_id.location_id]) {
            self.currentLocationDepartureLabel_F.text        = [NSString stringWithFormat:@"%@\n%@\n%@ %@",
                                                                [((Transport_Group *)self.item).sender_id.location_name
                                                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                                ((Transport_Group *)self.item).sender_id.street,
                                                                ((Transport_Group *)self.item).sender_id.zip,
                                                                ((Transport_Group *)self.item).sender_id.city];
        } else {
            self.currentLocationDepartureLabel_F.text        = [NSString stringWithFormat:@"%@\n%@\n%@ %@",
                                                                [((Transport_Group *)self.item).addressee_id.location_name
                                                                 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                                ((Transport_Group *)self.item).addressee_id.street,
                                                                ((Transport_Group *)self.item).addressee_id.zip,
                                                                ((Transport_Group *)self.item).addressee_id.city];
        }
        self.currentLocationDepartureLabel_F.numberOfLines = 3;
        self.currentLocationDepartureLabel_F.lineBreakMode = UILineBreakModeWordWrap;
        self.currentLocationDepartureLabel_F.font = [UIFont fontWithName:self.currentLocationDepartureLabel_F.font.familyName size:13];
        self.currentLocationDepartureLabel_F.frame       = CGRectMake(self.currentLocationDepartureLabel_F.frame.origin.x,
                                                                      3,
                                                                      self.currentLocationDepartureExtension_F.frame.origin.x
                                                                      + self.currentLocationDepartureExtension_F.frame.size.width
                                                                      - self.currentLocationDepartureLabel_F.frame.origin.x,
                                                                      self.currentLocationStreetAddress_F.frame.origin.y - 5);
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = self.currentLocationDepartureLabel_F.text;
        self.currentLocationDepartureLabel_B.numberOfLines = 3;
        self.currentLocationDepartureLabel_B.lineBreakMode = UILineBreakModeWordWrap;
        self.currentLocationDepartureLabel_B.font = [UIFont fontWithName:self.currentLocationDepartureLabel_B.font.familyName size:13];
        self.currentLocationDepartureLabel_B.frame       = CGRectMake(self.currentLocationDepartureLabel_B.frame.origin.x,
                                                                      3,
                                                                      self.currentLocationDepartureExtension_B.frame.origin.x
                                                                      + self.currentLocationDepartureExtension_B.frame.size.width
                                                                      - self.currentLocationDepartureLabel_B.frame.origin.x,
                                                                      self.currentLocationStreetAddress_B.frame.origin.y - 5);
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (!itemIsTransportGroup && ((Departure *)self.item).departure) {
        self.currentLocationDepartureLabel_F.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_F.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).departure dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        self.currentLocationDepartureLabel_B.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_B.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).departure dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (!itemIsTransportGroup && ((Departure *)self.item).arrival) {
        self.currentLocationDepartureLabel_F.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_F.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).arrival dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        self.currentLocationDepartureLabel_B.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_B.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).arrival dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (!itemIsTransportGroup && ((Departure *)self.item).location_id.location_code)  { 
        self.currentLocationDepartureLabel_F.text        = ((Departure *)self.item).location_id.location_code;
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = ((Departure *)self.item).location_id.location_code;
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (!itemIsTransportGroup && ((Departure *)self.item).transport_group_id.task)  { 
        self.currentLocationDepartureLabel_F.text        = ((Departure *)self.item).transport_group_id.task;
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = ((Departure *)self.item).transport_group_id.task;
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (!itemIsTransportGroup && PFTourTypeSupported(@"1X1", nil) &&
               ((Departure *)self.item).location_id.code && ((Departure *)self.item).location_id.code.length > 0) {
        self.currentLocationDepartureLabel_F.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).location_id.location_name];
        self.currentLocationDepartureLabel_F.numberOfLines = 2;
        self.currentLocationDepartureLabel_F.lineBreakMode = UILineBreakModeWordWrap;
        self.currentLocationDepartureLabel_F.font = [UIFont fontWithName:self.currentLocationDepartureLabel_F.font.familyName size:15];
        self.currentLocationDepartureLabel_F.frame       = CGRectMake(self.currentLocationDepartureLabel_F.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_F.frame.origin.y,
                                                                      self.currentLocationDepartureExtension_F.frame.origin.x
                                                                      + self.currentLocationDepartureExtension_F.frame.size.width
                                                                      - self.currentLocationDepartureLabel_F.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_F.frame.size.height);
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).location_id.location_name];
        self.currentLocationDepartureLabel_B.numberOfLines = 2;
        self.currentLocationDepartureLabel_B.lineBreakMode = UILineBreakModeWordWrap;
        self.currentLocationDepartureLabel_B.font = [UIFont fontWithName:self.currentLocationDepartureLabel_B.font.familyName size:15];
        self.currentLocationDepartureLabel_B.frame       = CGRectMake(self.currentLocationDepartureLabel_B.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_B.frame.origin.y,
                                                                      self.currentLocationDepartureExtension_B.frame.origin.x
                                                                      + self.currentLocationDepartureExtension_B.frame.size.width
                                                                      - self.currentLocationDepartureLabel_B.frame.origin.x,
                                                                      self.currentLocationDepartureLabel_B.frame.size.height);
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (self.item == nil) {
        self.currentLocationDepartureLabel_F.text        = nil;
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = nil;
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else {
        if (!itemIsTransportGroup) {
            self.currentLocationDepartureLabel_F.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).departure_id];
            self.currentLocationDepartureTime_F.hidden       = YES;
            self.currentLocationDepartureExtension_F.hidden  = YES;
            self.currentLocationDepartureLabel_B.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).departure_id];
            self.currentLocationDepartureTime_B.hidden       = YES;
            self.currentLocationDepartureExtension_B.hidden  = YES;
        }
    }
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        NSNumber *locationId = nil;
        NSNumber *transportGroupId = nil;
        if (itemIsTransportGroup) {
            locationId = self.transportGroupTourStop.location_id.location_id;
            transportGroupId = ((Transport_Group *)self.item).transport_group_id;
        } else {
            locationId = ((Departure *)self.item).location_id.location_id;
            transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
        }
        self.currentUnitCount.text = FmtStr(@"%i", [Transport countOf:Unit|RollContainer|Pallet forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
    } else {
        if (itemIsTransportGroup) {
            NSNumber *locationId = ((Transport_Group *)self.item).addressee_id.location_id;
            NSNumber *transportGroupId = ((Transport_Group *)self.item).transport_group_id;
            self.currentPalletCount.text = FmtStr(@"%i", [Transport countOf:Pallet forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
            self.currentRollcontainerCount.text	 = FmtStr(@"%i", [Transport countOf:RollContainer forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
            self.currentUnitCount.text	 = FmtStr(@"%i", [Transport countOf:Unit forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
        } else {
            NSNumber *locationId = ((Departure *)self.item).location_id.location_id;
            NSNumber *transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
            self.currentPalletCount.text = FmtStr(@"%i", [Transport countOf:Pallet forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
            self.currentRollcontainerCount.text	 = FmtStr(@"%i", [Transport countOf:RollContainer forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
            self.currentUnitCount.text	 = FmtStr(@"%i", [Transport countOf:Unit forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
        }
    }
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        BOOL demoMode = PFCurrentModeIsDemo();
        NSMutableString *infoSigns = [NSMutableString string];
        [infoSigns appendString:@""];
        NSNumber *toLocation = nil;
        NSNumber *transportGroupId = nil;
        NSManagedObjectContext *context = nil;
        if (itemIsTransportGroup) {
            Transport_Group *tg = ((Transport_Group *)self.item);
            toLocation = tg.addressee_id.location_id;
            transportGroupId = tg.transport_group_id;
            context = tg.managedObjectContext;
        } else {
            Departure *dep = ((Departure *)self.item);
            toLocation = dep.location_id.location_id;
            transportGroupId = dep.transport_group_id.transport_group_id;
            context = dep.managedObjectContext;
        }
        for (NSString *sign in [Transport allInfoSigns]) {
            if (demoMode || [Transport hasStagingInfo:sign toLocation:toLocation transportGroup:transportGroupId inCtx:context]){
                [infoSigns appendString:sign];
            }
        }
        self.paketeLabel.text = infoSigns;
    }
    if (itemIsTransportGroup && PFBrandingSupported(BrandingCCC_Group, nil)) {
        BOOL demoMode = PFCurrentModeIsDemo();
        NSMutableString *infoSigns = [NSMutableString string];
        [infoSigns appendString:@""];
        if (demoMode ||
            [[((Transport_Group *)self.item).transport_id filteredSetUsingPredicate:
              [NSPredicate predicateWithFormat:@"temperatureZone == \"FS1\""]] allObjects].count != 0)
            [infoSigns appendString:[NSString stringWithFormat:@"%@ ",
                                     [NSString stringWithUTF8String:"\u2744"]]]; // @"❄️" is not shown correctly
        if (demoMode ||
            [[((Transport_Group *)self.item).transport_id filteredSetUsingPredicate:
              [NSPredicate predicateWithFormat:@"temperatureZone == \"FS2\""]] allObjects].count != 0)
            [infoSigns appendString:[NSString stringWithFormat:@"%@", @"⛄"]];
        if (demoMode ||
            [[((Transport_Group *)self.item).transport_id filteredSetUsingPredicate:
              [NSPredicate predicateWithFormat:@"temperatureZone == \"FS5\""]] allObjects].count != 0)
            [infoSigns appendString:[NSString stringWithFormat:@"%@", @"⚓️"]];
        if (infoSigns.length > 0) {
            self.transportGroupSummaryButton.layer.backgroundColor =
            [[[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 1.0] autorelease].CGColor;
        } else {
            self.transportGroupSummaryButton.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        }
        self.transportGroupSummaryButton.layer.cornerRadius = 9.0;
    }
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound || PFBrandingSupported(BrandingTechnopark, nil)) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
	}
    self.textInputTC.text = nil;
    if (shouldTriggerSyncOnExit) {
        [SVR_SyncDataManager triggerSendingTraceLogDataWithUserInfo:nil];
    }
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return self.customHeader;
    else
        return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.customHeader)
        return self.customHeader.frame.size.height;
    
    return UITableViewAutomaticDimension;
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewAutomaticDimension;
}

- (CGFloat) calculateSizeForIndexPath:(NSIndexPath *) indexPath
{
    static DSPF_TransportCell_technopark* sizingCell;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sizingCell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_TransportCell_technopark" owner:nil options:nil] objectAtIndex:0];        // Do any other initialisation stuff here
    });
    
    
} */

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

	return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    if (section == 0)
        return [self.transportCodesAtWork count];
    else if (section == 1)
        return [self.pickupCodesAtWork count];
    else if (section == 2)
        return [self.serviceCodesAtWork count];
    
    return 0;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
    
	if(aSection == 0) {
		return NSLocalizedString(@"TITLE_037", @"geladen:");
	}
    else if (aSection == 1 && _pickupCodesAtWork.count > 0 )
        return @"Забрать";
    else if (aSection == 2 && _serviceCodesAtWork.count > 0 )
        return @"Услуги";
        ;
	return nil;

}

- (NSString *)transportCode:(NSIndexPath *)indexPath {
    return [[self.transportCodesAtWork objectAtIndex:indexPath.row] valueForKey:@"code"];
}

- (void) gestureRecognizerAction:(UIGestureRecognizer*) sender
{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
     
    UITableViewCell *boundCell = (UITableViewCell*)sender.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:boundCell];
    Transport *selectedTransport = nil;
    
    if (indexPath.section == 0)
        selectedTransport = transportCodesAtWork[indexPath.row];
    else if (indexPath.section == 1)
        selectedTransport = _pickupCodesAtWork[indexPath.row];
    
    if (selectedTransport)
    {
        NSRange range = {.location = 1, .length = selectedTransport.code.length-2};
        NSString *cleanCode = [selectedTransport.code substringWithRange:range];
        NSNotification *notification = [NSNotification notificationWithName:@"123" object:nil userInfo:@{@"barcodeData":cleanCode, @"finger":@"YES"}];
        [self didReturnBarcode:notification];
    }
}

/*- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}*/

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if (PFBrandingSupported(BrandingTechnopark, nil))
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_TransportCell_technopark" owner:nil options:nil] objectAtIndex:0];
        else
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0)
    {
    
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            Transport *transport = [self.transportCodesAtWork objectAtIndex:indexPath.row];
            [((DSPF_TransportCell_technopark*)cell) setTransport:transport isLoad:NO];
            UILongPressGestureRecognizer *gestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)] autorelease];
            gestureRecognizer.minimumPressDuration = 3.0;
            gestureRecognizer.numberOfTouchesRequired = 1;
            [cell addGestureRecognizer:gestureRecognizer];
        }
        else
        {
            cell.textLabel.text = [self transportCode:indexPath];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
    }
    else if (indexPath.section == 1)
    {
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            Transport *transport = [self.pickupCodesAtWork objectAtIndex:indexPath.row];
            [((DSPF_TransportCell_technopark*)cell) setTransport:transport isLoad:NO];
            UILongPressGestureRecognizer *gestureRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)] autorelease];
            gestureRecognizer.minimumPressDuration = 3.0;
            gestureRecognizer.numberOfTouchesRequired = 1;
            [cell addGestureRecognizer:gestureRecognizer];
        }
        else
        {
            cell.textLabel.text = [self transportCode:indexPath]; //SHOULD BE [self serviceCode:indexPath] !
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }
    }
    else if (indexPath.section == 2)
    {
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            Transport *transport = [self.serviceCodesAtWork objectAtIndex:indexPath.row];
            [((DSPF_TransportCell_technopark*)cell) setTransport:transport isLoad:NO];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            cell.textLabel.text = [self transportCode:indexPath]; //SHOULD BE [self serviceCode:indexPath] !
            cell.textLabel.textAlignment = UITextAlignmentCenter;
        }

    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (Transport*) transportFromTransportCode:(NSString*) transportCode
{
    NSArray* transports = [Transport withPredicate:[NSPredicate predicateWithFormat:@"code = %@", transportCode] inCtx:self.ctx];
    return transports.firstObject;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // It is only a info list.
}


#pragma mark - Button actions

- (IBAction)scanDown:(UIButton *)aButton {
    if (PFBrandingSupported(BrandingBiopartner, nil) &&
        [aButton isEqual:self.paketButton]) {
        if (!itemIsTransportGroup) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
            for (ArchiveOrderHead *tmpOrderHead in [NSArray arrayWithArray:
                                                    [ArchiveOrderHead orderHeadsWithPredicate:[NSPredicate predicateWithFormat:@"orderState = 00"]
                                                                              sortDescriptors:nil
                                                                       inCtx:self.ctx]]) {
                [self.ctx deleteObject:tmpOrderHead];
            }
            [self.ctx saveIfHasChanges];
            DSPF_Order *dspf_Order      = [[[DSPF_Order alloc] init] autorelease];
            dspf_Order.title            = ((Departure *)self.item).location_id.location_name;
            dspf_Order.dataTask         = @"WRKACTDTA";
            dspf_Order.runsAsTakingBack = YES;
            dspf_Order.dataHeaderInfo = [ArchiveOrderHead orderHeadWithClientData:[NSNumber numberWithInt: [[NSUserDefaults currentUserID] intValue]]
                                                                      forLocation:((Departure *)self.item).location_id
                                                           inCtx:self.ctx];
            [self.navigationController pushViewController:dspf_Order animated:YES];
        }
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
    }
}

- (IBAction)scanUp:(UIButton *)aButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}

- (void)didReturnBarcode:(NSNotification *)aNotification {
    unloadedByFinger = ([[aNotification userInfo] objectForKey:@"finger"] != nil);
    [NSUserDefaults setCurrentTC:[[aNotification userInfo] valueForKey:@"barcodeData"]];
    [self performSelectorOnMainThread:@selector(checkForTransportData) withObject:nil waitUntilDone:NO];
}

- (void)getImageForTransportCode { 
	if ([self.currentTC.text length] > 0 &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_030", @"Kamera einschalten") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
        [DPHUtilities waitForAlertToShow:0.236f];
		self.dspf_ImagePicker = [[[DSPF_ImagePicker alloc] initWithParameters:nil] autorelease];
        self.dspf_ImagePicker.pickerDelegate = self;
		[self presentModalViewController:self.dspf_ImagePicker animated:YES];
        [showActivity closeActivityInfo];
		[showActivity release];
	}
}


#pragma mark - Image picker delegate

- (void)didFinishWithPhoto:(UIImage *)aPicture descriptionText:(NSString *)descriptionText userInfo:(NSDictionary *)userInfo {
    [self dismissModalViewControllerAnimated:YES];
    DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_031", @"Foto speichern") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
    // Pfad bzw. Daten und Namen fürs Speichern vorbereiten
    //  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData   *screenShot_PNG;
    //  NSString *screenShot_PNG_name;
    // UIImage als PNG konvertieren und im Dokumentenverzeichnis speichern 
    screenShot_PNG      = UIImagePNGRepresentation(aPicture);
    //  screenShot_PNG_name = [NSString stringWithFormat:@"%@.png", @"ScreenShot"];
    //  [screenShot_PNG writeToFile:[documentsDirectory stringByAppendingPathComponent:screenShot_PNG_name] atomically:YES];
    // ITEMPHOTO
    Departure *fromDeparture = nil;
    if (itemIsTransportGroup) {
        fromDeparture = self.transportGroupTourStop;
    } else {
        fromDeparture = ((Departure *)self.item);
    }
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueItemPhoto
                                                            fromDeparture:fromDeparture toLocation:fromDeparture.location_id];
    [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
    [currentTransport setValue:[NSUserDefaults currentTC]                                                forKey:@"receipt_text"];
    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
    [self.ctx saveIfHasChanges]; 
    self.currentTC.text = [NSUserDefaults currentTC]; 
    [showActivity closeActivityInfo];
    [showActivity release];
}

- (void)didFinishWithoutPhoto {
    [self dismissModalViewControllerAnimated:YES]; 
    self.currentTC.text = [NSUserDefaults currentTC]; 
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField {
	aTextField.text		 = nil;
	aTextField.textColor = [UIColor blackColor];
	aTextField.font		 = [UIFont fontWithName:@"Helvetica" size:18];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
	[aTextField resignFirstResponder];
	if (aTextField.text.length) {
		return YES;
	}else {
		return NO;
	}
}

- (void)textFieldDidEndEditing:(UITextField *)aTextField {
	if (self.textInputTC.text && self.textInputTC.text.length > 0) {
		/* Eingabe o.k. */
        [NSUserDefaults setCurrentTC:aTextField.text];
        [self checkForTransportData];
		[self switchViews];
	}
	/* Eingabe leer */
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.tableView                           = nil;
	self.scanView                            = nil;
	self.textView                            = nil;
	self.currentLocationDepartureExtension_F = nil;
    self.currentLocationDepartureTime_F      = nil;
    self.currentLocationDepartureLabel_F     = nil;
	self.currentLocationStreetAddress_F      = nil;
	self.currentLocationZipCode_F            = nil;
	self.currentLocationCity_F               = nil;
	self.currentLocationDepartureExtension_B = nil;
    self.currentLocationDepartureTime_B      = nil;
    self.currentLocationDepartureLabel_B     = nil;
	self.currentLocationStreetAddress_B      = nil;
	self.currentLocationZipCode_B            = nil;
	self.currentLocationCity_B               = nil;
	self.textInputTC                         = nil;
	self.currentTC                           = nil;
	self.currentPalletCount                  = nil;
    self.currentRollcontainer_tourTask       = nil;
    self.currentRollcontainerCount           = nil;
    self.currentUnit_tourTask                = nil;
	self.currentUnitCount                    = nil;
    self.currentTCbar                        = nil;
    self.currentTCbarTitle                   = nil;
    self.currentTCbarSpace01                 = nil;
    self.currentTCbarCamera                  = nil;
    self.currentTCbarSpace02                 = nil;
    self.currentTCbarPrice                   = nil;
    self.currentTCPriceBadge                 = nil;
    self.transportCodeButton                 = nil;
    self.transportGroupSummaryButton         = nil;
    self.paketButton                         = nil;
    self.paletteButton                       = nil;
    self.paketeLabel                         = nil;
    self.rollcontainerLabel                  = nil;
    self.palettenLabel                       = nil;
}


- (void)dealloc { 
	[dspf_ImagePicker					 release];
	[ctx                                 release];
	[transportCodesAtWork                release];
    [transportGroupTourStop              release];
    [item                                release];
    [paketeLabel                         release];
    [rollcontainerLabel                  release];
    [palettenLabel                       release];
    [transportCodeButton                 release];
    [paketButton                         release];
    [paletteButton                       release];
    [transportGroupSummaryButton         release];
	[currentLocationDepartureExtension_F release];
    [currentLocationDepartureTime_F      release];
    [currentLocationDepartureLabel_F     release];
	[currentLocationStreetAddress_F      release];
	[currentLocationZipCode_F            release];
	[currentLocationCity_F               release];
	[currentLocationDepartureExtension_B release];
    [currentLocationDepartureTime_B      release];
    [currentLocationDepartureLabel_B     release];
	[currentLocationStreetAddress_B      release];
	[currentLocationZipCode_B            release];
	[currentLocationCity_B               release];
	[textInputTC                         release];
	[currentTC                           release];
	[scanInputTC                         release];
	[currentPalletCount                  release];
    [currentRollcontainer_tourTask       release];
    [currentRollcontainerCount           release];
    [currentUnit_tourTask                release];
	[currentUnitCount                    release];
    [currentTCbar                        release];
    [currentTCbarTitle                   release];
    [currentTCbarSpace01                 release];
    [currentTCbarCamera                  release];
    [currentTCbarSpace02                 release];
    [currentTCbarPrice                   release];
    [currentTCPriceBadge                 release];
    [tourTask                            release];
	[tableView                           release];
	[scanView                            release];
	[textView                            release];
    [_customHeader                       release];
    [_serviceCodesAtWork                 release];
    [_indexPathToUpdate                  release];
    [super dealloc];
}


@end

