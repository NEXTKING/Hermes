//
//  DSPF_Payment.m
//  Hermes
//
//  Created by Lutz  Thalmann on 30.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Payment.h"
#import "DSPF_Suspend.h"
#import "DSPF_Error.h"

#import "Location.h"
#import "Transport.h"

@implementation DSPF_Payment

@synthesize textView; 
@synthesize totalValue;
@synthesize total;
@synthesize todo;
@synthesize input;
@synthesize mode;
@synthesize mode_get;
@synthesize mode_put;
@synthesize mode_clear;
@synthesize mode_storno;
@synthesize currentCustomerID;
@synthesize currentCustomerName;
@synthesize currentDeparture;
@synthesize currentTransportGroup;
@synthesize input_1;
@synthesize input_2;
@synthesize input_3;
@synthesize input_4;
@synthesize input_5;
@synthesize input_6;
@synthesize input_7;
@synthesize input_8;
@synthesize input_9;
@synthesize input_0;
@synthesize inputDecimalSeparator;
@synthesize inputFormatter;
@synthesize currencyFormatter;
@synthesize prvTotal;
@synthesize ctx;
@synthesize delegate;

#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

- (NSNumberFormatter *)currencyFormatter { 
    if (!currencyFormatter) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter  setNumberStyle:NSNumberFormatterCurrencyStyle]; 
        [currencyFormatter  setGeneratesDecimalNumbers:YES];
        [currencyFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
    }
    return currencyFormatter;
}

- (NSNumberFormatter *)inputFormatter { 
    if (!inputFormatter) {
        inputFormatter = [[NSNumberFormatter alloc] init];
        [inputFormatter  setNumberStyle:NSNumberFormatterDecimalStyle]; 
        [inputFormatter  setPositiveFormat:@"#,###,##0.00"];
        [inputFormatter  setNegativePrefix:@" "];
        [inputFormatter  setGeneratesDecimalNumbers:YES];
        [inputFormatter  setAlwaysShowsDecimalSeparator:YES];
        [inputFormatter  setDecimalSeparator:[self.inputFormatter.locale objectForKey:NSLocaleDecimalSeparator]];
        [inputFormatter  setGroupingSeparator:[self.inputFormatter.locale objectForKey:NSLocaleGroupingSeparator]];
        [inputFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4]; 
    }
    return inputFormatter;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil { 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		self.title = NSLocalizedString(@"TITLE_038", @"Kassieren"); 
    }
    return self;
}

#pragma mark - View lifecycle

- (void)collectMoney:(NSString *)amount { 
    if ([[NSDecimalNumber decimalNumberWithString:amount] floatValue] != 0.00) {
        // PAYMENTONDELIVERY
        NSString *task = nil;
        if (self.currentTransportGroup) {
            task = self.currentTransportGroup.task;
        } else if (self.currentDeparture.transport_group_id.task) {
            task = self.currentDeparture.transport_group_id.task;
        }
        NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
        NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValuePaymentOnDelivery
                                                                fromDeparture:self.currentDeparture toLocation:self.currentDeparture.location_id];
        [currentTransport setValue:amount                                                                    forKey:@"price"];
        [currentTransport setValueOrSkip:task                                                                forKey:@"task"];
        [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
        [self.ctx saveIfHasChanges];
    }
}

