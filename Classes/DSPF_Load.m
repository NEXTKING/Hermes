//
//  DSPF_Load.m
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Load.h"
#import "DSPF_Unload.h"
#import "DSPF_Suspend.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"
#import "DSPF_Order.h"
#import "DSPF_TransportItem.h"
#import "DSPF_TransportGroupSummary.h"
#import "DPHButtonsView.h"
#import "HermesAppDelegate.h"
#import "DSPF_TransportCell_technopark.h"
#import "DSPF_SwitcherView.h"

#import "Location.h"
#import "Location_Alias.h"
#import "Transport_Group.h"
#import "Transport.h"
#import "ArchiveOrderHead.h"

NSString * const LoadParameterTransportBox = @"LoadParameterTransportBox";

@interface DSPF_Load()
@property (nonatomic, retain) DPHButtonsView *buttons;
@property (nonatomic, retain) UIButton *paketButton;
@property (nonatomic, retain) UIButton *paletteButton;

@property (nonatomic, retain)          id                        item;
@property (nonatomic, retain)          NSString                 *tourTask;
@property (nonatomic, assign)          BOOL                      preventScanning;
@property (nonatomic, retain)          Departure                *transportGroupTourStop;
@property (nonatomic, retain)          Transport_Box            *transportBox;
@property (nonatomic, assign)          NSUInteger               updatedTransportsCount;
@property (nonatomic, retain)          UIView*                  customHeader;
@end

@implementation DSPF_Load
@synthesize buttons;
@synthesize scanView;
@synthesize tableView;
@synthesize textView;
@synthesize palettenLabel;
@synthesize rollcontainerLabel;
@synthesize paketeLabel;
@synthesize transportGroupSummaryButton;
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
@synthesize currentTCDestination;
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
@synthesize item;
@synthesize transportGroupTourStop;
@synthesize tourTask;
@synthesize transportBox;
@synthesize	transportCodesAtWork;
@synthesize dspf_ImagePicker;
@synthesize paketButton;
@synthesize paletteButton;
@synthesize updatedTransportsCount;

- (instancetype)init {
    return [self initWithParameters:nil];
}

- (instancetype)initWithParameters:(NSDictionary *) parameters {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.item = nilOrObject([parameters objectForKey:ControllerParameterItem]);
        self.tourTask = nilOrObject([parameters objectForKey:ControllerParameterTourTask]);
        self.preventScanning = [nilOrObject([parameters objectForKey:ControllerParameterPreventScanning]) boolValue];
        self.delegate = nilOrObject([parameters objectForKey:ControllerParameterDelegate]);
        self.transportGroupTourStop = nilOrObject([parameters objectForKey:ControllerTransportGroupTourStop]);
        
        self.transportBox = nilOrObject([parameters objectForKey:LoadParameterTransportBox]);
        self.cancellationMode = [[parameters objectForKey:@"CancellationMode"] boolValue];
        
        self.title = NSLocalizedString(@"TITLE_008", @"Laden");
    }
    return self;
}

