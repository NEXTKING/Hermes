//
//  NSUserDefaults+Additions.m
//  dphHermes
//
//  Created by Tomasz Kransyk on 29.04.15.
//
//

#import "NSUserDefaults+Additions.h"

// System variables

// TourFinishCheck
NSString * const TourFinishCheckNone = @"NONE";
NSString * const TourFinishCheckMSG = @"MSG";
NSString * const TourFinishCheckErr = @"ERR";

// Hermes Server
static NSString * const NSUserDefaultsHermesServerSchemeKey = @"HermesApp_SYSVAL_SCHEME";
static NSString * const NSUserDefaultsHermesServerHostKey = @"HermesApp_SYSVAL_HOST";
static NSString * const NSUserDefaultsHermesServerPathKey = @"HermesApp_SYSVAL_PATH";
static NSString * const NSUserDefaultsHermesServerPortKey = @"HermesApp_SYSVAL_PORT";

// Hermes Self Distribution
static NSString * const NSUserDefaultsSelfDistSchemeKey                 = @"HermesSelfDistribution_SYSVAL_SCHEME";
static NSString * const NSUserDefaultsSelfDistUserKey                   = @"HermesSelfDistribution_SYSVAL_USER";
static NSString * const NSUserDefaultsSelfDistPasswordKey               = @"HermesSelfDistribution_SYSVAL_PASSWORD";
static NSString * const NSUserDefaultsSelfDistHostKey                   = @"HermesSelfDistribution_SYSVAL_HOST";
static NSString * const NSUserDefaultsSelfDistPortKey                   = @"HermesSelfDistribution_SYSVAL_PORT";
static NSString * const NSUserDefaultsSelfDistPathKey                   = @"HermesSelfDistribution_SYSVAL_PATH";
static NSString * const NSUserDefaultsSelfDistVersionCheckDateKey       = @"enterpriseDistributionVersionCheckDate";

static NSString * const NSUserDefaultsHermesRunsWithTourAdjustmentKey = @"HermesApp_SYSVAL_RUN_withTourAdjustment";
static NSString * const NSUserDefaultsHermesRunsWithTourTypeKey = @"HermesApp_SYSVAL_RUN_withTourType";
static NSString * const NSUserDefaultsHermesRunsWithBoxWithArticleKey = @"HermesApp_SYSVAL_RUN_withBoxWithArticle";
static NSString * const NSUserDefaultsHermesRunsWithFlexibleUnload = @"HermesApp_SYSVAL_RUN_withFlexibleUnload";
static NSString * const NSUserDefaultsCurrentTCKey = @"currentTC";

static NSString * const NSUserDefaultsBoxBarcodeKey = @"boxBarcode";
static NSString * const NSUserDefaultsCurrentTruckIdKey = @"currentTruckID";
static NSString * const NSUserDefaultsCurrentTourIdKey = @"currentTourID";
static NSString * const NSUserDefaultsCurrentUserIDKey =  @"currentUserID";
static NSString * const NSUserDefaultsCurrentStintDayOfWeekKey = @"CurrentStintDayOfWeek";
static NSString * const NSUserDefaultsCurrentStintDayOfWeekNameKey =  @"CurrentStintDayOfWeekName";
static NSString * const NSUserDefaultsCurrentStintStartKey =  @"CurrentStintStart";
static NSString * const NSUserDefaultsCurrentStintPauseTimeKey =  @"CurrentStintPauseTime";
static NSString * const NSUserDefaultsCurrentStintDidQuitLoadingKey =  @"CurrentStintDidQuitLoading";

static NSString * const NSUserDefaultsUdidKey = @"udid";
static NSString * const NSUserDefaultsBrandingKey = @"HermesApp_Branding";
static NSString * const NSUserDefaultsPrinterIdKey = @"PrinterID";
static NSString * const NSUserDefaultsPrinterAddressKey = @"PrinterAddress";

NSString * const HermesApp_SYSVAL_DEMO_MODE = @"HermesApp_SYSVAL_DEMO_MODE";
NSString * const HermesApp_SYSVAL_RUN_withTourType = @"HermesApp_SYSVAL_RUN_withTourType";
NSString * const HermesApp_SYSVAL_RUN_withTourAdjustment = @"HermesApp_SYSVAL_RUN_withTourAdjustment";
NSString * const HermesApp_SYSVAL_RUN_withTourFinishCheck = @"HermesApp_SYSVAL_RUN_withTourFinishCheck";

