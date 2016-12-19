//
//  ProgramFacility.m
//  dphHermes
//
//  Created by Lutz Thalmann on 04.06.15.
//
//

#pragma mark Runtime APIs

NSDictionary * PFDebugGetCaller() {
    NSCharacterSet *callStackSeparatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSUInteger callerStackIndex = 1; // 0 = PFDebugGetCaller, 0 = "self"
    NSArray  *callStackArray  = [NSThread callStackSymbols];
    NSString *callStackString = [callStackArray objectAtIndex:callerStackIndex];
    NSMutableArray *callerArray = [NSMutableArray arrayWithArray:
                                   [callStackString componentsSeparatedByCharactersInSet:callStackSeparatorSet]];
    [callerArray removeObject:@""];
    if ((callerStackIndex + 2) < callStackArray.count) {
        callerStackIndex ++;
        callStackString = [callStackArray objectAtIndex:callerStackIndex];
        callerArray = [NSMutableArray arrayWithArray:
                          [callStackString componentsSeparatedByCharactersInSet:callStackSeparatorSet]];
        [callerArray removeObject:@""];
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (callerArray.count > 0) [userInfo setObject:[callerArray objectAtIndex:0] forKey:@"CallStack"];
    if (callerArray.count > 1) [userInfo setObject:[callerArray objectAtIndex:1] forKey:@"Framework"];
    if (callerArray.count > 2) [userInfo setObject:[callerArray objectAtIndex:2] forKey:@"MemoryAddress"];
    if (callerArray.count > 3) [userInfo setObject:[callerArray objectAtIndex:3] forKey:@"CallerClass"];
    if (callerArray.count > 4) [userInfo setObject:[callerArray objectAtIndex:4] forKey:@"CallerFunction"];
    if (callerArray.count > 5) [userInfo setObject:[callerArray objectAtIndex:5] forKey:@"CallerLine"];
    return [NSDictionary dictionaryWithDictionary:userInfo];
}

void PFDebugLog(NSString *format, ...) {
    if ([NSUserDefaults currentModeIsDebug]) {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);
    }
}

extern BOOL PFCurrentModeIsDemo() {
    return ((HermesAppDelegate *)[[UIApplication sharedApplication] delegate]).currentAppModeIsDemo;
}

#pragma mark OperatingSystem APIs

NSString * iOSVersionFromString(NSString *version) {
    NSArray *components = [version componentsSeparatedByString:@"."];
    NSMutableString *correctedVersion = [[NSMutableString alloc] init];
    for (NSString *component in components) {
        if ([correctedVersion length] == 0) {
            [correctedVersion appendFormat:@"%@.", component];
        } else {
            [correctedVersion appendString:component];
        }
    }
    return [correctedVersion copy];
}

CGFloat iosVersion() {
    NSString *version = iOSVersionFromString([[UIDevice currentDevice] systemVersion]);
    return [version floatValue];
}

NSString * PFOsVersion() {
    return [[UIDevice currentDevice] systemVersion];
}

BOOL PFOsVersionCompareLT(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending);
}

BOOL PFOsVersionCompareLE(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending);
}

BOOL PFOsVersionCompareEQ(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame);
}

BOOL PFOsVersionCompareGE(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending);
}

BOOL PFOsVersionCompareGT(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending);
}

#pragma mark Device APIs

NSString * PFDeviceId() {
    // TODO NEW: udid = [[[UIDevice currentDevice].identifierForVendor UUIDString] retain];
    //
    // OR Mac Address
    //
    if (PFBrandingSupported(BrandingTechnopark, nil))
        return @"SIMULATOR";
    if (PFDeviceIsSimulator()) return @"SIMULATOR";
    //return [[UIDevice currentDevice] valueForKey:@"uniqueIdentifier"];
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

BOOL PFDeviceIsSimulator() {
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *deviceName = [[UIDevice currentDevice] name];
    BOOL modelIsSimulator = ([deviceModel length] > 8 && [deviceModel rangeOfString:@"Simulator"].location != NSNotFound);
    BOOL nameIsSimulator = ([deviceName length] > 8 && [deviceName rangeOfString:@"Simulator"].location != NSNotFound);
    return modelIsSimulator || nameIsSimulator;
}

#pragma mark Application APIs

BOOL PFTourTypeSupported(NSString *types, ...) {
    NSMutableSet *checkList = [NSMutableSet set];
    va_list args;
    va_start(args, types);
    for (NSString *type = types; type != nil; type = va_arg(args, NSString *)) {
        [checkList addObject:type];
    }
    va_end(args);
    return ([checkList member:[NSUserDefaults systemValueForKey:HermesApp_SYSVAL_RUN_withTourType]] != nil);
}

BOOL PFBrandingSupported(NSString *brandings, ...) {
    NSMutableSet *checkList = [NSMutableSet set];
    va_list args;
    va_start(args, brandings);
    for (NSString *branding = brandings; branding != nil; branding = va_arg(args, NSString *)) {
        if ([branding isEqualToString:BrandingCCC_Group]) {
            [checkList addObject:BrandingCCC];
            [checkList addObject:BrandingCGR];
            [checkList addObject:BrandingCTR];
            [checkList addObject:BrandingFrigo];
        } else {
            [checkList addObject:branding];
        }
    }
    va_end(args);
    NSString *currentBranding = [NSUserDefaults systemValueForKey:HermesApp_Branding];
    if (!currentBranding) currentBranding = BrandingNONE;
    return ([checkList member:currentBranding] != nil);
}

extern BOOL PFLanguageSupported(NSSet *languages) {
    return ([languages member:[currentLocaleCode() substringToIndex:2]] != nil);
}

extern UIImage *PFBrandingLogo() {
    NSString *branding = [NSUserDefaults systemValueForKey:HermesApp_Branding];
    if (branding) return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:
                                                           [branding stringByAppendingString:@"_logo"] ofType:@"png"]];
    return nil;
}

#pragma mark Settings APIs

extern NSInteger PFHermesServerVersion() {
    NSInteger version = 1;
    if (PFBrandingSupported(BrandingETA, BrandingCCC_Group, BrandingUnilabs, BrandingNONE,BrandingTechnopark, nil)) {
        version = 2;
    }
    return version;
}