#pragma mark - Initialization

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
    NSMutableArray *tmpTCbar = [NSMutableArray arrayWithArray:self.currentTCbar.items];
    [tmpTCbar removeAllObjects]; 
    if ([self.currentTC.text length] > 0) { 
        if ([[NSUserDefaults standardUserDefaults] boolForKey: @"HermesApp_SYSVAL_RUN_withImageForTransPortCodes"]) { 
            [self.currentTCbarCamera setAction:@selector(getImageForTransportCode)]; 
            [tmpTCbar insertObject:self.currentTCbarCamera  atIndex:0];
        } 
    }
    if (!self.transportBox) {
        self.currentTCbarTitle.title = NSLocalizedString(@"TITLE_037", @"geladen:");
    } else {
        self.currentTCbarTitle.title = [NSString stringWithFormat:@"🆔:%@ %@",
                                        self.transportBox.code,
                                        NSLocalizedString(@"TITLE_037", @"geladen:")];
    }
    [tmpTCbar insertObject:self.currentTCbarSpace01 atIndex:0];
    [tmpTCbar insertObject:self.currentTCbarTitle   atIndex:0];
    [self.currentTCbar setItems:tmpTCbar animated:NO]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paletteButton = [DPHButtonsView grayButtonWithTitle:nil];
    self.paketButton = [DPHButtonsView grayButtonWithTitle:nil];
    
    [self.paletteButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.paletteButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self.paletteButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchCancel];
    [self.paletteButton addTarget:self action:@selector(scanDown:) forControlEvents:UIControlEventTouchDown];
    
    [self.paketButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.paketButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self.paketButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchCancel];
    [self.paketButton addTarget:self action:@selector(scanDown:) forControlEvents:UIControlEventTouchDown];
    
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
	self.paketeLabel.text               = NSLocalizedString(@"MESSAGE_027", @"Pakete");
    
    //[[[UIColor alloc] initWithRed:0 / 255 green:0 / 255 blue:0 / 255 alpha: 0.5] autorelease]]]];
    self.textInputTC.placeholder        = NSLocalizedString(@"PLACEHOLDER_003", @"transportcode");
    NSString *paletteButtonText = NSLocalizedString(@"TITLE_049", @"Palette");
    NSString *paketButtonText = NSLocalizedString(@"TITLE_084", @"Paket");
    if (PFTourTypeSupported(@"1X1", nil)) {
        [self.paletteButton setBackgroundImage:[UIImage imageNamed:@"b280x48_n.png"] forState:UIControlStateNormal];
        [self.paletteButton setFrame:CGRectMake(20, 310, 281, 96)];
        self.paketButton.hidden = YES;
        paletteButtonText = NSLocalizedString(@"MESSAGE_032", @"Transportcode");
    } else if ([NSUserDefaults isRunningWithBoxWithArticle]) {
        paletteButtonText = [NSLocalizedString(@"TITLE_109", @"LABOR") uppercaseString];
        paketButtonText = [NSLocalizedString(@"TITLE_084", @"PAKET") uppercaseString];
    } else if (PFBrandingSupported(BrandingBiopartner, nil)) {
        paletteButtonText = NSLocalizedString(@"LHM", @"LHM");
        paketButtonText = NSLocalizedString(@"Gebinde", @"Gebinde");
    }
    
    [self.paletteButton setTitle:paletteButtonText forState:UIControlStateNormal];
    [self.paketButton setTitle:paketButtonText forState:UIControlStateNormal];
    
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
    
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        self.palettenLabel.text = NSLocalizedString(@"TITLE_127", @"Transport bag");
        self.paketeLabel.text = NSLocalizedString(@"TITLE_128", @"Specimen bag");
        
        self.paletteButton.hidden = YES;
        NSString *paketButtonText = NSLocalizedString(@"TITLE_126", @"Scan specimen bag");
        if ([NSUserDefaults isRunningWithBoxWithArticle] && self.transportBox == nil) {
            paketButtonText = NSLocalizedString(@"TITLE_130", @"Scan transport bag");
        }
        [self.paketButton setTitle:paketButtonText forState:UIControlStateNormal];
    }
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        self.tableView.estimatedRowHeight = 44.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"technoparkBackground.png"]];
        self.tableView.backgroundView = backgroundImage;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [backgroundImage release];
        
        DSPF_SwitcherView *switcherView = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SwitcherView_technopark" owner:nil options:nil]objectAtIndex:0];
        
        if (!_cancellationMode)
        {
            [switcherView addStateWithTitle:@"Загрузка" options:nil];
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [cancelButton setTitle:@"Отменить" forState:UIControlStateNormal];
            cancelButton.frame = CGRectMake(switcherView.frame.size.width - 90, switcherView.frame.size.height/2 - 22, 80, 44);
            [cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
            [switcherView addSubview:cancelButton];
        }
        else
        {
            [switcherView addStateWithTitle:@"Загрузка (Режим отмены)" options:nil];
            
            UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [cancelButton setTitle:@"Load" forState:UIControlStateNormal];
            cancelButton.frame = CGRectMake(switcherView.frame.size.width - 90, switcherView.frame.size.height/2 - 22, 80, 44);
            [cancelButton addTarget:self action:@selector(loaaaaad) forControlEvents:UIControlEventTouchUpInside];
            //switcherView.nextButton = cancelButton;
            [switcherView addSubview:cancelButton];
            
        }
        
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
                                      @"transport_group_id.transport_group_id = %lld && (trace_type_id = nil || trace_type_id.trace_type_id <= 80) && code != ',,'",
                                      [((Departure *)self.item).transport_group_id.transport_group_id longLongValue]] sortDescriptors:nil inCtx:((Departure *)self.item).managedObjectContext];
    }
    
    self.buttons.verticalArrangement = NO;
    self.buttons.buttonsHeight = 96.0f;
    self.buttons.buttons = @[self.paletteButton, self.paketButton];
}

- (void) loaaaaad
{
    NSNotification *notification = [NSNotification notificationWithName:@"123" object:nil userInfo:@{@"barcodeData":@"2046750"}];
    [self didReturnBarcode:notification];
}

- (void) cancelAction
{
    NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                  ControllerParameterItem : objectOrNSNull(self.item),
                                  ControllerParameterPreventScanning : @(preventScanning),
                                  ControllerTransportGroupTourStop: objectOrNSNull(self.transportGroupTourStop) };
    DSPF_Unload *dspf_Unload = [[[DSPF_Unload alloc] initWithParameters:parameters] autorelease];
    [self.navigationController pushViewController:dspf_Unload animated:YES];
}


- (NSPredicate *)predicateForTransportCodesAtWork {
    NSPredicate *predicate = nil;
    
    NSPredicate *traceTypeCodePredicate = [NSPredicate predicateWithFormat:
                                           @"(trace_type_id = nil OR trace_type_id.code != %@ && trace_type_id.code != %@ && !(trace_type_id.trace_type_id >= 80))",
                                           TraceTypeStringUnload, TraceTypeStringLoad];
    NSPredicate *itemIdNilOrItemWithCategory2 = [NSPredicate predicateWithFormat:@"(item_id = nil OR item_id.itemCategoryCode = \"2\")"];
    
    if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
        if (itemIsTransportGroup) {
            predicate = AndPredicates([Transport withFromLocationId:self.transportGroupTourStop.location_id.location_id],
                                      [Transport withTransportGroupId:((Transport_Group *)self.item).transport_group_id],
                                      itemIdNilOrItemWithCategory2,
                                      traceTypeCodePredicate, nil);
        } else {
            predicate = AndPredicates([Transport withFromLocationId:((Departure *)self.item).location_id.location_id],
                                      traceTypeCodePredicate, nil);
            if (((Departure *)self.item).transport_group_id.transport_group_id) {
                predicate = AndPredicates(predicate, [Transport withTransportGroupId:((Departure *)self.item).transport_group_id.transport_group_id], nil);
            }
        }
    } else {
        if (itemIsTransportGroup) {
            predicate = AndPredicates([Transport withToLocationId:((Transport_Group *)self.item).addressee_id.location_id],
                                      [Transport withTransportGroupId:((Transport_Group *)self.item).transport_group_id],
                                      itemIdNilOrItemWithCategory2,
                                      traceTypeCodePredicate, nil);
        } else {
            predicate = AndPredicates([Transport withToLocationId:((Departure *)self.item).location_id.location_id],
                                      traceTypeCodePredicate, nil);
            
            if (((Departure *)self.item).transport_group_id.transport_group_id) {
                predicate = AndPredicates(predicate, [Transport withTransportGroupId:((Departure *)self.item).transport_group_id.transport_group_id], nil);
            }
        }
    }
    return predicate;
}

