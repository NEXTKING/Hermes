//
//  Pgm.m
//  dphHermes
//
//  Created by iLutz on 09.06.15.
//
//

// #import "Message.h"
#import <objc/message.h>

NSDictionary * ProgramLibrary = nil;
NSString * const CPFErrorDomain = @"CPF"; // IBM -> Control Program Function

@interface Pgm()

typedef NSError * (^program)(NSDictionary *);

@end

@implementation Pgm

+ (NSError *)execute:(NSString *)pgm withParameters:(NSDictionary *)parm {
    if (!ProgramLibrary) { ProgramLibrary = @ {
            @"PgmStartDebug" : ^() {
                PFDebugLog(@"PgmStartDebug");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HermesApp_SYSVAL_DEBUG_MODE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return (NSError *)nil;
            },
            @"PgmEndDebug" : ^() {
                PFDebugLog(@"PgmEndDebug");
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:HermesApp_SYSVAL_DEBUG_MODE];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return (NSError *)nil;
            },
            @"PgmStartPushNotificationReceiver" : ^() {
                PFDebugLog(@"PgmStartPushNotificationReceiver");
                UIApplication *app = [UIApplication sharedApplication];
                if (PFTourTypeSupported(@"0X1", @"1X1", nil) || PFHermesServerVersion() >= 2) {
                    if (PFOsVersionCompareGE(@"8.0")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        id currentSettings = [app performSelector:NSSelectorFromString(@"currentUserNotificationSettings")];
#pragma clang diagnostic pop
                        NSUInteger allowedTypes = [[currentSettings valueForKeyPath:@"types"] unsignedIntegerValue];
                        if (allowedTypes == 0 /*None*/) {
                            // using hardcoded values for "UIUserNotificationType" instead of constants to allow backwards compatibility
                            NSUInteger types = (1 << 0/*Badge*/) | (1 << 1/*Sound*/) | (1 << 2/*Alert*/);
                            Class clz = NSClassFromString(@"UIUserNotificationSettings");
                            SEL selector = NSSelectorFromString(@"settingsForTypes:categories:");
                            PFDebugLog(@"Registering user notification setting types: %lu", (unsigned long)types);
                            id settings = objc_msgSend(clz, selector, types, nil);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [app performSelector:NSSelectorFromString(@"registerUserNotificationSettings:") withObject:settings];
#pragma clang diagnostic pop
                        } else {
                            PFDebugLog(@"Registering for push notificaitons");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                            [app performSelector:NSSelectorFromString(@"registerForRemoteNotifications") withObject:nil];
#pragma clang diagnostic pop
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        }
                    } else {
                        // using hardcoded values for "UIRemoteNotificationType" to avoid deprecation warnings under iOS 8 and later
                        NSUInteger types = (1 << 0/*Badge*/) | (1 << 1/*Sound*/) | (1 << 2/*Alert*/) | (1 << 3/*NewsstandContentAvailability*/);
                        [app registerForRemoteNotificationTypes:types];
                    }
                }
                return (NSError *)nil;
            },
            @"PgmInitializeUserDefaultEntries" : ^(NSDictionary *theParameters) {
                PFDebugLog(@"PgmInitializeUserDefaultEntries %@", theParameters);
                /*!
                 Open the plist file, read and pars its content and set defined key
                 value pairs in NSUserDefaults standardUserDefaults. \n
                 \params NSString *nameOfPlist
                 */
                NSString *plist    = [theParameters valueForKey:@"plist"];
                BOOL      force    = [[theParameters valueForKey:@"force"] boolValue];
                NSString *branding = [NSUserDefaults systemValueForKey:HermesApp_Branding];
                if (branding && !PFCurrentModeIsDemo()) {
                    if (PFBrandingSupported(BrandingCCC_Group, nil))
                        plist = [@"CCC" stringByAppendingPathComponent:plist];
                    else
                        plist = [branding stringByAppendingPathComponent:plist];
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
                if(settingsBundle) {
                    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:plist]];
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
                return (NSError *)nil;
            },
            @"PgmRevokeItunesFileSharingPermission" : ^(NSDictionary *theParameters) {
                PFDebugLog(@"PgmRevokeItunesFileSharingPermission %@", theParameters);
                NSString *fileName = [theParameters valueForKey:@"fileName"];
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSString *srcFile      = [NSHomeDirectory()
                                          stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]];
                NSString *tgtFile      = [NSHomeDirectory()
                                          stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/%@", fileName]];
                if(![fileMgr fileExistsAtPath:srcFile])
                    return (NSError *)nil; // o.k. - the file was already moved or does not exist at this time
                NSError *error   = nil;
                if([fileMgr isReadableFileAtPath:srcFile] && [fileMgr fileExistsAtPath:tgtFile]) {
                    [fileMgr removeItemAtPath:tgtFile error:&error];
                    if (error) {
                        // code = 9899 IBM -> Error occurred during processing of command.
                        NSLog(@"PgmRevokeItunesFileSharingPermission: %@, %@", error, [error userInfo]);
                        return (NSError *)[NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:error.userInfo];
                    }
                }
                [fileMgr moveItemAtPath:srcFile toPath:tgtFile error:&error];
                if (error) {
                    // code = 9899 IBM -> Error occurred during processing of command.
                    NSLog(@"PgmRevokeItunesFileSharingPermission: %@, %@", error, [error userInfo]);
                    return (NSError *)[NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:error.userInfo];
                }
                return (NSError *)nil;
            },
            @"PgmInitializeDemoDB" : ^() {
                PFDebugLog(@"PgmInitializeDemoDB");
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSString *srcFile      = [[NSBundle mainBundle] pathForResource:@"Demo_orig" ofType:@"sqlite"];
                NSString *tgtFile      = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Demo.sqlite"];
                NSError *error   = nil;
                if([fileMgr fileExistsAtPath:tgtFile]) {
                    if(![fileMgr removeItemAtPath:tgtFile error:&error]) {
                        if (error) {
                            // code = 9899 IBM -> Error occurred during processing of command.
                            NSLog(@"PgmInitializeDemoDB: %@, %@", error, [error userInfo]);
                            return (NSError *)[NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:error.userInfo];
                        }
                    }
                }
                if(![fileMgr copyItemAtPath:srcFile toPath:tgtFile error:&error]) {
                    if (error) {
                        // code = 9899 IBM -> Error occurred during processing of command.
                        NSLog(@"PgmInitializeDemoDB: %@, %@", error, [error userInfo]);
                        return (NSError *)[NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:error.userInfo];
                    }
                }
                return (NSError *)nil;
            },
            @"PgmInitializeImageDirectory" : ^(NSDictionary *theParameters) {
                PFDebugLog(@"PgmInitializeImageDirectory %@", theParameters);
                NSString *directory = [theParameters valueForKey:@"directory"];
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                NSString *tgtPath      = [NSHomeDirectory()
                                          stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/%@Images", directory]];
                NSError *error = nil;
                BOOL isDirectory;
                if(![fileMgr fileExistsAtPath:tgtPath isDirectory:&isDirectory] || !isDirectory) {
                    [fileMgr createDirectoryAtPath:tgtPath withIntermediateDirectories:NO attributes:nil error:&error];
                    if (error) {
                        // code = 9899 IBM -> Error occurred during processing of command.
                        NSLog(@"PgmInitializeImageDirectory: %@, %@", error, [error userInfo]);
                        return (NSError *)[NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:error.userInfo];
                    }
                }
                return (NSError *)nil;
            },
            @"PgmClearDB" : ^() {
                PFDebugLog(@"PgmClearDB");
                id applicationDelegate = [[UIApplication sharedApplication] delegate];
                if (![[NSUserDefaults systemValueForKey:HermesApp_SYSVAL_DEMO_MODE] isEqualToString:@"TRUE"] &&
                    [applicationDelegate respondsToSelector:@selector(persistentStoreCoordinator)] &&
                    [applicationDelegate respondsToSelector:@selector(disconnectFromPersistentStore)] &&
                    [applicationDelegate respondsToSelector:@selector(connectToPersistentStore)]) {
                    [applicationDelegate disconnectFromPersistentStore];
                    [NSUserDefaults setSystemValue:@"TRUE" forKey:HermesApp_SYSVAL_DEMO_MODE];
                    [applicationDelegate connectToPersistentStore];
                    NSURL *url = ((NSPersistentStore *)[((NSPersistentStoreCoordinator *)
                                                         [applicationDelegate persistentStoreCoordinator]).persistentStores lastObject]).URL;
                    PFDebugLog(@"... deleting %@", url);
                    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
                    [applicationDelegate disconnectFromPersistentStore];
                    [NSUserDefaults setSystemValue:@"FALSE" forKey:HermesApp_SYSVAL_DEMO_MODE];
                    for (NSString *key in [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]) {
                        if ([key hasPrefix:@"lastUpdate"] || [key hasPrefix:@"current"] || [key hasPrefix:@"Current"])  {
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                        }
                    }
                    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"downloadCacheControl"];
                    [NSUserDefaults setCurrentTourId:nil];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [applicationDelegate connectToPersistentStore];
                }
                return (NSError *)nil;
            },
            @"PgmSaveUserDefaultEntries" : ^(NSDictionary *theParameters) {
                PFDebugLog(@"PgmSaveUserDefaultEntries %@", theParameters);
                NSString *backupPlist    = [theParameters valueForKey:@"backupPlist"];
                [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]
                 writeToFile:[NSHomeDirectory() stringByAppendingPathComponent:backupPlist] atomically:YES];
                return (NSError *)nil;
            },
            @"PgmRestoreUserDefaultEntries" : ^(NSDictionary *theParameters) {
                PFDebugLog(@"PgmRestoreUserDefaultEntries %@", theParameters);
                NSString *backupPlist    = [theParameters valueForKey:@"backupPlist"];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSDictionary *backup = [NSDictionary dictionaryWithContentsOfFile:
                                        [NSHomeDirectory() stringByAppendingPathComponent:backupPlist]];
                for (NSString *key in [backup allKeys]) {
                    if (key && key.length > 0      &&
                        ![key hasPrefix:@"Apple"]  &&
                        ![key hasPrefix:@"NS"]     &&
                        ![key hasPrefix:@"iT"]     &&
                        ![key hasPrefix:@"WebKit"] &&
                        ![key hasPrefix:@"TVOut"]  &&
                        ![key isEqualToString:HermesApp_SYSVAL_DEMO_MODE])  {
                        [userDefaults setObject:[backup objectForKey:key] forKey:key];
                    }
                }
                [userDefaults synchronize];
                return (NSError *)nil;
            }
            /* TODO send a message to the applications main message handler
            ,@"PgmSendMessage" : ^(NSDictionary *theParameters) {
                PFDebugLog(@"PgmSendMessage %@", theParameters);   
                Message *m = [[[Message alloc] init] autorelease];
                m.type = MessageTypeInfo;
                m.format = @"Hallo";
                return (NSError *)nil;
            }
            */
        };
    }
    @try {
        program p = [ProgramLibrary valueForKey:pgm];
        if (p) {
            return p(parm);
        } else {
            NSMutableDictionary * info = [NSMutableDictionary dictionary];
            [info setValue:@"CPF_PgmNotFound" forKey:@"ExceptionName"];
            [info setValue:[NSString stringWithFormat:@"%@ not in ProgramLibrary", pgm] forKey:@"ExceptionReason"];
            // [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
            // [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
            // [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
            // code = 9899 IBM -> Error occurred during processing of command.
            NSError *error = [NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:info];
            NSLog(@"%@: %@", [NSString stringWithString:pgm], error);
            return error;
        }
    }
    @catch (NSException *exception) {
        NSMutableDictionary * info = [NSMutableDictionary dictionary];
        [info setValue:exception.name forKey:@"ExceptionName"];
        [info setValue:exception.reason forKey:@"ExceptionReason"];
        [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
        [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
        [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
        // code = 9899 IBM -> Error occurred during processing of command.
        NSError *error = [NSError errorWithDomain:CPFErrorDomain code:9899 userInfo:info];
        NSLog(@"%@: %@", [NSString stringWithString:pgm], error);
        return error;
        /*
         Preprocessor macros for logging
         
         Note the use of a pair of underscore characters around both sides of the macro.
         
         | Macro                | Format   | Description
         __func__               %s         Current function signature
         __LINE__               %d         Current line number
         __FILE__               %s         Full path to source file
         __PRETTY_FUNCTION__    %s         Like __func__, but includes verbose
         type information in C++ code.
         Expressions for logging
         
         | Expression                       | Format   | Description
         NSStringFromSelector(_cmd)         %@         Name of the current selector
         NSStringFromClass([self class])    %@         Current object's class name
         [[NSString                         %@         Source code file name
         stringWithUTF8String:__FILE__]
         lastPathComponent]
         [NSThread callStackSymbols]        %@         NSArray of stack trace
         */
    }
}

@end
