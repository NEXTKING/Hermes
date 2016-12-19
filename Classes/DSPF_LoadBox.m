//
//  DSPF_LoadBox.m
//  Hermes
//
//  Created by Lutz  Thalmann on 17.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_LoadBox.h"
#import "DSPF_Unload.h"
#import "DSPF_Suspend.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"
#import "DSPF_Load.h"
#import "DPHButtonsView.h"

#import "Location_Alias.h"
#import "Transport_Group.h"
#import "Transport.h"
#import "Transport_Box.h"

NSString const * LoadBoxParameterShowingLoadingForbidden = @"LoadBoxParameterShowingLoadingForbidden";
NSString const * LoadBoxParameterConfirmingNewBoxesForbidden = @"LoadBoxParameterConfirmingNewBoxesForbidden";

@interface DSPF_LoadBox()
@property (nonatomic, retain) DPHButtonsView *buttons;
@end

@implementation DSPF_LoadBox {
    BOOL showingLoadingForbiddden;
    BOOL confirmingNewBoxesForbidden;
    BOOL shouldTriggerSyncOnExit;
}
@synthesize buttons;
@synthesize scanView;
@synthesize textView;
@synthesize palettenLabel;
@synthesize paketeLabel;
@synthesize boxLabel;
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
@synthesize currentTCDestination;
@synthesize scanInputTC;
@synthesize preventScanning;
@synthesize currentTCbar;
@synthesize currentTCbarTitle;
@synthesize currentTCbarSpace01;
@synthesize currentTCbarCamera;
@synthesize item;
@synthesize tourTask;
@synthesize ctx;
@synthesize dspf_ImagePicker;
@synthesize wasSkippedOnce;
@synthesize previousBoxCode;
@synthesize currentBag;
@synthesize currentPackage;

- (instancetype)init {
    return [self initWithParameters:nil];
}

- (instancetype)initWithParameters:(NSDictionary *) parameters {
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil]) {
        self.item = nilOrObject([parameters objectForKey:ControllerParameterItem]);
        self.tourTask = nilOrObject([parameters objectForKey:ControllerParameterTourTask]);
        self.preventScanning = [nilOrObject([parameters objectForKey:ControllerParameterPreventScanning]) boolValue];
        showingLoadingForbiddden = [[parameters objectForKey:LoadBoxParameterShowingLoadingForbidden] boolValue];
        confirmingNewBoxesForbidden = [[parameters objectForKey:LoadBoxParameterConfirmingNewBoxesForbidden] boolValue];
        shouldTriggerSyncOnExit = [[parameters objectForKey:ControllerTriggerSynchronisationOnExit] boolValue];
        
        self.title = NSLocalizedString(@"TITLE_108", @"Box wählen");
        if (PFBrandingSupported(BrandingUnilabs, nil)) {
            self.title = NSLocalizedString(@"TITLE_129", @"Select transport bag");
        }
    }
    return self;
}

#pragma mark - buttons

- (UIButton *) looseButton {
    return [self.buttons buttonWithTitle:[[self leftButtonLabel] uppercaseString]];
}

- (UIButton *) boxButton {
    return [self.buttons buttonWithTitle:[[self rightButtonLabel] uppercaseString]];
}

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (Location *)currentTCDestination {
	if (!currentTCDestination) {
		currentTCDestination = [[Location alloc] init];
	}
	return currentTCDestination;
}

