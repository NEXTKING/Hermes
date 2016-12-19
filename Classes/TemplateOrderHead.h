//
//  TemplateOrderHead.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TemplateOrderLine;
@class User;

@interface TemplateOrderHead : NSManagedObject

+ (TemplateOrderHead *)templateHeadWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (TemplateOrderHead *)templateHeadWithName:(NSString *)templateName clientData:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)templateHeadsWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;
+ (TemplateOrderHead *)templateHeadFromName:(NSString *)templateName inCtx:(NSManagedObjectContext *)aCtx;
+ (BOOL )templateHeadWithName:(NSString *)templateName hasCurrentOrderInCtx:(NSManagedObjectContext *)aCtx;
+ (void)removeAllEmptyServerDomainTemplatesInCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSNumber * isUserDomain;
@property (nonatomic, strong) NSNumber * template_id;
@property (nonatomic, strong) NSDate * templateDate;
@property (nonatomic, strong) NSString * templateName;
@property (nonatomic, strong) NSNumber * templateState;
@property (nonatomic, strong) NSDate * templateValidFrom;
@property (nonatomic, strong) NSDate * templateValidUntil;
@property (nonatomic, strong) NSDate * transmissionDate;
@property (nonatomic, strong) NSDate * templateDeliveryFrom;
@property (nonatomic, strong) NSDate * templateDeliveryUntil;
@property (nonatomic, strong) NSSet *templateOrderLine;
@property (nonatomic, strong) User *user;
@end

@interface TemplateOrderHead (CoreDataGeneratedAccessors)

- (void)addTemplateOrderLineObject:(TemplateOrderLine *)value;
- (void)removeTemplateOrderLineObject:(TemplateOrderLine *)value;
- (void)addTemplateOrderLine:(NSSet *)values;
- (void)removeTemplateOrderLine:(NSSet *)values;
@end
