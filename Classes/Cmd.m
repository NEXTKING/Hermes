//
//  Cmd.m
//  dphHermes
//
//  Created by iLutz on 09.06.15.
//
//

@implementation Cmd

// CALL (Call Program)
+ (NSError *)call:(NSString *)program parameters:(NSDictionary *)parameters {
    return [Pgm execute:program withParameters:parameters];
}

// CALL (Call Program)
+ (NSError *)call:(NSString *)program {
    return [Cmd call:program parameters:nil];
}

// STRDBG (Start Debug)
+ (NSError *)startDebug {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmStartDebug"];
}

// ENDDBG (End Debug Mode)
+ (NSError *)endDebug {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmEndDebug"];
}

// STRPSNRCV (Start Push Notification Receiver)
+ (NSError *)startPushNotificationReceiver {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmStartPushNotificationReceiver"];
}

// INZUSRDFTE (Initialize User Default Entries)
+ (NSError *)initializeUserDefaultEntries:(NSString *)plist force:(BOOL)force {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmInitializeUserDefaultEntries"
          parameters:@{@"plist": plist, @"force": [NSNumber numberWithBool:force]}];
}

// INZTSTCFG (Initialize Test Configuration)
+ (NSError *)initializeTestConfig {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    NSError *error = [Cmd call:@"PgmClearDB"];
    if (error) return error;
    else       return [Cmd call:@"PgmInitializeUserDefaultEntries"
                     parameters:@{@"plist": @"ServerInfo.t.plist", @"force": [NSNumber numberWithBool:YES]}];
}

// INZPRDCFG (Initialize productive Configuration)
+ (NSError *)initializeProdConfig {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    NSError *error = [Cmd call:@"PgmClearDB"];
    if (error) return error;
    else       return [Cmd call:@"PgmInitializeUserDefaultEntries"
                     parameters:@{@"plist": @"ServerInfo.plist", @"force": [NSNumber numberWithBool:YES]}];
}

// INZDDB (Initialize Demo Database)
+ (NSError *)initializeDemoDB {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmInitializeDemoDB"];
}

// INZIMGDIR (Initialize Image Directory)
+ (NSError *)initializeImageDirectory:(NSString *)directory {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmInitializeImageDirectory"
          parameters:@{@"directory": directory}];
}

// RVKIFSPMN (Revoke iTunes File Sharing Permission)
+ (NSError *)revokeItunesFileSharingPermission:(NSString *)fileName {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmRevokeItunesFileSharingPermission"
          parameters:@{@"fileName": fileName}];
}

// CLRDB (Clear Database)
+ (NSError *)clearDB {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmClearDB"];
}

// SAVUSRDFTE (Save User Default Entries)
+ (NSError *)saveUserDefaultEntries {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmSaveUserDefaultEntries"
          parameters:@{@"backupPlist": @"Library/recentProductiveModeUserDefaults.plist"}];
}

// SAVUSRDFTE (Save User Default Entries)
+ (NSError *)saveUserDefaultEntries:(NSString *)backupPlist {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmSaveUserDefaultEntries"
          parameters:@{@"backupPlist": backupPlist}];
}

// RSTUSRDFTE (Restore User Default Entries)
+ (NSError *)restoreUserDefaultEntries {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmRestoreUserDefaultEntries"
          parameters:@{@"backupPlist": @"Library/recentProductiveModeUserDefaults.plist"}];
}

// RSTUSRDFTE (Restore User Default Entries)
+ (NSError *)restoreUserDefaultEntries:(NSString *)backupPlist {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmRestoreUserDefaultEntries"
          parameters:@{@"backupPlist": backupPlist}];
}

// SNDMSG (Send Message)
+ (NSError *)sendMessage {
    PFDebugLog(@"Cmd %@", NSStringFromSelector(_cmd));
    return [Cmd call:@"PgmSendMessage"
          parameters:@{@"message": @""}];
}

@end