- (void)switchViews { 
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.618];

    if (self.scanView.window) {
        self.transportCodesAtWork = [Transport withPredicate:[self predicateForTransportCodesAtWork] inCtx:ctx()];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(didReturnBarcode:)
                                                             name:@"barcodeData" object:nil];
            });
        }
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keyboard" ofType:@"png"]]
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(switchViews)] autorelease];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
        });
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"barcode_white" ofType:@"png"]]
                                          style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(switchViews)] autorelease];
    }
}

- (void)storeTransportCodeDataWithToLocation:(Location *) aToLocation {
    if (PFTourTypeSupported(@"1X1", nil) && PFBrandingSupported(BrandingOerlikon, nil)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
        DSPF_TransportItem *dspf_TransportItem = [[DSPF_TransportItem alloc] initWithNibName:@"DSPF_TransportItem" bundle:nil];
        dspf_TransportItem.title          = [NSUserDefaults currentTC];
        dspf_TransportItem.dspf_Load      = self;
        [self.navigationController pushViewController:dspf_TransportItem animated:YES];
        [dspf_TransportItem release];
    } else {
        NSString *transportCode = [NSUserDefaults currentTC];
        if (PFTourTypeSupported(@"1X1", nil)) {
            scanDeviceShouldReturnPalletBarcode = NO;
        }
        
        Departure *dep = nil;
        if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
            dep = [Departure firstTourDepartureInCtx:ctx()];
        } else {
            if (itemIsTransportGroup) {
                dep = self.transportGroupTourStop;
            } else {
                dep = ((Departure *)self.item);
            }
        }
        Location *toLocation = nil;
        if (itemIsTransportGroup) {
            toLocation = ((Transport_Group *)self.item).addressee_id;
        } else {
            toLocation = aToLocation;
        }
        
        NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:transportCode traceType:TraceTypeValueLoad fromDeparture:dep toLocation:toLocation finalDestination:[transportBox finalDestinationLocation] isPallet:@(scanDeviceShouldReturnPalletBarcode)];
        [Transport addTransportBox:self.transportBox toTraceLogDict:currentTransport];
        if (PFBrandingSupported(BrandingViollier, nil) && [[NSUserDefaults currentTC] hasPrefix:@"V001:"]) {
            [currentTransport setValue:[NSNumber numberWithInt:1]                                        forKey:@"occurrences"];
        }
        
        NSPredicate *transportPredicate = AndPredicates([Transport withCodes:@[transportCode]],[Transport withTransportGroupId:dep.transport_group_id.transport_group_id], nil);
        NSNumber *traceTypeOfTransportBeforeChange = [[[[Transport withPredicate:transportPredicate inCtx:ctx()] lastObject] trace_type_id] trace_type_id];
        if ([traceTypeOfTransportBeforeChange intValue] == 0) {
            ++updatedTransportsCount;
        }
        
        [currentTransport setValue:@YES forKey:@"loading_operation"];
        
        Transport *transport = [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
        Transport_Group *transportGroup = [Transport_Group transportGroupForItem:self.item ctx:ctx() createWhenNotExisting:NO];
        
        [transportGroup removeTransport_idObject:transport];
        [ctx() saveIfHasChanges];
        scanDeviceShouldReturnPalletBarcode = NO;
        self.currentTC.text = [NSUserDefaults currentTC];
        [self setCountValues];
        [self setTCbar];
        if (updatedTransportsCount > 0 &&
            ([self.currentPalletCount.text intValue] + [self.currentRollcontainerCount.text intValue] + [self.currentUnitCount.text intValue]) == 0)
        {
            [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information")
                               messageText:NSLocalizedString(@"MESSAGE_009", @"Für diese Ziel-Adresse\nist jetzt\nalles geladen.\n\nLaden beenden ?")
                                      item:StatusReadySwitchToTourLocationItem
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
        }
        if (PFTourTypeSupported(@"0X1", nil) && !self.transportBox && [NSUserDefaults isRunningWithBoxWithArticle]) {
            if (self.delegate != nil) {
                [self.delegate loadController:self didLoadTransportsWithCodes:@[[NSUserDefaults currentTC]]];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
        
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            NSUInteger index = NSNotFound;
            for (Transport *currentTransport in transportCodesAtWork) {
                NSString *borderedCode = [NSString stringWithFormat:@",%@,",transportCode];
                
                if ([currentTransport.code containsString:borderedCode] && [currentTransport.trace_type_id.code isEqualToString:TraceTypeStringLoad])
                {
                    index = [transportCodesAtWork indexOfObject:currentTransport];
                    break;
                }
            }
            if (index != NSNotFound)
            {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    
    }
}

- (void) setCountValues {
    if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
        NSNumber *locationId = nil;
        NSNumber *transportGroupId = nil;
        if (itemIsTransportGroup) {
            locationId = ((Transport_Group *)self.item).sender_id.location_id;
            transportGroupId = ((Transport_Group *)self.item).transport_group_id;
        } else {
            locationId = ((Departure *)self.item).location_id.location_id;
            transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
        }
        self.currentPalletCount.text = FmtStr(@"%i",
                                              [Transport countOf:Pallet fromTourLocation:locationId transportGroup:transportGroupId ctx:ctx()]);
        self.currentRollcontainerCount.text	 = FmtStr(@"%i",
                                                      [Transport countOf:RollContainer fromTourLocation:locationId transportGroup:transportGroupId ctx:ctx()]);
        self.currentUnitCount.text	 = FmtStr(@"%i",
                                              [Transport countOf:Unit fromTourLocation:locationId transportGroup:transportGroupId ctx:ctx()]);
    } else {
        if (itemIsTransportGroup) {
            self.currentPalletCount.text = [NSString stringWithFormat:@"%i",
                                            [Transport transportsOpenPalletCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                                 transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                         inCtx:ctx()]];
            self.currentRollcontainerCount.text	 = [NSString stringWithFormat:@"%i",
                                                    [Transport transportsOpenRollContainerCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                                                transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                                        inCtx:ctx()]];
            self.currentUnitCount.text	 = [NSString stringWithFormat:@"%i",
                                            [Transport transportsOpenUnitCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                               transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                       inCtx:ctx()]];
        } else {
            if (PFTourTypeSupported(@"1X1", nil)) {
                self.currentPalletCount.text = [NSString stringWithFormat:@"%i",
                                                [Transport transportsPalletCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                 transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                                          inCtx:ctx()]];
                self.currentRollcontainerCount.text	 = [NSString stringWithFormat:@"%i",
                                                        [Transport transportsRollContainerCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                                transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                                                         inCtx:ctx()]];
                self.currentUnitCount.text	 = [NSString stringWithFormat:@"%i",
                                                [Transport transportsUnitCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                               transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                                        inCtx:ctx()]];
            } else {
                self.currentPalletCount.text = [NSString stringWithFormat:@"%i",
                                                [Transport transportsOpenPalletCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                     transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                                              inCtx:ctx()]];
                self.currentRollcontainerCount.text	 = [NSString stringWithFormat:@"%i",
                                                        [Transport transportsOpenRollContainerCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                                    transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                                                             inCtx:ctx()]];
                self.currentUnitCount.text	 = [NSString stringWithFormat:@"%i",
                                                [Transport transportsOpenUnitCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                   transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                                            inCtx:ctx()]];
            }
        }
    }
}

- (void)storeTransportItemData {
    if (PFTourTypeSupported(@"1X1", nil)) {
        scanDeviceShouldReturnPalletBarcode = NO;
        self.currentTC.text = [NSUserDefaults currentTC];
        [self setCountValues];
        [self setTCbar];
    }
}

+ (BOOL)shouldSwitchToUnloadWithItem:(NSManagedObject *)item transportGroupTourStop:(Departure *)transportGroupTourStop task:(NSString *) tourTask error:(NSError **) error {
    BOOL itemIsTransportGroup = ([item isKindOfClass:[Transport_Group class]]);
    Transport_Group *transportGroup = nil;
    Location *toLocation = nil;
    if (itemIsTransportGroup) {
        transportGroup = ((Transport_Group *)item);
        toLocation = transportGroupTourStop.location_id;
    } else {
        transportGroup = ((Departure *)item).transport_group_id;
        toLocation = ((Departure *)item).location_id;
    }
    
    if (PFTourTypeSupported(@"1X1", nil) && ![Transport shouldLoadTransportItems:[NSUserDefaults currentTC] transportGroup:transportGroup.transport_group_id inCtx:ctx()]) {
        SetError(error, [NSError errorForAlreadyLoadedTransportCode:[NSUserDefaults currentTC] domain:DPHLoadDomain]);
        return NO;
    } else if (![Transport shouldLoadTransportCode:[NSUserDefaults currentTC] transportGroup:transportGroup.transport_group_id inCtx:ctx()]) {
        if (PFBrandingSupported(BrandingViollier, nil) && [[NSUserDefaults currentTC] hasPrefix:@"V001:"] &&
            ![Transport shouldUnloadTransportCode:[NSUserDefaults currentTC]
                                       atLocation:toLocation.location_id
                                   transportGroup:transportGroup.transport_group_id
                                            inCtx:ctx()])
        {
            return NO;
        } else {
            SetError(error, [NSError errorForAlreadyLoadedTransportCode:[NSUserDefaults currentTC] domain:DPHLoadDomain]);
            return NO;
        }
    } else {
        if ([tourTask isEqualToString:TourTaskNormalDrive]) {
            Location *location = nil;
            Transport_Group *transportGroup = nil;
            if (itemIsTransportGroup) {
                location = ((Transport_Group *)item).addressee_id;
                transportGroup = ((Transport_Group *)item);
            } else {
                location = ((Departure *)item).location_id;
                transportGroup = ((Departure *)item).transport_group_id;
            }
            
            if (!PFBrandingSupported(BrandingTechnopark, nil) && [Transport shouldUnloadTransportCode:[NSUserDefaults currentTC] atLocation:location.location_id
                                      transportGroup:transportGroup.transport_group_id inCtx:ctx()])
            {
                //FIXME: also throw an error?
                [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
                return YES;
            }
        }
    }
    return NO;
}

- (IBAction)showTransportGroupSummary {
    if (itemIsTransportGroup) {
        DSPF_TransportGroupSummary *dspf_TransportGroupSummary = [[[DSPF_TransportGroupSummary alloc] init] autorelease];
        dspf_TransportGroupSummary.transportGroup = self.item;
        [self.navigationController pushViewController:dspf_TransportGroupSummary animated:YES];
    }
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )aItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex
{
    if (!self.preventScanning) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
    }
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if ([(NSString *)aItem isEqualToString:@"confirmToLoad"]) {
            [self performSelectorOnMainThread:@selector(selectDestination) withObject:nil waitUntilDone:NO];
			return;
		}
		if ([(NSString *)aItem isEqualToString:@"switchToUnLoad"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                              ControllerParameterItem : objectOrNSNull(self.item)};
                
                DSPF_Unload *dspf_Unload = [[[DSPF_Unload alloc] initWithParameters:parameters] autorelease];
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
                [viewControllers removeLastObject];
                [viewControllers addObject:dspf_Unload];
                [self.navigationController setViewControllers:viewControllers animated:YES];
            });
			return;
		}
	}
}

