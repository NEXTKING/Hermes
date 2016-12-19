//
//  DSPF_Login.m
//  Hermes
//
//  Created by Lutz  Thalmann on 03.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HermesAppDelegate.h"
#import "DSPF_Error.h"
#import "DSPF_Login.h"
#import "DSPF_SelectTruck.h"
#import "DSPF_SelectTour.h"
#import "DSPF_Menu.h"
#import "DSPF_Synchronisation.h"
#import "DSPF_Activity.h"
#import "DSPF_Workspace.h"
#import "DSPF_Finish.h"

#import "User.h"
#import "Departure.h"

static NSString * const Login_DataUpdateBeforeTruckSelectionKey = @"Login_DataUpdateBeforeTruckSelectionKey";

@interface DSPF_Login()
@property (nonatomic, assign) BOOL isDriver;
@property (nonatomic, assign) BOOL isLoginByScanAllowed;
@property (nonatomic, retain) User *currentUser;
@property (nonatomic, retain) NSManagedObjectContext *ctx;
@property (nonatomic, retain) NSString *udid;
@end

@implementation DSPF_Login
@synthesize logonView;
@synthesize useEitherGermanOrEnglishLabel;
@synthesize infoView;
@synthesize flagView;
@synthesize languageSupportLabel;
@synthesize versionView;
@synthesize copyrightView;
@synthesize usrprf;
@synthesize password;
@synthesize brandingImageView;
@synthesize currentUser;
@synthesize isDriver;
@synthesize ctx;
@synthesize udid;
@synthesize truckImageView;
@synthesize flippedTruckImageView;
@synthesize truckInfoImageView;
@synthesize flippedTruckInfoImageView;
@synthesize fullTruckImageView;

- (NSManagedObjectContext *)ctx {
    if (!ctx) { 
		ctx = [[(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx] retain]; 
    }
    return ctx;
}

- (NSString *)udid {
    if (!udid) { 
        udid = [PFDeviceId() retain];
    }
    return udid;
}

- (NSArray *)serverDataForKey:(NSString *)aKey {
    NSArray  *serverData = nil;
    NSError  *error      = nil;
    NSHTTPURLResponse    *response;
    NSData               *tmpData;
    //@"http://zhsrv-dev64.zh.dph.local:100/evoweb/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    //@"https://zhsrv-dev64.zh.dph.local/eta/webmethod/download/location_group?returnType=xmlplist&zipped=true&sn=%@", self.udid]]]
    NSString *serverURL = [[DSPF_Synchronisation hermesServerURL] stringByAppendingFormat:@"/download/%@?returnType=xmlplist&zipped=true&sn=%@", aKey, PFDeviceId()];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:240];
    [request setHTTPMethod:@"GET"];
    if ((PFTourTypeSupported(@"1XX", nil)  && [NSUserDefaults isRunningWithTourAdjustment] && [aKey isEqualToString:@"transport"]) ||
        (PFTourTypeSupported(@"1XX", nil)  && [aKey isEqualToString:@"cargo"]) ||
        (PFTourTypeSupported(@"1XX", nil)  && [aKey isEqualToString:@"schedule"])) {
        if ([[NSUserDefaults currentTourId] longLongValue] != 0 &&
            [[NSUserDefaults currentTruckId] longLongValue] != 0)
        {
            serverURL = [serverURL stringByAppendingFormat:@"%@&tvid=%@&trid=%@", serverURL, [NSUserDefaults currentTourId], [NSUserDefaults currentTruckId]];
        }
    }
    [request setURL:[NSURL URLWithString:serverURL]];
    if ([NSURLConnection canHandleRequest:request]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        tmpData  = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (!error) {
            serverData = [DSPF_Synchronisation arrayFromDownloadedServerData:tmpData downloadingKey:aKey];
        }
    }
    return serverData;
}

