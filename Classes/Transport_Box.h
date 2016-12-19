//
//  Transport_Box.h
//  Hermes
//
//  Created by Attila Teglas on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Transport;
@class Location;

@interface Transport_Box : NSManagedObject


- (Transport *) initiallyCreatedTransport;
- (Location *) finalDestinationLocation;
+ (Transport_Box *)transport_boxWithBarCode:(NSString *)barCode inCtx:(NSManagedObjectContext *)aCtx;
+ (BOOL)hasBoxWithCode:(NSString *)boxCode inCtx:(NSManagedObjectContext *)aCtx;
+ (Transport_Box *)recommendedBoxInCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *) withPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)transport_boxPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSSet *transport_id;
@property (nonatomic, strong) NSNumber *status;
@end

@interface Transport_Box (CoreDataGeneratedAccessors)

- (void)addTransport_idObject:(Transport *)value;
- (void)removeTransport_idObject:(Transport *)value;
- (void)addTransport_id:(NSSet *)values;
- (void)removeTransport_id:(NSSet *)values;
@end

@interface Transport_Box (Validation)
+ (BOOL) validateTextInput:(NSString *) inputText;
+ (BOOL) validateTransportBoxCode:(NSString *) transportCode;
+ (BOOL) validateTransportBoxBarcode:(NSString *) transportCode;
@end

@interface Transport_Box (Predicate)
+ (NSPredicate *) withCode:(NSString *) code;
+ (NSPredicate *) deletableOnEndOfTour;
@end