//
//  DSPF_StatusReady.m
//  Hermes
//
//  Created by Lutz  Thalmann on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DSPF_StatusReady.h"

NSString const * StatusReadySwitchToLoadItem = @"switchToLoad";
NSString const * StatusReadySwitchToTourLocationItem = @"switchToTourLocation";
NSString const * StatusReadyConfirmUnloadAtFinalDestination = @"confirmTransit";

@implementation DSPF_StatusReady

@synthesize	alertView;
@synthesize	item;
@synthesize delegate;

+ (DSPF_StatusReady *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate {
    return [DSPF_StatusReady messageTitle:messageTitle messageText:messageText item:aItem delegate:aDelegate cancelButtonTitle:nil otherButtonTitle:nil];
}

+ (DSPF_StatusReady *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitle:(NSString *) otherButtonTitle
{
    if (otherButtonTitle == nil && cancelButtonTitle == nil) {
        cancelButtonTitle = NSLocalizedString(@"TITLE_004", @"Abbrechen");
        otherButtonTitle = NSLocalizedString(@"TITLE_063", @"Weiter");
    }
    DSPF_StatusReady *dspf_StatusReady = [[DSPF_StatusReady alloc] init];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        dspf_StatusReady.alertView =
        [[[UIAlertView alloc] initWithTitle:messageTitle
                                         message:messageText
                                        delegate:dspf_StatusReady
                               cancelButtonTitle:cancelButtonTitle
                               otherButtonTitles:otherButtonTitle, nil] autorelease];
    } else {
        //   Color: Moos
        dspf_StatusReady.alertView =
        [DSPF_ColoredAlert coloredAlertWithTitle:messageTitle
                                         message:messageText
                                 backgroundColor:[[[UIColor alloc]
                                                   initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0]
                                                  autorelease]
                                     borderColor:[UIColor colorWithHue:0.625 saturation:0.0 brightness:0.8 alpha:0.8]
                                        delegate:dspf_StatusReady
                               cancelButtonTitle:cancelButtonTitle
                               otherButtonTitles:otherButtonTitle, nil];
    }
    dspf_StatusReady.delegate = aDelegate;
    dspf_StatusReady.item     = aItem;
    [dspf_StatusReady.alertView show];
    [DPHUtilities waitForAlertToShow:0.236f];
	return dspf_StatusReady;
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.delegate dspf_StatusReady:self didConfirmMessageTitle:((UIAlertView *)self.alertView).title item:self.item
					withButtonTitle:[theAlertView buttonTitleAtIndex:buttonIndex] buttonIndex:buttonIndex];
    // [[[theAlertView valueForKey:@"_buttons"] objectAtIndex:buttonIndex] valueForKey:@"title"]];
    [self autorelease];
}

- (void)dealloc {
    [alertView   release];
	[item        release];
    [super dealloc];
}


@end