- (void)syncTOUR {
	DSPF_Activity *showActivity = [[DSPF_Activity messageTitle:NSLocalizedString(@"TITLE_003", @"Datenübertragung")
                                                   messageText:NSLocalizedString(@"MESSAGE_012", @"Bitte warten Sie bis alle Daten geladen wurden.")
                                             cancelButtonTitle:NSLocalizedString(@"TITLE_004", @"Abbrechen")  
                                                      delegate:self] retain];
    NSArray *tmpToursArray      = [self serverDataForKey:@"tour"];
    if (tmpToursArray && tmpToursArray.count != 0) {
        for (NSDictionary *serverData in tmpToursArray) {
            [Tour fromServerData:serverData inCtx:self.ctx];
        }
        [SVR_SyncDataManager saveLastSyncedTimeStamp:[NSDate date] forClass:Tour.class];
        [self.ctx saveIfHasChanges];
    }
    [showActivity closeActivityInfo];
    [showActivity release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"DPH Hermes";
        
        _isLoginByScanAllowed = [[NSUserDefaults branding] isEqualToString:BrandingTechnopark];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.usrprf.text		= nil;
	self.usrprf.textColor	= [UIColor blackColor];
	self.usrprf.font		= [UIFont fontWithName:@"Helvetica" size:14];
    self.usrprf.placeholder = NSLocalizedString(@"PLACEHOLDER_001", @"username");
	self.password.text		= nil;
	self.password.textColor	= [UIColor blackColor];
	self.password.font		= [UIFont fontWithName:@"Helvetica" size:14];
    self.password.placeholder = NSLocalizedString(@"PLACEHOLDER_002", @"passwort");
    self.isDriver			= NO;
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReturnBarcode:)
                                                     name:@"barcodeData" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_102", @"Software-Aktualisierung")
                       messageText:[NSString stringWithFormat:NSLocalizedString(@"MESSAGE_039",
                                                                                @"Es ist eine neue Version verfügbar.\n\nJetzt aktualisieren ?")]
                              item:@"selfDistribution"
                          delegate:self cancelButtonTitle:NSLocalizedString(@"TITLE_064", @"NEIN") otherButtonTitle:NSLocalizedString(@"TITLE_065", @"JA")];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncALLdone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"barcodeData" object:nil];
    [super viewWillDisappear:animated];
}

- (BOOL) hidesBottomBarWhenPushed
{
    return YES;
}

-(void)syncALLdone {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncALLdone" object:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:[[[DSPF_SelectTruck alloc] init] autorelease] animated:YES];
    });
}

/*!
 Sets branding, depending on the username and password.
 E.g.: user types "adm_HERMES" as user name and "branding_ETA" as password,
 then app switches to ETA branding.
 */