NSString * const HermesApp_Branding = @"HermesApp_Branding";
// brandings
NSString * const BrandingETA = @"ETA";
NSString * const BrandingUnilabs = @"Unilabs";
NSString * const BrandingCCC_Group = @"CCC_Group";
NSString * const BrandingCCC = @"CCC";
NSString * const BrandingCTR = @"CTR";
NSString * const BrandingCGR = @"CGR";
NSString * const BrandingOerlikon = @"oerlikon";
NSString * const BrandingBiopartner = @"biopartner";
NSString * const BrandingRegent = @"Regent";
NSString * const BrandingWebStar = @"WebStar";
NSString * const BrandingViollier = @"viollier";
NSString * const BrandingFrigo = @"frigo";
NSString * const BrandingTechnopark = @"tchp";
NSString * const BrandingNONE = @"none";

// SystemValues "NO plist" debug mode
NSString * const HermesApp_SYSVAL_DEBUG_MODE = @"HermesApp_SYSVAL_DEBUG_MODE";

@implementation NSUserDefaults (Additions)

+ (void) clearTourDataCache {
    [NSUserDefaults setCurrentTourId:nil];
    [NSUserDefaults setCurrentTruckId:nil];
    [NSUserDefaults setCurrentStintStart:nil];
    [NSUserDefaults setCurrentStintDayOfWeek:nil];
    [NSUserDefaults setCurrentStintPauseTime:nil];
    [NSUserDefaults setCurrentStintDidQuitLoading:nil];
}

+ (NSSet *)currentLicensedLanguages {
    NSMutableSet *languages = [NSMutableSet set];
    [languages addObject:@"de"];
    if (PFBrandingSupported(BrandingNONE, BrandingViollier, BrandingCCC_Group, BrandingETA, BrandingUnilabs, nil)) {
        [languages addObject:@"fr"];
    }
    if (PFBrandingSupported(BrandingNONE, BrandingViollier, BrandingCCC_Group, BrandingUnilabs, nil)) {
        [languages addObject:@"it"];
    }
    if (PFBrandingSupported(BrandingNONE, BrandingViollier, nil)) {
        [languages addObject:@"ru"];
    }
    if (PFBrandingSupported(BrandingNONE, BrandingUnilabs, nil)) {
        [languages addObject:@"en"];
    }
#warning Testing
    if (PFBrandingSupported(BrandingTechnopark, nil)){
        [languages addObject:@"en"];
        [languages addObject:@"ru"];
    }
    return [NSSet setWithSet:languages];
}

+ (BOOL )currentModeIsDebug {
    return [[self systemValueForKey:HermesApp_SYSVAL_DEBUG_MODE] boolValue];
}

+ (BOOL )currentTourWithTourAdjustment {
    return [[self systemValueForKey:HermesApp_SYSVAL_RUN_withTourAdjustment] isEqualToString:@"TRUE"];
}

+ (NSString *) selfDistributionServerURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedPort = [defaults stringForKey:NSUserDefaultsSelfDistPortKey];
    NSString *port = @"";
    if (savedPort && ![savedPort isEqualToString:@""] && ![savedPort isEqualToString:@"21"] && ![savedPort isEqualToString:@"80"]) {
        port = [port stringByAppendingFormat:@":%@", savedPort];
    }
    NSString *scheme = [defaults stringForKey:NSUserDefaultsSelfDistSchemeKey];
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.1" options:NSNumericSearch] != NSOrderedAscending) {
        scheme = @"http";
    }
    
    NSString *URL  = [NSString stringWithFormat:@"%@://%@:%@@%@%@/%@",
                              scheme,
                              [defaults stringForKey:NSUserDefaultsSelfDistUserKey],
                              [defaults stringForKey:NSUserDefaultsSelfDistPasswordKey],
                              [defaults stringForKey:NSUserDefaultsSelfDistHostKey],
                              port,
                              [defaults stringForKey:NSUserDefaultsSelfDistPathKey]];
    return URL;
}

+ (NSString *) hermesServerHost {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NSUserDefaultsHermesServerHostKey];
}

+ (NSString *) hermesServerScheme {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NSUserDefaultsHermesServerSchemeKey];
}

+ (NSString *) hermesServerPath {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NSUserDefaultsHermesServerPathKey];
}

+ (NSString *) hermesServerPort {
    return [[NSUserDefaults standardUserDefaults] stringForKey:NSUserDefaultsHermesServerPortKey];
}

+ (NSNumber *) currentUserID {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentUserIDKey];
}

+ (void) setCurrentUserID:(NSNumber *) currentUserID {
    [self setOrRemoveValue:currentUserID forKey:NSUserDefaultsCurrentUserIDKey];
}

+ (NSString *) boxBarcode {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsBoxBarcodeKey];
}

