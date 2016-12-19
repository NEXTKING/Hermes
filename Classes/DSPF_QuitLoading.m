//
//  DSPF_QuitLoading.m
//  Hermes
//
//  Created by Lutz on 03.07.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_QuitLoading.h"
#import "DSPF_NameForSignature.h"
#import "DSPF_Menu.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"
#import "DSPF_Finish.h"

#import "Location.h"
#import "Tour_Exception.h"
#import "Transport.h"
#import "Transport_Box.h"
#import "Trace_Log.h"
#import "User.h"

@implementation DSPF_QuitLoading

@synthesize tourStartLabel;
@synthesize tourEndeLabel;
@synthesize abschliessenButton;
@synthesize tourTitle;
@synthesize currentTourTitle;
@synthesize currentStintStart;
@synthesize currentStintEnd;
@synthesize tourDeparturesAtWork;
@synthesize ctx;
@synthesize udid;
@synthesize didItOnce;


#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}


- (NSArray *)tourDeparturesAtWork { 
    if (!tourDeparturesAtWork) { 
        tourDeparturesAtWork = [[NSArray arrayWithArray:
                                 [Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES"] 
                                                    sortDescriptors:[NSArray arrayWithObjects:
                                                                     [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:NO], nil]
                                             inCtx:self.ctx]] retain];
    }
    return tourDeparturesAtWork;
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tourStartLabel.text    = NSLocalizedString(@"MESSAGE_044", @"Start:");
    self.tourEndeLabel.text     = NSLocalizedString(@"MESSAGE_045", @"Ende:");
    [self.abschliessenButton setTitle:NSLocalizedString(@"TITLE_010", @"abschliessen") forState:UIControlStateNormal];
	self.udid                   = PFDeviceId();
    self.didItOnce              = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    self.currentTourTitle.text  = self.tourTitle;
    if (self.tourDeparturesAtWork && [self.tourDeparturesAtWork lastObject]) {
        if (!self.didItOnce) {
            NSArray	*sortDescriptors  = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"to_location_id.zip"    ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:@"to_location_id.city"   ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:@"to_location_id.street" ascending:YES],
                                         [NSSortDescriptor sortDescriptorWithKey:@"to_location_id.location_name"   ascending:YES],
                                         nil];
            NSArray *transportsToLoad = nil;
            NSError *error = nil;
            if (PFBrandingSupported(BrandingCCC_Group, nil)) {
                transportsToLoad = [Transport transportsWithPredicate:
                                    [NSPredicate predicateWithFormat:
                                     @"(trace_type_id.code != %@ OR trace_type_id = nil) AND item_id.itemCategoryCode = \"2\" AND "
                                      "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count) AND "
                                      "transport_group_id.pickUpAction = nil", @"LOAD"]
                                                      sortDescriptors:sortDescriptors inCtx:self.ctx];
                
            } else {
                transportsToLoad = [Transport transportsWithPredicate:
                                    [NSPredicate predicateWithFormat:
                                     @"trace_type_id.code != %@ AND item_id = nil AND "
                                      "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count) AND "
                                      " transport_group_id = nil", @"LOAD"]
                                                      sortDescriptors:sortDescriptors inCtx:self.ctx];
            }
            if ((transportsToLoad && [transportsToLoad count] > 0) || error.code == DPHErrorDeliveryNotLoaded){
                if ([DSPF_QuitLoading shouldAllowQuitingUnfinishedLoading]) {
                    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status")
                                   messageText:NSLocalizedString(@"ERROR_MESSAGE_011", @"Es soll noch Ware geladen werden !")
                                          item:@"confirmToQuitLoading"
                                      delegate:self];
                } else {
                    [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_024", @"Tour-Status")
                                   messageText:NSLocalizedString(@"ERROR_MESSAGE_011", @"Es soll noch Ware geladen werden !")
                                      delegate:self];
                }
            }
            self.didItOnce = YES;
        }
        self.currentStintStart.text = [NSUserDefaults currentStintStart];
        self.currentStintEnd.text   = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                     dateStyle:NSDateFormatterMediumStyle
                                                                     timeStyle:NSDateFormatterMediumStyle];
	} else {
        User *currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:self.ctx];
        [self dspf_SignatureForName:nil didReturnSignature:nil forName:[NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName]];
    }
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")]) {
        // new: DSPF_QuitLoading can also be invoked from DSPF_Tour
        UIViewController *menu = [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)];
        for (UIViewController *viewController in self.navigationController.viewControllers) {
            if ([viewController isKindOfClass:[DSPF_Menu class]]) {
                menu = viewController;
                break;
            }
        }
        [self.navigationController popToViewController:menu animated:YES];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)quitLoadingTOUR {
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        User *currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:self.ctx];
        [self dspf_SignatureForName:nil didReturnSignature:nil forName:[NSString stringWithFormat:@"%@ %@", currentUser.firstName, currentUser.lastName]];
    } else {
        DSPF_NameForSignature *dspf_NameForSignature = [[[DSPF_NameForSignature alloc] initWithNibName:@"DSPF_NameForSignature" bundle:nil] autorelease];
        dspf_NameForSignature.departure              = [self.tourDeparturesAtWork lastObject];
        dspf_NameForSignature.isPickup               = YES;
        dspf_NameForSignature.delegate               = self;
        [self.navigationController pushViewController:dspf_NameForSignature animated:YES];
    }
}