- (void) loginPressed {
    if (self.usrprf.text.length > 0 && self.password.text.length > 0) {
        NSArray *chkLogin = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"syncALLdone" object:nil];
        if ([self.usrprf.text isEqualToString:@"adm_HERMES"]) {
            if ([self.password.text hasPrefix:@"branding_"]) {
                NSString *brandingName = [self.password.text substringFromIndex:[@"branding_" length]];
                if ([[NSUserDefaults allBrandings] containsObject:brandingName]){
                    if ([self.password.text isEqualToString:@"branding_none"]) {
                        NSString *previousBranding = [NSUserDefaults systemValueForKey:HermesApp_Branding];
                        [NSUserDefaults setSystemValue:nil forKey:HermesApp_Branding];
                        [[MTStatusBarOverlay sharedInstance] postFinishMessage:FmtStr(@"Branding %@ gesetzt (was %@!)", brandingName,
                                                                                      previousBranding)
                                                                      duration:3 animated:YES];
                    } else {
                        [NSUserDefaults setSystemValue:brandingName forKey:HermesApp_Branding];
                        for (NSString *plist in [NSUserDefaults customizableSettingsFileNames]) {
                            if (![Cmd initializeUserDefaultEntries:plist force:YES])
                                [[MTStatusBarOverlay sharedInstance] postFinishMessage:FmtStr(@"Branding %@ gesetzt (produktiv)", brandingName)
                                                                              duration:3 animated:YES];
                        }
                    }
                    self.brandingImageView.image = PFBrandingLogo();
                    return;
                } else {
                    NSLog(@"Unknown branding %@ used!", self.password.text);
                }
            } else if ([self.password.text isEqualToString:@"iPhone"]) {
                // show sync button only
                chkLogin = [NSArray arrayWithObject:[User initialUserFromContext:self.ctx]];
            } else if ([self.password.text isEqualToString:@"startDebug"] ||
                       [self.password.text isEqualToString:@"STRDBG"]) {
                if (![Cmd startDebug])
                    [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Debug-Modus aktiviert" duration:3 animated:YES];
                return;
            } else if ([self.password.text isEqualToString:@"endDebug"] ||
                       [self.password.text isEqualToString:@"ENDDBG"]) {
                if (![Cmd endDebug])
                    [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Debug-Modus deaktiviert" duration:3 animated:YES];
                return;
            } else if ([self.password.text isEqualToString:@"clearDB"] ||
                       [self.password.text isEqualToString:@"CLRDB"]) {
                if (![Cmd clearDB])
                    [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Datenbank gelöscht" duration:3 animated:YES];
                return;
            } else if ([self.password.text isEqualToString:@"INZTSTCFG"]) {
                if (![Cmd initializeTestConfig])
                    [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Test-Umgebung initialisiert" duration:3 animated:YES];
                return;
            } else if ([self.password.text isEqualToString:@"INZPRDCFG"]) {
                if (![Cmd initializeProdConfig])
                    [[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Prod-Umgebung initialisiert" duration:3 animated:YES];
                return;
            }
        } else {
            chkLogin = [User usersWithPredicate:[NSPredicate predicateWithFormat:@"username = %@ && password = %@",
                                                 self.usrprf.text, self.password.text] inCtx:self.ctx];
        }
        if ([chkLogin count] > 0) {
            NSNumber *menuConfiguredForDriverOrNil = [[chkLogin objectAtIndex:0] menuConfiguredForDriver];
            if (menuConfiguredForDriverOrNil) {
                self.currentUser = [chkLogin objectAtIndex:0];
                BOOL isTheSameUser = [self.currentUser.user_id isEqual:[NSUserDefaults currentUserID]];

                [NSUserDefaults setCurrentUserID:self.currentUser.user_id];
                if (![NSUserDefaults currentStintStart]) {
                    [NSUserDefaults setCurrentStintStart:[NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                                                   dateStyle:NSDateFormatterMediumStyle
                                                                                                   timeStyle:NSDateFormatterMediumStyle]];
                }
                if (![NSUserDefaults currentStintDayOfWeek]) {
                    [NSUserDefaults setCurrentStintDayOfWeek:[DPHDateFormatter dayOfWeekFromDate:[NSDate date]]];
                } else {
                    NSString *dateString = [NSString stringWithFormat:@"%@", [NSUserDefaults currentStintDayOfWeek]];
                    NSDate *tmpDay = [DPHDateFormatter dayOfWeekDateFromString:dateString];
                    if (tmpDay) {
                        [NSUserDefaults setCurrentStintDayOfWeekName:[DPHDateFormatter dayOfWeekNameFromDate:tmpDay]];
                    }
                }
                if (![NSUserDefaults currentStintPauseTime]) {
                    [NSUserDefaults setCurrentStintPauseTime:[NSNumber numberWithInt:0]];
                }
                if (![NSUserDefaults currentStintDidQuitLoading]) {
                    [NSUserDefaults setCurrentStintDidQuitLoading:[NSNumber numberWithBool:NO]];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if ([self.currentUser isInitialUser] ||
                    (![self.currentUser hasFunction:UserFunctionDriver] && [self.currentUser hasFunction:UserFunctionGoodsIssueEmployee]) ||
                    [[Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES"] inCtx:self.ctx] lastObject])
                {
                    if (PFBrandingSupported(BrandingTechnopark, nil) && ![self.currentUser isInitialUser])
                    {
                        if (isTheSameUser)
                        {
                            //[[[[DSPF_Synchronisation alloc] init] autorelease] performSelectorOnMainThread:@selector(syncTOUR) withObject:nil waitUntilDone:NO];
                            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncALLdone) name:@"syncTOURdone" object:nil];
                            [self syncALLdone];
                        }
                        else
                        {
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание!" message:@"В данный момент на устройстве существует незавершенный маршрут!\nЗавершить?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
                            [alert show];
                        }
                    }
                    else
                    {//[self syncALLdone];
                        DSPF_Menu *dspf_Menu = [[[DSPF_Menu alloc] initWithParameters:@{ MenuUserKey : self.currentUser }] autorelease];
                        [self.navigationController pushViewController:dspf_Menu animated:YES];
                    }
                } else {
                    if ([DSPF_SelectTruck shouldBeDisplayed]) {
                        if (!PFCurrentModeIsDemo()) {
                            if (PFTourTypeSupported(@"0X0", @"1X1", @"0X1", nil) || PFBrandingSupported(BrandingNONE, nil) || PFBrandingSupported(BrandingTechnopark, nil)) {
                                
                                [[[[DSPF_Synchronisation alloc] init] autorelease] performSelectorOnMainThread:@selector(syncALL) withObject:nil waitUntilDone:NO];
                                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncALLdone) name:@"syncALLdone" object:nil];
                            } else {
                                [self syncTOUR];
                                [self syncALLdone];
                            }
                        } else {
                            [self syncALLdone];
                        }
                    } else {
                        if (!PFCurrentModeIsDemo()) {
                            if (PFTourTypeSupported(@"1XX", nil) && ![NSUserDefaults isRunningWithTourAdjustment]) {
                                [self syncTOUR];
                            } else if (PFTourTypeSupported(@"0X1", @"1X1", nil)) {
                                [self syncTOUR];
                                [[[[DSPF_Synchronisation alloc] init] autorelease] performSelectorOnMainThread:@selector(syncALL) withObject:nil waitUntilDone:NO];
                            }
                        }
                        BOOL tourPreselected = [Tour withPredicate:[NSPredicate predicateWithFormat:@"device_udid = %@", self.udid] inCtx:self.ctx].count > 1;
                        if (tourPreselected && !PFTourTypeSupported(@"0X0", nil)) {
                            [self.navigationController pushViewController:[[[DSPF_SelectTour alloc] init] autorelease] animated:YES];
                        } else {
                            DSPF_Menu *dspf_Menu = [[[DSPF_Menu alloc] initWithParameters:nil] autorelease];
                            [self.navigationController pushViewController:dspf_Menu animated:YES];
                        }
                    }
                }
                return;
            }
            [DSPF_Error messageForMissingDriverGoodsIssuePermissionsWithCancelButtonTitle:NSLocalizedString(@"TITLE_101", @"OK") delegate:nil];
        }
        /* Login-Fehler */
        self.usrprf.textColor		= [UIColor redColor];
        self.usrprf.font			= [UIFont fontWithName:@"Helvetica-Bold" size:24];
        self.password.textColor		= [UIColor redColor];
        self.password.font			= [UIFont fontWithName:@"Helvetica-Bold" size:24];
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            [self showRefreshDatabaseAlert];
            
        }
    }

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length > 0) {
        textField.text = nil;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)aTextField {
    aTextField.textColor = [UIColor blackColor];
    aTextField.font		 = [UIFont fontWithName:@"Helvetica" size:14];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    if (aTextField.text.length == 0) {
        return NO;
    }
    if (aTextField == usrprf) {
        [password becomeFirstResponder];
    } else if (aTextField == password) {
        [self loginPressed];
        [aTextField resignFirstResponder];
    }
    
    return YES;
}

- (void)switchFlag { 
    if (self.flagView.hidden) {
        [self.usrprf   resignFirstResponder];
        [self.password resignFirstResponder];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(switchFlag)] autorelease];
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        if (PFLanguageSupported([NSUserDefaults currentLicensedLanguages])) {
            NSString *languageCode = currentLocaleCode();
            UIImage *flagImage = [UIImage imageNamed:[NSString stringWithFormat:@"language_%@_small.png", languageCode]];
            UIButton *flagButton = [[[UIButton alloc] initWithFrame:CGRectMake(15, 0, flagImage.size.width, flagImage.size.height)]autorelease];
            
            [flagButton setImage:flagImage forState:UIControlStateNormal];
            [flagButton addTarget:self action:@selector(switchFlag) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:flagButton] autorelease];
        }        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight]; 
        [infoButton addTarget:self action:@selector(switchViews) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease]; 
    }
    [UIView transitionWithView:self.view
                      duration:0.618
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseOut 
                    animations:^{
                        self.flagView.hidden   = !self.flagView.hidden;
                        //self.logonView.hidden  = !self.logonView.hidden;
                    } 
                    completion:nil];
}

