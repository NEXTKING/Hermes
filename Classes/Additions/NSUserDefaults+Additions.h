//
//  NSUserDefaults+Additions.h
//  dphHermes
//
//  Created by Tomasz Kransyk on 29.04.15.
//
//

#import <Foundation/Foundation.h>

// TourFinishCheck
extern NSString * const TourFinishCheckNone;
extern NSString * const TourFinishCheckMSG;
extern NSString * const TourFinishCheckErr;

extern NSString * const HermesApp_SYSVAL_DEMO_MODE;
extern NSString * const HermesApp_SYSVAL_RUN_withTourType;
extern NSString * const HermesApp_SYSVAL_RUN_withTourAdjustment;
extern NSString * const HermesApp_SYSVAL_RUN_withTourFinishCheck;

extern NSString * const HermesApp_Branding;
// brandings
extern NSString * const BrandingETA;
extern NSString * const BrandingUnilabs;
extern NSString * const BrandingCCC_Group;
extern NSString * const BrandingCCC;
extern NSString * const BrandingCTR;
extern NSString * const BrandingCGR;
extern NSString * const BrandingOerlikon;
extern NSString * const BrandingBiopartner;
extern NSString * const BrandingRegent;
extern NSString * const BrandingWebStar;
extern NSString * const BrandingViollier;
extern NSString * const BrandingFrigo;
extern NSString * const BrandingTechnopark;
extern NSString * const BrandingNONE;

// SystemValues "NO plist" debug mode
extern NSString * const HermesApp_SYSVAL_DEBUG_MODE;

@interface NSUserDefaults (Additions)

+ (void) clearTourDataCache;

+ (NSSet *)currentLicensedLanguages;
+ (BOOL )currentModeIsDebug;
+ (BOOL )currentTourWithTourAdjustment;

+ (NSDate *) enterpriseDistributionVersionCheckDate;
+ (void) setEnterpriseDistributionVersionCheckDate:(NSDate *)checkDate;

+ (NSString *) selfDistributionServerURL;

+ (NSString *) hermesServerHost;
+ (NSString *) hermesServerScheme;
+ (NSString *) hermesServerPath;
+ (NSString *) hermesServerPort;

+ (NSString *) currentTC;
+ (void) setCurrentTC:(NSString *) currentTC;

+ (NSString *) boxBarcode;
+ (void) setBoxBarcode:(NSString *) boxBarcode;

+ (NSNumber *) currentUserID;
+ (void) setCurrentUserID:(NSNumber *) currentUserID;

+ (NSNumber *) currentTruckId;
+ (void) setCurrentTruckId:(NSNumber *) truckId;

+ (NSNumber *) currentTourId;
+ (void) setCurrentTourId:(NSNumber *) tourId;

+ (NSNumber *) currentStintDayOfWeek;
+ (void) setCurrentStintDayOfWeek:(NSNumber *)currentStintDayOfWeek;

+ (NSString *) currentStintDayOfWeekName;
+ (void) setCurrentStintDayOfWeekName:(NSString *)currentStintDayOfWeekName;

+ (NSString *) currentStintStart;
+ (void) setCurrentStintStart:(NSString *) currentStintStart;

+ (NSNumber *) currentStintPauseTime;
+ (void) setCurrentStintPauseTime:(NSNumber *) currentStintPauseTime;

+ (NSNumber *) currentStintDidQuitLoading;
+ (void) setCurrentStintDidQuitLoading:(NSNumber *) currentStintDidQuitLoading;

+ (NSString *) currentPrinterID;
+ (void) setCurrentPrinterID: (NSString*) printerID;

+ (NSString*) currentPrinterAddress;
+ (void) setCurrentPrinterAddress:(NSString *)printerAddress;

+ (BOOL) isRunningWithTourAdjustment;
+ (BOOL) isRunningWithBoxWithArticle;
+ (BOOL) isRunningWithFlexibleUnload;
+ (BOOL) isRunningWithTourType:(NSString *) tourType;
+ (BOOL) isBranding:(NSString *) brandingName;
+ (NSString *) tourFinishCheckValue;
+ (NSString *) branding;
+ (void) setBranding:(NSString *) branding;

+ (void)registerDefaultsFromSettingsBundlePlist:(NSString *)aPlist force:(BOOL)force;

+ (NSArray *) customizableSettingsFileNames;

+ (void)setSystemValue:(id )value forKey:(NSString *)key;
+ (id )systemValueForKey:(NSString *)key;

+ (NSArray *) allBrandings;

@end

extern NSString * const NSUserDefaultsCurrentInventoryIDKey;
extern NSString * const NSUserDefaultsCurrentInventoryPositionNumberKey;

@interface NSUserDefaults (Counters)
+ (NSNumber *) nextTransportPackagingId;
+ (NSNumber *) nextTraceLogId;
+ (NSNumber *) nextTemplateHeadId;
+ (NSNumber *) nextInventoryPositionNumber;
+ (NSNumber *) nextInventoryId;
+ (NSNumber *) nextOrderHeadId;
+ (NSNumber *) nextLocationAliasId;
+ (NSNumber *) nextTransportGroupId;
+ (NSNumber *) nextTransportId;
@end
