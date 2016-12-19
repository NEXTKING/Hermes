//
//  ItemProductInformation.h
//  StoreOnline
//
//  Created by iLutz on 14.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Keyword;

@interface ItemProductInformation : NSManagedObject<ItemHolder>

+ (ItemProductInformation *)itemProductInformationWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)itemProductInformationsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) NSSet *productInformationKeywords;
@end

@interface ItemProductInformation (CoreDataGeneratedAccessors)

- (void)addProductInformationKeywordsObject:(Keyword *)value;
- (void)removeProductInformationKeywordsObject:(Keyword *)value;
- (void)addProductInformationKeywords:(NSSet *)values;
- (void)removeProductInformationKeywords:(NSSet *)values;
@end
