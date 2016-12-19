//
//  TObjectGenerator.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 29.07.15.
//
//

#import "TObjectGenerator.h"


@implementation TObjectGenerator

+ (NSDictionary *)anyPushNotificaitonWithType:(NSInteger)type notificationId:(NSInteger) notificationId tourId:(NSInteger)tourId {
    NSString *tourIdString = [NSString stringWithFormat:@"%d", tourId];
    NSString *notificationIdString = [NSString stringWithFormat:@"%d", notificationId];
    NSString *typeString = [NSString stringWithFormat:@"%d", type];
    NSString *alert = [NSString stringWithFormat:@"Type: %@, notificationId: %@, tourId: %@", typeString, notificationIdString, tourIdString];
    return [[NSDictionary alloc] initWithObjectsAndKeys:
                          typeString, @"type",
                          @{ @"alert": alert, @"sound" : @"default"}, @"aps",
                          notificationIdString, @"id",
                          tourIdString, @"tour_id",
                          nil];
}

+ (Trace_Type *) anyTraceTypeWithType:(TraceTypeValue) traceType ctx:(NSManagedObjectContext *) ctx {
    Trace_Type *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Trace_Type class]) inManagedObjectContext:ctx];
    object.trace_type_id = [NSNumber numberWithInteger:traceType];
    object.code = [Trace_Type traceTypeStringFromValue:traceType];
    return object;
}

@end