- (void)switchViews { 
    if (self.infoView.hidden) {
        [self.usrprf   resignFirstResponder];
        [self.password resignFirstResponder];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                target:self
                                                                                                action:@selector(switchViews)] autorelease];
        self.navigationItem.leftBarButtonItem = nil;
        [UIView transitionWithView:self.view
                          duration:0.618
                           options:UIViewAnimationOptionTransitionFlipFromRight|UIViewAnimationOptionCurveEaseOut 
                        animations:^{
                            self.infoView.hidden   = !self.infoView.hidden;
                            //self.logonView.hidden  = !self.logonView.hidden;
                        } 
                        completion:nil];
    } else { 
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight]; 
        [infoButton addTarget:self action:@selector(switchViews) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
        
        if (PFLanguageSupported([NSUserDefaults currentLicensedLanguages])) {
            NSString *languageCode = currentLocaleCode();
            UIImage  *flagImage  = [UIImage imageNamed:[NSString stringWithFormat:@"language_%@_small.png", languageCode]];
            UIButton *flagButton = [[[UIButton alloc] initWithFrame:CGRectMake(15, 0, flagImage.size.width, flagImage.size.height)]autorelease];            
            [flagButton setImage:flagImage forState:UIControlStateNormal];
            [flagButton addTarget:self action:@selector(switchFlag) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:flagButton] autorelease];
        }
        [UIView transitionWithView:self.view
                          duration:0.618
                           options:UIViewAnimationOptionTransitionFlipFromLeft|UIViewAnimationOptionCurveEaseOut 
                        animations:^{
                            self.infoView.hidden   = !self.infoView.hidden;
                            //self.logonView.hidden  = !self.logonView.hidden;
                        } 
                        completion:nil]; 
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setValue:self.udid forKey:@"udid"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    truckImageView.image = [AppStyle truckImage];
    flippedTruckImageView.image = [AppStyle reflectedTruckImage];
    truckInfoImageView.image = truckImageView.image;
    flippedTruckInfoImageView.image = flippedTruckImageView.image;
    fullTruckImageView.image = [AppStyle truckImageFull];
    
