// 
//  Trace_Log.m
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Trace_Log.h"

#import "Trace_Type.h"
#import "Transport.h"
#import "Truck.h"
#import "User.h"

@implementation Trace_Log 

+ (Trace_Log *)traceLogWithTraceData:(NSDictionary *)traceData inCtx:(NSManagedObjectContext *)aCtx {
	Trace_Log *traceLog  = nil;
	NSError   *error	 = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Trace_Log" inManagedObjectContext:aCtx];
	db_handle.predicate    = [NSPredicate predicateWithFormat:@"trace_log_id < %i", 0];
	
	// lastObject returns nil, if no data in db_handle
	traceLog			   = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
	
	if (!error) {
		if (!traceLog) {
			// INSERT new Object (db_handle returns nil without an error)
			traceLog = [NSEntityDescription insertNewObjectForEntityForName:@"Trace_Log" inManagedObjectContext:aCtx];
            traceLog.trace_log_id = [NSUserDefaults nextTraceLogId];
		}
		// UPDATE properties for existing Object
		traceLog.trace_time		  = [NSDate date];
        traceLog.receipt_data	  = nil;
        if ([traceData objectForKey:@"receipt_data"]) { 
            traceLog.receipt_data = [traceData objectForKey:@"receipt_data"];
        }
		traceLog.receipt_text	  = nil;
        if ([traceData valueForKey:@"receipt_text"]) { 
            traceLog.receipt_text = [traceData valueForKey:@"receipt_text"];
        }
        [traceLog setUserInfoDictionary:[traceData valueForKey:@"userInfo"]];
		traceLog.transport_id	  = [Transport  transportWithTraceData:traceData  inCtx:aCtx];
		traceLog.truck_id		  = [Truck      truckWithTraceData:traceData      inCtx:aCtx];
		traceLog.user_id		  = [User       userWithTraceData:traceData       inCtx:aCtx];
		traceLog.trace_type_id	  = [Trace_Type trace_TypeWithTraceData:traceData inCtx:aCtx];
	} else {
		 NSLog(@"ERROR Trace_Log traceLogWithTraceData:  %@ %@", error, [error userInfo]); 
	}

	
	return traceLog;
}

+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate inCtx:(NSManagedObjectContext *)aCtx {
    return [Trace_Log withPredicate:aPredicate sortDescriptors:nil inCtx:aCtx];
}

+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *traceLogs = nil;
	NSError  *error		= nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:@"Trace_Log" inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    db_handle.sortDescriptors = sortDescriptors;
	
	// lastObject returns nil, if no data in db_handle
	traceLogs				   = [aCtx executeFetchRequest:db_handle error:&error];
	return traceLogs;
}

@dynamic trace_time;
@dynamic trace_log_id;
@dynamic receipt_data;
@dynamic receipt_dataType;
@dynamic receipt_text;
@dynamic truck_id;
@dynamic transport_id;
@dynamic trace_type_id;
@dynamic user_id;
@dynamic userInfo;
@synthesize userInfoDictionary;


- (void) setUserInfoDictionary:(NSDictionary *)aDict {
    NSString *errorString = nil;
    NSData *convertedDict = nil;
    if (aDict) {
        convertedDict = [NSPropertyListSerialization dataFromPropertyList:aDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
    }
    if (errorString != nil) {
        NSLog(@"Could not convert dictionary %@ to plist and store it in the TraceLog. Reason: %@", aDict, errorString);
    } else {
        self.userInfo = convertedDict;
    }
}

- (NSDictionary *) userInfoDictionary {
    NSDictionary *result = nil;
    if (self.userInfo != nil) {
        NSError *error = nil;
        NSDictionary *propertyList = [NSPropertyListSerialization propertyListWithData:self.userInfo options:NSPropertyListImmutable format:NULL error:&error];
        if (error != nil) {
            NSLog(@"Could not convert TraceLog data to dictionary. Reason: %@", error);
        } else {
            result = propertyList;
        }
    }
    return result;
}

@end


@implementation Trace_Log (Predicates)

+ (NSPredicate *) withTraceTypes:(NSArray *) traceTypes {
    return [NSPredicate predicateWithFormat:@"trace_type_id.trace_type_id IN %@", traceTypes];
}
                               
@end
