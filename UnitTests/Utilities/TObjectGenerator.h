//
//  TObjectGenerator.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 29.07.15.
//
//
#import <UIKit/UIKit.h>
#import "Trace_Type.h"

@interface TObjectGenerator : NSObject
+ (NSDictionary *)anyPushNotificaitonWithType:(NSInteger)type notificationId:(NSInteger) notificationId tourId:(NSInteger)tourId;

+ (Trace_Type *) anyTraceTypeWithType:(TraceTypeValue) traceType ctx:(NSManagedObjectContext *) ctx;
@end
