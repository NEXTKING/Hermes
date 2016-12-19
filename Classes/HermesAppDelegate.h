//
//  HermesAppDelegate.h
//  Hermes
//
//  Created by Lutz  Thalmann on 24.11.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

/*
 ARMv8 / ARM64 = iPhone 5s, iPad Air, Retina iPad Mini
 ARMv7s = iPhone 5, iPhone 5c, iPad 4
 ARMv7  = iPhone 3GS, iPhone 4, iPhone 4S, iPod 3G/4G/5G, iPad, iPad 2, iPad 3, iPad Mini
 ARMv6  = iPhone, iPhone 3G, iPod 1G/2G
*/

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SVR_ScanDeviceManager.h"
#import "SVR_SyncDataManager.h"
#import "AppStyle.h"
#import "DSPF_Warning.h"
#import "DPHDeviceHandOver.h"
#import "SVR_LocationManager.h"
#import "DSPF_Workspace.h"
#import "DPHUpdatesChecker.h"

@class HermesAppDelegate;

extern NSManagedObjectContext *ctx(void);
extern HermesAppDelegate *AppDelegate(void);

@interface HermesAppDelegate : NSObject <UIApplicationDelegate, UIAlertViewDelegate, DSPF_WarningDelegate, UINavigationControllerDelegate> {
    
    UIWindow                     *window;	
    
@private
    UIWindow                     *extWindow;
    UIScreen					 *extScreen;
    UILabel                      *statusWarning;
    UIView                       *flagView;
    UILabel                      *useEitherGermanOrEnglishLabel;
    UIImageView                  *duplicate;
    UIAlertView                  *checkScreen;
    
    NSManagedObjectContext       *ctx_;
    NSManagedObjectModel         *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;

	UINavigationController		 *navigationController;
    BOOL                          currentAppModeIsDemo; // normal (productive)=0 / demo=1
    NSData                       *pushNotificationDeviceToken;
    BOOL                          hasActiveProblemsWithGPS;
    BOOL                          hasActiveProblemsWithNET;
}
@property (nonatomic, retain, readonly) SVR_ScanDeviceManager        *svr_ScanDeviceManager;
@property (nonatomic, retain, readonly) SVR_SyncDataManager          *syncDataManager;
@property (nonatomic, retain, readonly) DPHDeviceHandOver            *deviceHandOver;
@property (nonatomic, retain, readonly) SVR_LocationManager          *locationManager;
@property (nonatomic, retain, readonly) DPHUpdatesChecker            *updatesChecker;

@property (nonatomic, retain) IBOutlet  UIWindow                     *window; 
@property (nonatomic, retain)           UIWindow                     *extWindow;
@property (nonatomic, retain)           UIScreen                     *extScreen;
@property (nonatomic, retain)           UILabel                      *statusWarning;
@property (nonatomic, retain)           UIView                       *flagView;
@property (nonatomic, retain)           UIImageView                  *duplicate;
@property (nonatomic, retain)           UILabel                      *useEitherGermanOrEnglishLabel;
@property (nonatomic, retain)           UIAlertView                  *checkScreen;
@property (nonatomic, retain)			UINavigationController       *navigationController;
@property (nonatomic, retain)           DSPF_Workspace               *workspace;

@property (nonatomic, readonly)         BOOL                          currentAppModeIsDemo;

@property (nonatomic, retain, readonly) NSManagedObjectContext       *ctx;
@property (nonatomic, retain, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSString                     *sqliteFileName;
@property (nonatomic, retain, readonly) NSString                     *licensedLanguages;

- (void)setNetworkProblemIndicatorVisible:(BOOL)visible;
- (void)setLocationServicesProblemIndicatorVisible:(BOOL)visible;
- (void)disconnectFromPersistentStore;
- (void)connectToPersistentStore;

@end

