//
//  InventoryLine.h
//  StoreOnline
//
//  Created by iLutz on 02.08.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class InventoryHead;
@class User;

@interface InventoryLine : NSManagedObject<ItemHolder>

+ (InventoryLine *)inventoryLineForInventoryHead:(InventoryHead *)inventoryHead
                                      withItemID:(NSString *)itemID
                                         barCode:(NSString *)barCode
                                         itemQTY:(NSNumber *)itemQTY
                                atPositionNumber:(NSNumber *)atPositionNumber
                                            task:(NSString *)task
                                          userID:(NSNumber *)userID
                          inCtx:(NSManagedObjectContext *)aCtx;
+ (InventoryLine *)currentInventoryLineInCtx:(NSManagedObjectContext *)aCtx;
+ (NSUInteger )currentInventoryQTYForPositionNumber:(NSNumber *)positionNumber
                                      inventoryHead:(InventoryHead *)inventoryHead
                             inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)inventoryLinesToSyncInCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)inventoryLinesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * itemBarCode;
@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSNumber * itemQTY;
@property (nonatomic, strong) NSNumber * itemQTYFixed;
@property (nonatomic, strong) NSNumber * itemQTYOriginal;
@property (nonatomic, strong) NSDate * positionInserted;
@property (nonatomic, strong) NSNumber * positionNumber;
@property (nonatomic, strong) NSNumber * positionStatus;
@property (nonatomic, strong) NSDate * positionTransmitted;
@property (nonatomic, strong) NSDate * positionUpdated;
@property (nonatomic, strong) User *correctionUser;
@property (nonatomic, strong) InventoryHead *inventoryHead;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) User *user;

@end
