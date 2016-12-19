//
//  Cmd.h
//  dphHermes
//
//  Created by iLutz on 09.06.15.
//
//

#import <Foundation/Foundation.h>

@interface Cmd : NSObject

/*  Based on IBM's command line interface
 
 common VERB parts
 create     (CRTxxx)
 delete     (DLTxxx)
 add        (ADDxxx)
 remove     (RMVxxx)
 start      (STRxxx)
 end        (ENDxxx)
 initialize (INZxxx)
 configure  (CFGxxx)
 change     (CHGxxx)
 save       (SAVxxx)
 restore    (RSTxxx)
 submit     (SBMxxx)
 Hold       (HLDxxx)
 Release    (RLSxxx)
 grant      (GRTxxx)
 revoke     (RVKxxx)
 send       (SNDxxx)
 display    (DSPxxx)
 print      (PRTxxx)
 copy       (CPYxxx)
 move       (MOVxxx)
 merge      (MRGxxx)
 common SUBJECT parts
 command    (xxxCMD)
 menu       (xxxMNU)
 message    (xxxMSG)
 user       (xxxUSR)
 device     (xxxDEV)
 connection (xxxCNN)
 receiver   (xxxRCV)
 system     (xxxSYS)
 */

+ (NSError *)call:(NSString *)program parameters:(NSDictionary *)parameters;
+ (NSError *)call:(NSString *)program;
+ (NSError *)startDebug;
+ (NSError *)endDebug;
+ (NSError *)startPushNotificationReceiver;
+ (NSError *)initializeUserDefaultEntries:(NSString *)plist force:(BOOL)force;
+ (NSError *)initializeTestConfig;
+ (NSError *)initializeProdConfig;
+ (NSError *)initializeDemoDB;
+ (NSError *)initializeImageDirectory:(NSString *)directory;
+ (NSError *)revokeItunesFileSharingPermission:(NSString *)fileName;
+ (NSError *)clearDB;
+ (NSError *)saveUserDefaultEntries;
+ (NSError *)saveUserDefaultEntries:(NSString *)backupPlist;
+ (NSError *)restoreUserDefaultEntries;
+ (NSError *)restoreUserDefaultEntries:(NSString *)backupPlist;
+ (NSError *)sendMessage;

@end