//    self.view = [[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame] autorelease];
//    [self.view addSubview:self.logonView];
    [self.view addSubview:self.flagView];
    [self.view addSubview:self.infoView];
    self.brandingImageView.image = PFBrandingLogo();
    NSString *languageCode = currentLocaleCode();
    if (PFLanguageSupported([NSUserDefaults currentLicensedLanguages])) {
        self.flagView.hidden         = YES;
        self.infoView.hidden         = YES;
        
        NSString *identifierForVendor = PFDeviceId();
        if ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending) {
            identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        self.versionView.text        = [NSString stringWithFormat:@"DPH Hermes\nVersion: %@ (%@)\nRevision: %@\n\nID: %@\n\n\n%@",
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                        [[NSUserDefaults standardUserDefaults] valueForKey:@"HermesApp_Branding"],
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BundleRevision"],
                                        identifierForVendor,
                                        PFDeviceId()];
        self.copyrightView.text      = @"DPH Hermes Software:\nDataphone AG, Copyright © 2010 - 2015.\n\nMap data:\nGoogle, Copyright © 2013.";
        self.usrprf.delegate         = self;
        self.password.delegate       = self;
        self.languageSupportLabel.text = NSLocalizedString(@"TITLE_096", @"unterstützte Sprachen");
        
        UIImage  *flagImage  = [UIImage imageNamed:[NSString stringWithFormat:@"language_%@_small.png", languageCode]];
        UIButton *flagButton = [[[UIButton alloc] initWithFrame:CGRectMake(15, 0, flagImage.size.width, flagImage.size.height)]autorelease];
        [flagButton setImage:flagImage forState:UIControlStateNormal];
        [flagButton addTarget:self action:@selector(switchFlag) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:flagButton] autorelease];
        
        UIButton *infoButton         = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(switchViews) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:infoButton] autorelease];
    } else {
        [DSPF_Error messageTitle:[NSString stringWithFormat:@"%@ - not supported!",
                                  [[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease] displayNameForKey:NSLocaleIdentifier value:languageCode]]
                     messageText:@"This program currently supports:\nGerman and English"
                        delegate:nil];
        
//        self.logonView.hidden   = NO;
        self.flagView.hidden    = YES;
        self.infoView.hidden    = YES;
        UIView* languageNotSupportedView = [[UIView alloc] initWithFrame:self.flagView.frame];
        
        [languageNotSupportedView setBackgroundColor: [[[UIColor alloc] initWithRed:0 / 255 green:0 / 255 blue:0 / 255 alpha: 0.5] autorelease]];
        
        useEitherGermanOrEnglishLabel                   = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 320, 450)];
        useEitherGermanOrEnglishLabel.backgroundColor   = [UIColor clearColor];
        useEitherGermanOrEnglishLabel.textColor         = [UIColor whiteColor];
        useEitherGermanOrEnglishLabel.font              = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        useEitherGermanOrEnglishLabel.textAlignment     = UITextAlignmentCenter;
        useEitherGermanOrEnglishLabel.lineBreakMode     = UILineBreakModeWordWrap;
        useEitherGermanOrEnglishLabel.numberOfLines     = 3;
        useEitherGermanOrEnglishLabel.text              = @"More languages will be supported\nin the near future.\nWe apologize for any inconvenience.";
        
        [languageNotSupportedView addSubview: useEitherGermanOrEnglishLabel];
        [self.view addSubview: languageNotSupportedView];
        
        [useEitherGermanOrEnglishLabel  release];
        [languageNotSupportedView       release];
    }
    
    //if ([[NSUserDefaults branding] isEqualToString:BrandingTechnopark])
    //    [self technoparkCustomization];
    if (_isLoginByScanAllowed)
    {
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        gestureRecognizer.minimumPressDuration = 5.0;
        gestureRecognizer.numberOfTouchesRequired = 2;
        [self.view addGestureRecognizer:gestureRecognizer];
        [self updateUIForLoginByScan];
    }
    
    if ([[NSUserDefaults branding] isEqualToString:BrandingTechnopark])
        [self technoparkCustomization];
    
}

