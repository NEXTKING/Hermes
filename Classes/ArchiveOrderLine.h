//
//  ArchiveOrderLine.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 01.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "Item.h"

@class ArchiveOrderHead;
@class Item;
@class User;


@interface ArchiveOrderLine : NSManagedObject<ItemHolder>

+ (ArchiveOrderLine *)orderLineWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderLine *)orderLineForOrderHead:(ArchiveOrderHead *)orderHead 
                                 withItemID:(NSString *)itemID 
                                    itemQTY:(NSNumber *)itemQTY 
                                     userID:(NSNumber *)userID 
                               templateName:(NSString *)templateName 
                     inCtx:(NSManagedObjectContext *)aCtx;
+ (NSUInteger )currentOrderQTYForItem:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)orderLinesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderLine *)currentOrderLineInCtx:(NSManagedObjectContext *)aCtx;
+ (ArchiveOrderLine *)previousOrderLineForItemID:(NSString *)itemID inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)currentOrderLinesInCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSDate * itemInserted;
@property (nonatomic, strong) NSNumber * itemQTY;
@property (nonatomic, strong) NSDate * itemUpdated;
@property (nonatomic, strong) NSString * templateName;
@property (nonatomic, strong) ArchiveOrderHead *archiveOrderHead;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) User *user;

@end
