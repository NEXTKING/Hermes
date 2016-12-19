//
//  DSPF_LocationInfo.m
//  Hermes
//
//  Created by Lutz on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_LocationInfo.h"
#import "DSPF_Suspend.h"
#import "DSPF_Activity.h"

#import "Transport_Group.h"
#import "Transport.h"
#import <AddressBook/ABPerson.h>

@implementation DSPF_LocationInfo

@synthesize departure;
@synthesize location;
@synthesize tourTask;
@synthesize svr_LocationManager;
@synthesize paletteAbzuladenLabel;
@synthesize paketeAbzuladenLabel;
@synthesize nachnahmeBetragLabel;
@synthesize kontaktLabel;
@synthesize contactName;
@synthesize streetAddress;
@synthesize zipCode;
@synthesize city;
@synthesize pallets;
@synthesize units;
@synthesize paymentOnDelivery;
@synthesize infoText;
@synthesize contactPhone;
@synthesize contactSMS;
@synthesize contactEmail;
@synthesize button_PHONE;
@synthesize button_SMS;
@synthesize button_MAIL;
@synthesize button_NAVIGON;
@synthesize buttonView;
@synthesize buttonSelection;
@synthesize buttonPage;
@synthesize currencyFormatter;
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


#pragma mark - View lifecycle


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		UITapGestureRecognizer *tapToSuspend = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suspend)] autorelease];
		[tapToSuspend setNumberOfTapsRequired:2];
		[tapToSuspend setNumberOfTouchesRequired:2];
		[self.view	  addGestureRecognizer:tapToSuspend];
        self.buttonSelection.contentSize = self.buttonView.frame.size;
        self.buttonSelection.delegate    = self;
        self.buttonPage.numberOfPages = (self.buttonView.frame.size.width / self.buttonSelection.bounds.size.width);
        self.buttonPage.currentPage = 0;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)suspend {
	[DSPF_Suspend suspendWithDefaultsOnViewController:self]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.svr_LocationManager = [[[SVR_LocationManager alloc] init] autorelease];
    UIBarButtonItem *tourLocationForDepartureButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageWithContentsOfFile:
                                                                                               [[NSBundle mainBundle] pathForResource:@"terminate_white"
                                                                                                                               ofType:@"png"]]
                                                                                        style:UIBarButtonItemStyleBordered
                                                                                       target:self
                                                                                       action:@selector(shouldSelectTourLocationForDeparture)] autorelease];
    if ([NSUserDefaults isRunningWithBoxWithArticle]) {
        self.paletteAbzuladenLabel.text = NSLocalizedString(@"TITLE_104", @"Labor abzuladen");
    } else if (PFBrandingSupported(BrandingBiopartner, nil)) {
        self.paletteAbzuladenLabel.text = NSLocalizedString(@"TITLE_112", @"Ladehilfsmittel abzuladen");
        self.units.center = self.pallets.center;
        self.pallets.hidden = YES;
    } else if (PFBrandingSupported(BrandingCCC_Group, nil)) {
        self.paletteAbzuladenLabel.hidden = YES;
        self.paketeAbzuladenLabel.hidden = YES;
        self.pallets.hidden = YES;
        self.units.hidden = YES;
        tourLocationForDepartureButton = nil;
    } else {
        self.paletteAbzuladenLabel.text = NSLocalizedString(@"TITLE_090", @"Paletten abzuladen");
    }
    self.paketeAbzuladenLabel.text  = NSLocalizedString(@"TITLE_091", @"Pakete abzuladen");
    self.nachnahmeBetragLabel.text  = NSLocalizedString(@"TITLE_092", @"Nachnahmebetrag");
    
    if (PFBrandingSupported(BrandingUnilabs, nil)){
        self.paletteAbzuladenLabel.text = NSLocalizedString(@"TITLE_127", @"Transport bag");
        self.paketeAbzuladenLabel.text = NSLocalizedString(@"TITLE_128", @"Specimen bag");
    }
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.streetAddress.frame = CGRectMake(self.streetAddress.frame.origin.x,
                                              self.streetAddress.frame.origin.y,
                                              self.streetAddress.frame.size.width,
                                              self.city.frame.origin.y - self.streetAddress.frame.origin.y +
                                              self.city.frame.size.height);
        self.streetAddress.numberOfLines = 3;
        self.streetAddress.lineBreakMode = UILineBreakModeWordWrap;
        [self.streetAddress setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
        self.streetAddress.minimumFontSize = 8.0;
        self.streetAddress.textAlignment   = UITextAlignmentCenter;
        self.city.frame         = CGRectZero;
        self.zipCode.frame      = CGRectZero;
        self.kontaktLabel.text  = NSLocalizedString(@"TITLE_103", @"Umfrage");
    } else {
        self.kontaktLabel.text  = NSLocalizedString(@"TITLE_093", @"Kontakt");
    }
    [self.button_PHONE setTitle:NSLocalizedString(@"TITLE_094", @"Anruf") forState:UIControlStateNormal];
    [self.button_SMS   setTitle:NSLocalizedString(@"TITLE_095", @"SMS")   forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = tourLocationForDepartureButton;
}