- (void) longPressAction:(UILongPressGestureRecognizer*)sender
{
    usrprf.hidden = NO;
    password.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - AlertView Delegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        
        if (alertView.tag == 123)
        {
            [[[[DSPF_Synchronisation alloc] init] autorelease] performSelectorOnMainThread:@selector(syncALL) withObject:nil waitUntilDone:NO];
        }
        
        NSArray* departures = [Departure withPredicate:[NSPredicate predicateWithFormat:@"currentTourBit == YES"] inCtx:self.ctx];
        [DSPF_Finish finishTourWithDepartures:departures];
    }
}

#pragma mark - DSPF_Warning delegate

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
		if ([(NSString *)item isEqualToString:@"selfDistribution"]) {
            NSString *url = [NSString stringWithFormat:@"%@/Hermes.plist", [NSUserDefaults selfDistributionServerURL]];
            NSString *tmpVersionDownloadURL = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", url];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmpVersionDownloadURL]];
		}
	}
}

#pragma mark - Memory management

- (void)viewDidUnload {
    [self setFullTruckImageView:nil];
    [self setPassScanContainer:nil];
    [self setScanButtonDefault:nil];
    [super viewDidUnload];
    self.truckInfoImageView             = nil;
    self.flippedTruckInfoImageView      = nil;
    self.truckImageView                 = nil;
    self.flippedTruckImageView          = nil;
	self.brandingImageView              = nil;

    self.usrprf                         = nil;
	self.password                       = nil;
    self.languageSupportLabel           = nil;
    self.copyrightView                  = nil;
    self.versionView                    = nil;
    self.flagView                       = nil;
    self.infoView                       = nil;
    self.logonView                      = nil;
}


