//
//  HermesAppDelegate.m
//  Hermes
//
//  Created by Lutz  Thalmann on 24.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSPF_Login.h"
#import "DSPF_Synchronisation.h"
#import "DSPF_Error.h"

#import <objc/message.h>

#import <CoreText/CoreText.h>

NSManagedObjectContext *ctx(void) {
    return [(HermesAppDelegate *)[[UIApplication sharedApplication] delegate] ctx];
}

HermesAppDelegate *AppDelegate(void) {
    return (HermesAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@implementation HermesAppDelegate

static CADisplayLink *displayLink = nil;

@synthesize window;
@synthesize extWindow; 
@synthesize extScreen;
@synthesize statusWarning;
@synthesize flagView;
@synthesize useEitherGermanOrEnglishLabel;
@synthesize duplicate;
@synthesize checkScreen;
@synthesize navigationController;
@synthesize deviceHandOver;
@synthesize syncDataManager;
@synthesize locationManager;
@synthesize svr_ScanDeviceManager;
@synthesize workspace;
@synthesize updatesChecker;

@synthesize currentAppModeIsDemo;

#pragma mark - Application lifecycle

- (UINavigationController *)navigationController { 
    if (!navigationController) {
        if (PFBrandingSupported(BrandingViollier, BrandingBiopartner, BrandingCCC_Group, nil)) {
            NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary:
                                                       [[UINavigationBar appearance] titleTextAttributes]];
            [titleBarAttributes setValue:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:19] forKey:UITextAttributeFont];
            [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
            NSMutableDictionary *barButtonAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UIBarButtonItem appearance] titleTextAttributesForState:UIControlStateNormal]];
            [barButtonAttributes setValue:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13] forKey:UITextAttributeFont];
            [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAttributes forState:UIControlStateNormal];
        }
        else if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigationTitle_technopark.png"] forBarMetrics:UIBarMetricsDefault];
            [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                                 forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}];
            [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:96.0/255.0 green:155.0/255.0 blue:199.0/255.0 alpha:1.0]];
        }
        navigationController = [[UINavigationJumpThroughController alloc] initWithRootViewController:
                                [[[DSPF_Login alloc] initWithNibName:@"DSPF_Login" bundle:nil] autorelease]];
        navigationController.navigationBar.barStyle = UIBarStyleBlack;
        navigationController.navigationBar.alpha = 0.875;
    }
    return navigationController;
}

- (UILabel *)statusWarning {
    if (!statusWarning) {
        UIFont *usedFont = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        CGSize textSize = [@"⚠🎯📡" sizeWithFont:usedFont];
        CGRect statusbarFrame = [[UIApplication sharedApplication] statusBarFrame];
        CGFloat y = floorf((CGRectGetHeight(statusbarFrame) - textSize.height) / 2.0f);
        statusWarning = [[UILabel alloc] initWithFrame:CGRectMake(statusbarFrame.size.width * 2 / 3 - [@"⚠" sizeWithFont:usedFont].width, y,
                                                                  textSize.width, textSize.height)];
        statusWarning.font = usedFont;
        statusWarning.backgroundColor = [UIColor clearColor];
    }
    return statusWarning;
}

