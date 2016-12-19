//
//  DSPF_TransportUnitItem.m
//  Hermes
//
//  Created by Lutz  Thalmann on 15.02.11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_TransportUnitItem.h"
#import "DSPF_TransportUnit.h"
#import "DSPF_Suspend.h"
#import "DSPF_Error.h"
#import "Location.h"
#import "Transport.h"

@implementation DSPF_TransportUnitItem

@synthesize scanView;
@synthesize textView;
@synthesize geladenLabel;
@synthesize geladenLabel2;
@synthesize transportCodeButton;
@synthesize currentLocationStreetAddress_F;
@synthesize currentLocationZipCode_F;
@synthesize currentLocationCity_F;
@synthesize textInputTC;
@synthesize currentTC_F;
@synthesize currentTU_F;
@synthesize currentTC_B;
@synthesize currentTU_B;
@synthesize scanInputTC;


#pragma mark - View lifecycle

#define TEXT_BUTTON_TITLE  NSLocalizedString(@"TITLE_052", @"Erfassen")
#define SCAN_BUTTON_TITLE  NSLocalizedString(@"TITLE_053", @"Scannen")

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"connectScanDevice" object:self userInfo:nil];
	self.view = self.textView;
	self.textInputTC.delegate = self;
    self.geladenLabel.text      = NSLocalizedString(@"MESSAGE_031", @"geladen");
    self.geladenLabel2.text      = NSLocalizedString(@"MESSAGE_031", @"geladen");
    [self.transportCodeButton setTitle:NSLocalizedString(@"MESSAGE_032", @"Transportcode") forState:UIControlStateNormal];
    self.textInputTC.placeholder = NSLocalizedString(@"PLACEHOLDER_003", @"Transportcode");
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

- (void)checkForTransportUnit {
    NSRange  barCodeTrailerRange = [Transport rangeOfTrailerFromBarcode:[NSUserDefaults currentTC]];
	if (barCodeTrailerRange.location != NSNotFound) {
        [NSUserDefaults setCurrentTC:[[NSUserDefaults currentTC] substringToIndex:barCodeTrailerRange.location]];
	}
	DSPF_TransportUnit *dspf_TransportUnit = [[[DSPF_TransportUnit alloc] initWithNibName:@"DSPF_TransportUnit" bundle:nil] autorelease];
	[dspf_TransportUnit setDelegate:self];
	dspf_TransportUnit.title = NSLocalizedString(@"TITLE_056", @"Ziel");
	[self.navigationController pushViewController:dspf_TransportUnit animated:YES];
}

- (void) dspf_TransportUnit:(DSPF_TransportUnit *)sender didReturnTransportUnit:(NSString *)transportUnit withLocation:(Location *)location forTransportCode:(NSString *)transportCode {
	self.currentTC_F.text					 = transportCode;
	self.currentTU_F.text					 = transportUnit;
	self.currentTC_B.text					 = transportCode;
	self.currentTU_B.text					 = transportUnit;
	self.currentLocationStreetAddress_F.text = location.street;
	self.currentLocationZipCode_F.text       = location.zip;
	self.currentLocationCity_F.text			 = location.city;	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReturnBarcode:) name:@"barcodeData" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
		[[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectScanDevice" object:self userInfo:nil];
	}
    [super viewWillDisappear:animated];
}

#pragma mark - Button actions

- (IBAction)scanDown:(UIButton *)aButton {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
	if ([aButton.titleLabel.text isEqualToString:NSLocalizedString(@"TITLE_049",@"Palette")]) {
		scanDeviceShouldReturnPalletBarcode = YES;
	}else {
		scanDeviceShouldReturnPalletBarcode = NO;
	}	
}


- (IBAction)scanUp:(UIButton *)aButton {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}


- (void)didReturnBarcode:(NSNotification *)aNotification {
    [NSUserDefaults setCurrentTC:[[aNotification userInfo] valueForKey:@"barcodeData"]];
	[self checkForTransportUnit];
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
		if (self.textInputTC.text.length < 6) {
			/* Fehler */
			self.textInputTC.textColor = [UIColor redColor];
			self.textInputTC.font	   = [UIFont fontWithName:@"Helvetica-Bold" size:24];
			return;
		}
		NSRange upperCaseLetterRange = [@"ABCDEFGHIJKLMNOPQRSTUVWXYZ" rangeOfString:[self.textInputTC.text substringToIndex:1]];
		if (upperCaseLetterRange.location == NSNotFound) {
			/* Fehler */
			self.textInputTC.textColor = [UIColor redColor];
			self.textInputTC.font	   = [UIFont fontWithName:@"Helvetica-Bold" size:24];
			return;
		}
		/* Eingabe o.k. */
		scanDeviceShouldReturnPalletBarcode = NO;
        [NSUserDefaults setCurrentTC:aTextField.text];
		[self checkForTransportUnit];
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
	self.scanView						= nil;
	self.textView						= nil;
	self.currentLocationStreetAddress_F = nil;
	self.currentLocationZipCode_F       = nil;
	self.currentLocationCity_F			= nil;
	self.textInputTC					= nil;
	self.currentTC_F					= nil;
	self.currentTU_F					= nil;
	self.currentTC_B					= nil;
	self.currentTU_B					= nil;
    self.geladenLabel                   = nil;
    self.geladenLabel2                  = nil;
}


- (void)dealloc {
	[currentLocationStreetAddress_F release];
	[currentLocationZipCode_F       release];
	[currentLocationCity_F			release];
	[textInputTC					release];
	[currentTC_F					release];
	[currentTU_F					release];
	[currentTC_B					release];
	[currentTU_B					release];
	[scanInputTC					release];
	[scanView						release];
	[textView						release];
    [geladenLabel					release];
	[geladenLabel2					release];
    [super dealloc];
}


@end

