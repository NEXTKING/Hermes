//
//  ArchiveOrderHead.h
//  StoreOnline
//
//  Created by iLutz on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ArchiveOrderLine;
@class User;
@class Location;

@interface ArchiveOrderHead : NSManagedObject

+ (ArchiveOrderHead *)orderHeadWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderHead *)orderHeadWithClientData:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderHead *)orderHeadWithClientData:(NSNumber *)userID forStore:(NSNumber *)storeID inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderHead *)orderHeadWithClientData:(NSNumber *)userID forLocation:(Location *)location inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderHead *)subsetOrderHeadForOrderHead:(ArchiveOrderHead *)orderHead withOrderLines:(NSArray *)orderLines;
+ (NSArray  *)orderHeadsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderHead *)currentOrderHeadInCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)pendingOrderHeadsToSyncInCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSDate * deliveryDate;
@property (nonatomic, strong) NSNumber * order_id;
@property (nonatomic, strong) NSDate * orderDate;
@property (nonatomic, strong) NSNumber * orderState;
@property (nonatomic, strong) NSString * remoteOrderID;
@property (nonatomic, strong) NSDate * transmissionDate;
@property (nonatomic, strong) NSNumber * store_id;
@property (nonatomic, strong) NSSet *archiveOrderLine;
@property (nonatomic, strong) User *user;
@end

@interface ArchiveOrderHead (CoreDataGeneratedAccessors)

- (void)addArchiveOrderLineObject:(ArchiveOrderLine *)value;
- (void)removeArchiveOrderLineObject:(ArchiveOrderLine *)value;
- (void)addArchiveOrderLine:(NSSet *)values;
- (void)removeArchiveOrderLine:(NSSet *)values;
@end