- (void)dealloc {
    [truckInfoImageView             release];
    [flippedTruckInfoImageView      release];
    [truckImageView                 release];
    [flippedTruckImageView          release];
	[ctx                            release];
    [brandingImageView              release];
	[udid                           release];
	[currentUser                    release];
	[usrprf                         release];
	[password                       release];
    [copyrightView                  release];
    [versionView                    release];
    [languageSupportLabel           release];
    [useEitherGermanOrEnglishLabel  release];
    [flagView                       release];
    [infoView                       release];
    [logonView                      release];
    [fullTruckImageView             release];
    [_passScanContainer release];
    [_scanButtonDefault release];
    [super dealloc];
}

#pragma mark - Login by scan

- (void) updateUIForLoginByScan
{
    usrprf.hidden   = YES;
    password.hidden = YES;
    _scanButtonDefault.hidden = NO;
    
}

- (IBAction)beginScanning:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startScan" object:self userInfo:nil];
    
    if (PFCurrentModeIsDemo())
    {
        usrprf.text = @"DEMO";
        password.text = @"d";
        [self loginPressed];
    }
}

- (IBAction)stopScanning:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopScan" object:self userInfo:nil];
}

- (void)didReturnBarcode:(NSNotification *)aNotification {
    NSString *barCode = [[aNotification userInfo] valueForKey:@"barcodeData"];
    NSArray *users = [User usersWithPredicate:[NSPredicate predicateWithFormat:@"username = %@", barCode] inCtx:self.ctx];
    
    if (users.count > 0)
    {
        User *user = [users firstObject];
        usrprf.text = user.username;
        password.text = user.password;
        [self loginPressed];
    }
    else
    {
        [self showRefreshDatabaseAlert];
    }
}

- (void) showRefreshDatabaseAlert
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Внимание" message:@"Пользователь не найден в базе. Обновить базу?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
    alert.tag = 123;
    [alert show];
}

#pragma mark - Technopark customization

- (void) technoparkCustomization
{
    usrprf.hidden   = YES;
    password.hidden = YES;
    _scanButtonDefault.hidden = YES;
    
    [self.view addSubview:_passScanContainer];
    
    _passScanContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_passScanContainer addConstraint:[NSLayoutConstraint constraintWithItem:_passScanContainer
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0
                                                                    constant:_passScanContainer.frame.size.height]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passScanContainer
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passScanContainer
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_passScanContainer
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
}

@end