#pragma mark - View lifecycle

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)setTCbar { 
    NSMutableArray *tmpTCbar = [NSMutableArray arrayWithArray:self.currentTCbar.items];
    [tmpTCbar removeAllObjects]; 
    if ([self.boxLabel.text length] > 0) { 
        if ([[NSUserDefaults standardUserDefaults] boolForKey: @"HermesApp_SYSVAL_RUN_withImageForTransPortCodes"]) { 
            [self.currentTCbarCamera setAction:@selector(getImageForTransportCode)]; 
            [tmpTCbar insertObject:self.currentTCbarCamera  atIndex:0];
        } 
    } 
    [tmpTCbar insertObject:self.currentTCbarSpace01 atIndex:0];
    [tmpTCbar insertObject:self.currentTCbarTitle   atIndex:0];
    [self.currentTCbar setItems:tmpTCbar animated:NO]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentLocationDepartureExtension_F.text = @"🕙";
    self.currentLocationDepartureExtension_B.text = @"🕙";
    if (PFBrandingSupported(BrandingViollier, nil)) {
        NSMutableDictionary *barButtonAttributes = [NSMutableDictionary dictionaryWithDictionary: [self.currentTCbarTitle titleTextAttributesForState:UIControlStateNormal]];
        [barButtonAttributes setValue:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17] forKey:UITextAttributeFont];
        [self.currentTCbarTitle setTitleTextAttributes:barButtonAttributes forState:UIControlStateNormal];
    }
    self.palettenLabel.text             = NSLocalizedString(@"TITLE_109", @"Labor");
	self.paketeLabel.text               = NSLocalizedString(@"MESSAGE_027", @"Pakete");
    self.currentBag.text                = NSLocalizedString(@"TITLE_109", @"Labor");
    self.currentTCbarTitle.title        = NSLocalizedString(@"TITLE_037", @"geladen:"); 
    self.textInputTC.placeholder        = NSLocalizedString(@"PLACEHOLDER_003", @"transportcode");
	
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        self.palettenLabel.text = NSLocalizedString(@"TITLE_127", @"Transport bag");
        self.paketeLabel.text = NSLocalizedString(@"TITLE_128", @"Specimen bag");
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
    [self setupButtons];
}

- (void)setupButtons {
    UIButton *looseButton = [DPHButtonsView grayButtonWithTitle:[[self leftButtonLabel] uppercaseString]];
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        looseButton.hidden = YES;
    }
    UIButton *boxButton = [DPHButtonsView grayButtonWithTitle:[[self rightButtonLabel] uppercaseString]];
    
    [looseButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpInside];
    [looseButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpOutside];
    [looseButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchCancel];
    [looseButton addTarget:self action:@selector(looseButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    [boxButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpInside];
    [boxButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchUpOutside];
    [boxButton addTarget:self action:@selector(scanUp:) forControlEvents:UIControlEventTouchCancel];
    [boxButton addTarget:self action:@selector(boxButtonClicked:) forControlEvents:UIControlEventTouchDown];
    
    self.buttons.verticalArrangement = NO;
    self.buttons.buttonsHeight = 96.0f;
    self.buttons.buttons = @[looseButton, boxButton];
}

- (void)switchViews {
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.618];
    if (self.scanView.window) { 
		[self.scanView  removeFromSuperview];
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
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBoxBarcode:)
                                                         name:@"barcodeData" object:nil];
        }
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard.png"]
                                          style:UIBarButtonItemStyleBordered target:self action:@selector(switchViews)] autorelease];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
        self.navigationItem.rightBarButtonItem =  [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barcode_white.png"]
                                          style:UIBarButtonItemStyleBordered target:self action:@selector(switchViews)] autorelease];
    }
}