- (void) dspf_StatusReady:(DSPF_StatusReady *)sender didConfirmMessageTitle:(NSString *)messageTitle
                     item:(id )aItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) clickedButtonIndex
{
	if ([[sender alertView] cancelButtonIndex] != clickedButtonIndex) {
        if (aItem == StatusReadySwitchToTourLocationItem) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
			return;
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.preventScanning) {
        self.paketButton.enabled = NO;
        self.paletteButton.enabled = NO;
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
    [self setCountValues];
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
            if (demoMode || [Transport hasStagingInfo:sign forLocation:toLocation transportGroup:transportGroupId inCtx:context]){
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
        self.transportGroupSummaryButton.layer.cornerRadius = 9.0;    }
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated { 
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
	}
    self.textInputTC.text = nil; 
    [super viewWillDisappear:animated];
}


#pragma mark - Table view data source

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
        return self.customHeader;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.customHeader)
        return self.customHeader.frame.size.height;
    
    return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.transportCodesAtWork count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)aSection {
	if(aSection == 0) {
		return NSLocalizedString(@"TITLE_048", @"abzuholen:");
	}
	return nil;
}

- (NSString *)transportCode:(NSIndexPath *)indexPath {
    return [[self.transportCodesAtWork objectAtIndex:indexPath.row] valueForKey:@"code"];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_TransportCell_technopark" owner:nil options:nil] objectAtIndex:0];
        else
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        Transport *transport = self.transportCodesAtWork[indexPath.row];
        [((DSPF_TransportCell_technopark*)cell) setTransport:transport isLoad:YES];
    }
    else
    {
        cell.textLabel.text = [self transportCode:indexPath];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (Transport*) transportFromTransportCode:(NSString*) transportCode
{
    NSArray* transports = [Transport withPredicate:[NSPredicate predicateWithFormat:@"code = %@", transportCode] inCtx:ctx()];
    return transports.firstObject;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


#pragma mark - Button actions

- (IBAction)scanDown:(UIButton *)aButton {
    if (!itemIsTransportGroup && PFBrandingSupported(BrandingBiopartner, nil) && [aButton isEqual:self.paketButton]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
        for (ArchiveOrderHead *tmpOrderHead in [NSArray arrayWithArray:
                                                [ArchiveOrderHead orderHeadsWithPredicate:[NSPredicate predicateWithFormat:@"orderState = 00"]
                                                                          sortDescriptors:nil
                                                                   inCtx:ctx()]]) {
                                                    [ctx() deleteObject:tmpOrderHead];
                                                }
        [ctx() saveIfHasChanges];
        DSPF_Order *dspf_Order    = [[[DSPF_Order alloc] init] autorelease];
        dspf_Order.title          = ((Departure *)self.item).location_id.location_name;
        dspf_Order.dataTask       = @"WRKACTDTA";
        dspf_Order.runsAsTakingBack = NO;
        dspf_Order.dataHeaderInfo = [ArchiveOrderHead orderHeadWithClientData:[NSNumber numberWithInt:[[NSUserDefaults currentUserID] intValue]]
                                                                     forLocation:((Departure *)self.item).location_id
                                                       inCtx:ctx()];
        [self.navigationController pushViewController:dspf_Order animated:YES];
    } else {
        if ([[aButton.titleLabel.text uppercaseString] isEqualToString:[NSLocalizedString(@"TITLE_084", @"Paket") uppercaseString]]) {
            scanDeviceShouldReturnPalletBarcode = NO;
        }else {
            scanDeviceShouldReturnPalletBarcode = YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
    }
}

- (IBAction)scanUp:(UIButton *)aButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}

- (void)didReturnBarcode:(NSNotification *)aNotification {
    NSString *barcode = [[aNotification userInfo] valueForKey:@"barcodeData"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(processBarcode:validationEnabled:) withObject:barcode withObject:@YES];
    });
}