+ (void) setBoxBarcode:(NSString *) boxBarcode {
    [self setOrRemoveValue:boxBarcode forKey:NSUserDefaultsBoxBarcodeKey];
}

+ (NSNumber *) currentTruckId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentTruckIdKey];
}

+ (void) setCurrentTruckId:(NSNumber *) truckId {
    [self setOrRemoveValue:truckId forKey:NSUserDefaultsCurrentTruckIdKey];
}

+ (NSNumber *) currentTourId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentTourIdKey];
}

+ (void) setCurrentTourId:(NSNumber *) tourId {
    [self setOrRemoveValue:tourId forKey:NSUserDefaultsCurrentTourIdKey];
}

+ (NSNumber *) currentStintDayOfWeek {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentStintDayOfWeekKey];
}

+ (void) setCurrentStintDayOfWeek:(NSNumber *)currentStintDayOfWeek {
    [self setOrRemoveValue:currentStintDayOfWeek forKey:NSUserDefaultsCurrentStintDayOfWeekKey];
}

+ (NSString *) currentStintDayOfWeekName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentStintDayOfWeekNameKey];
}

+ (void) setCurrentStintDayOfWeekName:(NSString *)currentStintDayOfWeekName {
    [self setOrRemoveValue:currentStintDayOfWeekName forKey:NSUserDefaultsCurrentStintDayOfWeekNameKey];
}

+ (NSString *) currentTC {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentTCKey];
}

+ (void) setCurrentTC:(NSString *) currentTC {
    [self setOrRemoveValue:currentTC forKey:NSUserDefaultsCurrentTCKey];
}

+ (NSString *) currentStintStart {
   return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentStintStartKey];
}

+ (void) setCurrentStintStart:(NSString *) currentStintStart {
    [self setOrRemoveValue:currentStintStart forKey:NSUserDefaultsCurrentStintStartKey];
}

+ (NSNumber *) currentStintPauseTime {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentStintPauseTimeKey];
}

+ (void) setCurrentStintPauseTime:(NSNumber *)currentStintPauseTime {
    [self setOrRemoveValue:currentStintPauseTime forKey:NSUserDefaultsCurrentStintPauseTimeKey];
}

+ (NSNumber *) currentStintDidQuitLoading {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsCurrentStintDidQuitLoadingKey];
}

+ (void) setEnterpriseDistributionVersionCheckDate:(NSDate *)checkDate {
    [self setOrRemoveValue:checkDate forKey:NSUserDefaultsSelfDistVersionCheckDateKey];
}

+ (NSDate *) enterpriseDistributionVersionCheckDate {
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsSelfDistVersionCheckDateKey];
}

+ (void) setCurrentStintDidQuitLoading:(NSNumber *) currentStintDidQuitLoading {
    [self setOrRemoveValue:currentStintDidQuitLoading forKey:NSUserDefaultsCurrentStintDidQuitLoadingKey];
}

+ (NSString *) tourFinishCheckValue {
    return [[NSUserDefaults standardUserDefaults] valueForKey:HermesApp_SYSVAL_RUN_withTourFinishCheck];
}

+ (BOOL) isRunningWithTourAdjustment {
    
    if (PFBrandingSupported(BrandingTechnopark, nil))
        return YES;
    return [[[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsHermesRunsWithTourAdjustmentKey] isEqualToString:@"TRUE"];
}

+ (BOOL) isRunningWithTourType:(NSString *) tourType {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsHermesRunsWithTourTypeKey] isEqualToString:tourType];
}

+ (BOOL) isRunningWithBoxWithArticle {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsHermesRunsWithBoxWithArticleKey] isEqualToString:@"TRUE"];
}

+ (BOOL) isRunningWithFlexibleUnload {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsHermesRunsWithFlexibleUnload] isEqualToString:@"TRUE"];
}

+ (BOOL) isBranding:(NSString *) brandingName {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsBrandingKey] isEqualToString:brandingName];
}

+ (NSString *) branding {
    return [[NSUserDefaults standardUserDefaults] valueForKey:HermesApp_Branding];
}

+ (void) setBranding:(NSString *) branding {
    return [NSUserDefaults setSystemValue:branding forKey:HermesApp_Branding];
}


+ (NSString*) currentPrinterID
{
     return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsPrinterIdKey];
}

+ (void) setCurrentPrinterID:(NSString *)printerID
{
    return [NSUserDefaults setSystemValue:printerID forKey:NSUserDefaultsPrinterIdKey];
}

+ (NSString*) currentPrinterAddress
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:NSUserDefaultsPrinterAddressKey];
}

+ (void) setCurrentPrinterAddress:(NSString *)printerAddress
{
    return [NSUserDefaults setSystemValue:printerAddress forKey:NSUserDefaultsPrinterAddressKey];
}


