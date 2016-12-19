//
//  ItemDescription.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Keyword;

@interface ItemDescription : NSManagedObject<ItemHolder>

+ (ItemDescription *)itemDescriptionWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)itemDescriptionsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) NSSet *descriptionKeywords;
@end

@interface ItemDescription (CoreDataGeneratedAccessors)

- (void)addDescriptionKeywordsObject:(Keyword *)value;
- (void)removeDescriptionKeywordsObject:(Keyword *)value;
- (void)addDescriptionKeywords:(NSSet *)values;
- (void)removeDescriptionKeywords:(NSSet *)values;
@end