- (void)viewWillAppear:(BOOL)animated { 
    [super viewWillAppear:animated];
    self.contactName.text       = self.location.contact_name;
    if (PFBrandingSupported(BrandingViollier, nil)) {
        self.streetAddress.text = self.location.location_name;
    } else {
        self.city.text          = self.location.city;
        self.zipCode.text       = self.location.zip;
        self.streetAddress.text = self.location.street;
    }
    self.pallets.text           = [NSString stringWithFormat:@"%i", [Transport transportsPalletCountForTourLocation:self.location.location_id
                                                                                                     transportGroup:self.departure.transport_group_id.transport_group_id
                                                                                             inCtx:self.ctx]];
	self.units.text             = [NSString stringWithFormat:@"%i", [Transport transportsUnitCountForTourLocation:self.location.location_id
                                                                                                   transportGroup:self.departure.transport_group_id.transport_group_id
                                                                                           inCtx:self.ctx]];
    if ([[Transport transportsPriceForTourLocation:self.location.location_id 
                                    transportGroup:self.departure.transport_group_id.transport_group_id
                            inCtx:self.ctx] floatValue] == 0.00) { 
        self.nachnahmeBetragLabel.text = @"";
        self.paymentOnDelivery.text    = @"";
    } else {
        self.paymentOnDelivery.text = [self.currencyFormatter stringFromNumber:[Transport transportsPriceForTourLocation:self.location.location_id
                                                                                                          transportGroup:self.departure.transport_group_id.transport_group_id
                                                                                                  inCtx:self.ctx]]; 
    }
    if (PFBrandingSupported(BrandingBiopartner, nil)) {
        BOOL demoMode = PFCurrentModeIsDemo();
        NSMutableString *infoSigns = [NSMutableString string];
        [infoSigns appendString:@""];
        for (NSString *sign in [Transport allInfoSigns]) {
            if (demoMode || [Transport hasStagingInfo:sign toLocation:self.departure.location_id.location_id
                                       transportGroup:self.departure.transport_group_id.transport_group_id
                                                inCtx:self.departure.managedObjectContext]){
                [infoSigns appendString:sign];
            }
        }
        self.paketeAbzuladenLabel.text = infoSigns;
    }
    // infoText per delivery
    NSMutableString *allInfos   = [[[NSMutableString alloc] init] autorelease];
    if (PFTourTypeSupported(@"0X1", @"1X1", nil)) {
        if ([self.location.location_code length] > 0) {
            [allInfos appendFormat:@"👤 %@", self.location.location_code];
        }
        if ([self.departure.infoText length] > 0) {
            if (allInfos.length > 0) {
                [allInfos appendFormat:@"\n"];
            }
            [allInfos appendFormat:@"🏁 %@", self.departure.infoText];
        }
        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            NSArray *transportGroupAddresseeSortDescriptors = [NSArray arrayWithObjects:
                                                               [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_name" ascending:YES],
                                                               [NSSortDescriptor sortDescriptorWithKey:@"sender_id.zip" ascending:YES],
                                                               [NSSortDescriptor sortDescriptorWithKey:@"sender_id.city" ascending:YES],
                                                               [NSSortDescriptor sortDescriptorWithKey:@"sender_id.location_id" ascending:YES], nil];
            NSArray *groupSenderSortDescriptors = [NSArray arrayWithObjects:
                                                   [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_name" ascending:YES],
                                                   [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.zip" ascending:YES],
                                                   [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.city" ascending:YES],
                                                   [NSSortDescriptor sortDescriptorWithKey:@"addressee_id.location_id" ascending:YES], nil];
            NSArray *transportGroupAdressees = [[[self.departure.location_id.transport_group_addressee_id allObjects]
                                                filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:
                                                                             @"(0 != SUBQUERY(transport_id, $t, "
                                                                             "($t.trace_type_id.code = %@ || $t.trace_type_id.code = %@) && "
                                                                             "($t.item_id = nil OR $t.item_id.itemCategoryCode = \"2\")).@count)", @"LOAD", @"UNLOAD"]]
                                                sortedArrayUsingDescriptors:transportGroupAddresseeSortDescriptors];
            NSArray *transportGroupSenders = [[[self.departure.location_id.transport_group_sender_id allObjects]
                                               filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"transport_id.@count != 0"]]
                                              sortedArrayUsingDescriptors:groupSenderSortDescriptors];

            NSMutableString *pickupInfos = [[[NSMutableString alloc] init] autorelease];
            NSMutableString *deliveryInfos = [[[NSMutableString alloc] init] autorelease];
            for (Transport_Group *transportGroupWithInfoText in [transportGroupAdressees arrayByAddingObjectsFromArray:transportGroupSenders]) {
                if (transportGroupWithInfoText.pickUpInfoText.length > 0 && [transportGroupWithInfoText.sender_id.location_id isEqualToNumber:self.location.location_id]) {
                    [pickupInfos appendFormat:@"⬆ %@\t\n", transportGroupWithInfoText.task];
                    [pickupInfos appendFormat:@"%@\n", transportGroupWithInfoText.pickUpInfoText];
                }
                if (transportGroupWithInfoText.deliveryInfoText.length > 0 && [transportGroupWithInfoText.addressee_id.location_id isEqualToNumber:self.location.location_id]) {
                    [deliveryInfos appendFormat:@"⬇ %@\t\n", transportGroupWithInfoText.task];
                    [deliveryInfos appendFormat:@"%@\n", transportGroupWithInfoText.deliveryInfoText];
                }
            }
            if ([allInfos length] > 0 && (pickupInfos.length > 0 || deliveryInfos.length > 0)) {
                [allInfos appendString:@"\n"];
            }
            if ([pickupInfos length] > 0) {
                [allInfos appendString:pickupInfos];
            }
            NSString *pickupDeliveryTextsSeparator = @"";
            if ([pickupInfos length] > 0 && [deliveryInfos length] > 0) {
                pickupDeliveryTextsSeparator = @"\n\n";
            }
            if ([deliveryInfos length] > 0) {
                [allInfos appendFormat:@"%@%@", pickupDeliveryTextsSeparator, deliveryInfos];
            }
        }
    } else {
        //  [allInfos appendFormat:@"\tTest-Lieferung: %@\t\n", @"0815/4711"];
        //  [allInfos appendFormat:@"%@\n", @"Hallo"];
        for (Transport_Group *transportGroupWithInfoText in [NSArray arrayWithArray:[[NSSet setWithArray:
                                                [[Transport transportsWithPredicate:[NSPredicate predicateWithFormat:
                                                 @"transport_group_id != nil && "
                                                  "to_location_id.location_id = %lld && "
                                                  "(trace_type_id.code = %@ OR trace_type_id.code = %@) && "
                                                  "transport_group_id.info_text != nil && "
                                                  "transport_group_id.info_text != %@",
                                                  [self.location.location_id longLongValue], @"LOAD", @"UNLOAD", @""]
                                                                    sortDescriptors:nil inCtx:self.ctx]
                                                 valueForKeyPath:@"transport_group_id"]] allObjects]]) {
            [allInfos appendFormat:@"\tLieferung: %@\t\n", transportGroupWithInfoText.task];
            [allInfos appendFormat:@"%@\n", transportGroupWithInfoText.info_text];
        }
    }
    self.infoText.text          = allInfos;
    NSInteger buttonCount   = 4;
    if (!self.location.contact_phone || self.location.contact_phone.length == 0) {
        self.button_PHONE.enabled   = NO;
        self.button_MAIL.center     = self.button_PHONE.center;
        [self.button_PHONE removeFromSuperview];
        buttonCount--;
        self.button_SMS.enabled     = NO;
        self.button_NAVIGON.center  = self.button_SMS.center;
        [self.button_SMS removeFromSuperview];
        buttonCount--;
    } else {
        if (PFBrandingSupported(BrandingCCC_Group, nil)) {
            [self.button_PHONE setTitle:self.location.contact_phone forState:UIControlStateNormal];
            self.contactPhone.text = @"";
        } else {
            self.contactPhone.text = self.location.contact_phone;
        }
        if (PFBrandingSupported(BrandingOerlikon, nil) ||
            PFBrandingSupported(BrandingCCC_Group, BrandingOerlikon, nil)) {
            self.button_SMS.enabled     = NO;
            self.button_NAVIGON.center  = self.button_SMS.center;
            [self.button_SMS removeFromSuperview];
            buttonCount--;
        } else {
            self.contactSMS.text    = self.location.contact_phone;
        }
    }
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"navigon://anyAddress"]]]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tomtomhome://anyAddress"]]]) {
            if (![[self.button_NAVIGON imageForState:UIControlStateNormal] isEqual:[UIImage imageNamed:@"tomtom.png"]]) {
                [self.button_NAVIGON removeTarget:self action:@selector(switchToNavigon) forControlEvents:UIControlEventTouchUpInside];
                [self.button_NAVIGON addTarget:self    action:@selector(switchToTomtom)  forControlEvents:UIControlEventTouchUpInside];
                [self.button_NAVIGON setImage:[UIImage imageNamed:@"tomtom.png"] forState:UIControlStateNormal];
            }
        } else {
            self.button_NAVIGON.enabled = NO;
            self.button_MAIL.center     = self.button_NAVIGON.center;
            [self.button_NAVIGON removeFromSuperview];
            buttonCount--;
        }
    }
    if (!self.location.contact_email || self.location.contact_email.length == 0) {
        self.button_MAIL.enabled    = NO;
        [self.button_MAIL removeFromSuperview];
        buttonCount--;
    } else {
        if (PFBrandingSupported(BrandingCCC_Group, BrandingOerlikon, nil)) {
            self.button_MAIL.enabled    = NO;
            [self.button_MAIL removeFromSuperview];
            buttonCount--;
        } else {
            self.contactEmail.text  = self.location.contact_email;
        }
    }
    if (buttonCount > 2) {
        self.buttonSelection.scrollEnabled = YES;
        [self.buttonSelection flashScrollIndicators];
    } else {
        self.buttonSelection.scrollEnabled = NO;
    }
}

