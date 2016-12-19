//
//  SVR_SyncDataManager.h
//  Hermes
//
//  Created by Lutz  Thalmann on 08.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPHUtilities.h"
#import "SyncTask.h"

typedef enum : NSUInteger {
    SVR_SyncDataManagerStatusIdle,
    SVR_SyncDataManagerStatusSending
} SVR_SyncDataManagerStatus;

extern NSString * const SVR_SyncDataManagerStatusKey;


@interface SVR_SyncDataManager : NSObject <NSURLConnectionDelegate> {
    
}
@property (atomic, assign, readonly) SVR_SyncDataManagerStatus status;

@end



@interface SVR_SyncDataManager (Additions)

+ (NSPredicate *) predicateForTraceLogsToSynchronize;

+ (void) saveLastSyncedTimeStamp:(NSDate *) date forClass:(Class<DPHSynchronizable>) clz;
+ (void) saveLastSyncedTimeStamp:(NSDate *) date forKey:(NSString *) key;

+ (NSMutableURLRequest *) requestFromDictionary:(NSDictionary *) dictionary url:(NSURL *) url;

- (NSUInteger) unsynchronizedTraceLogsCount;

+ (void) triggerSendingTraceLogDataWithUserInfo:(NSDictionary *) userInfo;
+ (void) triggerSendingTraceLogDataOnlyWithUserInfo:(NSDictionary *) userInfo;
+ (void) triggerSendingRentalAndRestitutionDataWithUserInfo:(NSDictionary *)userInfo;

@end
