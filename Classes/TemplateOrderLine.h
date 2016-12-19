//
//  TemplateOrderLine.h
//  StoreOnline
//
//  Created by iLutz on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class TemplateOrderHead;
@class User;

@interface TemplateOrderLine : NSManagedObject<ItemHolder>

+ (TemplateOrderLine *)templateLineWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (TemplateOrderLine *)templateLineForTemplateHead:(TemplateOrderHead *)templateHead 
                                        withItemID:(NSString *)itemID 
                                           itemQTY:(NSNumber *)itemQTY 
                                            userID:(NSNumber *)userID  
                            inCtx:(NSManagedObjectContext *)aCtx;
+ (TemplateOrderLine *)templateLineForItemID:(NSString *)itemID inTemplate:(TemplateOrderHead *)templateHead;
+ (NSUInteger )currentTemplateQTYForItem:(NSString *)itemID templateHead:(TemplateOrderHead*)templateHead inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)templateLinesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * infoText;
@property (nonatomic, strong) NSString * itemID;
@property (nonatomic, strong) NSDate * itemInserted;
@property (nonatomic, strong) NSNumber * itemQTY;
@property (nonatomic, strong) NSDate * itemUpdated;
@property (nonatomic, strong) NSString * sortValue;
@property (nonatomic, strong) Item *item;
@property (nonatomic, strong) TemplateOrderHead *templateOrderHead;
@property (nonatomic, strong) User *user;

@end
