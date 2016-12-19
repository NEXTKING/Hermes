//
//  DSPF_Error.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSPF_Error.h"

@implementation DSPF_Error

@synthesize	alertView;

+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText {
    return [DSPF_Error messageTitle:messageTitle messageText:messageText delegate:nil cancelButtonTitle:nil otherButtonTitle:nil];
}

+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate {
    return [DSPF_Error messageTitle:messageTitle messageText:messageText delegate:delegate cancelButtonTitle:nil otherButtonTitle:nil];
}

+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate cancelButtonTitle:(NSString *) cancelTitle {
    return [DSPF_Error messageTitle:messageTitle messageText:messageText delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitle:nil];
}

+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitle:(NSString *) otherButtonTitle
{
    DSPF_Error *dspf_Error = [[DSPF_Error alloc] init];
    if ([cancelButtonTitle length] == 0) {
        cancelButtonTitle = NSLocalizedString(@"TITLE_063", @"Weiter");
    }
    if (delegate == nil) {
        delegate = dspf_Error;
    }
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        dspf_Error.alertView =
        [[[UIAlertView alloc] initWithTitle:messageTitle
                                         message:messageText
                                        delegate:delegate
                               cancelButtonTitle:cancelButtonTitle
                               otherButtonTitles:otherButtonTitle, nil] autorelease];

    } else {
        //   Color: apple
        dspf_Error.alertView =
        [DSPF_ColoredAlert coloredAlertWithTitle:messageTitle
                                         message:messageText
                                 backgroundColor:[[[UIColor alloc]
                                                   initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 1.0]
                                                  autorelease]
                                     borderColor:[UIColor colorWithHue:0.625 saturation:0.0 brightness:0.8 alpha:0.8]
                                        delegate:delegate
                               cancelButtonTitle:cancelButtonTitle
                               otherButtonTitles:otherButtonTitle, nil];
    }
    [dspf_Error.alertView show];
    [DPHUtilities waitForAlertToShow:0.236f];
    return dspf_Error;
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self release];
}

- (void)dealloc {
    [alertView   release];
    [super dealloc];
}


@end


@implementation DSPF_Error(StandardMessages)

+ (DSPF_Error *) messageFromError:(NSError *) error {
    NSString *title = [[error userInfo] objectForKey:NSErrorParameterTitle];
    NSString *text = [error localizedDescription];
    return [DSPF_Error messageTitle:title messageText:text];
}

+ (DSPF_Error *) messageForInvalidTransportWithBarcode:(NSString *) transportBarcode {
    return [DSPF_Error messageTitle:transportBarcode
                        messageText:NSLocalizedString(@"ERROR_MESSAGE_037",
                                                      @"darf nicht geladen werden.\nDiese Eingabe wird ignoriert!")];
}

+ (DSPF_Error *) messageForInvalidTransportBoxWithBarcode:(NSString *) transportBoxBarcode {
    return [DSPF_Error messageTitle:transportBoxBarcode
                        messageText:NSLocalizedString(@"ERROR_MESSAGE_036",
                                                      @"ist für Transportboxen ungültig.\nDiese Eingabe wird ignoriert!")];
}

+ (DSPF_Error *) messageForInvalidTransportCode:(NSString *) transportCode intendedToBePlacedInBoxWithCode:(NSString *) boxCode {
    NSString *text = FmtStr(NSLocalizedString(@"ERROR_MESSAGE__018", @"Der Artikel mit dem Barcode %@ darf nicht in %@ hingelegt werden!"),
                            transportCode, boxCode);
    return [DSPF_Error messageTitle:nil messageText:text];
}

+ (DSPF_Error *) messageForMissingDriverGoodsIssuePermissionsWithCancelButtonTitle:(NSString *) buttonTitle delegate:(id<UIAlertViewDelegate>) delegate {
    NSString *messageText = NSLocalizedString(@"ERROR_MESSAGE__019", @"Currently logged in user does not have permissions to use mobile client");
    NSString *title = NSLocalizedString(@"ERROR_MESSAGE__020", @"Permissions missing");
    
    DSPF_Error *dspfError = [DSPF_Error messageTitle:title messageText:messageText delegate:delegate cancelButtonTitle:buttonTitle];
    [dspfError.alertView setTag:AlertViewNoDriverGoodIssuePermissionsTag];
    return dspfError;
}

+ (DSPF_Error *) messageForUploadFailureWithTitle:(NSString *) title errorString:(NSString *) errorString {
    return [DSPF_Error messageTitle:title
                 messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_020", @"ACHTUNG:\nDer Server meldete folgendes Problem: %@!\nDie Daten wurden nicht gespeichert."), errorString]
                    delegate:nil];
}

@end

