//
//  DSPF_Activity.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSPF_Activity.h"
#import "DSPF_Error.h"

@implementation DSPF_Activity
@synthesize	alertView;
@synthesize	alertViewBackup;
@synthesize	cancelButtonIndex;

@synthesize cancelDelegate;

+ (DSPF_Activity *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate {
    DSPF_Activity *dspf_Activity = [[DSPF_Activity alloc] init];
    dspf_Activity.cancelDelegate = nil;
    dspf_Activity.alertView =
    [[[UIAlertView alloc] initWithTitle:messageTitle
                                message:messageText
                               delegate:dspf_Activity
                      cancelButtonTitle:nil
                      otherButtonTitles:nil] autorelease];
    [dspf_Activity.alertView show];
    [DPHUtilities waitForAlertToShow:0.236f];
    UIActivityIndicatorView *activityIndicator	= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //			activityIndicator.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height * 0.67f );
    activityIndicator.center = CGPointMake(142.00, 94.47);
    [activityIndicator startAnimating];
    [dspf_Activity.alertView addSubview:[activityIndicator autorelease]];
    return dspf_Activity;
}

+ (DSPF_Activity *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText cancelButtonTitle:(NSString *)cancelButtonTitle delegate:(id)delegate {
    DSPF_Activity *dspf_Activity = [[DSPF_Activity alloc] init];
    dspf_Activity.cancelDelegate = delegate;
    dspf_Activity.cancelButtonIndex = 1;
    dspf_Activity.alertView =
    [[[UIAlertView alloc] initWithTitle:messageTitle
                                message:messageText
                               delegate:dspf_Activity
                      cancelButtonTitle:nil
                      otherButtonTitles:cancelButtonTitle, nil] autorelease];
    UIActivityIndicatorView *activityIndicator	= [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    activityIndicator.center = CGPointMake(34.634148, 27.370001);
    [activityIndicator startAnimating];
    [dspf_Activity.alertView addSubview:activityIndicator];
    [dspf_Activity.alertView show];
    
    [DPHUtilities waitForAlertToShow:0.236f];
    return dspf_Activity;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationWillResignActive:)
                                                         name:UIApplicationWillResignActiveNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(applicationDidBecomeActive:)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
        }
    }
    return self;
}

- (void)applicationWillResignActive:(NSNotification *)aNotification {
    if (self.alertView.window) {
        self.alertViewBackup = self.alertView;
        [self.alertView setDelegate:nil];
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:NO];
        self.alertView = nil;
    } else {
        self.alertViewBackup = nil;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.alertViewBackup) {
            self.alertView = self.alertViewBackup;
            [self.alertViewBackup setDelegate:nil];
            self.alertViewBackup = nil;
            [self.alertView setDelegate:self];
            [self.alertView show];
        }
    });
}

- (void) closeActivityInfo {
	//  -1 = closed by program call
    if (self.alertViewBackup) {
        [self.alertViewBackup setDelegate:nil];
        self.alertViewBackup = nil;
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self	name:UIApplicationWillResignActiveNotification object:nil];
        [notificationCenter removeObserver:self	name:UIApplicationDidBecomeActiveNotification  object:nil];
        [self autorelease];
    } else {
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
            [self.alertView dismissWithClickedButtonIndex:-1 animated:NO];
        } else {
            [self.alertView dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
}

- (void)setCancelButtonIndex:(NSInteger )aCancelButtonIndex {
    cancelButtonIndex = aCancelButtonIndex;
    if (aCancelButtonIndex < 1) {
        if (self.alertView.firstOtherButtonIndex != -1) {
            if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending) {
                [[[self.alertView valueForKey:@"_buttons"]
                  objectAtIndex:self.alertView.firstOtherButtonIndex] setEnabled:NO];
            } else {
                CGRect alertViewFrame = self.alertView.frame;
                self.alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [[self.alertView textFieldAtIndex:0] sendActionsForControlEvents:UIControlEventEditingChanged];
                [[self.alertView textFieldAtIndex:0] resignFirstResponder];
                self.alertView.alertViewStyle = UIAlertViewStyleDefault;
                self.alertView.frame = CGRectMake(alertViewFrame.origin.x,
                                                  alertViewFrame.origin.y,
                                                  alertViewFrame.size.width,
                                                  alertViewFrame.size.height);
            }
        }
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    return (self.cancelButtonIndex > -1);
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //  -1 = closed by program call
    if (buttonIndex > -1) {
        [self.cancelDelegate dspf_Activity:(DSPF_Activity *)self didCancelActivity:self.alertView.title];
        [DSPF_Error messageTitle:self.alertView.title
                     messageText:NSLocalizedString(@"ERROR_MESSAGE_023", @"ACHTUNG: Der Prozess wurde abgebrochen. Dadurch sind nicht alle Daten auf dem aktuellen Stand.") delegate:nil];
    }
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self	name:UIApplicationWillResignActiveNotification object:nil];
        [notificationCenter removeObserver:self	name:UIApplicationDidBecomeActiveNotification  object:nil];
    }
    [UIResponder dismissCurrentAlertController];
    [self autorelease];
}

- (void)dealloc {
    [alertViewBackup release];
    [alertView       release];
    [super dealloc];
}


@end
