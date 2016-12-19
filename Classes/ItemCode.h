//
//  ItemCode.h
//  StoreOnline
//
//  Created by iLutz on 02.08.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@interface ItemCode : NSManagedObject<ItemHolder>

+ (ItemCode *)itemCodeWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Item *)itemForCode:(NSString *)code                          inCtx:(NSManagedObjectContext *)aCtx;
+ (NSInteger )itemCountForCode:(NSString *)code inCtx:(NSManagedObjectContext *)aCtx;
+ (NSString *)salesUnitItemCodeForItemID:(NSString *)itemID     inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)itemCodesWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * distinction;
@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSNumber * itemQTY;
@property (nonatomic, strong) Item *item;

@end