- (void)showProblemIndicator {
    NSString *textToSet = @"";
    if (hasActiveProblemsWithGPS || hasActiveProblemsWithNET) {
        textToSet = [textToSet stringByAppendingString:@"⚠"];
        if (hasActiveProblemsWithGPS) {
            textToSet = [textToSet stringByAppendingString:@"🎯"];
        }
        if (hasActiveProblemsWithNET) {
            textToSet = [textToSet stringByAppendingString:@"📡"];
        }
    }
    self.statusWarning.text = textToSet;
    BOOL hidden = (self.statusWarning.text.length == 0);
    if (!hidden) {
        CABasicAnimation *textAlert  = [CABasicAnimation animationWithKeyPath:@"transform"];
        [textAlert setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.26, 1.26, 1.26)]];
        [textAlert setAutoreverses:YES];
        [textAlert setRepeatCount:MAXFLOAT];
        [textAlert setDuration:0.26];
        [self.statusWarning.layer removeAnimationForKey:@"transform"];
        [self.statusWarning.layer addAnimation:textAlert forKey:@"transform"];
        [[MTStatusBarOverlay sharedInstance] setBackgroundViews:[NSSet setWithObjects:statusWarning, nil]];
        [[MTStatusBarOverlay sharedInstance] show];
    } else {
        [self.statusWarning.layer removeAllAnimations];
        [[MTStatusBarOverlay sharedInstance] setBackgroundViews:nil];
        [[MTStatusBarOverlay sharedInstance] hide];
    }
}

- (void)setNetworkProblemIndicatorVisible:(BOOL)visible { 
    hasActiveProblemsWithNET = visible;
    [self showProblemIndicator];
}

- (void)setLocationServicesProblemIndicatorVisible:(BOOL)visible {
    hasActiveProblemsWithGPS = visible;
    [self showProblemIndicator];    
}