- (void) processBarcode:(NSString *) barcode validationEnabled:(NSNumber *) validationEnabled {
    [self processBarcode:barcode validate:[validationEnabled boolValue]];
}

- (void) processBarcode:(NSString *) barcode validate:(BOOL) validationEnabled {
    NSAssert([NSThread mainThread] == [NSThread currentThread], @"Ooops, the method should be executred in main thread!");
    if (validationEnabled) {
        if (![Transport validateTransportWithCode:barcode]) {
            [DSPF_Error messageForInvalidTransportWithBarcode:barcode];
            return;
        } else {
            NSString *boxCode = [Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]];
            if ([boxCode length] > 0 && ![Transport canPlaceTransportWithCode:barcode toTransportWithCode:boxCode]) {
                [DSPF_Error messageForInvalidTransportCode:barcode intendedToBePlacedInBoxWithCode:boxCode];
                return;
            }
        }
    }
    [NSUserDefaults setCurrentTC:barcode];
    
    NSError *error = nil;
    NSDictionary *parameters = @{ ControllerParameterItem : objectOrNSNull(self.item),
                                  ControllerParameterTourTask: objectOrNSNull(self.tourTask),
                                  ControllerTransportGroupTourStop: objectOrNSNull(self.transportGroupTourStop),
                                  ControllerTransportBoxCode : objectOrNSNull(self.transportBox.code)};
    Location *toLocation = [DSPF_Load destinationLocationForTransportBarcode:barcode userInfo:parameters error:&error];
    self.currentTCDestination = toLocation;
    if (toLocation == nil && error != nil) {
        if ([error code] == DPHErrorCodeShouldSwitchToUnload) {
            NSString *transportCode = [[error userInfo] objectForKey:NSErrorParameterTransportCode];
            [DSPF_Warning messageForSwitchingToUnloadingForTransportCode:transportCode delegate:self];
        } else if ([error code] == DPHErrorDestinationCouldNotBeInferred) {
            //FIXME: test me
            [self selectDestination];
        } else if ([error code] == DPHErrorLoadingTransportAnywayNotConfirmed) {
            NSString *transportCode = [[error userInfo] objectForKey:NSErrorParameterTransportCode];
            Location *location = [[error userInfo] objectForKey:NSErrorParameterLocation];
            NSString *messageFormat = NSLocalizedString(@"ERROR_MESSAGE_019", @"%@\n%@\n%@ %@\n\n%@\nist nicht für diese Tour !");
            if ([tourTask isEqualToString:TourTaskLoadingOnly]) {
                messageFormat = NSLocalizedString(@"ERROR_MESSAGE_018", @"%@\n%@\n%@ %@\n\n%@ ist nicht\nfür diese Lieferung !");
            }
            NSString *message = [NSString stringWithFormat:messageFormat, location.location_name, location.street, location.zip, location.city, transportCode];
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_036", @"Ziel-Adresse") messageText:message item:@"confirmToLoad" delegate:self];
        } else {
            [DSPF_Error messageFromError:error];
        }
    }
    if (toLocation != nil) {
        [self storeTransportCodeDataWithToLocation:toLocation];
    }
}