- (void) item:(NSString *) option hasBeenConfirmed:(BOOL)confirmed {
    Transport_Box *transportBox = nil;
    if (!confirmed) {
        //FIXME: handle it differently - don't use previousBoxCode
        if ([option isEqualToString:@"confirmNewBox"] && self.previousBoxCode && self.previousBoxCode.length > 0) {
            [NSUserDefaults setBoxBarcode:self.previousBoxCode];
        }
    } else {
        if ([option isEqualToString:@"confirmNewBox"]) {
            self.wasSkippedOnce = YES; // perform as this box is already in use
            [self storeTransportCodeDataWithToLocation:nil];
        } else if ([option isEqualToString:@"confirmCargoWithoutBox"]) {
            transportBox = nil;
            self.wasSkippedOnce = NO;  // force loading the recommended box after loading this transport code
            [self showLoadingControllerWithTransportBox:transportBox];
        }
    }
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )aItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
    BOOL userConfirmed = [[sender alertView] cancelButtonIndex] != buttonIndex;
	if (userConfirmed) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
	} else {
        if (!self.preventScanning) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
        }
    }
    [self item:aItem hasBeenConfirmed:userConfirmed];
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    
    if (self.preventScanning) {
        self.looseButton.enabled = NO;
        self.boxButton.enabled = NO;
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self   name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBoxBarcode:) name:@"barcodeData" object:nil];
    }
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.currentLocationStreetAddress_F.text = ((Departure *)self.item).location_id.location_name;
        self.currentLocationStreetAddress_B.text = ((Departure *)self.item).location_id.location_name;
    } else {
        self.currentLocationCity_F.text          = ((Departure *)self.item).location_id.city;
        self.currentLocationZipCode_F.text       = ((Departure *)self.item).location_id.zip;
        self.currentLocationStreetAddress_F.text = ((Departure *)self.item).location_id.street;
        self.currentLocationCity_B.text          = ((Departure *)self.item).location_id.city;
        self.currentLocationZipCode_B.text       = ((Departure *)self.item).location_id.zip;
        self.currentLocationStreetAddress_B.text = ((Departure *)self.item).location_id.street;
    }
    if (PFTourTypeSupported(@"1X1", nil) && PFBrandingSupported(BrandingOerlikon, nil) &&
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
    } else if (((Departure *)self.item).departure) {
        self.currentLocationDepartureLabel_F.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_F.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).departure dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        self.currentLocationDepartureLabel_B.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_B.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).departure dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (((Departure *)self.item).arrival) {
        self.currentLocationDepartureLabel_F.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_F.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).arrival dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        self.currentLocationDepartureLabel_B.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
        self.currentLocationDepartureTime_B.text  = [NSDateFormatter localizedStringFromDate:
                                                     ((Departure *)self.item).arrival dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    } else if (((Departure *)self.item).location_id.location_code)  { 
        self.currentLocationDepartureLabel_F.text        = ((Departure *)self.item).location_id.location_code;
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = ((Departure *)self.item).location_id.location_code;
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (((Departure *)self.item).transport_group_id.task)  { 
        self.currentLocationDepartureLabel_F.text        = ((Departure *)self.item).transport_group_id.task;
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = ((Departure *)self.item).transport_group_id.task;
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    } else if (PFTourTypeSupported(@"1X1", nil) &&
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
        self.currentLocationDepartureLabel_F.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).departure_id];
        self.currentLocationDepartureTime_F.hidden       = YES;
        self.currentLocationDepartureExtension_F.hidden  = YES;
        self.currentLocationDepartureLabel_B.text        = [NSString stringWithFormat:@"%@", ((Departure *)self.item).departure_id];
        self.currentLocationDepartureTime_B.hidden       = YES;
        self.currentLocationDepartureExtension_B.hidden  = YES;
    }
    NSNumber *locationId = ((Departure *)self.item).location_id.location_id;
    NSNumber *transportGroupId = ((Departure *)self.item).transport_group_id.transport_group_id;
    if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
        self.currentBag.text = FmtStr(@"%i", [Transport countOf:Pallet fromTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
        self.currentPackage.text = FmtStr(@"%i", [Transport countOf:Unit fromTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
    } else {
        self.currentBag.text = FmtStr(@"%i", [Transport countOf:OpenPallet forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
        self.currentPackage.text = FmtStr(@"%i", [Transport countOf:OpenUnit forTourLocation:locationId transportGroup:transportGroupId ctx:self.ctx]);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.wasSkippedOnce && !showingLoadingForbiddden) {
        Transport_Box *recommendedBox = [Transport_Box recommendedBoxInCtx:self.ctx];
        if (recommendedBox) {
            [self processBarcode:recommendedBox.code validate:YES];
            self.wasSkippedOnce = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated { 
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
	}
    if (shouldTriggerSyncOnExit) {
        [SVR_SyncDataManager triggerSendingTraceLogDataWithUserInfo:nil];
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Button actions

- (void) boxButtonClicked:(id) sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
}

- (void) looseButtonClicked:(id) sender {
    self.boxLabel.text = [[self leftButtonLabel] uppercaseString];
    [DSPF_Warning messageTitle:[[self leftButtonLabel] uppercaseString]
                   messageText:NSLocalizedString(@"MESSAGE_041", @"Wollen Sie wirklich Ware zum Ausliefern laden?")
                          item:@"confirmCargoWithoutBox"
                      delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
}

- (IBAction)scanUp:(UIButton *)aButton {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}

// Method for saving the box barcode

- (void)didReturnBoxBarcode:(NSNotification *)aNotification {
    NSString *scannedBarcode = [[aNotification userInfo] valueForKey:@"barcodeData"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(processBarcode:validationEnabled:) withObject:scannedBarcode withObject:@YES];
    });
}

- (void) processBarcode:(NSString *) barcode validationEnabled:(NSNumber *) validationEnabled {
    [self processBarcode:barcode validate:[validationEnabled boolValue]];
}

- (void) processBarcode:(NSString *) barcode validate:(BOOL) validationEnabled {
    if (validationEnabled) {
        if (![Transport_Box validateTransportBoxBarcode:barcode]) {
            [DSPF_Error messageForInvalidTransportBoxWithBarcode:barcode];
            return;
        }
    }
    self.previousBoxCode = [NSUserDefaults boxBarcode];
    [NSUserDefaults setBoxBarcode:barcode];
    NSString *boxCode  = [Transport transportCodeFromBarcode:barcode];
    
    if ([Transport_Box hasBoxWithCode:boxCode inCtx:self.ctx]) {
        self.boxLabel.text = boxCode;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
        Transport_Box *transportBox = [Transport_Box transport_boxWithBarCode:boxCode inCtx:self.ctx];
        [self showLoadingControllerWithTransportBox:transportBox];
    } else {
        if (!confirmingNewBoxesForbidden) {
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_107", @"Neue Box")
                           messageText:[NSString stringWithFormat:NSLocalizedString(@"MESSAGE_040", @"%@\nals neue Box verwenden?"),
                                        [Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]]]
                                  item:@"confirmNewBox"
                              delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
            return;
        }
        [self storeTransportCodeDataWithToLocation:nil];
    }
}

- (void)storeTransportCodeDataWithToLocation:(nullable Location *)chosenLocation {
    NSString *boxBarcode = [NSUserDefaults boxBarcode];
    NSString *boxCode  = [Transport transportCodeFromBarcode:boxBarcode];
    if (![Transport_Box hasBoxWithCode:boxCode inCtx:self.ctx]) {
        Location *toLocation = chosenLocation;
        if (toLocation == nil) {
            NSError *error = nil;
            NSDictionary *parameters = @{ ControllerParameterItem : objectOrNSNull(self.item),
                                          ControllerParameterTourTask: objectOrNSNull(self.tourTask)};
            toLocation = [DSPF_Load destinationLocationForTransportBarcode:boxBarcode userInfo:parameters error:&error];
            if (toLocation == nil && error != nil) {
                [self selectDestination];
                return;
            }
        }
        if (toLocation != nil) {
            self.boxLabel.text = boxCode;
            Transport_Box *tmpTransport_Box = [Transport_Box transport_boxWithBarCode:boxCode inCtx:self.ctx];
            if (PFBrandingSupported(BrandingUnilabs, nil)) {
                Departure *departure = (Departure *) self.item;
                Location *finalDestination = [Transport destinationFromBarcode:[NSUserDefaults boxBarcode] inCtx:self.ctx];
                NSMutableDictionary *dict = [Transport dictionaryWithCode:boxCode traceType:TraceTypeValueLoad fromDeparture:departure
                                                               toLocation:toLocation finalDestination:finalDestination isPallet:@YES];
                [Transport addLocation:[[AppDelegate() locationManager] rcvLocation] toTraceLogDict:dict];
                [Transport transportWithDictionaryData:dict inCtx:self.ctx];
            }
            [self.ctx saveIfHasChanges];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
            [self showLoadingControllerWithTransportBox:tmpTransport_Box];
        }
    }
}

- (void)getImageForTransportCode {
	if ([self.boxLabel.text length] > 0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_030", @"Kamera einschalten") messageText:@"Bitte warten." delegate:self] retain];
        [DPHUtilities waitForAlertToShow:0.236f];
		self.dspf_ImagePicker = [[[DSPF_ImagePicker alloc] initWithParameters:nil] autorelease];
        self.dspf_ImagePicker.pickerDelegate = self;
		[self presentModalViewController:self.dspf_ImagePicker animated:YES];
        [showActivity closeActivityInfo];
		[showActivity release];
	}
}

- (void) showLoadingControllerWithTransportBox:(Transport_Box *) transportBox {
    if (!showingLoadingForbiddden) {
        NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                      ControllerParameterItem : objectOrNSNull(self.item),
                                      LoadParameterTransportBox : objectOrNSNull(transportBox)};
        
        DSPF_Load *dspf_Load = [[[DSPF_Load alloc] initWithParameters:parameters] autorelease];
        [self.navigationController pushViewController:dspf_Load animated:YES];
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
    Departure *fromDeparture = ((Departure *)self.item);
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueItemPhoto
                                                            fromDeparture:fromDeparture toLocation:fromDeparture.location_id];
    [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
    [currentTransport setValue:[Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]]          forKey:@"receipt_text"];
    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
    [self.ctx saveIfHasChanges];
    self.boxLabel.text = [Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]];
    [showActivity closeActivityInfo];
    [showActivity release]; 
}

- (void)didFinishWithoutPhoto {
    [self dismissModalViewControllerAnimated:YES]; 
    self.boxLabel.text = [Transport transportCodeFromBarcode:[NSUserDefaults boxBarcode]]; 
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
    if ([Transport_Box validateTextInput:aTextField.text]) {
        /* Eingabe o.k. */
        [self processBarcode:aTextField.text validate:YES];
        [self switchViews];
    } else {
        self.textInputTC.textColor = [UIColor redColor];
        self.textInputTC.font	   = [UIFont fontWithName:@"Helvetica-Bold" size:24];
    }
}

- (NSString *) leftButtonLabel {
    NSString *result = NSLocalizedString(@"TITLE_105", @"LIEFERN");
    return result;
}

- (NSString *) rightButtonLabel {
    NSString *result = NSLocalizedString(@"TITLE_106", @"AUTO");
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        result = NSLocalizedString(@"TITLE_130", @"Transport-Sack/Box scannen");
    }
    return result;
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSUserDefaults standardUserDefaults] synchronize];
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
    self.currentTCbar                        = nil;
    self.currentTCbarTitle                   = nil;
    self.currentTCbarSpace01                 = nil;
    self.currentTCbarCamera                  = nil;
    self.boxLabel                            = nil;
    self.currentPackage                      = nil;
    self.currentBag                          = nil;
    self.paketeLabel                         = nil;
    self.palettenLabel                       = nil;
    self.buttons                             = nil;
    
}

- (void)dealloc {
    [buttons                             release];
    [previousBoxCode                     release];
	[dspf_ImagePicker					 release];
	[ctx                release];
    [currentBag                          release];
    [currentPackage                      release]; 
    [item                                release];
    [palettenLabel                       release];
    [paketeLabel                         release];
    [boxLabel                            release];
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
	[currentTCDestination                release];
	[scanInputTC                         release];
    [currentTCbar                        release];
    [currentTCbarTitle                   release];
    [currentTCbarSpace01                 release];
    [currentTCbarCamera                  release];
    [tourTask                            release];
	[scanView                            release];
	[textView                            release];
    [super dealloc];
}

#pragma mark -

- (void) selectDestination {
    // disable scanning during the destination selection
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
    DSPF_Destination *dspf_Destination = [[DSPF_Destination alloc] initWithNibName:NSStringFromClass([DSPF_Destination class]) bundle:nil];
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
        //FIXME: react
        [self storeTransportCodeDataWithToLocation:location];
    }
}

@end