- (IBAction)switchToPhone {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",
                                                [self.location.contact_phone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
}

- (IBAction)switchToSMS { 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", 
                                                [self.location.contact_phone stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
}

- (IBAction)switchToMail { 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@%@", 
                                                                     self.location.contact_email,
                                                                     [[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_Branding"],
                                                                     @"-Hermes-Client"]]];
}

- (IBAction)switchToNavigon { 
    if (YES) { 
        //           @"navigon://route/Hermes-Route/?target=coordinate/Zwischenhalt/8.4581184/47.4536038&target=coordinate/%@/%@/%@",
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"navigon://coordinate/%@/%@/%@", 
                                                                         self.location.location_name, [self.location.longitude stringValue], 
                                                                          [self.location.latitude stringValue]] 
                                                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"navigon://address/%@/%@/%@/%@/%@",
                                                                          self.location.location_name, self.location.country_code,
                                                                          self.location.zip, self.location.city, self.location.street]
                                                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
}

- (IBAction)switchToTomtom {
    NSString *tomTomFormat = @"tomtomhome:geo:action=navigateto&lat=%@&long=%@&name=%@";
    if ([self.location.latitude  floatValue] != 0.000000 && [self.location.longitude floatValue] != 0.000000) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSString stringWithFormat:tomTomFormat,
                                                                          [self.location.latitude stringValue], [self.location.longitude stringValue],
                                                                          self.location.location_name]
                                                                         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    } else {
        DSPF_Activity *showActivity = [DSPF_Activity messageTitle:@" " messageText:NSLocalizedString(@"MESSAGE__004", @"Bitte warten.") delegate:self];
        [DPHUtilities waitForAlertToShow:0.236f];
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        NSMutableDictionary *geocode = [NSMutableDictionary dictionary];
        if (self.location.city.length > 0)         [geocode setValue:self.location.city         forKey:(NSString *)kABPersonAddressCityKey];
        if (self.location.street.length > 0)       [geocode setValue:self.location.street       forKey:(NSString *)kABPersonAddressStreetKey];
        if (self.location.zip.length > 0)          [geocode setValue:self.location.zip          forKey:(NSString *)kABPersonAddressZIPKey];
        if (self.location.country_code.length > 0) [geocode setValue:self.location.country_code forKey:(NSString *)kABPersonAddressCountryCodeKey];
        if (self.location.state.length > 0)        [geocode setValue:self.location.state        forKey:(NSString *)kABPersonAddressStateKey];
        [geocoder geocodeAddressDictionary:geocode completionHandler:^(NSArray *placemarks, NSError *error) {
            [showActivity closeActivityInfo];
            CLPlacemark *placemark = [placemarks lastObject];
            if (placemark) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:
                                                            [[NSString stringWithFormat:tomTomFormat,
                                                              [[NSNumber numberWithDouble:placemark.location.coordinate.latitude] stringValue],
                                                              [[NSNumber numberWithDouble:placemark.location.coordinate.longitude] stringValue],
                                                              self.location.location_name]
                                                             stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            }
         }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.buttonSelection]) {
        self.buttonPage.currentPage = self.buttonSelection.contentOffset.x / self.buttonSelection.bounds.size.width;
    }
}

