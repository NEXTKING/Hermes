//
//  DSPF_TourLocation.m
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Tour.h"
#import "DSPF_TourLocation.h"
#import "DSPF_Activity.h"
#import "DSPF_LoadBox.h"
#import "DSPF_Unload.h"
#import "DSPF_Load.h"
#import "DSPF_ShortDelivery.h"
#import "DSPF_NameForSignature.h"
#import "DSPF_TransportGroupSummary.h"
#import "DSPF_Suspend.h"
#import "DSPF_Error.h"
#import "DSPF_TourLocationTechnopark.h"
#import "ChatInteractorViewController.h"

#import "Tour_Exception.h"
#import "Transport.h"

@implementation DSPF_TourLocation 

@synthesize departureLabel;
@synthesize departureTime;
@synthesize palettenLabel;
@synthesize rollcontainerLabel;
@synthesize paketeLabel;
@synthesize departureExtension;
@synthesize streetAddress;
@synthesize zipCode;
@synthesize city;
@synthesize price;
@synthesize pallets;
@synthesize pallets_tourTask;
@synthesize rollcontainer;
@synthesize rollcontainer_tourTask;
@synthesize units;
@synthesize units_tourTask;
@synthesize transportGroupSummaryButton;
@synthesize button_UNLOAD;
@synthesize button_LOAD;
@synthesize button_PROOF;
@synthesize button_FINISH;
@synthesize tourTask;
@synthesize item;
@synthesize transportGroupTourStop;
@synthesize didItOnce;
@synthesize didShowCallCenterInfo;
@synthesize withReceiptRequirement;
@synthesize withImageAsReceipt;
@synthesize hasImageAsReceipt;
@synthesize withSignatureAsReceipt;
@synthesize hasSignatureAsReceipt;
@synthesize hasConfirmedIncompleteLOAD;
@synthesize hasConfirmedIncompleteUNLOAD;
@synthesize ctx;
@synthesize dspf_ImagePicker;
@synthesize delegate;
@synthesize boxWithArticle;


#pragma mark - Initialization

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain];
    }
    return ctx;
}

#pragma mark - View lifecycle

- (instancetype) initWithParameters:(NSDictionary *)parameters
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])
    {
        self.item = nilOrObject([parameters objectForKey:ControllerParameterItem]);
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
		[tapToSuspend setNumberOfTapsRequired:2];
		[tapToSuspend setNumberOfTouchesRequired:2];
		[self.view	  addGestureRecognizer:tapToSuspend];
    }
    return self;
}


- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.departureExtension.text                = @"🕙";
    self.paketeLabel.text                       = NSLocalizedString(@"MESSAGE_027", @"Pakete");
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        self.palettenLabel.text = NSLocalizedString(@"MESSAGE_043", @"Ladehilfsmittel");
        self.units.center = self.pallets.center;
        self.pallets.hidden = YES;
        self.units_tourTask.hidden = YES;
        self.rollcontainerLabel.hidden     = YES;
        self.rollcontainer.hidden          = YES;
        self.rollcontainer_tourTask.hidden = YES;
        self.transportGroupSummaryButton.hidden = YES;
    } else {
        if ([NSUserDefaults isRunningWithBoxWithArticle]) {
            self.palettenLabel.text = NSLocalizedString(@"TITLE_109", @"Labor");
        } else {
            self.palettenLabel.text = NSLocalizedString(@"MESSAGE_028", @"Paletten");
        }
        if (!PFBrandingSupported(BrandingCCC_Group, nil)) {
            self.paketeLabel.center = self.rollcontainerLabel.center;
            self.units.center = self.rollcontainer.center;
            self.units_tourTask.center = self.rollcontainer_tourTask.center;
            self.rollcontainerLabel.hidden     = YES;
            self.rollcontainer.hidden          = YES;
            self.rollcontainer_tourTask.hidden = YES;
            self.transportGroupSummaryButton.hidden = YES;
        } else {
            self.rollcontainerLabel.text = NSLocalizedString(@"MESSAGE_049", @"RollContainer");
        }
    }
    if (PFBrandingSupported(BrandingUnilabs, nil)) {
        self.palettenLabel.text = NSLocalizedString(@"TITLE_127", @"Transport bag");
        self.paketeLabel.text = NSLocalizedString(@"TITLE_128", @"Specimen bag");
    }
    [self.button_UNLOAD  setTitle:NSLocalizedString(@"TITLE_080", @"Abladen")           forState:UIControlStateNormal];
    [self.button_LOAD    setTitle:NSLocalizedString(@"TITLE_081", @"Laden")             forState:UIControlStateNormal];
    [self.button_PROOF   setTitle:NSLocalizedString(@"TITLE_082", @"Unterschreiben")    forState:UIControlStateNormal];    
    [self.button_FINISH  setTitle:NSLocalizedString(@"TITLE_083", @"Abfahren")          forState:UIControlStateNormal];
    self.button_LOAD.titleLabel.textAlignment   = UITextAlignmentCenter;
    self.button_UNLOAD.titleLabel.textAlignment = UITextAlignmentCenter;
    self.button_PROOF.titleLabel.textAlignment  = UITextAlignmentCenter;
    self.button_FINISH.titleLabel.textAlignment = UITextAlignmentCenter;
    if ([[NSUserDefaults standardUserDefaults] boolForKey: @"HermesApp_SYSVAL_RUN_withImageForTourlocation"]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                                                                                                target:self
                                                                                                action:@selector(getImageForProofOfDelivery)] autorelease];
    }
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        DSPF_TourLocationTechnopark *technoparkController = [DSPF_TourLocationTechnopark new];
        technoparkController.tableDataSource = self;
        [self addChildViewController:technoparkController];
        CGRect technoparkFraem = technoparkController.view.frame;
        technoparkFraem.origin.y = 0;
        technoparkFraem.origin.x = 0;
        technoparkFraem.size = self.view.bounds.size;
        technoparkController.view.frame = technoparkFraem;
        [self.view addSubview:technoparkController.view];
        
        Departure *currentDeparture = (Departure*)self.item;
        technoparkController.completedTransports = [Transport transportsWithPredicate:
         [NSPredicate predicateWithFormat:
          @"transport_group_id.transport_group_id = %lld && trace_type_id.code = %@",
          [currentDeparture.transport_group_id.transport_group_id longLongValue], TraceTypeStringUnload] sortDescriptors:nil inCtx:currentDeparture.managedObjectContext];
        
        //UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"technoparkBackground.png"]];
        //self.technoparkTableView.backgroundView = backgroundImage;
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //[backgroundImage release];
        
        
        UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        chatButton.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 44);
        mapButton.frame = CGRectMake(0, 0, self.view.frame.size.width/2, 44);
        [mapButton addTarget:self action:@selector(switchToYandexNavi) forControlEvents:UIControlEventTouchUpInside];
        
        
        //[chatButton setBackgroundImage:barButtonBackground  forState:UIControlStateNormal];
        //[chatButton setBackgroundImage:barButtonPressedBackground  forState:UIControlStateSelected];
        
        /*UIImage *listImageNotRendered = [UIImage imageNamed:@"chat_bar_normal.png"];
        UIImage *chatImage = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        listImageNotRendered = [UIImage imageNamed:@"chat_bar_selected.png"];
        UIImage *chatImageSelected = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        listImageNotRendered = [UIImage imageNamed:@"map_bar_normal.png"];
        UIImage *mapImage = [listImageNotRendered imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];*/
        
        [chatButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_normal.png"]  forState:UIControlStateNormal];
        [chatButton setBackgroundImage:[UIImage imageNamed:@"chat_bar_selected.png"]  forState:UIControlStateHighlighted];
        [mapButton setBackgroundImage:[UIImage imageNamed:@"map_bar_normal.png"]  forState:UIControlStateNormal];
        [mapButton setBackgroundImage:[UIImage imageNamed:@"map_bar_selected.png"]  forState:UIControlStateHighlighted];
        
        UIBarButtonItem * chatItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
        UIBarButtonItem *startItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
   
        UIBarButtonItem* noSpace = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
        UIBarButtonItem* noSpace1 = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
        noSpace1.width = -16;
        noSpace.width = -10;
        
        self.toolbarItems = @[noSpace1,chatItem, noSpace, startItem];

    }
    
	self.didItOnce = NO;
    self.didShowCallCenterInfo = NO;
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.streetAddress.frame = CGRectMake(self.streetAddress.frame.origin.x,
                                              self.streetAddress.frame.origin.y,
                                              self.streetAddress.frame.size.width,
                                              self.city.frame.origin.y - self.streetAddress.frame.origin.y +
                                              self.city.frame.size.height);
        self.streetAddress.numberOfLines = 3;
        self.streetAddress.lineBreakMode = UILineBreakModeWordWrap;
        [self.streetAddress setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:17]];
        self.streetAddress.minimumFontSize = 8.0;
        self.streetAddress.textAlignment   = UITextAlignmentCenter;
        self.city.frame         = CGRectZero;
        self.zipCode.frame      = CGRectZero;
    }
    // Property settings from outside are first available in viewWillAppear.
}