- (void)calculatePaymentTotal {
    if (self.input.text && self.input.text.length > 0) {
        if ([[self.inputFormatter numberFromString:self.input.text] floatValue] != 0.00) {
            AudioServicesPlaySystemSound(cashSound); 
            self.prvTotal           = self.total.text; 
            self.mode_storno.center = self.mode_clear.center;
            self.mode_storno.hidden = NO;
            self.mode_clear.hidden  = YES;
        } else { 
            if (self.prvTotal           &&
                !self.mode_clear.hidden &&
                ![self.prvTotal isEqualToString:self.total.text]) { 
                self.mode_storno.hidden = NO;
                self.mode_clear.hidden  = YES; 
            } else { 
                self.prvTotal           = self.total.text;
                self.mode_storno.hidden = YES;
                self.mode_clear.hidden  = NO;
            } 
        }
        if ([self.input.textColor isEqual:[[[UIColor alloc] initWithRed:25.0 / 255 green:190.0 / 255 blue:114.0 / 255 alpha: 1.0]  autorelease]]) {
            self.total.text = [self.currencyFormatter stringFromNumber:[[NSDecimalNumber 
                                                                         decimalNumberWithDecimal:[[self.currencyFormatter numberFromString:self.total.text] decimalValue]]
                                                                        decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:
                                                                                                    [[self.inputFormatter numberFromString:self.input.text] decimalValue]]]];
            [self collectMoney:[[[NSDecimalNumber decimalNumberWithString:@"0.00"] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:
                                    [[self.inputFormatter numberFromString:self.input.text] decimalValue]]] stringValue]];
        } else {
            self.total.text = [self.currencyFormatter stringFromNumber:[[NSDecimalNumber 
                                                                         decimalNumberWithDecimal:[[self.currencyFormatter numberFromString:self.total.text] decimalValue]]
                                                                        decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:
                                                                                               [[self.inputFormatter numberFromString:self.input.text] decimalValue]]]];
            [self collectMoney:[[[NSDecimalNumber decimalNumberWithString:@"0.00"] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithDecimal:
                                    [[self.inputFormatter numberFromString:self.input.text] decimalValue]]] stringValue]];
        }
        if ([[self.currencyFormatter numberFromString: self.total.text] floatValue] == 0.00) {
            inputExponent   = 0;
            self.input.text = nil;
            [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information") 
                               messageText:NSLocalizedString(@"MESSAGE_037", @"Die Ware ist jetzt vollständig bezahlt und kann abgeladen werden.")
                                      item:@"switchToUnload"
                                  delegate:self];
        } else { 
            if ([[self.currencyFormatter numberFromString: self.total.text] floatValue] > 0.00) {
                self.todo.text = NSLocalizedString(@"TITLE_099", @"Betrag:");
                self.total.textColor = [[[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0] autorelease];
                self.input.textColor = [[[UIColor alloc] initWithRed:25.0 / 255 green:190.0 / 255 blue:114.0 / 255 alpha: 1.0]  autorelease];
                self.mode.image      = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"money_get" ofType:@"png"]]; 
                inputExponent                      = 0;
                self.input.text                    = nil;
                self.input_1.enabled               = YES;
                self.input_2.enabled               = YES;
                self.input_3.enabled               = YES;
                self.input_4.enabled               = YES;
                self.input_5.enabled               = YES;
                self.input_6.enabled               = YES;
                self.input_7.enabled               = YES;
                self.input_8.enabled               = YES;
                self.input_9.enabled               = YES;
                self.input_0.enabled               = YES;
                self.inputDecimalSeparator.enabled = YES; 
                self.mode_put.hidden = YES;
                self.mode_get.hidden = NO;
            } else { 
                self.todo.text = NSLocalizedString(@"TITLE_044", @"Rückgeld:");
                self.total.textColor = [[[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0]  autorelease];
                self.input.textColor = [[[UIColor alloc] initWithRed:255.0 / 255 green:42.0 / 255 blue:28.0 / 255 alpha: 1.0] autorelease];
                self.mode.image      = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"money_put" ofType:@"png"]]; 
                self.input.text = [self.inputFormatter stringFromNumber:
                                   [NSDecimalNumber decimalNumberWithDecimal:[[self.currencyFormatter numberFromString: self.total.text] decimalValue]]];
                self.input_1.enabled               = NO;
                self.input_2.enabled               = NO;
                self.input_3.enabled               = NO;
                self.input_4.enabled               = NO;
                self.input_5.enabled               = NO;
                self.input_6.enabled               = NO;
                self.input_7.enabled               = NO;
                self.input_8.enabled               = NO;
                self.input_9.enabled               = NO;
                self.input_0.enabled               = NO;
                self.inputDecimalSeparator.enabled = NO;
                self.mode_put.center = self.mode_get.center;
                self.mode_put.hidden = NO;
                self.mode_get.hidden = YES;
            }
        }
    } else {
        if ([[self.currencyFormatter numberFromString: self.total.text] floatValue] == 0.00) {
            inputExponent   = 0;
            self.input.text = nil;
            [DSPF_StatusReady messageTitle:NSLocalizedString(@"TITLE_034", @"Status-Information") 
                               messageText:NSLocalizedString(@"MESSAGE_037", @"Die Ware ist jetzt vollständig bezahlt und kann abgeladen werden.")
                                      item:@"switchToUnload"
                                  delegate:self];
        }        
    }
}

