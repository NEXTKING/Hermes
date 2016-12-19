//
//  DSPF_Suspend.m
//  Hermes
//
//  Created by Lutz  Thalmann on 29.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSPF_Suspend.h"
#import "DSPF_TransportInfo.h"
#import "DSPF_ShippingInfo.h"
#import "DSPF_SelectTour.h"
#import "DSPF_LoadBox.h"
#import "DSPF_Unload.h"

@implementation DSPF_Suspend

@synthesize pause;
@synthesize suspendingSeconds;
@synthesize suspendingLoop;
@synthesize caller;


+ (DSPF_Suspend *)suspendWithDefaultsOnViewController:(UIViewController *)aViewController {
	return [[[[DSPF_Suspend alloc] init] autorelease] showOptionButtons:aViewController];
}

- (id) showOptionButtons:(UIViewController *)aViewController {
	self.suspendingSeconds = [[NSUserDefaults currentStintPauseTime] intValue];
    NSMutableArray *otherButtonsArray = nil;
    if (PFTourTypeSupported(@"1XX", @"1X1", nil)) {
        otherButtonsArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"TITLE_059", @"Pause"),
                                                             NSLocalizedString(@"TITLE_060", @"Info zum Versand"),
                                                             NSLocalizedString(@"TITLE_061", @"Info zur Ladung"), nil];
    } else {
        otherButtonsArray = [NSMutableArray arrayWithObjects:NSLocalizedString(@"TITLE_059", @"Pause"),
                                                             NSLocalizedString(@"TITLE_061", @"Info zur Ladung"), nil];
    }
    User *currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
    if ([currentUser hasFunction:UserFunctionGoodsIssueEmployee] && PFBrandingSupported(BrandingCCC_Group, nil)) {
        [otherButtonsArray addObject:NSLocalizedString(@"TITLE_134", @"Gerät übergeben")];
    }
    if ([currentUser hasFunction:UserFunctionDriver] && PFBrandingSupported(BrandingUnilabs, nil)) {
        [otherButtonsArray addObject:NSLocalizedString(@"TITLE_135", @"Waren übergeben")];
        [otherButtonsArray addObject:NSLocalizedString(@"TITLE_138", @"Waren übernehmen")];
    }
    NSString *destructiveButtonTitle = nil;
    if (PFBrandingSupported(BrandingViollier, nil)) {
        destructiveButtonTitle = NSLocalizedString(@"TITLE_117", @"Tourabbruch");
    }
    [self initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"TITLE_058", @"Pause: %02d:%02d:%02d\n"),
                         (self.suspendingSeconds / 3600),
                         ((self.suspendingSeconds / 60) % 60),
                         (self.suspendingSeconds % 60)]
               delegate:self
      cancelButtonTitle:nil
 destructiveButtonTitle:destructiveButtonTitle
      otherButtonTitles:nil];
    for (NSString *buttonTitle in otherButtonsArray) {
        [self addButtonWithTitle:buttonTitle];
    }
    self.cancelButtonIndex = [self addButtonWithTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen")];
	self.caller    = aViewController;
	[self showInView:aViewController.view];
	return self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    NSString *currentButtonTitle = [self buttonTitleAtIndex:buttonIndex];
    UIButton *currentButton = nil;
    if ([self respondsToSelector:NSSelectorFromString(@"_alertController")]) {
        for (id tmpView in [[self valueForKey:@"_alertController"] actions]) {
            if ([[tmpView title] isEqualToString:currentButtonTitle]) {
                currentButton = tmpView;
                break;
            }
        }
    } else {
        for (UIView *tmpView in self.subviews) {
            if ([tmpView isKindOfClass:[UIButton class]]) {
                if ([((UIButton *)tmpView).titleLabel.text isEqualToString:currentButtonTitle]) {
                    currentButton = (UIButton *)tmpView;
                    break;
                }
            }
        }
    }
    if (self.pause &&
        ![currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_059", @"Pause")] &&
        ![currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
        NSString *pauseButtonTitle = NSLocalizedString(@"TITLE_059", @"Pause");
        UIButton *pauseButton = nil;
        if ([self respondsToSelector:NSSelectorFromString(@"_alertController")]) {
            for (id tmpView in [[self valueForKey:@"_alertController"] actions]) {
                if ([[tmpView title] isEqualToString:pauseButtonTitle]) {
                    pauseButton = tmpView;
                    break;
                }
            }
        } else {
            for (UIView *tmpView in self.subviews) {
                if ([tmpView isKindOfClass:[UIButton class]]) {
                    if ([((UIButton *)tmpView).titleLabel.text isEqualToString:pauseButtonTitle]) {
                        pauseButton = (UIButton *)tmpView;
                        break;
                    }
                }
            }
        }
        if ([self respondsToSelector:NSSelectorFromString(@"_alertController")]) {
            [pauseButton setEnabled:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.618 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [pauseButton setEnabled:YES];
            });
        } else {
            [pauseButton setHighlighted:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.618 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                [pauseButton setHighlighted:NO];
            });
        }
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_059", @"Pause")]) {
            // Pause                (otherButton[x])
            if (!self.pause) {
                self.pause = YES;
                self.suspendingLoop = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(nextSecond) userInfo:nil repeats:YES];
                [self.suspendingLoop fire];
                if ([self respondsToSelector:NSSelectorFromString(@"_alertController")]) {
                    // save "old" textcolor
                    // set  "new" textcolor
                } else {
                    [currentButton setTitleColor:[currentButton titleColorForState:UIControlStateNormal] forState:UIControlStateHighlighted];
                    [currentButton setTitleColor:[[[UIColor alloc] initWithRed:0.0 / 255 green:128.0 / 255 blue:64.0 / 255 alpha: 1.0] autorelease]
                                        forState:UIControlStateNormal];
                }
            } else {
                self.pause = NO;
                [self.suspendingLoop invalidate];
                if ([self respondsToSelector:NSSelectorFromString(@"_alertController")]) {
                    // restore "old" textcolor
                } else {
                    [currentButton setTitleColor:[currentButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateNormal];
                }
            }
    } else {
        [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *currentButtonTitle = [self buttonTitleAtIndex:buttonIndex];
    UIButton *currentButton = nil;
    
    if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
        // Abbrechen            (cancelButton)
        if (self.pause) {
            self.pause = NO;
            [self.suspendingLoop invalidate];
            if ([self respondsToSelector:NSSelectorFromString(@"_alertController")]) {
                // restore "old" textcolor
            } else {
                [currentButton setTitleColor:[currentButton titleColorForState:UIControlStateHighlighted] forState:UIControlStateNormal];
            }
        }
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_060", @"Info zum Versand")]) {
        // Info zum Versand    (otherButton[x])
        [self.caller.navigationController pushViewController:[[[DSPF_ShippingInfo alloc] init] autorelease] animated:YES];
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_061", @"Info zur Ladung")]) {
        // Info zur Ladung      (otherButton[x])
        [self.caller.navigationController pushViewController:[[[DSPF_TransportInfo alloc] init] autorelease] animated:YES];
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_117", @"Tourabbruch")]) {
        // Tourabbruch          (otherButton[x])
        DSPF_SelectTour *dspf_SelectTour = [[[DSPF_SelectTour alloc] init] autorelease];
        dspf_SelectTour.task = TourTaskTourAbbruch;
        [self.caller.navigationController pushViewController:dspf_SelectTour animated:YES];
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_134", @"Gerät übergeben")]) {
        [[AppDelegate() deviceHandOver] tryHandingDeviceOver];
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_135", @"Waren übergeben")]) {
        NSDictionary *parameters = @{ UnloadParameterProcessChangeForbidden : @YES,
                                      ControllerTriggerSynchronisationOnExit : @YES };
        DSPF_Unload *unload = [[[DSPF_Unload alloc] initWithParameters:parameters] autorelease];
        [self.caller.navigationController pushViewController:unload animated:YES];
    } else if ([currentButtonTitle isEqualToString:NSLocalizedString(@"TITLE_138", @"Waren übernehmen")]) {
        if ([NSUserDefaults isRunningWithBoxWithArticle]) {
            NSDictionary *params = @{ LoadBoxParameterShowingLoadingForbidden : @YES,
                                      LoadBoxParameterConfirmingNewBoxesForbidden: @YES,
                                      ControllerTriggerSynchronisationOnExit : @YES };
            DSPF_LoadBox *loadBox = [[[DSPF_LoadBox alloc] initWithParameters:params] autorelease];
            [self.caller.navigationController pushViewController:loadBox animated:YES];
        }
    }
    [super dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) nextSecond {
    [NSUserDefaults setCurrentStintPauseTime:[NSNumber numberWithInt:([[NSUserDefaults currentStintPauseTime] intValue]+ 1)]];
	self.suspendingSeconds += 1;
	self.title = [NSString stringWithFormat:NSLocalizedString(@"TITLE_058", @"Pause: %02d:%02d:%02d\n"), (self.suspendingSeconds / 3600), ((self.suspendingSeconds / 60) % 60), (self.suspendingSeconds % 60)];
}


-(void) dealloc {
	[caller release];
    [super	dealloc];
}

@end