- (void)updateMirroredScreenOnTimer {
    UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();    
    // Iterate over every window from back to front
    for (UIWindow *tmpWindow in [[UIApplication sharedApplication] windows]) {
        if (![tmpWindow respondsToSelector:@selector(screen)] || [tmpWindow screen] == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [tmpWindow center].x, [tmpWindow center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [tmpWindow transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[tmpWindow bounds].size.width * [[tmpWindow layer] anchorPoint].x,
                                  -[tmpWindow bounds].size.height * [[tmpWindow layer] anchorPoint].y);
            // Render the layer hierarchy to the current context
            [[tmpWindow layer] renderInContext:context]; 
            // Restore the context
            CGContextRestoreGState(context);
        }
    }    
    // Retrieve the screenshot image
    self.duplicate.image = [UIImage imageWithCGImage:[UIGraphicsGetImageFromCurrentImageContext() CGImage]];
    UIGraphicsEndImageContext();
}

- (void)screenDidChange:(NSNotification *)notification { 
    if (displayLink) {
        [displayLink invalidate];
        displayLink = nil;
    }
    // 1.		
	// Log the current screens and display modes
	NSArray *screens = [UIScreen screens];	
	
	NSUInteger screenCount = [screens count]; 
	if (screenCount > 1) { 
        // don't allow to sleep in presentation mode
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
		// 2.		
		// Select first external screen
		self.extScreen = [screens objectAtIndex:1];	
        // 3.
		// Set initial display mode to highest resolution
        self.extScreen.currentMode = [self.extScreen.availableModes lastObject]; 
        if (!self.extWindow || !CGRectEqualToRect(self.extWindow.bounds, [self.extScreen bounds])) {
            // Size of window has actually changed 
            // 4. 
            self.extWindow = [[[UIWindow alloc] initWithFrame:[self.extScreen bounds]] autorelease]; 
            // 5.
            self.extWindow.screen = self.extScreen; 
            self.extWindow.rootViewController = [[[UIViewController alloc] init] autorelease];
            self.duplicate = [[[UIImageView alloc] initWithFrame:self.extWindow.screen.bounds] autorelease];
            self.duplicate.contentMode = UIViewContentModeScaleAspectFit;
            self.duplicate.opaque = YES;
            self.duplicate.backgroundColor = [UIColor blackColor];
            self.extWindow.rootViewController.view = self.duplicate;
            displayLink = [self.window.screen displayLinkWithTarget:self selector:@selector(updateMirroredScreenOnTimer)];
            [displayLink setFrameInterval:60];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            // Create a screenshot of the main window and store it as UIImage
            // 6.
            [self.extWindow makeKeyAndVisible];
            if (self.checkScreen) {
                [self.checkScreen dismissWithClickedButtonIndex:1 animated:NO];
            }
            self.checkScreen = [[[UIAlertView alloc]initWithTitle:@"Bildschirmkopie" 
                                                          message:[NSString stringWithFormat:@"%@", self.extWindow.screen.currentMode] 
                                                         delegate:self 
                                                cancelButtonTitle:@"NEIN" otherButtonTitles:@"OK", nil] autorelease];
            [self.checkScreen show];
        }
    } else { 
        // allow to sleep in normal mode
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        // Release external screen and window
        if (self.duplicate) {
            self.duplicate  = nil;
        }
        if (self.extScreen) {
            self.extScreen  = nil;
        }
        if (self.extWindow) {
            self.extWindow  = nil;
        }
    }
}

-(void)alertView:(UIAlertView *)sender clickedButtonAtIndex:(NSInteger)button {
	if(button == 0) { 
        if ([self.extWindow.screen.currentMode isEqual:[self.extWindow.screen.availableModes objectAtIndex:0]]) { 
            if (displayLink) {
                [displayLink invalidate];
                displayLink = nil;
            }
            if (self.duplicate) {
                self.duplicate  = nil;
            }
            if (self.extScreen) {
                self.extScreen  = nil;
            }
            if (self.extWindow) {
                self.extWindow  = nil;
            }
            return;
        }
        self.extWindow.screen.currentMode = [self.extWindow.screen.availableModes objectAtIndex:
                                             ([self.extWindow.screen.availableModes indexOfObject:
                                               self.extWindow.screen.currentMode] -1)];
        self.duplicate.frame              = CGRectMake(self.extWindow.screen.bounds.origin.x,
                                                       self.extWindow.screen.bounds.origin.y,
                                                       self.extWindow.screen.bounds.size.width,
                                                       self.extWindow.screen.bounds.size.height);
        self.checkScreen = [[[UIAlertView alloc]initWithTitle:@"Bildschirmkopie" 
                                                      message:[NSString stringWithFormat:@"%@", self.extWindow.screen.currentMode] 
                                                     delegate:self 
                                            cancelButtonTitle:@"NEIN" otherButtonTitles:@"OK", nil] autorelease];
        [self.checkScreen show];
    }
}

- (void)mergeContext:(NSNotification *)aNotification {    
    if (aNotification.object != self.ctx) {        
        [self.ctx mergeChangesFromContextDidSaveNotification:aNotification]; 
    } 
}

- (void)hermesAppModeToggle {
    // Release all viewControllers from the current navigation stack
    [self.navigationController popToRootViewControllerAnimated:NO];
    // Clear the current screen
    [self.navigationController.view removeFromSuperview];
    // Release the "old" navigationController
    [navigationController    release]; navigationController = nil;
    // Stop background Synchronisation
    [syncDataManager release];     syncDataManager  = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [self disconnectFromPersistentStore];
    currentAppModeIsDemo = !currentAppModeIsDemo;
    if (currentAppModeIsDemo) {
        [Cmd initializeUserDefaultEntries:@"ServerInfo_demo.plist"      force:YES];
        [Cmd initializeUserDefaultEntries:@"ApplicationInfo_demo.plist" force:YES];
    } else {
        [Cmd restoreUserDefaultEntries];
    }
    [self connectToPersistentStore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContext:) name:NSManagedObjectContextDidSaveNotification object:nil];
    // Start background synchronisation
    syncDataManager = [[SVR_SyncDataManager  alloc] init];
    // Create a "new" navigationController and show it on the screen
    [window addSubview:self.navigationController.view];
}