- (void) switchToYandexNavi
{
    NSString *url = [NSString stringWithFormat:@"yandexnavi://build_route_on_map?lat_to=%f&lon_to=%f", ((Departure*)self.item).location_id.latitude.doubleValue, ((Departure*)self.item).location_id.longitude.doubleValue];
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:url]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"URL error"
                                                        message:[NSString stringWithFormat:
                                                                 @"No custom URL defined for %@", url]
                                                       delegate:self cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) switchToChat
{
#pragma warning - Need to figure out order ID
    ChatInteractorViewController *chatInteractor = [[ChatInteractorViewController alloc] initWithOrderId:1];
    [self.navigationController pushViewController:[chatInteractor orderChat] animated:YES];

}

- (BOOL) shouldRequireReceipt {
    BOOL shouldRequireReceipt = [[[NSUserDefaults standardUserDefaults]
                                    valueForKey:@"HermesApp_SYSVAL_RUN_alwaysWithProofOfDelivery"] isEqualToString:@"TRUE"];
    if (!shouldRequireReceipt &&
        [[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_alwaysWithProofOfDelivery"] isEqualToString:@"DATA-SENSITIVE"]) {
        
        if (itemIsTransportGroup) {
            Transport_Group *transportGroup = (Transport_Group *)self.item;
            if (([transportGroup.sender_id isEqual:self.transportGroupTourStop.location_id] &&
                 [transportGroup.pickUpAgainstReceipt boolValue]) ||
                ([transportGroup.addressee_id isEqual:self.transportGroupTourStop.location_id] &&
                 [transportGroup.handOutAgainstReceipt boolValue])) {
                    shouldRequireReceipt = YES;
                }
        } else {
            // item as departure
            Departure *departure = (Departure *) self.item;
            shouldRequireReceipt = [departure.transport_group_id.handOutAgainstReceipt boolValue] || [departure.location_id.force_signature boolValue];
        }
        if (PFBrandingSupported(BrandingETA, BrandingCCC_Group, BrandingBiopartner, nil)){
            [[NSUserDefaults standardUserDefaults] setBool:NO  forKey:@"HermesApp_SYSVAL_RUN_withImageAsReceipt"];
            [[NSUserDefaults standardUserDefaults] setBool:shouldRequireReceipt forKey:@"HermesApp_SYSVAL_RUN_withSignatureAsReceipt"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return shouldRequireReceipt;
}

- (void)reloadViewComponents {
    if (!self.didItOnce) {
        self.withReceiptRequirement = [self shouldRequireReceipt];
        
        self.withImageAsReceipt     = [[NSUserDefaults standardUserDefaults] boolForKey:@"HermesApp_SYSVAL_RUN_withImageAsReceipt"];
        self.withSignatureAsReceipt = [[NSUserDefaults standardUserDefaults] boolForKey:@"HermesApp_SYSVAL_RUN_withSignatureAsReceipt"];
        if (self.withSignatureAsReceipt && [self.tourTask isEqualToString:TourTaskNormalDrive] && !PFBrandingSupported(BrandingETA, nil)) {
            self.button_PROOF.hidden  = NO;
        } else {
            self.button_UNLOAD.center = self.button_LOAD.center;
            self.button_LOAD.center   = self.button_PROOF.center;
            self.button_PROOF.hidden  = YES;
        }
        if (![self.tourTask isEqualToString:TourTaskNormalDrive] || itemIsTransportGroup) {
            [self.button_FINISH setTitle:NSLocalizedString(@"TITLE_010", @"Abschliessen") forState:UIControlStateNormal];
        }
        if (!itemIsTransportGroup && PFBrandingSupported(BrandingViollier, BrandingOerlikon, nil) &&
            ((Departure *)self.item).location_id.code && ((Departure *)self.item).location_id.code.length > 0) {
            self.title              = ((Departure *)self.item).location_id.code;
        } else if (!itemIsTransportGroup &&
                   ((Departure *)self.item).location_id.location_name && ((Departure *)self.item).location_id.location_name.length > 0) {
            self.title              = ((Departure *)self.item).location_id.location_name;
        } else if (!itemIsTransportGroup &&
                   ((Departure *)self.item).location_id.city && ((Departure *)self.item).location_id.city.length > 0) {
            self.title              = ((Departure *)self.item).location_id.city;
        } else {
            if (!itemIsTransportGroup) {
                self.title          = @"???";
            } else {
                self.title          = ((Transport_Group *)self.item).task;
            }
        }
        if (self.title.length > 14) {
            NSRange l = [self.title rangeOfComposedCharacterSequencesForRange:(NSRange){0, 7}];
            NSRange r = [self.title rangeOfComposedCharacterSequencesForRange:(NSRange){self.title.length - 7, 7}];
            self.title = [[[self.title substringWithRange:l] stringByAppendingString:@"…"] stringByAppendingString:[self.title substringWithRange:r]];
        }
        if (!itemIsTransportGroup) {
            if (PFBrandingSupported(BrandingViollier, nil)) {
                self.streetAddress.text = ((Departure *)self.item).location_id.location_name;
            } else {
                self.city.text          = ((Departure *)self.item).location_id.city;
                self.zipCode.text       = ((Departure *)self.item).location_id.zip;
                self.streetAddress.text = ((Departure *)self.item).location_id.street;
            }
            if (PFTourTypeSupported(@"1X1", nil) && PFBrandingSupported(BrandingOerlikon, nil) &&
                ((Departure *)self.item).location_id.code && ((Departure *)self.item).location_id.code.length > 0) {
                self.departureLabel.text       = [NSString stringWithFormat:@"%@", ((Departure *)self.item).location_id.location_name];
                self.departureLabel.numberOfLines = 2;
                self.departureLabel.lineBreakMode = UILineBreakModeWordWrap;
                self.departureLabel.font = [UIFont fontWithName:self.departureLabel.font.familyName size:15];
                self.departureLabel.frame      = CGRectMake(self.departureLabel.frame.origin.x,
                                                            self.departureLabel.frame.origin.y,
                                                            self.departureExtension.frame.origin.x
                                                            + self.departureExtension.frame.size.width
                                                            - self.departureLabel.frame.origin.x,
                                                            self.departureLabel.frame.size.height);
                self.departureTime.hidden      = YES;
                self.departureExtension.hidden = YES;
            } else if (((Departure *)self.item).departure) {
                self.departureLabel.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
                self.departureTime.text  = [NSDateFormatter localizedStringFromDate:
                                            ((Departure *)self.item).departure dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            } else if (((Departure *)self.item).arrival) {
                self.departureLabel.text = NSLocalizedString(@"MESSAGE_026", @"Abfahrt:");
                self.departureTime.text  = [NSDateFormatter localizedStringFromDate:
                                            ((Departure *)self.item).arrival dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
            } else if (((Departure *)self.item).location_id.location_code)  {
                self.departureLabel.text       = ((Departure *)self.item).location_id.location_code;
                self.departureTime.hidden      = YES;
                self.departureExtension.hidden = YES;
            } else if (((Departure *)self.item).transport_group_id.task)  {
                self.departureLabel.text       = ((Departure *)self.item).transport_group_id.task;
                self.departureTime.hidden      = YES;
                self.departureExtension.hidden = YES;
            } else if (PFTourTypeSupported(@"1X1", nil) &&
                       ((Departure *)self.item).location_id.code && ((Departure *)self.item).location_id.code.length > 0) {
                self.departureLabel.text       = [NSString stringWithFormat:@"%@", ((Departure *)self.item).location_id.location_name];
                self.departureLabel.numberOfLines = 2;
                self.departureLabel.lineBreakMode = UILineBreakModeWordWrap;
                self.departureLabel.font = [UIFont fontWithName:self.departureLabel.font.familyName size:15];
                self.departureLabel.frame      = CGRectMake(self.departureLabel.frame.origin.x,
                                                            self.departureLabel.frame.origin.y,
                                                            self.departureExtension.frame.origin.x
                                                            + self.departureExtension.frame.size.width
                                                            - self.departureLabel.frame.origin.x,
                                                            self.departureLabel.frame.size.height);
                self.departureTime.hidden      = YES;
                self.departureExtension.hidden = YES;
            } else {
                self.departureLabel.text       = [NSString stringWithFormat:@"%@", ((Departure *)self.item).departure_id];
                self.departureTime.hidden      = YES;
                self.departureExtension.hidden = YES;
            }
        } else {
            self.city.text          = self.transportGroupTourStop.location_id.city;
            self.zipCode.text       = self.transportGroupTourStop.location_id.zip;
            self.streetAddress.text = self.transportGroupTourStop.location_id.location_name;
            CGFloat actualLocationNameFontSize;
            [self.streetAddress.text sizeWithFont:self.streetAddress.font
                                               minFontSize:self.streetAddress.minimumFontSize
                                            actualFontSize:&actualLocationNameFontSize
                                                  forWidth:(self.streetAddress.frame.size.width - 10)
                                             lineBreakMode:LineBreakModeByTruncatingTail];
            self.streetAddress.text = self.transportGroupTourStop.location_id.street;
            CGFloat actualStreetAddressFontSize;
            [self.streetAddress.text sizeWithFont:self.streetAddress.font
                                      minFontSize:self.streetAddress.minimumFontSize
                                   actualFontSize:&actualStreetAddressFontSize
                                         forWidth:(self.streetAddress.frame.size.width - 10)
                                    lineBreakMode:LineBreakModeByTruncatingTail];
            actualStreetAddressFontSize = MIN(actualLocationNameFontSize, actualStreetAddressFontSize);
            if (actualLocationNameFontSize > 15.00) actualLocationNameFontSize = 15.00;
            self.streetAddress.font = [self.streetAddress.font fontWithSize:
                                       actualLocationNameFontSize];
            self.streetAddress.text = [NSString stringWithFormat:@"%@\n%@",
                                       self.transportGroupTourStop.location_id.location_name,
                                       self.transportGroupTourStop.location_id.street];
            self.streetAddress.numberOfLines = 2;
            self.streetAddress.lineBreakMode = LineBreakModeByTruncatingTail;
            self.streetAddress.frame = CGRectMake(self.streetAddress.frame.origin.x,
                                                  self.streetAddress.frame.origin.y,
                                                  self.streetAddress.frame.size.width,
                                                  self.city.frame.origin.y -
                                                  self.streetAddress.frame.origin.y + 7);
            [self.streetAddress.superview bringSubviewToFront:self.streetAddress];
            if ([self.transportGroupTourStop.location_id.location_id isEqualToNumber:
                 ((Transport_Group *)self.item).addressee_id.location_id]) {
                self.departureLabel.text        = [NSString stringWithFormat:@"%@\n%@\n%@ %@",
                                                   [((Transport_Group *)self.item).sender_id.location_name
                                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                   ((Transport_Group *)self.item).sender_id.street,
                                                   ((Transport_Group *)self.item).sender_id.zip,
                                                   ((Transport_Group *)self.item).sender_id.city];
            } else {
                self.departureLabel.text        = [NSString stringWithFormat:@"%@\n%@\n%@ %@",
                                                   [((Transport_Group *)self.item).addressee_id.location_name
                                                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                                   ((Transport_Group *)self.item).addressee_id.street,
                                                   ((Transport_Group *)self.item).addressee_id.zip,
                                                   ((Transport_Group *)self.item).addressee_id.city];
            }
            self.departureLabel.numberOfLines = 3;
            self.departureLabel.lineBreakMode = UILineBreakModeWordWrap;
            self.departureLabel.font = [UIFont fontWithName:self.departureLabel.font.familyName size:13];
            self.departureLabel.frame       = CGRectMake(self.departureLabel.frame.origin.x,
                                                         3,
                                                         self.departureExtension.frame.origin.x
                                                         + self.departureExtension.frame.size.width
                                                         - self.departureLabel.frame.origin.x,
                                                         self.streetAddress.frame.origin.y - 5);
            self.departureTime.hidden      = YES;
            self.departureExtension.hidden = YES;
        }
        if (!itemIsTransportGroup) {
            NSPredicate *predicate = AndPredicates([Transport withToLocationId:((Departure *)self.item).location_id.location_id],
                                                   [Transport withTraceLogCodes:@[TraceTypeStringLoad]], nil);
            if ([[Transport withPredicate:predicate inCtx:self.ctx] count] == 0) {
                self.withReceiptRequirement = NO;
                // If there is already everything unloaded, then a second receipt is now just optional.
            }
        } else {
            NSNumber *toLocationId = self.transportGroupTourStop.location_id.location_id;
            if ([[Transport withPredicate:[NSPredicate predicateWithFormat:@"to_location_id.location_id = %@ && trace_type_id.code = %@", toLocationId, @"LOAD"]
                                    inCtx:self.ctx] count] == 0 &&
                [[Transport withPredicate:[NSPredicate predicateWithFormat:@"from_location_id.location_id = %@ && trace_type_id.code != %@", toLocationId, @"LOAD"]
                                    inCtx:self.ctx] count] == 0)
            {
                self.withReceiptRequirement = NO;
                // If there is already everything unloaded, then a second receipt is now just optional.
            }
        }
    }
    
    //TODO: "same" implementation is in Load (method setCountValues)
    if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
        if (itemIsTransportGroup) {
            if ([self.transportGroupTourStop.location_id.location_id isEqualToNumber:
                 ((Transport_Group *)self.item).addressee_id.location_id] ||
                [self.transportGroupTourStop isEqual:[Departure lastTourDepartureInCtx:self.ctx]]) {
                self.price.text            = [NSString stringWithFormat:@"%@",
                                              [Transport transportsPriceForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                                         transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                 inCtx:self.ctx]];
                self.pallets.text          = [NSString stringWithFormat:@"%i",
                                              [Transport transportsPalletCountForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                                               transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                       inCtx:self.ctx]];
                self.rollcontainer.text    = [NSString stringWithFormat:@"%i",
                                              [Transport transportsRollContainerCountForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                                                      transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                              inCtx:self.ctx]];
                self.units.text            = [NSString stringWithFormat:@"%i",
                                              [Transport transportsUnitCountForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                                             transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                     inCtx:self.ctx]];
                self.pallets_tourTask.text       = @"⬇";
                self.rollcontainer_tourTask.text = @"⬇";
                self.units_tourTask.text         = @"⬇";
            } else {
                self.price.text            = [NSString stringWithFormat:@"%@",
                                              [Transport transportsOpenPriceForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                             transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                     inCtx:self.ctx]];
                self.pallets.text          = [NSString stringWithFormat:@"%i",
                                              [Transport transportsOpenPalletCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                                   transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                           inCtx:self.ctx]];
                self.rollcontainer.text    = [NSString stringWithFormat:@"%i",
                                              [Transport transportsOpenRollContainerCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                                          transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                                  inCtx:self.ctx]];
                self.units.text            = [NSString stringWithFormat:@"%i",
                                              [Transport transportsOpenUnitCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                                 transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                         inCtx:self.ctx]];
                self.pallets_tourTask.text       = @"⬆";
                self.rollcontainer_tourTask.text = @"⬆";
                self.units_tourTask.text         = @"⬆";
            }
        } else {
            self.price.text            = [NSString stringWithFormat:@"%@",
                                          [Transport transportsPriceForTourLocation:((Departure *)self.item).location_id.location_id
                                                                     transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                             inCtx:self.ctx]];
            self.pallets.text          = [NSString stringWithFormat:@"%i",
                                          [Transport transportsPalletCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                           transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                   inCtx:self.ctx]];
            self.rollcontainer.text    = [NSString stringWithFormat:@"%i",
                                          [Transport transportsRollContainerCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                  transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                          inCtx:self.ctx]];
            self.units.text            = [NSString stringWithFormat:@"%i",
                                          [Transport transportsUnitCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                         transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                 inCtx:self.ctx]];
            self.pallets_tourTask.text       = @"⬇";
            self.rollcontainer_tourTask.text = @"⬇";
            self.units_tourTask.text         = @"⬇";
        }
    } else {
        if (itemIsTransportGroup) {
            self.price.text        = [NSString stringWithFormat:@"%@",
                                      [Transport transportsOpenPriceForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                     transportGroup:((Transport_Group *)self.item).transport_group_id
                                                             inCtx:self.ctx]];
            self.pallets.text   = [NSString stringWithFormat:@"%i",
                                   [Transport transportsOpenPalletCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                        transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                inCtx:self.ctx]];
            self.rollcontainer.text = [NSString stringWithFormat:@"%i",
                                       [Transport transportsOpenRollContainerCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                                   transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                           inCtx:self.ctx]];
            self.units.text     = [NSString stringWithFormat:@"%i",
                                   [Transport transportsOpenUnitCountForTourLocation:((Transport_Group *)self.item).addressee_id.location_id
                                                                      transportGroup:((Transport_Group *)self.item).transport_group_id
                                                              inCtx:self.ctx]];
        } else {
            self.price.text         = [NSString stringWithFormat:@"%@",
                                       [Transport transportsOpenPriceForTourLocation:((Departure *)self.item).location_id.location_id
                                                                      transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                              inCtx:self.ctx]];
            if (PFTourTypeSupported(@"1X1", nil)) {
                self.pallets.text   = [NSString stringWithFormat:@"%i",
                                       [Transport transportsPalletCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                        transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                inCtx:self.ctx]];
                self.rollcontainer.text = [NSString stringWithFormat:@"%i",
                                           [Transport transportsRollContainerCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                   transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                           inCtx:self.ctx]];
                self.units.text     = [NSString stringWithFormat:@"%i",
                                       [Transport transportsUnitCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                      transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                              inCtx:self.ctx]];
            } else {
                self.pallets.text   = [NSString stringWithFormat:@"%i",
                                       [Transport transportsOpenPalletCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                            transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                    inCtx:self.ctx]];
                self.rollcontainer.text = [NSString stringWithFormat:@"%i",
                                           [Transport transportsOpenRollContainerCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                                       transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                               inCtx:self.ctx]];
                self.units.text     = [NSString stringWithFormat:@"%i",
                                       [Transport transportsOpenUnitCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                                          transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                                  inCtx:self.ctx]];
            }
        }
        self.pallets_tourTask.text       = @"⬆";
        self.rollcontainer_tourTask.text = @"⬆";
        self.units_tourTask.text         = @"⬆";
    }
    if (!itemIsTransportGroup && PFBrandingSupported(BrandingBiopartner, nil)) {
        BOOL demoMode = PFCurrentModeIsDemo();
        NSMutableString *infoSigns = [NSMutableString string];
        [infoSigns appendString:@""];
        for (NSString *sign in [Transport allInfoSigns]) {
            if (demoMode || [Transport hasStagingInfo:sign toLocation:((Departure *)self.item).location_id.location_id
                                       transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                inCtx:((Departure *)self.item).managedObjectContext]){
                [infoSigns appendString:sign];
            }
        }
        self.paketeLabel.text = infoSigns;
        self.paketeLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:21];
    }
    if (itemIsTransportGroup && PFBrandingSupported(BrandingCCC_Group, nil)) {
        BOOL demoMode = PFCurrentModeIsDemo();
        NSMutableString *infoSigns = [NSMutableString string];
        [infoSigns appendString:@""];
        if (demoMode ||
            [[((Transport_Group *)self.item).transport_id filteredSetUsingPredicate:
              [NSPredicate predicateWithFormat:@"temperatureZone == \"FS1\""]] allObjects].count != 0)
            [infoSigns appendString:[NSString stringWithFormat:@"%@ ",
                                     [NSString stringWithUTF8String:"\u2744"]]]; // @"❄️" is not shown correctly
        if (demoMode ||
            [[((Transport_Group *)self.item).transport_id filteredSetUsingPredicate:
              [NSPredicate predicateWithFormat:@"temperatureZone == \"FS2\""]] allObjects].count != 0)
            [infoSigns appendString:[NSString stringWithFormat:@"%@", @"⛄"]];
        if (demoMode ||
            [[((Transport_Group *)self.item).transport_id filteredSetUsingPredicate:
              [NSPredicate predicateWithFormat:@"temperatureZone == \"FS5\""]] allObjects].count != 0)
            [infoSigns appendString:[NSString stringWithFormat:@"%@", @"⚓️"]];
        if (infoSigns.length > 0) {
            self.transportGroupSummaryButton.layer.backgroundColor =
            [[[UIColor alloc] initWithRed:255.0 / 255 green:128.0 / 255 blue:0.0 / 255 alpha: 1.0] autorelease].CGColor;
        } else {
            self.transportGroupSummaryButton.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        }
        self.transportGroupSummaryButton.layer.cornerRadius = 9.0;
        /*
        self.paketeLabel.text = infoSigns;
        self.paketeLabel.textAlignment = UITextAlignmentCenter;
        self.paketeLabel.textColor = [UIColor whiteColor];
        self.paketeLabel.font = [UIFont fontWithName:@"AppleColorEmoji" size:19];
        CGRect labelFrame = self.paketeLabel.frame;
        [self.paketeLabel sizeToFit];
        CALayer *backGround = [CALayer layer];
        backGround.frame = CGRectMake(self.paketeLabel.frame.origin.x,
                                      self.paketeLabel.frame.origin.y
                                      - 3 + (labelFrame.size.height - self.paketeLabel.frame.size.height) / 2,
                                      self.units_tourTask.frame.origin.x
                                      + self.units_tourTask.frame.size.width
                                      - 9
                                      - labelFrame.origin.x,
                                      self.paketeLabel.frame.size.height);
        backGround.backgroundColor = [[[UIColor alloc] initWithRed:232.0 / 255 green:31.0 / 255 blue:23.0 / 255 alpha: 0.9] autorelease].CGColor;
        backGround.cornerRadius = 3;
        [self.paketeLabel.layer.superlayer addSublayer:backGround];
        [self.paketeLabel.layer removeFromSuperlayer];
        [backGround.superlayer addSublayer:self.paketeLabel.layer];
        */
           /*
           [self.paketeLabel.layer.superlayer insertSublayer:backGround atIndex:
           [self.paketeLabel.layer.superlayer.sublayers indexOfObject:self.paketeLabel.layer]];
           */
        /*
        self.paketeLabel.backgroundColor = [UIColor clearColor];
        [self.paketeLabel setFrame:CGRectMake(labelFrame.origin.x,
                                              labelFrame.origin.y,
                                              self.units_tourTask.frame.origin.x
                                              + self.units_tourTask.frame.size.width
                                              - 9
                                              - labelFrame.origin.x,
                                              labelFrame.size.height)];
        */
    }
    if (![NSUserDefaults isRunningWithFlexibleUnload]) {
        self.button_UNLOAD.enabled = [[self allTransportsToUnload] count] > 0;
    }
    
    self.didItOnce = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    itemIsTransportGroup = ([self.item isKindOfClass:[Transport_Group class]]);
    [self reloadViewComponents];
}

- (void)dismissDeliveryPayment {
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.view setNeedsDisplay];
}

- (void)payDelivery {
    DSPF_Payment *dspf_Payment    = [[DSPF_Payment alloc] initWithNibName:@"DSPF_Payment" bundle:nil];
    dspf_Payment.delegate         = self;
    if (itemIsTransportGroup) {
        dspf_Payment.currentDeparture = self.transportGroupTourStop;
        dspf_Payment.totalValue       = [Transport transportsPriceForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                                   transportGroup:((Transport_Group *)self.item).transport_group_id
                                                           inCtx:self.ctx];
        dspf_Payment.currentTransportGroup = self.item;
    } else {
        dspf_Payment.currentDeparture = (Departure *)self.item;
        dspf_Payment.totalValue       = [Transport transportsPriceForTourLocation:((Departure *)self.item).location_id.location_id
                                                                   transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                                           inCtx:self.ctx];
    }
    UINavigationController *navigationController  = [[UINavigationController alloc] initWithRootViewController:dspf_Payment];
    navigationController.navigationBar.barStyle   = self.navigationController.navigationBar.barStyle;
    navigationController.toolbar.tintColor        = self.navigationController.toolbar.tintColor;
    navigationController.toolbar.alpha            = self.navigationController.toolbar.alpha;
    [dspf_Payment release];
    [self.navigationController presentModalViewController:navigationController animated:YES];
    [navigationController release];
}

- (void)infoMessageSound {
    NSError *error;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:
                                  [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/reminder.wav",
                                                          [[NSBundle mainBundle] resourcePath]]]
                                                                        error:&error];
    audioPlayer.numberOfLoops = 3;
    audioPlayer.volume        = 1.0;
    [audioPlayer play];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.618]];
    [audioPlayer stop];
    [audioPlayer release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
        if (!itemIsTransportGroup && !self.didShowCallCenterInfo) {
            if (((Departure *)self.item).infoMessage &&
                ((Departure *)self.item).infoMessage.length > 0) {
                if (((Departure *)self.item).infoMessageDate) {
                    NSDate *date = [DPHDateFormatter dateFromString:[NSUserDefaults currentStintStart]
                                                      withDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle locale:[NSLocale currentLocale]];
                    NSInteger tmpInterval_1 = [((Departure *)self.item).infoMessageDate timeIntervalSinceNow];
                    NSInteger tmpInterval_2 = [((Departure *)self.item).infoMessageDate timeIntervalSinceDate:date];
                    if ((tmpInterval_1 / 86400) == 0 || (tmpInterval_2 / 86400) == 0) {
                        [[[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"TITLE_111", @"CallCenter-Info")
                                                    message:((Departure *)self.item).infoMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
                        [self performSelectorOnMainThread:@selector(infoMessageSound) withObject:nil waitUntilDone:NO];
                    }
                } else if (PFBrandingSupported(BrandingBiopartner, nil)) {
                    [[[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Kunden-Info", @"Kunden-Info")
                                                message:((Departure *)self.item).infoMessage
                                               delegate:nil
                                      cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
                    [self performSelectorOnMainThread:@selector(infoMessageSound) withObject:nil waitUntilDone:NO];
                }
            }
            self.didShowCallCenterInfo = YES;
        }
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            [self reloadViewComponents];
            return;
        }
        
        if ((itemIsTransportGroup &&
             [[Transport transportsPriceForTourLocation:self.transportGroupTourStop.location_id.location_id
                                         transportGroup:((Transport_Group *)self.item).transport_group_id
                                 inCtx:self.ctx] floatValue] != 0.00) ||
            (!itemIsTransportGroup &&
             [[Transport transportsPriceForTourLocation:((Departure *)self.item).location_id.location_id
                                         transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                 inCtx:self.ctx] floatValue] != 0.00)) {
            [self payDelivery];
        }
    }
}

- (IBAction)didLeaveTourLocation {
    if (!itemIsTransportGroup) {
        if (PFBrandingSupported(BrandingRegent, nil)) {
            for (Transport *tmpTransport in [[((Departure *)self.item).location_id.transport_destination_id allObjects]
                                             filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                @"trace_type_id.code = %@", @"LOAD"]]) {
                tmpTransport.to_departure_id = [Departure lastTourDepartureInCtx:self.ctx];
                tmpTransport.to_location_id  = [Departure lastTourDepartureInCtx:self.ctx].location_id;
            }
            [self.ctx saveIfHasChanges];
        }
    }
    if (self.delegate && [(NSObject *)self.delegate isKindOfClass:[DSPF_Tour class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    [SVR_SyncDataManager triggerSendingRentalAndRestitutionDataWithUserInfo:nil];
    if ([self.tourTask isEqualToString:TourTaskNormalDrive] || (PFTourTypeSupported(@"1XX", nil) && [NSUserDefaults isRunningWithTourAdjustment])) {
        [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
    } else {
        [SVR_SyncDataManager triggerSendingTraceLogDataWithUserInfo:nil];
    }
    [self.delegate dspf_TourLocation:self didFinishTourForItem:self.item];
}
- (IBAction)transportCodesShouldBeginLoading { 
    self.navigationItem.hidesBackButton = YES;
    self.hasSignatureAsReceipt = NO;
    self.hasImageAsReceipt = NO;
    if (itemIsTransportGroup &&
        (([self.tourTask isEqualToString:TourTaskLoadingOnly] &&
          ![((Transport_Group *)self.item).pickUpAction unsignedIntegerValue])
         ||
         ([((Transport_Group *)self.item).sender_id isEqual:self.transportGroupTourStop.location_id] &&
          (![((Transport_Group *)self.item).pickUpAction unsignedIntegerValue] ||
           [((Transport_Group *)self.item).pickUpAction unsignedIntegerValue] == 3)))) {
        [[DSPF_Confirm question:NSLocalizedString(@"TITLE_122", @"Gesamte Lieferung")
                           item:@"confirmLoadALL"
                  buttonTitleOK:NSLocalizedString(@"TITLE_008", @"Laden")
                 buttonTitleYES:NSLocalizedString(@"TITLE_119", @"Laden mV")
                  buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                     showInView:self.view] setDelegate:self];
    } else {
        NSNumber *preventScanning = @NO;
        if (!itemIsTransportGroup && [[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withBoxWithArticle"]isEqualToString:@"TRUE"]) {
            NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                          ControllerParameterItem : objectOrNSNull(self.item),
                                          ControllerParameterPreventScanning : preventScanning };
            DSPF_LoadBox *dspf_LoadBox = [[[DSPF_LoadBox alloc] initWithParameters:parameters] autorelease];
            [self.navigationController pushViewController:dspf_LoadBox animated:YES];
        } else {
            if (itemIsTransportGroup &&
                [((Transport_Group *)self.item).sender_id isEqual:self.transportGroupTourStop.location_id] &&
                [((Transport_Group *)self.item).pickUpAction unsignedIntegerValue] == 2) {
                preventScanning = @YES;
            }
            NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                          ControllerParameterItem : objectOrNSNull(self.item),
                                          ControllerParameterPreventScanning : preventScanning,
                                          ControllerTransportGroupTourStop: objectOrNSNull(self.transportGroupTourStop) };
            DSPF_Load *dspf_Load = [[[DSPF_Load alloc] initWithParameters:parameters] autorelease];
            [self.navigationController pushViewController:dspf_Load animated:YES];
        }
    }
}

- (void)loadALL {
    NSArray *tmpTransports = [self allTransportsToLoad];
    if (!tmpTransports || tmpTransports.count == 0) {
        NSString *identifierCode = nil;
        if (itemIsTransportGroup) {
            identifierCode = ((Transport_Group *)self.item).code;
        } else {
            identifierCode = ((Departure *)self.item).transport_group_id.code;
        }
        [DSPF_Error messageTitle:[NSString stringWithFormat:@"%@", identifierCode]
                     messageText:NSLocalizedString(@"MESSAGE_010", @"ist bereits geladen.\nDiese Eingabe wird ignoriert!")
                        delegate:nil];
    } else {
        Transport_Group *transportGroup = [Transport_Group transportGroupForItem:self.item ctx:self.ctx createWhenNotExisting:NO];
        for (Transport *tmpTransport in tmpTransports) {
            NSInteger numberOfItems = 0;
            if (!tmpTransport.occurrences)
                numberOfItems = 1;
            else
                numberOfItems += [tmpTransport.occurrences integerValue];
            for (int i = 0; i < numberOfItems; i++) {
                Departure *fromDeparture = nil;
                Location *toLocation = nil;
                if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
                    fromDeparture = [Departure firstTourDepartureInCtx:self.ctx];
                } else {
                    if (itemIsTransportGroup) {
                        fromDeparture = self.transportGroupTourStop;
                    } else {
                        fromDeparture = ((Departure *)self.item);
                    }
                }
                if (itemIsTransportGroup) {
                    toLocation = ((Transport_Group *)self.item).addressee_id;
                } else {
                    toLocation = tmpTransport.to_location_id;
                }
                
                NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:tmpTransport.code traceType:TraceTypeValueLoad
                                                                        fromDeparture:fromDeparture toLocation:toLocation];
                
                [currentTransport setObject:[NSNumber numberWithBool:NO]                                          forKey:@"isPallet"];
                Transport *transport = [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
                [transportGroup removeTransport_idObject:transport];
            }
        }
        [self.ctx saveIfHasChanges];
        [self reloadViewComponents];
        [self.view setNeedsDisplay];
    }
}

- (NSArray *) allTransportsToUnload {
    NSArray *transportsToUnload = nil;
    NSArray *sortByCodeAsc = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil];
    NSPredicate *traceTypeLoadPredicate = [NSPredicate predicateWithFormat:@"trace_type_id.code = %@", @"LOAD"];
    NSPredicate *predicate = nil;
    if (itemIsTransportGroup) {
        NSPredicate *transportGroupId = [Transport withTransportGroupId:((Transport_Group *)self.item).transport_group_id];
        if ([self.transportGroupTourStop isEqual:[Departure lastTourDepartureInCtx:self.ctx]]) {
            predicate = AndPredicates(traceTypeLoadPredicate, transportGroupId, nil);
        } else {
            NSNumber *toLocationId = ((Transport_Group *)self.item).addressee_id.location_id;
            predicate = AndPredicates(traceTypeLoadPredicate, [Transport withToLocationId:toLocationId], transportGroupId, nil);
        }
    } else {
        NSNumber *toLocationId = ((Departure *)self.item).location_id.location_id;
        NSPredicate *toLocation = [Transport withToLocationId:toLocationId];
        predicate = AndPredicates(traceTypeLoadPredicate, toLocation, nil);
        if (((Departure *)self.item).transport_group_id) {
            NSPredicate *transportGroupId = [Transport withTransportGroupId:((Departure *)self.item).transport_group_id.transport_group_id];
            predicate = AndPredicates(predicate, transportGroupId, nil);
        }
    }
    transportsToUnload = [Transport transportsWithPredicate:predicate sortDescriptors:sortByCodeAsc inCtx:self.ctx];
    return transportsToUnload;
}

- (NSArray *) allTransportsToLoad {
    NSArray *tmpTransports;
    if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) {
        if (itemIsTransportGroup) {
            tmpTransports = [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                @"trace_type_id = nil AND trace_log_id.@count = 0 AND "
                                                                "to_location_id.location_id = %lld AND transport_group_id.transport_group_id = %ld AND "
                                                                "(item_id = nil OR item_id.itemCategoryCode = \"2\")",
                                                                [((Transport_Group *)self.item).addressee_id.location_id longLongValue],
                                                                [((Transport_Group *)self.item).transport_group_id longValue]]
                                               sortDescriptors:[NSArray arrayWithObjects:
                                                                [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil]
                                        inCtx:self.ctx];
        } else {
            if (((Departure *)self.item).transport_group_id) {
                tmpTransports = [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                    @"((trace_type_id = nil AND trace_log_id.@count = 0) OR trace_type_id.code = %@) AND "
                                                                    "to_location_id.location_id = %lld AND transport_group_id.transport_group_id = %ld",
                                                                    @"UNLOAD",
                                                                    [((Departure *)self.item).location_id.location_id longLongValue],
                                                                    [((Departure *)self.item).transport_group_id.transport_group_id longValue]]
                                                   sortDescriptors:[NSArray arrayWithObjects:
                                                                    [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil]
                                            inCtx:self.ctx];
            } else {
                tmpTransports = [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                    @"((trace_type_id = nil AND trace_log_id.@count = 0) OR trace_type_id.code = %@) AND "
                                                                    "to_location_id.location_id = %lld",
                                                                    @"UNLOAD",
                                                                    [((Departure *)self.item).location_id.location_id longLongValue]]
                                                   sortDescriptors:[NSArray arrayWithObjects:
                                                                    [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil]
                                            inCtx:self.ctx];
            }
        }
    } else {
        if (itemIsTransportGroup) {
            tmpTransports = [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                @"((trace_type_id = nil AND trace_log_id.@count = 0) OR trace_type_id.code = %@) AND "
                                                                "from_location_id.location_id = %lld AND "
                                                                "transport_group_id.transport_group_id = %ld AND "
                                                                "(item_id = nil OR item_id.itemCategoryCode = \"2\")",
                                                                @"UNLOAD",
                                                                [((Transport_Group *)self.item).sender_id.location_id longLongValue],
                                                                [((Transport_Group *)self.item).transport_group_id longValue]]
                                               sortDescriptors:[NSArray arrayWithObjects:
                                                                [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil]
                                        inCtx:self.ctx];
        } else {
            if (((Departure *)self.item).transport_group_id) {
                tmpTransports = [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                    @"trace_type_id = nil AND trace_log_id.@count = 0 AND from_location_id.location_id = %lld AND "
                                                                    "transport_group_id.transport_group_id = %ld",
                                                                    [((Departure *)self.item).location_id.location_id longLongValue],
                                                                    [((Departure *)self.item).transport_group_id.transport_group_id longValue]]
                                                   sortDescriptors:[NSArray arrayWithObjects:
                                                                    [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil]
                                            inCtx:self.ctx];
            } else {
                tmpTransports = [Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                                    @"trace_type_id = nil AND trace_log_id.@count = 0 AND from_location_id.location_id = %lld",
                                                                    [((Departure *)self.item).location_id.location_id longLongValue]]
                                                   sortDescriptors:[NSArray arrayWithObjects:
                                                                    [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES], nil]
                                            inCtx:self.ctx];
            }
        }
    }
    return tmpTransports;
}

- (void)unloadALL {
    NSArray *tmpTransports = [self allTransportsToUnload];
    if (!tmpTransports || tmpTransports.count == 0) {
        NSString *identifierCode = nil;
        if (itemIsTransportGroup) {
            identifierCode = ((Transport_Group *)self.item).code;
        } else {
            identifierCode = ((Departure *)self.item).transport_group_id.code;
        }
        [DSPF_Error messageTitle:[NSString stringWithFormat:@"%@", identifierCode]
                     messageText:NSLocalizedString(@"MESSAGE_050", @"ist bereits abgeladen.\nDiese Eingabe wird ignoriert!")
                        delegate:nil];
    } else {
        Transport_Group *transportGroup = [Transport_Group transportGroupForItem:self.item ctx:self.ctx createWhenNotExisting:YES];
        for (Transport *tmpTransport in tmpTransports) {
            NSInteger numberOfItems = 0;
            if (!tmpTransport.occurrences) {
                numberOfItems = 1;
            } else {
                numberOfItems += [tmpTransport.occurrences integerValue];
            }
            Departure *fromDeparture = nil;
            Location *toLocation = nil;
            if (itemIsTransportGroup) {
                fromDeparture = self.transportGroupTourStop;
                toLocation = self.transportGroupTourStop.location_id;
            } else {
                fromDeparture = ((Departure *)self.item);
                toLocation = fromDeparture.location_id;
            }
            for (int i = 0; i < numberOfItems; i++) {
                NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:tmpTransport.code traceType:TraceTypeValueUnload
                                                                        fromDeparture:fromDeparture toLocation:toLocation];
                if (tmpTransport.occurrences) {
                    [currentTransport setValue:[NSNumber numberWithInt:-1]                                        forKey:@"occurrences"];
                }
                Transport *transport = [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
                [transportGroup addTransport_idObject:transport];
            }
        }
        [self.ctx saveIfHasChanges];
        [self reloadViewComponents];
        [self.view setNeedsDisplay];
    }
}

- (IBAction)transportCodesShouldBeginUnloading {
	self.navigationItem.hidesBackButton = YES;
    self.hasSignatureAsReceipt = NO;
    self.hasImageAsReceipt = NO;
    if ([self.tourTask isEqualToString:TourTaskNormalDrive] && (
        (itemIsTransportGroup &&
         (([self.transportGroupTourStop isEqual:[Departure lastTourDepartureInCtx:self.ctx]] ||
           [((Transport_Group *)self.item).addressee_id isEqual:self.transportGroupTourStop.location_id]) &&
           (![((Transport_Group *)self.item).deliveryAction unsignedIntegerValue] ||
            [((Transport_Group *)self.item).deliveryAction unsignedIntegerValue] == 3)))
         ||
        (!itemIsTransportGroup &&
         PFBrandingSupported(BrandingOerlikon, nil))
         ||
        (!itemIsTransportGroup && PFBrandingSupported(BrandingBiopartner, nil) && [(Departure *)self.item isEqual:[Departure lastTourDepartureInCtx:self.ctx]]))) {
            [[DSPF_Confirm question:NSLocalizedString(@"TITLE_122", @"Gesamte Lieferung")
                               item:@"confirmUnloadALL"
                      buttonTitleOK:NSLocalizedString(@"TITLE_027", @"Abladen")
                     buttonTitleYES:NSLocalizedString(@"TITLE_120", @"Abladen mV")
                      buttonTitleNO:NSLocalizedString(@"TITLE__018", @"Abbrechen")
                         showInView:self.view] setDelegate:self];
    } else {
        BOOL preventScanning = NO;
        if (itemIsTransportGroup &&
            [((Transport_Group *)self.item).addressee_id isEqual:self.transportGroupTourStop.location_id] &&
            [((Transport_Group *)self.item).deliveryAction unsignedIntegerValue] == 2) {
            preventScanning = YES;
        }
        NSDictionary *parameters = @{ ControllerParameterTourTask : objectOrNSNull(self.tourTask),
                                      ControllerParameterItem : objectOrNSNull(self.item),
                                      ControllerParameterPreventScanning : @(preventScanning),
                                      ControllerTransportGroupTourStop: objectOrNSNull(self.transportGroupTourStop) };
        DSPF_Unload *dspf_Unload = [[[DSPF_Unload alloc] initWithParameters:parameters] autorelease];
        [self.navigationController pushViewController:dspf_Unload animated:YES];
    }
}

- (IBAction)getSignatureForProofOfDelivery {
    DSPF_NameForSignature *dspf_NameForSignature = [[[DSPF_NameForSignature alloc] initWithNibName:@"DSPF_NameForSignature" bundle:nil] autorelease];
    if (itemIsTransportGroup) {
        dspf_NameForSignature.departure             = self.transportGroupTourStop;
        dspf_NameForSignature.currentTransportGroup = self.item;
    } else {
        dspf_NameForSignature.departure          = (Departure *)self.item;
    }
    dspf_NameForSignature.delegate               = self;
    [self.navigationController pushViewController:dspf_NameForSignature animated:YES];
}

- (BOOL)checkProofOfDelivery {
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
    {
        NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
        NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueOutOfOrders
                                                                fromDeparture:((Departure *)self.item) toLocation:((Departure *)self.item).location_id];
        if (((Departure *)self.item).transport_group_id) {
            [currentTransport setValue:((Departure *)self.item).transport_group_id.task                      forKey:@"task"];
        }
        [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
        [self.ctx saveIfHasChanges];
        return YES;
    }
    
    if (self.withReceiptRequirement && [self.tourTask isEqualToString:TourTaskNormalDrive]) {
        NSPredicate *unloaded = [Transport withTraceLogCodes:@[TraceTypeStringUnload]];
        BOOL didUnloadFromTransportGroup = itemIsTransportGroup && [[Transport withPredicate:AndPredicates([Transport withToLocation:self.transportGroupTourStop.location_id], unloaded, nil) inCtx:self.ctx] count] > 0;
        BOOL didUnloadTransports = !itemIsTransportGroup && [[Transport withPredicate:AndPredicates([Transport withToLocation:((Departure *)self.item).location_id], unloaded, nil) inCtx:self.ctx] count] > 0;
        
        if (didUnloadTransports || didUnloadFromTransportGroup) {
            if (self.withImageAsReceipt && !self.hasImageAsReceipt) {
                [self getImageForProofOfDelivery];
                return NO;
            }
            
            if (self.withSignatureAsReceipt && !self.hasSignatureAsReceipt) {
                [self getSignatureForProofOfDelivery];
                return NO;
            }
        }
    }
    self.hasImageAsReceipt		 = NO;
    self.hasSignatureAsReceipt	 = NO;
    return YES;
}

- (int)totalItemsCount {
    return [self.pallets.text intValue] + [self.rollcontainer.text intValue] + [self.units.text intValue];
}

- (IBAction)shouldLeaveTourLocation { 
    if ([self.tourTask isEqualToString:TourTaskNormalDrive]) {
        BOOL shouldShowAlertStillSomethingToLoad = NO;
        if (itemIsTransportGroup) {
            if ([Transport transportsPickCountForTourLocation:self.transportGroupTourStop.location_id.location_id
                                               transportGroup:((Transport_Group *)self.item).transport_group_id inCtx:self.ctx] > 0 &&
                ![Transport hasReasonCodesFromDeparture:self.transportGroupTourStop.departure_id
                                         transportGroup:((Transport_Group *)self.item).transport_group_id inCtx:self.ctx])
            {
                shouldShowAlertStillSomethingToLoad = YES;
            }
        } else {
            if ([Transport transportsPickCountForTourLocation:((Departure *)self.item).location_id.location_id
                                               transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                       inCtx:self.ctx] > 0 && !self.hasConfirmedIncompleteLOAD)
            {
                shouldShowAlertStillSomethingToLoad = YES;
            }
        }
        if (shouldShowAlertStillSomethingToLoad) {
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_028", @"Haltestellen-Status")
                           messageText:NSLocalizedString(@"ERROR_MESSAGE_009", @"Es soll hier noch Ware geladen werden !")
                                  item:@"confirmIncompleteLOAD"
                              delegate:self];

            return;
        }
        if ([self totalItemsCount] != 0 &&
            (
                (!itemIsTransportGroup && !self.hasConfirmedIncompleteUNLOAD && !PFTourTypeSupported(@"1XX", nil)) ||
                (!itemIsTransportGroup && ![Transport hasReasonCodesFromDeparture:((Departure *)self.item).departure_id transportGroup:nil inCtx:self.ctx] &&
                   PFTourTypeSupported(@"1XX", @"1X1", nil)) ||
                (itemIsTransportGroup && ![Transport hasReasonCodesFromDeparture:self.transportGroupTourStop.departure_id
                                                                     transportGroup:((Transport_Group *)self.item).transport_group_id inCtx:self.ctx])
             )
            )
        {
            [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_028", @"Haltestellen-Status")
                           messageText:NSLocalizedString(@"ERROR_MESSAGE_010", @"Es ist noch Ware für diese Haltestelle geladen !")
                                  item:@"confirmIncompleteUNLOAD"
                              delegate:self];
            return;
        }
        if (!itemIsTransportGroup && [Transport hasTransportCodesFromDeparture:((Departure *)self.item).departure_id transportGroup:nil inCtx:self.ctx]) {
            if ([self checkProofOfDelivery]) {
                [self didLeaveTourLocation];
            }
        } else if (itemIsTransportGroup && [Transport hasTransportCodesFromDeparture:self.transportGroupTourStop.departure_id
                                                                      transportGroup:((Transport_Group *)self.item).transport_group_id
                                                                  inCtx:self.ctx]) {
            if ([self checkProofOfDelivery]) {
                [self didLeaveTourLocation];
            }
        } else {
            if (itemIsTransportGroup && (
                 [Transport transportsPickCountForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                transportGroup:((Transport_Group *)self.item).transport_group_id
                                        inCtx:self.ctx] == 0 && [self totalItemsCount] == 0 &&
                 ![Transport hasReasonCodesFromDeparture:self.transportGroupTourStop.departure_id
                                          transportGroup:((Transport_Group *)self.item).transport_group_id inCtx:self.ctx])) {
                self.navigationItem.hidesBackButton = YES;
                DSPF_ShortDelivery *dspf_ShortDelivery   = [[[DSPF_ShortDelivery alloc] initWithNibName:@"DSPF_ShortDelivery" bundle:nil] autorelease];
                dspf_ShortDelivery.currentDeparture = self.transportGroupTourStop;
                dspf_ShortDelivery.currentTransportGroup = (Transport_Group *)self.item;
                dspf_ShortDelivery.isShortPickup = NO;
                [self.navigationController pushViewController:dspf_ShortDelivery animated:YES];
            } else if (!itemIsTransportGroup && (
                (![(Departure *)self.item isEqual:[Departure firstTourDepartureInCtx:self.ctx]] ||
                 [Transport transportsPickCountForTourLocation:((Departure *)self.item).location_id.location_id
                                                transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                        inCtx:self.ctx] > 0) &&
                (![(Departure *)self.item isEqual:[Departure lastTourDepartureInCtx:self.ctx]] || [self totalItemsCount] != 0) &&
                ![((Departure *)self.item).canceled boolValue] &&
                ([((Departure *)self.item).confirmed boolValue] ||
                 ![Tour_Exception todaysTourExceptionForLocation:((Departure *)self.item).location_id]) &&
                ![Transport hasReasonCodesFromDeparture:((Departure *)self.item).departure_id
                                         transportGroup:nil
                                 inCtx:self.ctx])) {
                    self.navigationItem.hidesBackButton = YES;
                    id currentDeparture = nil;
                    if (itemIsTransportGroup) {
                        currentDeparture = self.transportGroupTourStop;
                    } else {
                        currentDeparture = (Departure *)self.item;
                    }
                    NSDictionary *parameters = @{ DeadHeadParameterCurrentDeparture : objectOrNSNull(currentDeparture) };
                    DSPF_Deadhead *dspf_Deadhead  = [[[DSPF_Deadhead alloc] initWithParameters:parameters] autorelease];
                    dspf_Deadhead.delegate = self;
                    [self.navigationController pushViewController:dspf_Deadhead animated:YES];
            } else {
                if (!itemIsTransportGroup) {
                    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
                    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueOutOfOrders
                                                                            fromDeparture:((Departure *)self.item) toLocation:((Departure *)self.item).location_id];
                    if (((Departure *)self.item).transport_group_id) {
                        [currentTransport setValue:((Departure *)self.item).transport_group_id.task                      forKey:@"task"];
                    }
                    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
                    [self.ctx saveIfHasChanges];
                    [self didLeaveTourLocation];
                }
            }
        }
    } else { 
        if ([self.tourTask isEqualToString:TourTaskLoadingOnly]) { 
            if (((itemIsTransportGroup &&
                  [Transport transportsPickCountForTourLocation:self.transportGroupTourStop.location_id.location_id
                                                 transportGroup:((Transport_Group *)self.item).transport_group_id
                                         inCtx:self.ctx] > 0) ||
                (!itemIsTransportGroup &&
                [Transport transportsPickCountForTourLocation:[Departure firstTourDepartureInCtx:self.ctx].location_id.location_id
                                               transportGroup:((Departure *)self.item).transport_group_id.transport_group_id
                                       inCtx:self.ctx] > 0)) &&
                !self.hasConfirmedIncompleteLOAD) {
                [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_029", @"Lieferschein-Status") 
                               messageText:NSLocalizedString(@"ERROR_MESSAGE_011", @"Es soll noch Ware geladen werden !")
                                      item:@"confirmIncompleteLOAD"
                                  delegate:self];
                return;
            } 
        }
        [self didLeaveTourLocation];
    }
}

- (IBAction)showTransportGroupSummary {
    if (itemIsTransportGroup) {
        DSPF_TransportGroupSummary *dspf_TransportGroupSummary = [[[DSPF_TransportGroupSummary alloc] init] autorelease];
        dspf_TransportGroupSummary.transportGroup = self.item;
        [self.navigationController pushViewController:dspf_TransportGroupSummary animated:YES];        
    }
}


- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(NSString *)anItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if ([anItem isEqualToString:@"confirmIncompleteUNLOAD"]) {
            if (PFTourTypeSupported(@"1XX", nil) || PFBrandingSupported(BrandingCCC_Group, nil)) {
                self.navigationItem.hidesBackButton = YES;
                DSPF_ShortDelivery *dspf_ShortDelivery = [[[DSPF_ShortDelivery alloc] initWithNibName:@"DSPF_ShortDelivery" bundle:nil] autorelease];
                if (itemIsTransportGroup) {
                    dspf_ShortDelivery.currentDeparture = self.transportGroupTourStop;
                    dspf_ShortDelivery.currentTransportGroup = (Transport_Group *)self.item;
                } else {
                    dspf_ShortDelivery.currentDeparture = (Departure *)self.item;
                    dspf_ShortDelivery.delegate = self;
                }
                dspf_ShortDelivery.isShortPickup = NO;
                [self.navigationController pushViewController:dspf_ShortDelivery animated:YES];
            } else {
                self.hasConfirmedIncompleteUNLOAD = YES;
                [self shouldLeaveTourLocation];
            }
		} else if ([anItem isEqualToString:@"confirmIncompleteLOAD"]) {
            if ((PFBrandingSupported(BrandingCCC_Group, nil))) {
                self.navigationItem.hidesBackButton = YES;
                DSPF_ShortDelivery *dspf_ShortDelivery = [[[DSPF_ShortDelivery alloc] initWithNibName:@"DSPF_ShortDelivery" bundle:nil] autorelease];
                if (itemIsTransportGroup) {
                    dspf_ShortDelivery.currentDeparture = self.transportGroupTourStop;
                    dspf_ShortDelivery.currentTransportGroup = (Transport_Group *)self.item;
                } else {
                    dspf_ShortDelivery.currentDeparture = (Departure *)self.item;
                }
                dspf_ShortDelivery.isShortPickup = YES;
                [self.navigationController pushViewController:dspf_ShortDelivery animated:YES];
            } else {
                self.hasConfirmedIncompleteLOAD = YES;
                [self shouldLeaveTourLocation];
            }
		} else if ([anItem isEqualToString:@"confirmShortPickup"]) {
            self.navigationItem.hidesBackButton = YES;
            DSPF_ShortDelivery *dspf_ShortDelivery   = [[[DSPF_ShortDelivery alloc] initWithNibName:@"DSPF_ShortDelivery" bundle:nil] autorelease];
            dspf_ShortDelivery.currentDeparture = self.transportGroupTourStop;
            dspf_ShortDelivery.currentTransportGroup = (Transport_Group *)self.item;
            dspf_ShortDelivery.isShortPickup = NO;
            [self.navigationController pushViewController:dspf_ShortDelivery animated:YES];
        } else if ([anItem isEqualToString:@"unloadWarning"]) {
            // do nothing
        }
	}
}

- (IBAction)getImageForProofOfDelivery {
    return [self getImageForProofOfDelivery:nil];
}

- (IBAction)getImageForProofOfDelivery:(NSDictionary *)parameters {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_030", @"Kamera einschalten") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
        [DPHUtilities waitForAlertToShow:0.236f];
        self.dspf_ImagePicker = [[[DSPF_ImagePicker alloc] initWithParameters:parameters] autorelease];
        self.dspf_ImagePicker.pickerDelegate = self;
		[self presentModalViewController:self.dspf_ImagePicker animated:YES];
        [showActivity closeActivityInfo];
		[showActivity release];
	} else {
		self.hasImageAsReceipt = YES;
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
    NSString *receiptText = [descriptionText length] > 0 ? descriptionText : @"LOCATIONPHOTO";
    // LOCATIONPHOTO
    Departure *fromDeparture = nil;
    if (itemIsTransportGroup) {
        fromDeparture = self.transportGroupTourStop;
    } else {
        fromDeparture = ((Departure *)self.item);
    }
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueLocationPhoto
                                                            fromDeparture:fromDeparture toLocation:fromDeparture.location_id];
    
    [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
    [currentTransport setValue:receiptText                                                               forKey:@"receipt_text"];
    if (itemIsTransportGroup) {
        [currentTransport setValue:((Transport_Group *)self.item).task                                   forKey:@"task"];
    } else {
        if (((Departure *)self.item).transport_group_id) {
            [currentTransport setValue:((Departure *)self.item).transport_group_id.task                  forKey:@"task"];
        }
    }
    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
    [self.ctx saveIfHasChanges];
    [showActivity closeActivityInfo];
    [showActivity release];
	self.hasImageAsReceipt = YES;   
}

- (void)didFinishWithoutPhoto {
    [self dismissModalViewControllerAnimated:YES];
	self.hasImageAsReceipt = NO;   
}

#pragma mark - Signature drawing delegate

- (void) dspf_SignatureForName:(DSPF_SignatureForName *)sender didReturnSignature:(UIImage *)aSignature forName:(NSString *)aName { 
    DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_032", @"Unterschrift speichern") messageText:NSLocalizedString(@"MESSAGE_002", @"Bitte warten.") delegate:self] retain];
    [DPHUtilities waitForAlertToShow:0.236f];
    // Pfad bzw. Daten und Namen fürs Speichern vorbereiten
//  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSData   *screenShot_PNG;
//  NSString *screenShot_PNG_name;
    // UIImage als PNG konvertieren und im Dokumentenverzeichnis speichern 
    screenShot_PNG      = UIImagePNGRepresentation(aSignature);
//  screenShot_PNG_name = [NSString stringWithFormat:@"%@.png", @"ScreenShot"];
//  [screenShot_PNG writeToFile:[documentsDirectory stringByAppendingPathComponent:screenShot_PNG_name] atomically:YES];
    // DELIVERYSIGNATURE
    Departure *fromDeparture = nil;
    if (itemIsTransportGroup) {
        fromDeparture = self.transportGroupTourStop;
    } else {
        fromDeparture = ((Departure *)self.item);
    }
    NSString *code = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:code traceType:TraceTypeValueDeliverySignature
                                                            fromDeparture:fromDeparture toLocation:fromDeparture.location_id];
    [currentTransport setValue:screenShot_PNG                                                            forKey:@"receipt_data"];
    [currentTransport setValue:aName                                                                     forKey:@"receipt_text"];
    if (itemIsTransportGroup) {
        [currentTransport setValue:((Transport_Group *)self.item).task                                   forKey:@"task"];
    } else {
        if (((Departure *)self.item).transport_group_id) {
            [currentTransport setValue:((Departure *)self.item).transport_group_id.task                  forKey:@"task"];
        }
    }
    [Transport transportWithDictionaryData:currentTransport inCtx:self.ctx];
    [self.ctx saveIfHasChanges];
    [showActivity closeActivityInfo];
    [showActivity release];
	self.hasSignatureAsReceipt = YES;
}