- (void)getImageForTransportCode { 
	if ([self.currentTC.text length] > 0 &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_030", @"Kamera einschalten") messageText:@"Bitte warten." delegate:self] retain];
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
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    Departure *fromDeparture = nil;
    if (itemIsTransportGroup) {
        fromDeparture = self.transportGroupTourStop;
    } else {
        fromDeparture = ((Departure *)self.item);
    }
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueItemPhoto
                                                            fromDeparture:fromDeparture toLocation:fromDeparture.location_id];
    [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
    [currentTransport setValue:[NSUserDefaults currentTC]                                                forKey:@"receipt_text"];
    [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
    [ctx() saveIfHasChanges];
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
    if (PFBrandingSupported(BrandingETA, BrandingOerlikon, nil)) {
        aTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }
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
	if (self.textInputTC.text.length > 0) {
        if (![Transport validateTextInput:self.textInputTC.text]) {
            self.textInputTC.textColor = [UIColor redColor];
            self.textInputTC.font	   = [UIFont fontWithName:@"Helvetica-Bold" size:24];
        } else {
            scanDeviceShouldReturnPalletBarcode = YES;
            if (PFBrandingSupported(BrandingUnilabs, nil)) {
                scanDeviceShouldReturnPalletBarcode = NO;
            }
            [self processBarcode:aTextField.text validate:YES];
            [self switchViews];
        }
	}
	/* Eingabe leer */
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
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
    self.transportGroupSummaryButton         = nil;
    self.paketeLabel                         = nil;
    self.rollcontainerLabel                  = nil;
    self.palettenLabel                       = nil;
    self.buttons                             = nil;
    self.paketButton                         = nil;
    self.paletteButton                       = nil;
}


- (void)dealloc {
    [paketButton                        release];
    [paletteButton                       release];
    [buttons                             release];
	[dspf_ImagePicker					 release];
	[transportCodesAtWork                release];
    [transportGroupTourStop              release];
    [item                                release];
    [palettenLabel                       release];
    [rollcontainerLabel                  release];
    [paketeLabel                         release];
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
	[currentTCDestination                release];
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
    [transportBox                        release];
    [tourTask                            release];
	[tableView                           release];
	[scanView                            release];
	[textView                            release];
    [_customHeader                        release];
    [super dealloc];
}


#pragma mark - select destination

+ (NSPredicate *)tourToLocationPredicateForTransportBarcode:(NSString *)barcode tourLocation:(Location *)tourLocation userInfo:(NSDictionary *) userInfo {
    id item = nilOrObject([userInfo objectForKey:ControllerParameterItem]);
    NSString *tourTask = nilOrObject([userInfo objectForKey:ControllerParameterTourTask]);
    BOOL itemIsTransportGroup = ([item isKindOfClass:[Transport_Group class]]);
    
    NSPredicate *tourLocationPredicate = AndPredicates([Transport_Group withLocation:tourLocation],
                                                       [Transport_Group withTourId:[[NSUserDefaults currentTourId] intValue]],
                                                       [Transport_Group withDayOfWeek:[[NSUserDefaults currentStintDayOfWeek] intValue]], nil);
    
    if (PFTourTypeSupported(@"0X0", nil)) {
        tourLocationPredicate = AndPredicates(tourLocationPredicate,
                                              [NSPredicate predicateWithFormat:@"sequence > %i", [Departure currentDepartureSequenceInCtx:ctx()]], nil);
    } else if ([tourTask isEqualToString:TourTaskLoadingOnly]) {
        if (!itemIsTransportGroup) {
            if (((Departure *)item).transport_group_id) {
                tourLocationPredicate = AndPredicates(tourLocationPredicate,
                                                      [NSPredicate predicateWithFormat:@"transport_group_id.transport_group_id = %lld",
                                                       [((Departure *)item).transport_group_id.transport_group_id longLongValue]], nil);
            }
        }
    } else if ([barcode hasAnyPrefix:@[@"V001:", @"V007:"]] && [barcode rangeOfString:@";"].location > 5) {
        NSString *locationCode = [[barcode substringFromIndex:5] substringToIndex:([barcode rangeOfString:@";"].location - 5)];
        tourLocationPredicate = AndPredicates([Transport_Group withTourId:[[NSUserDefaults currentTourId] intValue]],
                                              [Transport_Group withDayOfWeek:[[NSUserDefaults currentStintDayOfWeek] intValue]],
                                              [NSPredicate predicateWithFormat:@"location_id.code = %@", locationCode], nil);
    } else if (PFBrandingSupported(BrandingUnilabs, nil)) {
        tourLocationPredicate = tourLocationPredicate;
    } else {
        tourLocationPredicate = AndPredicates(tourLocationPredicate,
                                              [NSPredicate predicateWithFormat:@"(sequence = %i OR currentTourStatus < 50)",
                                               [[Departure lastTourDepartureInCtx:ctx()].sequence intValue]], nil);
    }
    return tourLocationPredicate;
}

+ (Location *) destinationLocationForTransportBarcode:(NSString *)transportCode userInfo:(NSDictionary *) userInfo error:(NSError **) error {
    id item = nilOrObject([userInfo objectForKey:ControllerParameterItem]);
    NSString *tourTask = nilOrObject([userInfo objectForKey:ControllerParameterTourTask]);
    Departure *transportGroupTourStop = nilOrObject([userInfo objectForKey:ControllerTransportGroupTourStop]);
    Departure *lastTourDeparture = [Departure lastTourDepartureInCtx:ctx()];
    Departure *firstTourDeparture = [Departure firstTourDepartureInCtx:ctx()];
    NSString *transportBoxCode = nilOrObject([userInfo objectForKey:ControllerTransportBoxCode]);
    BOOL itemIsTransportGroup = ([item isKindOfClass:[Transport_Group class]]);
    NSError *internalError = nil;
    NSString *transportBarcode = transportCode;
    
    [NSUserDefaults setCurrentTC:[Transport replaceAliasFromTransportCode:transportCode ctx:ctx()]];
    transportCode = [NSUserDefaults currentTC];
    
    NSError *showDestinationChooserError = [NSError errorWithDomain:DPHLoadDomain code:DPHErrorDestinationCouldNotBeInferred userInfo:nil];
    NSError *switchToUnloadError = [NSError errorWithDomain:DPHLoadDomain code:DPHErrorCodeShouldSwitchToUnload
                                                 userInfo:@{ NSErrorParameterTransportCode : transportCode }];
    
    Location *tourLocation = [Transport destinationFromBarcode:transportCode inCtx:ctx()];
    
    if (!tourLocation) {
         NSPredicate *transportPredicate = AndPredicates([Transport withCode:transportCode],[Transport withTransportGroupId:((Departure*)item).transport_group_id.transport_group_id], nil);
        tourLocation = [[[Transport withPredicate:transportPredicate inCtx:ctx()] firstObject] to_location_id];
        if (PFBrandingSupported(BrandingUnilabs, nil)) {
            Transport *containersTransport = nil;
            if (transportBoxCode) {
                containersTransport = [[Transport withPredicate:[Transport withCodes:@[transportBoxCode]] inCtx:ctx()] lastObject];
            }
            Location *tourEndPoint =  containersTransport.to_location_id;
            if (tourEndPoint == nil) {
                tourEndPoint = lastTourDeparture.location_id;
            }
            if (tourEndPoint) {
                tourLocation = tourEndPoint;
            } else {
                SetError(error, showDestinationChooserError);
                return nil;
            }
        }
        if (!tourLocation) {
            if ([DSPF_Load shouldSwitchToUnloadWithItem:item transportGroupTourStop:transportGroupTourStop task:tourTask error:&internalError]){
                SetError(error, switchToUnloadError);
                return nil;
            } else if (internalError != nil) {
                SetError(error, internalError);
                return nil;
            } else {
                if (itemIsTransportGroup) {
                    tourLocation = lastTourDeparture.location_id;
                } else if (PFTourTypeSupported(@"1X1", nil)) {
                    if ([tourTask isEqualToString:TourTaskLoadingOnly]) {
                        Location *tourEndPoint = ((Departure *)item).location_id;
                        if (![((Departure *)item).departure_id isEqualToNumber:firstTourDeparture.departure_id] &&
                            ![((Departure *)item).departure_id isEqualToNumber:lastTourDeparture.departure_id]  && tourEndPoint)
                        {
                            tourLocation = tourEndPoint;
                        } else {
                            SetError(error, [NSError errorForNotOnTheTourTransportCode:transportCode domain:DPHLoadDomain]);
                            if (PFBrandingSupported(BrandingOerlikon, nil)) {
                                SetError(error, showDestinationChooserError);
                            }
                            return nil;
                        }
                    } else {
                        Location *tourEndPoint = lastTourDeparture.location_id;
                        if (tourEndPoint && PFBrandingSupported(BrandingOerlikon, nil)) {
                            tourLocation = tourEndPoint;
                        } else {
                            SetError(error, [NSError errorForNotOnTheTourTransportCode:transportCode domain:DPHLoadDomain]);
                            return nil;
                        }
                    }
                } else if ((PFTourTypeSupported(@"1XX", @"0X1", nil) && !PFBrandingSupported(BrandingViollier, BrandingUnilabs, nil))){
                    Location *tourEndPoint = lastTourDeparture.location_id;
                    if (tourEndPoint) {
                        tourLocation = tourEndPoint;
                    } else {
                        SetError(error, showDestinationChooserError);
                        return nil;
                    }
                } else if (PFTourTypeSupported(@"0X1", nil) && PFBrandingSupported(BrandingViollier, nil)) {
                    Location *tourEndPoint = nil;
                    if ([transportCode rangeOfString:@"V005:"].location == 0) {
                        SetError(error, [NSError errorForEnteringUnexpectedTransportBoxCode:transportCode domain:DPHLoadDomain]);
                        return nil;
                    }
                    if ([transportCode hasAnyPrefix:@[@"V001:", @"V007:"]] && [transportCode rangeOfString:@";"].location > 5) {
                        tourEndPoint = ((Departure *)[[Departure withPredicate:
                                                       [NSPredicate predicateWithFormat:@"tour_id.tour_id = %i && dayOfWeek = %i && location_id.code = %@",
                                                        [[NSUserDefaults currentTourId] intValue],
                                                        [[NSUserDefaults currentStintDayOfWeek] intValue],
                                                        [[transportCode substringFromIndex:5]
                                                         substringToIndex:([transportCode rangeOfString:@";"].location - 5)]]
                                                               sortDescriptors:
                                                       @[[NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES]]
                                                                         inCtx:ctx()] lastObject]).location_id;
                    } else if ([transportCode hasPrefix:@"V00"]) {
                        tourEndPoint = lastTourDeparture.location_id;
                    }
                    if (tourEndPoint) {
                        tourLocation = tourEndPoint;
                    } else {
                        SetError(error, [NSError errorForNotOnTheTourTransportCode:transportCode domain:DPHLoadDomain]);
                        return nil;
                    }
                } else {
                    SetError(error, showDestinationChooserError);
                    return nil;
                }
            }
        }
    }
    
    
    transportCode = [Transport transportCodeFromBarcode:transportCode];
    [NSUserDefaults setCurrentTC:transportCode];

    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"location_id" ascending:NO]];  /* tourLocationCoordinate is not always unique */
    NSPredicate *tourLocationPredicate = [DSPF_Load tourToLocationPredicateForTransportBarcode:transportBarcode
                                                                               tourLocation:tourLocation userInfo:userInfo];
    
    
    NSArray *tourLocations = nil;
    if (itemIsTransportGroup) {
        tourLocations = [[[[((Transport_Group *)item).addressee_id.departure_id filteredSetUsingPredicate:tourLocationPredicate] allObjects]
                            valueForKeyPath:@"location_id"] sortedArrayUsingDescriptors:sortDescriptors];
    } else if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        tourLocations = @[tourLocation];
    }
    else {
        tourLocations = [Departure distinctLocationsFromDeparturesWithPredicate:tourLocationPredicate sortDescriptors:sortDescriptors inCtx:ctx()];
    }
    if ([tourLocations count] == 0) {
        if ([DSPF_Load shouldSwitchToUnloadWithItem:item transportGroupTourStop:transportGroupTourStop task:tourTask error:&internalError]) {
            SetError(error, switchToUnloadError);
            return nil;
        } else if (internalError != nil) {
            SetError(error, internalError);
            return nil;
        } else {
            if (tourLocation == nil) {
                if ([tourTask isEqualToString:TourTaskLoadingOnly] ||
                    ([transportCode hasAnyPrefix:@[@"V001:", @"V007:"]] && [transportCode rangeOfString:@";"].location > 5))
                {
                    SetError(error, [NSError errorForNotOnTheTourTransportCode:transportCode domain:DPHLoadDomain]);
                    return nil;
                } else {
                    SetError(error, showDestinationChooserError);
                    return nil;
                }
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
                
                SetError(error, [NSError errorWithDomain:DPHLoadDomain code:DPHErrorLoadingTransportAnywayNotConfirmed
                                         userInfo:@{ NSErrorParameterTransportCode : transportCode,
                                                     NSErrorParameterLocation : objectOrNSNull(tourLocation) }]);
                return nil;
            }
        }
    }
    if ([DSPF_Load shouldSwitchToUnloadWithItem:item transportGroupTourStop:transportGroupTourStop task:tourTask error:&internalError]) {
        SetError(error, switchToUnloadError);
        return nil;
    } else if (internalError != nil) {
        SetError(error, internalError);
        return nil;
    } else {
        return [tourLocations objectAtIndex:0];
    }
}

- (void) selectDestination {
    // disable scanning during the destination selection
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    DSPF_Destination *dspf_Destination = [[DSPF_Destination alloc] initWithNibName:@"DSPF_Destination" bundle:nil];
    [dspf_Destination setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dspf_Destination];
    navigationController.navigationBar.barStyle  = self.navigationController.navigationBar.barStyle;
    navigationController.toolbar.tintColor       = self.navigationController.toolbar.tintColor;
    navigationController.toolbar.alpha           = self.navigationController.toolbar.alpha;
    [dspf_Destination release];
    [self.navigationController presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (void) dspf_Destination:(DSPF_Destination *)sender didSelectLocation:(Location *)location userInfo:(NSDictionary *)userInfo {
    [self.navigationController dismissModalViewControllerAnimated:YES];
    if (location != nil) {
        self.currentTCDestination = location;
        [self storeTransportCodeDataWithToLocation:location];
    }
}

@end