-(void)executeNotificationRequest:(NSDictionary *)userInfo { 
    [DPHUtilities waitForAlertToShow:0.236f];
    NSInteger pushNotificationType = [[NSString stringWithFormat:@"%@", [userInfo valueForKey:@"type"]] integerValue];
    NSString *messageText = [NSString stringWithFormat:@"%@", [[userInfo valueForKey:@"aps"] valueForKey:@"alert"]];
    NSString *messageTitle = nil;
    NSString *notificationType = nil;
    if (pushNotificationType == 1) {
        messageTitle = NSLocalizedString(@"TITLE_110", @"CallCenter-Nachricht");
        notificationType = @"synchronizationRequestForTourMessage";
    } else if (pushNotificationType == 2) {
        messageTitle = NSLocalizedString(@"TITLE_124", @"Tour-Aktualisierung");
        notificationType = @"synchronizationRequestForTourUpdate";
    } else if (pushNotificationType == 3) {
        messageTitle = NSLocalizedString(@"TITLE_111", @"CallCenter-Info");
        notificationType = @"synchronizationRequestForTourTransfer";
    } else {
        messageTitle = NSLocalizedString(@"TITLE_111", @"CallCenter-Info");
        messageText = [[messageText stringByReplacingOccurrencesOfString:@"NEU " withString:@"🅿️ "]
                                    stringByReplacingOccurrencesOfString:@"ABGESAGT " withString:@"⛔️ "];
        notificationType = @"synchronizationRequestForTourNotification";
    }
    [DSPF_Warning messageTitle:messageTitle messageText:messageText item:@[notificationType, userInfo] delegate:self];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Successfully registered for push notifications. Received token: %@", deviceToken);
    if (!pushNotificationDeviceToken || ![pushNotificationDeviceToken isEqualToData:deviceToken]) { 
        [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendApplePushnotificationID"
                                                                                              object:self 
                                                                                            userInfo:[NSDictionary dictionaryWithObject:deviceToken 
                                                                                                                                 forKey:@"apnsid"]] 
                                                   postingStyle:NSPostASAP];
        pushNotificationDeviceToken = deviceToken;
        
        //[DSPF_Warning messageTitle:@"Token" messageText:[NSString stringWithFormat:@"%@", deviceToken] item:nil delegate:nil];
    }  
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register for push notifications. Reason: %@", error);
}