- (void)didSelectTourLocationForDeparture {
	DSPF_TourLocation *dspf_TourLocation	= [[[DSPF_TourLocation alloc] initWithNibName:@"DSPF_TourLocation" bundle:nil] autorelease];
	dspf_TourLocation.item                  = self.departure;
    dspf_TourLocation.tourTask              = self.tourTask;
	dspf_TourLocation.delegate				= self;
	[self.navigationController pushViewController:dspf_TourLocation animated:YES];
}

- (void)shouldSelectTourLocationForDeparture {
    double latitude = [self.departure.location_id.latitude doubleValue];
    double longitude = [self.departure.location_id.longitude doubleValue];
	if (self.svr_LocationManager.isRunning && [self.tourTask isEqualToString:TourTaskNormalDrive] && !(latitude  == 0.000000 && longitude == 0.000000)) {
            CLLocation *selectedLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            CLLocationDistance distance	 = [selectedLocation distanceFromLocation:self.svr_LocationManager.rcvLocation];
            [selectedLocation release]; 
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withDistanceCheck"] intValue] > 0) {
                if (distance > [[[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_SYSVAL_RUN_withDistanceCheck"] doubleValue]) {
                    [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_025", @"GPS-Koordinaten") 
                                   messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_008", @"%@\n%@\n%@ %@\n\nEntfernung: %4.3f km !"), 
                                                self.departure.location_id.location_name, 
                                                self.departure.location_id.street, 
                                                self.departure.location_id.zip, 
                                                self.departure.location_id.city,
                                                (distance / 1000)]
                                          item:self.departure
                                      delegate:self];
                    return;
                }
            }
        }
	[self didSelectTourLocationForDeparture];
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex { 
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) { 
        if ([item isKindOfClass:[Departure class]]) { 
            [self didSelectTourLocationForDeparture];
        } else if ([item isKindOfClass:[NSString class]]) {
            if ([item isEqualToString:@"NO DATA FOUND"]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
	}
}

- (void) dspf_TourLocation:(DSPF_TourLocation *)sender didFinishTourForItem:(id )aDeparture { 
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate dspf_LocationInfo:self didFinishTourForItem:aDeparture];
}



- (void)viewDidUnload {
    [super viewDidUnload];

    self.kontaktLabel           = nil;
    self.nachnahmeBetragLabel   = nil;
    self.paketeAbzuladenLabel   = nil;
    self.paletteAbzuladenLabel  = nil;
    self.contactName            = nil;
	self.streetAddress          = nil;
	self.zipCode                = nil;
	self.city                   = nil;
	self.pallets                = nil;
	self.units                  = nil;
    self.paymentOnDelivery      = nil;
    self.infoText               = nil;
    self.contactPhone           = nil;
    self.contactSMS             = nil;
    self.contactEmail           = nil;
    self.button_NAVIGON         = nil;
    self.button_PHONE           = nil;
    self.button_SMS             = nil;
    self.button_MAIL            = nil;
    self.buttonView             = nil;
    self.buttonPage             = nil;
    self.buttonSelection        = nil;
}


- (void)dealloc {
	[ctx   release];
    [currencyFormatter      release];
    [kontaktLabel           release];	
    [nachnahmeBetragLabel   release];    
    [paketeAbzuladenLabel   release];    
    [paletteAbzuladenLabel  release];    
    [streetAddress          release];
	[zipCode                release];
	[city                   release];
	[pallets                release];
	[units                  release];
    [paymentOnDelivery      release];
    [infoText               release];
    [contactEmail           release];
    [contactPhone           release];
    [contactSMS             release];
    [contactName            release];
    [svr_LocationManager    release];
    [tourTask               release];
    [location               release];
    [departure              release];
    [button_NAVIGON         release];
	[button_PHONE           release];
    [button_SMS             release];
    [button_MAIL            release];
    [buttonView             release];
    [buttonPage             release];
    [buttonSelection        release];
    [super dealloc];
}


@end
