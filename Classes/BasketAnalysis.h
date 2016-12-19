//
//  BasketAnalysis.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@interface BasketAnalysis : NSManagedObject<ItemHolder>

+ (BasketAnalysis *)basketanalysisWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)basketanalysisWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSString * analyzedItemID;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) Item *analyzedItem;

@end