/* Application's entry point */

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"HomeDirectory: %@", NSHomeDirectory());
    PFDebugLog(@"DeviceId: %@", PFDeviceId());
    PFDebugLog(@"iOS Version: %@", PFOsVersion());
    PFDebugLog(@"%@", NSStringFromSelector(_cmd));
    PFDebugLog(@"PFDebugGetCaller %@", PFDebugGetCaller());
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"udid"]; // not used anymore, removing it for clarity
    // older versions did store the those files in the NSDocumentDirectory - newer versions use the better NSLibraryDirectory
    if ([Cmd revokeItunesFileSharingPermission:@"Hermes.sqlite"] ||
        [Cmd revokeItunesFileSharingPermission:@"Demo.sqlite"] ||
        [Cmd revokeItunesFileSharingPermission:@"recentProductiveModeUserDefaults.plist"])
        abort(); // A crash here is better than doing something wrong !
    // Version 1.89 and above will store item images in folder "Library/ItemImages"
        if ([Cmd initializeImageDirectory:@"Item"]) abort(); // A crash here is better than doing something wrong !;
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    // No notifications are sent for screens that are present when the app is launched.
    [self screenDidChange:nil];
    [Cmd initializeUserDefaultEntries:@"Root.plist"                     force:NO];
    [Cmd initializeUserDefaultEntries:@"System.plist"                   force:NO];
    [Cmd initializeUserDefaultEntries:@"ServerInfo.plist"               force:NO];
    [Cmd initializeUserDefaultEntries:@"ApplicationInfo.plist"          force:NO];
    [Cmd initializeUserDefaultEntries:@"BarcodeEngine.plist"            force:NO];
    [Cmd initializeUserDefaultEntries:@"CardReader.plist"               force:NO];
    /* TODO check if this needs changes in the provision profile
    // older versions did store those files unencrypted
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HermesApp_SYSVAL_ENCRYPTED_DB"] &&
        [[[UIDevice currentDevice] systemVersion] compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager]
              setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey]
              ofItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Hermes.sqlite"] error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if (![[NSFileManager defaultManager]
              setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey]
              ofItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Demo.sqlite"] error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        if (![[NSFileManager defaultManager]
              setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey]
              ofItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"dphHermes.app/Demo_orig.sqlite"] error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    */
    // Key "HermesApp_SYSVAL_DEMO_MODE" is now available even if this is the first launch after the applications installation
    currentAppModeIsDemo = [[NSUserDefaults systemValueForKey:HermesApp_SYSVAL_DEMO_MODE] isEqualToString:@"TRUE"];
    if (currentAppModeIsDemo) {
        // entering foreground from normal mode into DEMO mode
        [Cmd initializeUserDefaultEntries:@"ServerInfo_demo.plist"      force:YES];
        [Cmd initializeUserDefaultEntries:@"ApplicationInfo_demo.plist" force:YES];
    }
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    if (self.ctx) { 
        // Start background synchronisation
        syncDataManager = [[SVR_SyncDataManager alloc] init];
    }
    locationManager = [[SVR_LocationManager alloc] init];
    // DSPF_Login is the navigationControllers rootViewController.
    // DSPF_Login depends on the shared ctx. So only now it is save to alloc and init the controller
    // after all settings and userDefaults are prepared.
    
    workspace = [[DSPF_Workspace alloc] init];
    workspace.navigationController = self.navigationController;
    [window setRootViewController:workspace];
    [window makeKeyAndVisible];
    
    [Cmd startPushNotificationReceiver];
    
    // Register for screen connect and disconnect notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChange:) name:UIScreenDidConnectNotification    object:nil]; 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenDidChange:) name:UIScreenDidDisconnectNotification object:nil]; 
    // Register for managed object context did save notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContext:)    name:NSManagedObjectContextDidSaveNotification object:nil];
    if (PFLanguageSupported([NSUserDefaults currentLicensedLanguages])) {
        if (!svr_ScanDeviceManager) {
            svr_ScanDeviceManager = [[SVR_ScanDeviceManager alloc] initWithSettingsPrefix:@"HermesApp_"];
        }
    }
    // Checking for launchOption "Push Notification"
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) { 
        // prepare to clear the message from the NotificationCenter
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
        // perform the action
        [self executeNotificationRequest:remoteNotification];
        // clear the message from the NotificationCenter
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    // Checking for launchOption "Local Notification"
    UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) { 
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        [self executeNotificationRequest:notification.userInfo];    
    }
    
    updatesChecker = [[DPHUpdatesChecker alloc] initWithURLToApplicationPlist:[NSString stringWithFormat:@"%@/Hermes.plist", [NSUserDefaults selfDistributionServerURL]]];
    [updatesChecker checkForApplicationUpdates];
    deviceHandOver = [[DPHDeviceHandOver alloc] init];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // needs a moment to access the new settings, if the user did change it in the iPhone settings
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.236f]];
    if ((!currentAppModeIsDemo && [[NSUserDefaults systemValueForKey:HermesApp_SYSVAL_DEMO_MODE] isEqualToString:@"TRUE"]) ||
        (currentAppModeIsDemo && ![[NSUserDefaults systemValueForKey:HermesApp_SYSVAL_DEMO_MODE] isEqualToString:@"TRUE"])) {
        [self hermesAppModeToggle];
    }
    
    NSDate *today = [NSDate date];
    NSDate *lastUpdateCheckedDate = [NSUserDefaults enterpriseDistributionVersionCheckDate];
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber == 0 && (!lastUpdateCheckedDate || ![today isSameDay:lastUpdateCheckedDate])) {
        [updatesChecker checkForApplicationUpdates];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if ([application applicationState] == UIApplicationStateInactive) { 
        // self called from notification center
        // must be a buffered "older" notification
        /*
        if (nowClearAllMessagesFromNotificationCenter) {
            application.applicationIconBadgeNumber = 1;
            application.applicationIconBadgeNumber = 0;
        }
        */
    } else if ([application applicationState] == UIApplicationStateActive) {
        // self running
        // must be the notification which is most up to date
    }
    // prepare to clear the message from the NotificationCenter
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    // perform the action
    [self executeNotificationRequest:userInfo];
    // clear the message from the NotificationCenter
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification { 
    [[UIApplication sharedApplication] cancelLocalNotification:notification];
    [self executeNotificationRequest:notification.userInfo];  
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.ctx saveIfHasChanges];
    // Backup all NSUserdefaults for a possible application mode switch (production or demo) before hibernating.
    if (!currentAppModeIsDemo) [Cmd saveUserDefaultEntries];
}

