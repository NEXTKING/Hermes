//
//  DSPF_TransportUnit.m
//  Hermes
//
//  Created by Lutz  Thalmann on 15.02.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_TransportUnit.h"
#import "DSPF_Suspend.h"
#import "DSPF_Error.h"
#import "Location_Alias.h"
#import "Transport.h"

#import "DSPF_Synchronisation.h"

// request parameters
static NSString * const TransportUnitCreationAllowLocationMismatch = @"allow_location_mismatch";

// server responses
static NSString * const TransportUnitCreationResponseDestinationNotMatching = @"DESTINATIONS_NOT_MATCHING";

// alert
static NSString * const TransportUnitAlert = @"TUA";

@interface DSPF_TransportUnit()
@property (nonatomic, retain) Location					*currentTCDestination;
@end


@implementation DSPF_TransportUnit

@synthesize scanView;
@synthesize textView;
@synthesize textInputTC;
@synthesize currentTC_F;
@synthesize textLabelTC_F;
@synthesize currentTC_B;
@synthesize textLabelTC_B;
@synthesize transportUnitButton;
@synthesize currentTCDestination;
@synthesize scanInputTC;
@synthesize ctx;
@synthesize delegate;

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

#define TEXT_BUTTON_TITLE  NSLocalizedString(@"TITLE_052", @"Erfassen")
#define SCAN_BUTTON_TITLE  NSLocalizedString(@"TITLE_053", @"Scannen")

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBarcode:) name:@"barcodeData" object:nil];
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
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:TEXT_BUTTON_TITLE 
																			   style:UIBarButtonItemStyleBordered
                                                                              target:self
																			  action:@selector(switchViews)] autorelease];
	self.currentTC_F.text = [NSUserDefaults currentTC];
	self.currentTC_B.text = [NSUserDefaults currentTC];
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        self.textLabelTC_F.text = @"Frachtstück";
        self.textLabelTC_B.text = @"Frachtstück";
        self.textInputTC.placeholder = NSLocalizedString(@"Bahnwagen", @"Bahnwagen");
        [self.transportUnitButton setTitle:NSLocalizedString(@"Bahnwagen", @"Bahnwagen") forState:UIControlStateNormal];
    }
}

- (void)switchViews {
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.618];
    if (self.scanView.window) {
		[self.scanView  removeFromSuperview];
		[self.textInputTC becomeFirstResponder];
        self.navigationItem.rightBarButtonItem.title = SCAN_BUTTON_TITLE;
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[self view] cache:NO];
    }else{
		self.textInputTC.text	   = nil;
		self.textInputTC.textColor = [UIColor blackColor];
		self.textInputTC.font	   = [UIFont fontWithName:@"Helvetica" size:18];
		[self.textInputTC resignFirstResponder];
		[self.view addSubview:self.scanView];
        self.navigationItem.rightBarButtonItem.title = TEXT_BUTTON_TITLE;
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[self view] cache:NO];
    }
	[UIView commitAnimations];	
}

- (NSDictionary *) transportUnitToSynchronize {
    //@"http://zhsrv-dev64.zh.dph.local:100/evoweb/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    //@"https://zhsrv-dev64.zh.dph.local/eta/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    
    NSString *longitude = [NSString stringWithFormat:@"%f", [self.currentTCDestination.longitude doubleValue]];
    NSString *latitude = [NSString stringWithFormat:@"%f", [self.currentTCDestination.latitude doubleValue]];
    
    NSMutableDictionary *syncToServer = [NSMutableDictionary dictionaryWithCapacity:7];
    [syncToServer setValue:[NSUserDefaults currentUserID]                                       forKey:@"user_id"];
    [syncToServer setValue:self.currentTC_F.text			                                    forKey:@"transport_code"];
    [syncToServer setValue:[NSUserDefaults currentTC]                                           forKey:@"transport_unit"];
    [syncToServer setValue:self.currentTCDestination.location_id								forKey:@"destination_location_id"];
    [syncToServer setValue:latitude                                                             forKey:@"destination_location_latitude"];
    [syncToServer setValue:longitude                                                            forKey:@"destination_location_longitude"];
    // "https://zhsrv-dev64.zh.dph.local/eta/webmethod/upload/shipping_unit?sn=%@",
    // "http://zhsrv-dev64.zh.dph.local:100/evoweb/webmethod/upload/shipping_unit?sn=%@",
    return syncToServer;
}

