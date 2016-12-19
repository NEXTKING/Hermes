//
//  InventoryHead.h
//  StoreOnline
//
//  Created by iLutz on 02.08.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class InventoryLine;

@interface InventoryHead : NSManagedObject

+ (InventoryHead *)inventoryHeadWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (InventoryHead *)inventoryHeadWithRemoteInventoryID:(NSString *)remoteInventoryID inCtx:(NSManagedObjectContext *)aCtx;
+ (InventoryHead *)currentInventoryHeadInCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)inventoryHeadsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSDate * inventoryDate;
@property (nonatomic, strong) NSNumber * inventoryID;
@property (nonatomic, strong) NSString * inventorySector;
@property (nonatomic, strong) NSNumber * inventoryState;
@property (nonatomic, strong) NSString * remoteInventoryID;
@property (nonatomic, strong) NSDate * transmissionDate;
@property (nonatomic, strong) NSSet *inventoryLine;
@end

@interface InventoryHead (CoreDataGeneratedAccessors)

- (void)addInventoryLineObject:(InventoryLine *)value;
- (void)removeInventoryLineObject:(InventoryLine *)value;
- (void)addInventoryLine:(NSSet *)values;
- (void)removeInventoryLine:(NSSet *)values;
@end
