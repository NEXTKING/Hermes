//
//  Trace_Log.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Trace_Type;
@class Transport;
@class Truck;
@class User;

@interface Trace_Log :  NSManagedObject {
}

+ (Trace_Log *)traceLogWithTraceData:(NSDictionary *)traceData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSDate * trace_time;
@property (nonatomic, strong) NSNumber * trace_log_id;
@property (nonatomic, strong) NSData * userInfo;
@property (nonatomic, strong) NSData * receipt_data;
@property (nonatomic, strong) NSData * receipt_dataType;
@property (nonatomic, strong) NSString * receipt_text;
@property (nonatomic, strong) Truck * truck_id;
@property (nonatomic, strong) Transport * transport_id;
@property (nonatomic, strong) Trace_Type * trace_type_id;
@property (nonatomic, strong) User * user_id;

@property (nonatomic, strong) NSDictionary *userInfoDictionary;

@end


@interface Trace_Log (Predicates)
+ (NSPredicate *) withTraceTypes:(NSArray *) traceTypes;
@end

