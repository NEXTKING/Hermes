//
//  Hitlist.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@interface Hitlist : NSManagedObject<ItemHolder>

+ (Hitlist *)hitlistWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)hitlistWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * productGroup;
@property (nonatomic, strong) NSNumber * positionNumber;
@property (nonatomic, strong) Item *item;

@end