- (void)confirmBackButton { 
    if ([[self.currencyFormatter numberFromString: self.total.text] floatValue] == 0.00) {
        [self.delegate dspf_Payment:self didReturnPayment:YES forTransportCode:self.currentCustomerID.text]; 
    } else {
        [[DSPF_Confirm question:NSLocalizedString(@"MESSAGE_038", @"Die Ware ist noch nicht bezahlt !") item:@"confirmBackButton" 
                 buttonTitleYES:((UIViewController *)self.delegate).title 
                  buttonTitleNO:NSLocalizedString(@"TITLE_004", @"Abbrechen") showInView:self.view] setDelegate:self]; 
    }
}

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view = self.textView; 
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] 
                                                                     pathForResource:@"payment_done" ofType:@"wav"]], &cashSound);
	UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
	[tapToSuspend setNumberOfTapsRequired:2];
	[tapToSuspend setNumberOfTouchesRequired:2];
	[self.textView addGestureRecognizer:tapToSuspend];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.inputDecimalSeparator setTitle:self.inputFormatter.decimalSeparator forState:UIControlStateNormal]; 
    self.total.text           = [self.currencyFormatter stringFromNumber:self.totalValue];
    self.input.text           = @"0"; 
    [self calculatePaymentTotal];
    self.currentCustomerID.text = [NSString stringWithFormat:@"%@ %@, %@", 
                                    self.currentDeparture.location_id.zip, self.currentDeparture.location_id.city, self.currentDeparture.location_id.street]; 
    if (self.currentDeparture.location_id.location_code && self.currentDeparture.location_id.location_code.length > 0) {
        self.currentCustomerName.text = [NSString stringWithFormat:@"%@ %@", 
                                         self.currentDeparture.location_id.location_code, self.currentDeparture.location_id.location_name];
    } else if (self.currentDeparture.location_id.code && self.currentDeparture.location_id.code.length > 0) {
        self.currentCustomerName.text = [NSString stringWithFormat:@"%@ %@", 
                                         self.currentDeparture.location_id.code, self.currentDeparture.location_id.location_name];
    } else {
        self.currentCustomerName.text = self.currentDeparture.location_id.location_name;
    }
    UIButton *backButton = [UIButton buttonWithType:101];      // left-pointing shape!
	[backButton addTarget:self action:@selector(confirmBackButton) forControlEvents:UIControlEventTouchUpInside];
	[backButton setTitle:((UIViewController *)self.delegate).title forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem  = [[[UIBarButtonItem alloc] initWithCustomView:backButton] autorelease];
    [self.mode_clear setTitle:NSLocalizedString(@"TITLE_086", @"löschen") forState:UIControlStateNormal];
    [self.mode_storno setTitle:NSLocalizedString(@"TITLE_087", @"storno") forState:UIControlStateNormal];
    [self.mode_put setTitle:NSLocalizedString(@"TITLE_088", @"rückgeld") forState:UIControlStateNormal];
    [self.mode_get setTitle:NSLocalizedString(@"TITLE_089", @"kassieren") forState:UIControlStateNormal];
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
		// back button was pressed.  
		// We know this is true because self is no longer in the navigation stack.
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
	}
    [super viewWillDisappear:animated];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)getInputFromButton:(UIButton *)aButton { 
    
    if ([aButton.titleLabel.text         isEqualToString:NSLocalizedString(@"TITLE_089", @"Kassieren")] ||
        [aButton.titleLabel.text         isEqualToString:NSLocalizedString(@"TITLE_088", @"Rückgeld")]  ||
        [aButton.titleLabel.text         isEqualToString:NSLocalizedString(@"TITLE_087", @"Storno")]    ||
        [aButton.titleLabel.text         isEqualToString:NSLocalizedString(@"TITLE_086", @"Löschen")]) { 
        if ([aButton.titleLabel.text     isEqualToString:NSLocalizedString(@"TITLE_087", @"Storno")]     ||
            [aButton.titleLabel.text     isEqualToString:NSLocalizedString(@"TITLE_086", @"Löschen")])   { 
            if ([aButton.titleLabel.text isEqualToString:NSLocalizedString(@"TITLE_087", @"Storno")])        { 
                AudioServicesPlaySystemSound(cashSound);
                [self collectMoney:[[[NSDecimalNumber decimalNumberWithDecimal:[[self.currencyFormatter numberFromString:self.total.text] decimalValue]] 
                                     decimalNumberBySubtracting:
                                     [NSDecimalNumber decimalNumberWithDecimal:[[self.currencyFormatter numberFromString:prvTotal] decimalValue]]] 
                                    stringValue]];
                self.total.text = self.prvTotal;
            }
            self.input.text = @"0"; 
        }
        [self calculatePaymentTotal];
        return;
    }
    self.mode_storno.hidden = YES;
    self.mode_clear.hidden  = NO;
    if ([aButton.titleLabel.text isEqualToString:self.inputFormatter.decimalSeparator]) {
        if (inputExponent  == 0) {
            inputExponent  -= 1; 
            aButton.enabled = NO;
        }
        return; 
    } else { 
        if (inputExponent <  0) { 
            inputExponent -= 1; 
            if (inputExponent < -2) { 
                self.input_1.enabled               = NO;
                self.input_2.enabled               = NO;
                self.input_3.enabled               = NO;
                self.input_4.enabled               = NO;
                self.input_5.enabled               = NO;
                self.input_6.enabled               = NO;
                self.input_7.enabled               = NO;
                self.input_8.enabled               = NO;
                self.input_9.enabled               = NO;
                self.input_0.enabled               = NO;
            }
        }
    }
    if (self.input.text) { 
        if (inputExponent < 0) { 
            NSDecimalNumber *tmpValue = [NSDecimalNumber decimalNumberWithString:aButton.titleLabel.text];
            for (NSInteger tmpExponent = inputExponent ; tmpExponent < -1 ; tmpExponent ++) { 
                tmpValue = [tmpValue decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
            }
            self.input.text = [self.inputFormatter stringFromNumber:
                               [[NSDecimalNumber decimalNumberWithDecimal:[[self.inputFormatter numberFromString:self.input.text] decimalValue]]
                                                    decimalNumberByAdding:tmpValue]];
        } else { 
            self.input.text = [self.inputFormatter stringFromNumber:
                               [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@%@", 
                                                   [self.inputFormatter numberFromString:self.input.text], aButton.titleLabel.text]]];
        }
    } else { 
        if (inputExponent < 0) { 
            NSDecimalNumber *tmpValue = [NSDecimalNumber decimalNumberWithString:aButton.titleLabel.text];
            for (NSInteger tmpExponent = inputExponent ; tmpExponent < -1 ; tmpExponent ++) { 
                tmpValue = [tmpValue decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"10"]];
            }
            self.input.text = [self.inputFormatter stringFromNumber:tmpValue]; 
        } else {
            self.input.text = [self.inputFormatter stringFromNumber:
                               [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", aButton.titleLabel.text]]]; 
        }
    }
} 

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)item withButtonTitle:(NSString *)buttonTitle {
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
		if ([(NSString *)item isEqualToString:@"confirmBackButton"]) {
            [self.delegate dspf_Payment:self didReturnPayment:NO forTransportCode:self.currentCustomerID.text];
		}
	}
} 