/*!
 Method opens a plist file, reads and parses its content and sets defined key
 value pairs in NSUserDefaults standardUserDefaults. \n
 \params NSString *nameOfPlist
 */
+ (void)registerDefaultsFromSettingsBundlePlist:(NSString *)aPlist force:(BOOL)force {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(settingsBundle) {
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:aPlist]];
        NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
        for (NSDictionary *prefSpecification in preferences) {
            NSString *key  = [prefSpecification objectForKey:@"Key"];
            NSString *type = [prefSpecification objectForKey:@"Type"];
            if (key) {
                // check if value readable in userDefaults
                id currentObject = [defaults objectForKey:key];
                if (!currentObject || force) {
                    // not readable: set value from Settings.bundle
                    if ([type isEqualToString:@"PSToggleSwitchSpecifier"]) {
                        if ([[prefSpecification objectForKey:@"DefaultValue"] boolValue]) {
                            [defaults setObject:[NSNumber numberWithBool:YES] forKey:key];
                        } else {
                            [defaults setObject:[NSNumber numberWithBool:NO]  forKey:key];
                        }
                    } else {
                        [defaults setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
                    }
                } else {
                    // already readable: don't touch
                }
            }
        }
        [defaults synchronize];
    }
}

+ (NSArray *) customizableSettingsFileNames {
    return [NSArray arrayWithObjects:
            @"ServerInfo.plist",
            @"ApplicationInfo.plist",
            @"BarcodeEngine.plist",
            nil];
}

+ (NSArray *) allBrandings {
    return [NSArray arrayWithObjects:
            BrandingETA,
            BrandingUnilabs,
            BrandingCCC,
            BrandingCTR,
            BrandingCGR,
            BrandingFrigo,
            BrandingOerlikon,
            BrandingBiopartner,
            BrandingRegent,
            BrandingWebStar,
            BrandingViollier,
            BrandingTechnopark,
            BrandingNONE,
            nil];
}

#pragma mark - Private

+ (void) setOrRemoveValue:(id) value forKey:(NSString *) key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (value) {
        [defaults setObject:value forKey:key];
    } else {
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
}

+ (BOOL) isBrandingCavegn {
    return PFBrandingSupported(BrandingCCC_Group, nil);
}

+ (void)setSystemValue:(id )value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

+ (id )systemValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

@end


// counters
static NSString * const NSUserDefaultsCurrentTransportGroupIDKey =  @"currentTransportGroupID";
static NSString * const NSUserDefaultsCurrentTransportIDKey =  @"currentTransportID";
static NSString * const NSUserDefaultsCurrentLocationAliasIDKey = @"currentLocationAliasID";
static NSString * const NSUserDefaultsCurrentOrderHeadIDKey = @"currentOrderHeadID";
static NSString * const NSUserDefaultsCurrentTemplateHeadIDKey = @"currentTemplateHeadID";
static NSString * const NSUserDefaultsCurrentTraceLogIDKey = @"currentTraceLogID";
static NSString * const NSUserDefaultsCurrentTransportPackagingIDKey = @"currentTransportPackagingID";

// public
NSString * const NSUserDefaultsCurrentInventoryIDKey = @"currentInventoryID";
NSString * const NSUserDefaultsCurrentInventoryPositionNumberKey = @"currentInventoryLinePositionNumber";

@implementation NSUserDefaults (Counters)

+ (NSNumber *) nextTransportPackagingId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentTransportPackagingIDKey];
}

+ (NSNumber *) nextTraceLogId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentTraceLogIDKey];
}

+ (NSNumber *) nextTemplateHeadId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentTemplateHeadIDKey];
}

+ (NSNumber *) nextInventoryPositionNumber {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentInventoryPositionNumberKey];
}

+ (NSNumber *) nextInventoryId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentInventoryIDKey];
}

+ (NSNumber *) nextOrderHeadId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentOrderHeadIDKey];
}

+ (NSNumber *) nextLocationAliasId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentLocationAliasIDKey];
}

+ (NSNumber *) nextTransportGroupId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentTransportGroupIDKey];
}

+ (NSNumber *) nextTransportId {
    return [NSUserDefaults nextIdForKey:NSUserDefaultsCurrentTransportIDKey];
}

+ (NSNumber *) nextIdForKey:(NSString *) defaultsKey {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [defaults valueForKey:defaultsKey];
    if (!number) {
        number = [NSNumber numberWithLong:1];
    }
    [self setOrRemoveValue:[NSNumber numberWithLong:[number longValue] + 1] forKey:defaultsKey];
    return number;
}

@end
