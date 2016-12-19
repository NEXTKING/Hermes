//
//  DSPF_Warning.m
//  Hermes
//
//  Created by Lutz  Thalmann on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DSPF_Warning.h"
#import "Location.h"

NSString const * WarningConfirmToUnloadItem = @"confirmToUnload";

@implementation DSPF_Warning

@synthesize	alertView;
@synthesize	item;
@synthesize audioPlayer;
@synthesize delegate;

+ (DSPF_Warning *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate {
    return [DSPF_Warning messageTitle:messageTitle messageText:messageText item:aItem delegate:aDelegate cancelButtonTitle:nil otherButtonTitle:nil];
}

+ (DSPF_Warning *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText item:(id )aItem delegate:(id)aDelegate cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitle:(NSString *) otherButtonTitle
{
    UIColor *alertBackgroundColor = [UIColor colorWithRed:250.0 / 255 green:219.0 / 255 blue:150.0 / 255 alpha: 1.0];
    UIColor *borderColor = [UIColor colorWithHue:0.625 saturation:0.0 brightness:0.8 alpha:0.8];
    
    if ([aItem isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@", (NSDictionary *)aItem);
    }
    DSPF_Warning *dspf_Warning = [[DSPF_Warning alloc] init];
    if ([aItem isKindOfClass:[NSDictionary class]] &&
        [[aItem valueForKey:@"item"] isEqualToString:@"retryPrinting"]) {
        
        dspf_Warning.alertView = [DSPF_Warning alertWithTitle:messageTitle
                                                      message:messageText
                                                     delegate:dspf_Warning
                                            cancelButtonTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen") otherButtonTitle:NSLocalizedString(@"TITLE_113", @"Wiederholen")
                                                      bgColor:alertBackgroundColor borderColor:borderColor];
        
    } else if ([aItem isKindOfClass:[NSArray class]] && ((NSArray *)aItem).count > 0 &&
        [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourNotification"]) {
        NSError *error;
        
        dspf_Warning.alertView = [DSPF_Warning alertWithTitle:messageTitle
                                                      message:messageText
                                                     delegate:dspf_Warning
                                            cancelButtonTitle:NSLocalizedString(@"TITLE_100", @"Ablehnen") otherButtonTitle:NSLocalizedString(@"TITLE_101", @"OK")
                                                      bgColor:alertBackgroundColor borderColor:borderColor];

        dspf_Warning.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/alarm.wav",
                                                             [[NSBundle mainBundle] resourcePath]]]
                                                                   error:&error] autorelease];
        dspf_Warning.audioPlayer.numberOfLoops = 3;
        dspf_Warning.audioPlayer.volume        = 1.0;
        [dspf_Warning.audioPlayer play];
        /*
         [[NSNotificationCenter defaultCenter] postNotificationName:@"*TTS" object:self userInfo:
         [NSDictionary dictionaryWithObject:
         [NSString stringWithFormat:@"%@! %@", messageTitle, messageText] forKey:@"*MSG"]];
         */
    } else if ([aItem isKindOfClass:[NSArray class]] && ((NSArray *)aItem).count > 0 &&
              [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourUpdate"]) {
        NSError *error;
        
        dspf_Warning.alertView = [DSPF_Warning alertWithTitle:messageTitle
                                                      message:messageText
                                                     delegate:dspf_Warning
                                            cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK") otherButtonTitle:nil
                                                      bgColor:alertBackgroundColor borderColor:borderColor];
        
        dspf_Warning.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/alarm.wav",
                                                             [[NSBundle mainBundle] resourcePath]]]
                                                                           error:&error] autorelease];
        dspf_Warning.audioPlayer.numberOfLoops = 3;
        dspf_Warning.audioPlayer.volume        = 1.0;
        [dspf_Warning.audioPlayer play];
        /*
         [[NSNotificationCenter defaultCenter] postNotificationName:@"*TTS" object:self userInfo:
         [NSDictionary dictionaryWithObject:
         [NSString stringWithFormat:@"%@! %@", messageTitle, messageText] forKey:@"*MSG"]];
         */
    } else if ([aItem isKindOfClass:[NSArray class]] && ((NSArray *)aItem).count > 0 &&
              [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourTransfer"]) {
        NSError *error;
        // @"🆕 5 x 🅿️ T:210"
        NSArray *parameter = [messageText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *number = @"";
        NSString *code = @"";
        if (parameter.count > 1) {
            number = [parameter objectAtIndex:1];
        }
        if (parameter.count > 4) {
            code = [parameter objectAtIndex:4];
        }
        NSString *messageText = [NSString stringWithFormat:NSLocalizedString(@"MESSAGE_048", @"%@ Haltestellen\nvon Tour %@ übernehmen."), number, code];
        
        dspf_Warning.alertView = [DSPF_Warning alertWithTitle:messageTitle
                                                      message:messageText
                                                     delegate:dspf_Warning
                                            cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK") otherButtonTitle:nil
                                                      bgColor:alertBackgroundColor borderColor:borderColor];

        dspf_Warning.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/alarm.wav",
                                                             [[NSBundle mainBundle] resourcePath]]]
                                                                           error:&error] autorelease];
        dspf_Warning.audioPlayer.numberOfLoops = 3;
        dspf_Warning.audioPlayer.volume        = 1.0;
        [dspf_Warning.audioPlayer play];
        /*
         [[NSNotificationCenter defaultCenter] postNotificationName:@"*TTS" object:self userInfo:
         [NSDictionary dictionaryWithObject:
         [NSString stringWithFormat:@"%@! %@", messageTitle, messageText] forKey:@"*MSG"]];
         */
    } else if ([aItem isKindOfClass:[NSArray class]] && ((NSArray *)aItem).count > 0 &&
               [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourMessage"]) {
        NSError *error;
        
        dspf_Warning.alertView = [DSPF_Warning alertWithTitle:messageTitle
                                                      message:messageText
                                                     delegate:dspf_Warning
                                            cancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK") otherButtonTitle:nil
                                                      bgColor:alertBackgroundColor borderColor:borderColor];
        
        dspf_Warning.audioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:
                                     [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/reminder.wav",
                                                             [[NSBundle mainBundle] resourcePath]]]
                                                                           error:&error] autorelease];
        dspf_Warning.audioPlayer.numberOfLoops = 1;
        dspf_Warning.audioPlayer.volume        = 1.0;
        [dspf_Warning.audioPlayer play];
        /*
         [[NSNotificationCenter defaultCenter] postNotificationName:@"*TTS" object:self userInfo:
         [NSDictionary dictionaryWithObject:
         [NSString stringWithFormat:@"%@! %@", messageTitle, messageText] forKey:@"*MSG"]];
         */
    } else {
        if (otherButtonTitle == nil && cancelButtonTitle == nil) {
            otherButtonTitle = NSLocalizedString(@"TITLE_063", @"Weiter");
            cancelButtonTitle = NSLocalizedString(@"TITLE_004", @"Abbrechen");
        }
        
        dspf_Warning.alertView = [DSPF_Warning alertWithTitle:messageTitle message:messageText delegate:dspf_Warning cancelButtonTitle:cancelButtonTitle otherButtonTitle:otherButtonTitle bgColor:alertBackgroundColor borderColor:borderColor];
    }
    [dspf_Warning setDelegate:aDelegate];
    [dspf_Warning setItem:aItem];
    [dspf_Warning.alertView show];
    [DPHUtilities waitForAlertToShow:0.236f];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending) {
        [(UILabel *)[dspf_Warning.alertView valueForKey:@"_titleLabel"]    setTextColor:[UIColor darkGrayColor]];
        [(UILabel *)[dspf_Warning.alertView valueForKey:@"_bodyTextLabel"] setTextColor:[UIColor grayColor]];
        NSMutableArray *buttonArray = [dspf_Warning.alertView valueForKey:@"_buttons"];
        [[buttonArray objectAtIndex:0] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        if (!([aItem isKindOfClass:[NSArray class]] && ((NSArray *)aItem).count > 0 &&
            ([(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourMessage"] ||
             [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourUpdate"]  ||
            [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourTransfer"]))) {
            [[buttonArray objectAtIndex:1] setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
    }
	return dspf_Warning;
}

- (void)alertView:(UIAlertView *)theAlertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
}

- (void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    /*
    [[NSNotificationCenter defaultCenter] postNotificationName:@"*TTS" object:self userInfo:
     [NSDictionary dictionaryWithObject:@"" forKey:@"*MSG"]];
    */
    [self.audioPlayer stop];
	[self.delegate dspf_Warning:self didConfirmMessageTitle:((UIAlertView *)self.alertView).title item:self.item
				withButtonTitle:[theAlertView buttonTitleAtIndex:buttonIndex] buttonIndex:buttonIndex];
     // [[[theAlertView valueForKey:@"_buttons"] objectAtIndex:buttonIndex] valueForKey:@"title"]];
    [self autorelease];
}

- (void)dealloc {
    [audioPlayer release];
    [item        release];
    [alertView   release];
    [super dealloc];
}

#pragma mark - Helper

+ (UIAlertView *) alertWithTitle:(NSString *) title message:(NSString *) message delegate:(id) delegate
               cancelButtonTitle:(NSString *)cancelTitle otherButtonTitle:(NSString *) otherButtonTitle bgColor:(UIColor *) bgColor borderColor:(UIColor *) borderColor
{
    UIAlertView *alertView = nil;
    if (PFOsVersionCompareGE(@"7.0")) {
        alertView = [[[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:delegate
                                      cancelButtonTitle:cancelTitle
                                      otherButtonTitles:otherButtonTitle, nil] autorelease];
    } else {
        alertView = [DSPF_ColoredAlert coloredAlertWithTitle:title
                                                     message:message
                                             backgroundColor:bgColor
                                                 borderColor:borderColor
                                                    delegate:delegate
                                           cancelButtonTitle:cancelTitle
                                           otherButtonTitles:otherButtonTitle, nil];
    }
    return alertView;
}


@end

@implementation DSPF_Warning(StandardMessages)

+ (DSPF_Warning *) messageForSwitchingToUnloadingForTransportCode:(NSString *) transport delegate:(id) delegate {
    return [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_047", @"Transport-Ziel")
                          messageText:[NSString stringWithFormat:NSLocalizedString(@"MESSAGE_011", @"%@\nsoll hier abgeladen werden.\n\nZum Abladen wechseln ?"), transport]
                                 item:@"switchToUnLoad"
                             delegate:delegate cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
}

+ (DSPF_Warning *) messageForConfirmingUnloadingTransportCode:(NSString *) transport initiallyIntendedDestination:(Location *)destination delegate:(id) delegate {
    NSString *title = NSLocalizedString(@"TITLE_036", @"Ziel-Adresse");
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_016", @"%@\n\n%@\nabladen ?"), [destination formattedString], transport];
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        title = NSLocalizedString(@"TITLE_140", @"Unloading");
        message = NSLocalizedString(@"ERROR_MESSAGE_040", @"Wirklich hier abladen?");
    }
    return [DSPF_Warning messageTitle:title messageText:message item:WarningConfirmToUnloadItem
                             delegate:delegate cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];;
}




@end