- (void) dspf_StatusReady:(DSPF_StatusReady *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if ([(NSString *)item isEqualToString:@"switchToUnload"]) {
            [self.delegate dspf_Payment:self didReturnPayment:YES forTransportCode:self.currentCustomerID.text];
		}
	}
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSUserDefaults standardUserDefaults] synchronize]; 
    AudioServicesDisposeSystemSoundID(cashSound);
	self.textView						= nil;
    self.total                          = nil;
    self.todo                           = nil;
    self.input                          = nil;
    self.input_1                        = nil;
    self.input_2                        = nil;
    self.input_3                        = nil;
    self.input_4                        = nil;
    self.input_5                        = nil;
    self.input_6                        = nil;
    self.input_7                        = nil;
    self.input_8                        = nil;
    self.input_9                        = nil;
    self.input_0                        = nil;
    self.inputDecimalSeparator          = nil;
    self.mode                           = nil;
    self.mode_clear                     = nil;
    self.mode_storno                    = nil;
    self.mode_get                       = nil;
    self.mode_put                       = nil;
	self.currentCustomerName            = nil;
    self.currentCustomerID              = nil;
}


- (void)dealloc {
	[ctx			release]; 
    [prvTotal                       release];
    [totalValue                     release];
    [total                          release];
    [todo                           release]; 
    [input                          release]; 
    [input_1                        release];
    [input_2                        release];
    [input_3                        release];
    [input_4                        release];
    [input_5                        release];
    [input_6                        release];
    [input_7                        release];
    [input_8                        release];
    [input_9                        release];
    [input_0                        release];
    [inputDecimalSeparator          release];
    [mode                           release];
    [mode_clear                     release];
    [mode_storno                    release];
    [mode_get                       release];
    [mode_put                       release];
	[currentCustomerName            release];
    [currentCustomerID              release];
    [currentTransportGroup          release];
    [currentDeparture               release];
    [currencyFormatter              release]; 
    [inputFormatter                 release];
	[textView						release]; 
    [super dealloc];
}


@end