#pragma mark - Signature drawing delegate

- (void) dspf_SignatureForName:(DSPF_SignatureForName *)sender didReturnSignature:(UIImage *)aSignature forName:(NSString *)aName {
    DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_032", @"Unterschrift speichern") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
    Departure *firstDepartureOnTour = [self.tourDeparturesAtWork lastObject];
    if (firstDepartureOnTour) {
        for (Transport *tmpTourTransport in [NSArray arrayWithArray:[Transport withPredicate:
                                                                     [NSPredicate predicateWithFormat:
                                                                      @"trace_type_id = nil && trace_log_id.@count = 0 && "
                                                                      "transport_group_id != nil && transport_group_id.pickUpAction = nil && "
                                                                      "(item_id = nil OR item_id.itemCategoryCode = \"2\")"] inCtx:self.ctx]]) {
            NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:tmpTourTransport.code traceType:TraceTypeValueUntouched
                                                                    fromDeparture:firstDepartureOnTour toLocation:firstDepartureOnTour.location_id];
            [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
            [self.ctx saveIfHasChanges];
        }
        NSData *screenShot_PNG = nil;
        if (aSignature) {
            screenShot_PNG = UIImagePNGRepresentation(aSignature);
        }
        // PICKUPSIGNATURE
        NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
        NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValuePickUpSignature
                                                                fromDeparture:firstDepartureOnTour toLocation:firstDepartureOnTour.location_id];
        [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
        [currentTransport setValue:aName                                                                     forKey:@"receipt_text"];
        [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            for (Departure *tmpDeparture in self.tourDeparturesAtWork) {
                if ([[tmpDeparture.location_id.transport_group_addressee_id allObjects]
                     filteredArrayUsingPredicate:
                     [NSPredicate predicateWithFormat:@"pickUpAction = nil && deliveryAction != nil"]].count == 0) {
                    tmpDeparture.currentTourStatus = [NSNumber numberWithInt:30];
                }
            }
        }
        [self.ctx saveIfHasChanges];
    }
    [showActivity closeActivityInfo];
    [showActivity release];
    [SVR_SyncDataManager triggerSendingRentalAndRestitutionDataWithUserInfo:nil];
    [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
    [NSUserDefaults setCurrentStintDidQuitLoading:[NSNumber numberWithBool:YES]];
    /*
     * would be nice, if "sendTraceLogDataOnly" did already send all trace logs 
     *
    for (Transport *tmpTourTransport in [NSArray arrayWithArray:[Transport transportsWithPredicate:
                                                                 [NSPredicate predicateWithFormat:
                                                                  @"(trace_type_id.code = %@ OR trace_type_id.code = %@) && "
                                                                  "(0 == SUBQUERY(trace_log_id, $l, $l.trace_log_id != 0).@count)",
                                                                  @"UNLOAD", @"UNTOUCHED"]
                                                                                   sortDescriptors:nil
                                                                            inCtx:self.ctx]]) {
        [self.ctx deleteObject:tmpTourTransport];
    }
    [self.ctx saveIfHasChanges];
    */
    UIViewController *menu = [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[DSPF_Menu class]]) {
            menu = viewController;
            break;
        }
    }
    [self.navigationController popToViewController:menu animated:YES];
}

+ (BOOL) shouldAllowQuitingUnfinishedLoading {
    BOOL shouldAllowQuiting = YES;
    if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        shouldAllowQuiting = NO;
    }
    return shouldAllowQuiting;
}

- (void)viewDidUnload {
    [super viewDidUnload];

    self.currentTourTitle           = nil;
	self.currentStintStart			= nil;
	self.currentStintEnd			= nil;
    self.tourStartLabel             = nil;
    self.tourEndeLabel              = nil;
    self.abschliessenButton         = nil;
}


- (void)dealloc {
	[ctx		release];
	[udid						release];
    [tourDeparturesAtWork       release];
    [tourTitle                  release];
    [currentTourTitle           release];
	[currentStintEnd		    release];
	[currentStintStart			release];
    [tourStartLabel             release];
    [tourEndeLabel              release];
    [abschliessenButton			release];
    [super dealloc];
}


@end