#pragma mark - Payment delegate

- (void)dspf_Payment:(DSPF_Payment *)sender didReturnPayment:(BOOL )completed forTransportCode:(NSString *)transportCode {
    [self dismissDeliveryPayment];
    if (!completed) {
        [self.navigationController popViewControllerAnimated:YES];
        [DSPF_Error messageTitle:NSLocalizedString(@"TITLE_033", @"Bezahlung") 
                     messageText:NSLocalizedString(@"ERROR_MESSAGE_012", @"Der Kassiervorgang ist noch nicht abgeschlossen. Die Ware muss im Fahrzeug bleiben!") delegate:nil];
    }
}

#pragma mark - DSPF_Confirm delegate

- (void) dspf_Confirm:(DSPF_Confirm *)sender didConfirmQuestion:(NSString *)question item:(NSObject *)aItem withButtonTitle:(NSString *)buttonTitle {
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE__018", @"Abbrechen")]) {
        if ([(NSString *)aItem isEqualToString:@"confirmLoadALL"]) {
            if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_119", @"Laden mV")]) {
                [self loadALL];
                self.navigationItem.hidesBackButton = YES;
                DSPF_ShortDelivery *dspf_ShortDelivery   = [[[DSPF_ShortDelivery alloc] initWithNibName:@"DSPF_ShortDelivery" bundle:nil] autorelease];
                dspf_ShortDelivery.currentDeparture = self.transportGroupTourStop;
                dspf_ShortDelivery.currentTransportGroup = (Transport_Group *)self.item;
                dspf_ShortDelivery.isShortPickup = YES;
                [self.navigationController pushViewController:dspf_ShortDelivery animated:YES];
            } else if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_008", @"Laden")])
                [self loadALL];
		} else if ([(NSString *)aItem isEqualToString:@"confirmUnloadALL"]) {
            NSString *tmpInfoText = ((Transport_Group *)self.item).info_text;
            if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_120", @"Abaden mV")]) {
                [self unloadALL];
                if (itemIsTransportGroup && tmpInfoText.length > 1 && [[tmpInfoText substringToIndex:1] isEqualToString:@"⚠"]) {
                    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_029", @"Lieferschein-Status")
                                   messageText:tmpInfoText
                                          item:@"confirmShortPickup"
                                      delegate:self];
                } else {
                    self.navigationItem.hidesBackButton = YES;
                    DSPF_ShortDelivery *dspf_ShortDelivery   = [[[DSPF_ShortDelivery alloc] initWithNibName:@"DSPF_ShortDelivery" bundle:nil] autorelease];
                    dspf_ShortDelivery.currentDeparture = self.transportGroupTourStop;
                    dspf_ShortDelivery.currentTransportGroup = (Transport_Group *)self.item;
                    dspf_ShortDelivery.isShortPickup = NO;
                    [self.navigationController pushViewController:dspf_ShortDelivery animated:YES];
                }
            } else if ([buttonTitle isEqualToString:NSLocalizedString(@"TITLE_027", @"Abladen")]){
                [self unloadALL];
                if (itemIsTransportGroup && tmpInfoText.length > 1 && [[tmpInfoText substringToIndex:1] isEqualToString:@"⚠"]) {
                    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_029", @"Lieferschein-Status")
                                   messageText:tmpInfoText
                                          item:@"unloadWarning"
                                      delegate:self];
                }
            }
		}
	}
}