- (void)storeTransportCodeData:(NSDictionary *)additionalParameters {
    NSString *serverURL  = [DSPF_Synchronisation hermesServerURL];
    NSDictionary *syncToServer = [[self transportUnitToSynchronize] dictionaryByAddingEntriesFromDictionary:additionalParameters];

	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload/shipping_unit?sn=%@", serverURL, PFDeviceId()]];
    NSMutableURLRequest *request = [SVR_SyncDataManager requestFromDictionary:syncToServer url:url];
    [request setTimeoutInterval:240];
    NSHTTPURLResponse *response = nil;
	NSData   *returnData   = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
	NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
	if ([returnString isEqualToString:@"OK"] || [response statusCode] == 200) {
		[self.navigationController popViewControllerAnimated:YES];
		[self.delegate dspf_TransportUnit:self didReturnTransportUnit:[NSUserDefaults currentTC] 
							 withLocation:self.currentTCDestination
						 forTransportCode:self.currentTC_F.text];
    } else {
        NSString *errorString = [response.allHeaderFields objectForKey:@"X-Hermes-ServiceError"];
        if ([errorString isEqualToString:TransportUnitCreationResponseDestinationNotMatching]) {
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_054", @"Versandeinheit speichern")
                           messageText:NSLocalizedString(@"MESSAGE__100", @"Zielort nicht korrekt. Zuteilen das Paket trotzdem?")
                                  item:TransportUnitAlert delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", "NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
        } else {
            [DSPF_Error messageForUploadFailureWithTitle:NSLocalizedString(@"TITLE_054", @"Versandeinheit speichern") errorString:errorString];
        }
    }
}

- (void)checkForDestinationData {
    [NSUserDefaults setCurrentTC:[Transport replaceAliasFromTransportCode:[NSUserDefaults currentTC] ctx:self.ctx]];
    
    Location *tourLocation = [Transport destinationFromBarcode:[NSUserDefaults currentTC] inCtx:self.ctx];
    
    [NSUserDefaults setCurrentTC:[Transport transportCodeFromBarcode:[NSUserDefaults currentTC]]];
    if (tourLocation == nil) {
        [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_055", @"Versand Ziel")
                     messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_022", @"ACHTUNG:\nFür %@ wurde kein Ort gefunden!\nDie Eingabe wird ignoriert."), [NSUserDefaults currentTC]]
                        delegate:nil];
        return;
    }
	self.currentTCDestination = tourLocation;
    [self storeTransportCodeData:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
	}
    [super viewWillDisappear:animated];
}

#pragma mark - Button actions

- (IBAction)scanDown:(UIButton *)aButton {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
	scanDeviceShouldReturnPalletBarcode = YES;	
}


- (IBAction)scanUp:(UIButton *)aButton {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}


- (void)didReturnBarcode:(NSNotification *)aNotification {
    [NSUserDefaults setCurrentTC:[[aNotification userInfo] valueForKey:@"barcodeData"]];
	[self checkForDestinationData];
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
        [NSUserDefaults setCurrentTC:aTextField.text];
		[self checkForDestinationData];
		[self switchViews];
	}
	/* Eingabe leer */
}

#pragma mark - AlertView delegate

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
    if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_065", @"JA")]) {
        [self storeTransportCodeData:[NSDictionary dictionaryWithObject:@"TRUE" forKey:TransportUnitCreationAllowLocationMismatch]];
    }
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSUserDefaults standardUserDefaults] synchronize];
	self.scanView						= nil;
	self.textView						= nil;
	self.textInputTC					= nil;
    self.transportUnitButton            = nil;
	self.currentTC_F					= nil;
    self.textLabelTC_F					= nil;
	self.currentTC_B					= nil;
    self.textLabelTC_B					= nil;
}


- (void)dealloc {
	[ctx			release];
	[textInputTC					release];
    [transportUnitButton            release];
    [textLabelTC_F                  release];
	[currentTC_F					release];
    [textLabelTC_B                  release];
	[currentTC_B					release];
	[currentTCDestination			release];
	[scanInputTC					release];
	[scanView						release];
	[textView						release];
    [super dealloc];
}


@end