- (void)applicationDidEnterBackground:(UIApplication *)application { 
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application { 
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self showProblemIndicator];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application { 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification            object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification         object:nil];
}


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)ctx {
    
    if (!ctx_) { 
        if (self.persistentStoreCoordinator) {
            ctx_ = [[NSManagedObjectContext alloc] init];
            [ctx_ setPersistentStoreCoordinator:self.persistentStoreCoordinator];
            [ctx_ setUndoManager:nil];
        }
    }
    return ctx_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (!managedObjectModel_) {
        managedObjectModel_ = [[NSManagedObjectModel alloc] 
                               initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Hermes" withExtension:@"momd"]]; 
    }
    return managedObjectModel_;
}
 
- (NSString *)sqliteFileName {    
    if (currentAppModeIsDemo) {
        if ([Cmd initializeDemoDB]) abort(); // A crash here is better than doing something wrong !
        return @"Demo.sqlite";
    } else {
        return @"Hermes.sqlite";
    }
}

- (void)disconnectFromPersistentStore {
    for (id persistentStore in persistentStoreCoordinator_.persistentStores) {
        [persistentStoreCoordinator_ removePersistentStore:persistentStore error:nil];
    }
}

- (void)connectToPersistentStore {
    NSError *error = nil;
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType 
                                                   configuration:nil 
                                                             URL:[[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                                                                          inDomains:NSUserDomainMask] lastObject] 
                                                                  URLByAppendingPathComponent:self.sqliteFileName] 
                                                         options:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, 
                                                                  [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
                                                                  nil] 
                                                           error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!persistentStoreCoordinator_) {    
        persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        [self connectToPersistentStore];        
    }    
    return persistentStoreCoordinator_;
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )aItem withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex { 
	if (![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_004", @"Abbrechen")] &&
        ![buttonTitle isEqualToString:NSLocalizedString(@"TITLE_100", @"Ablehnen")]) {
		if ([aItem isKindOfClass:[NSArray class]] &&
            [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourNotification"]) { 
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendRemoteNotificationResponse"
                                                                                                  object:self 
                                                                                                userInfo:[NSDictionary dictionaryWithObjects:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           (NSDictionary *)[aItem objectAtIndex:1], 
                                                                                                           @"YES", nil]
                                                                                                                                     forKeys:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           @"notification", 
                                                                                                           @"answer", nil]]] 
                                                       postingStyle:NSPostASAP];
            if ([(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"departure_id"]) { 
                [[[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease]
                 performSelectorOnMainThread:@selector(syncTOURwithOption:) 
                                  withObject:[NSString stringWithFormat:@"departure_id=%@", 
                                              [(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"departure_id"]] 
                               waitUntilDone:NO];
            } else {
                [[[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease]
                 performSelectorOnMainThread:@selector(syncTOURwithOption:) 
                                  withObject:@"" waitUntilDone:NO];
            }
		} else if ([aItem isKindOfClass:[NSArray class]] &&
                    ([(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourUpdate"] ||
                     [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourTransfer"])) {
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendRemoteNotificationResponse"
                                                                                                  object:self
                                                                                                userInfo:[NSDictionary dictionaryWithObjects:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           (NSDictionary *)[aItem objectAtIndex:1],
                                                                                                           @"YES", nil]
                                                                                                                                     forKeys:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           @"notification",
                                                                                                           @"answer", nil]]]
                                                       postingStyle:NSPostASAP];
                        
            if (PFBrandingSupported(BrandingTechnopark, nil))
            {
                DSPF_Synchronisation *dspf_Sync = [[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease];
                dspf_Sync.notifyObject = self;
                [dspf_Sync performSelector:@selector(syncTOUR) withObject:nil];
            }
            else if ([(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"tour_id"]) {
                [[[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease]
                 performSelectorOnMainThread:@selector(syncTOURwithOption:)
                 withObject:[NSString stringWithFormat:@"tour_id=%@",
                             [(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"tour_id"]]
                 waitUntilDone:NO];
            } else {
                [[[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease]
                 performSelectorOnMainThread:@selector(syncTOURwithOption:)
                 withObject:@"" waitUntilDone:NO];
            }
		} else if ([aItem isKindOfClass:[NSArray class]] &&
                   [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourMessage"]) {
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendRemoteNotificationResponse"
                                                                                                  object:self
                                                                                                userInfo:[NSDictionary dictionaryWithObjects:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           (NSDictionary *)[aItem objectAtIndex:1],
                                                                                                           @"YES", nil]
                                                                                                                                     forKeys:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           @"notification",
                                                                                                           @"answer", nil]]]
                                                       postingStyle:NSPostASAP];
            if ([(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"departure_id"]) {
                [[[[DSPF_Synchronisation alloc] initWithNibName:@"DSPF_Synchronisation" bundle:nil] autorelease]
                 performSelectorOnMainThread:@selector(syncTOURwithOption:)
                 withObject:[NSString stringWithFormat:@"departure_id=%@&type=%@",
                             [(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"departure_id"],
                             [(NSDictionary *)[aItem objectAtIndex:1] objectForKey:@"type"]]
                 waitUntilDone:NO];
            }
		}
	} else {
        if ([aItem isKindOfClass:[NSArray class]] &&
            [(NSString *)[aItem objectAtIndex:0]  isEqualToString:@"synchronizationRequestForTourNotification"]) { 
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"sendRemoteNotificationResponse"
                                                                                                  object:self 
                                                                                                userInfo:[NSDictionary dictionaryWithObjects:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           (NSDictionary *)[aItem objectAtIndex:1], 
                                                                                                           @"NO", nil]
                                                                                                                                     forKeys:
                                                                                                          [NSArray arrayWithObjects:
                                                                                                           @"notification", 
                                                                                                           @"answer", nil]]] 
                                                       postingStyle:NSPostASAP];
		}
    }
}

#pragma mark - Push Notifications

// iOS >= 8 only
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(id /* UIUserNotificationSettings */)notificationSettings {
    NSUInteger allowedTypes = [[notificationSettings valueForKeyPath:@"types"] unsignedIntegerValue];
    PFDebugLog(@"UIApplication didRegisterUserNotificationSettings: %@, types: %lu", notificationSettings, (unsigned long)allowedTypes);
    if (allowedTypes > 0 /*None*/) {
        PFDebugLog(@"Registering for push notificaitons");
        [[UIApplication sharedApplication] performSelector:@selector(registerForRemoteNotifications) withObject:nil];
    }
}


#pragma mark - Memory management


- (void)dealloc {
    [updatesChecker release];
    [deviceHandOver release];
    [ctx_       release];
    [managedObjectModel_         release];
    [persistentStoreCoordinator_ release];
    [pushNotificationDeviceToken release];

    [svr_ScanDeviceManager  release];
    [syncDataManager    release];
    [locationManager release];
    [workspace release];
	[navigationController	release];
    [checkScreen            release];
    [duplicate              release];
    [statusWarning          release];
    [extScreen              release];
    [extWindow				release];
    [window					release];
    [super dealloc];
}


@end