- (void) deadheadDidDismiss
{
    if (PFBrandingSupported(BrandingTechnopark, nil))
        [self didLeaveTourLocation];
}

- (void)viewDidUnload {
    [super viewDidUnload];


    self.departureLabel              = nil;
    self.departureTime               = nil;
    self.palettenLabel               = nil;
    self.rollcontainerLabel          = nil;
    self.paketeLabel                 = nil;
	self.departureExtension          = nil;
	self.streetAddress               = nil;
	self.zipCode                     = nil;
	self.city                        = nil;
    self.price                       = nil;
    self.pallets_tourTask            = nil;
	self.pallets                     = nil;
    self.rollcontainer_tourTask      = nil;
    self.rollcontainer               = nil;
    self.units_tourTask              = nil;
	self.units                       = nil;
    self.transportGroupSummaryButton = nil;
    self.button_UNLOAD               = nil;
    self.button_LOAD                 = nil;
    self.button_PROOF                = nil;
    self.button_FINISH               = nil;
}


- (void)dealloc { 
	[dspf_ImagePicker                release];
	[ctx            release];
    [departureExtension              release];
    [departureTime                   release];
	[departureLabel                  release];
    [palettenLabel                   release];
    [rollcontainerLabel              release];
    [paketeLabel                     release];
	[streetAddress                   release];
	[zipCode                         release];
	[city                            release];
    [price                           release];
    [pallets_tourTask                release];
	[pallets                         release];
    [rollcontainer_tourTask          release];
    [rollcontainer                   release];
	[units_tourTask                  release];
    [units                           release];
    [transportGroupSummaryButton     release];
    [button_UNLOAD                   release];
    [button_LOAD                     release];
    [button_PROOF                    release];
    [button_FINISH                   release];
    [tourTask                        release];
    [transportGroupTourStop          release];
    [item                            release];
    [_technoparkTableView release];
    [super dealloc];
}


@end
