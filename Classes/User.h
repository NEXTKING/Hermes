//
//  User.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "ArchiveOrderHead.h"
#import "ArchiveOrderLine.h"
#import "InventoryLine.h"
#import "TemplateOrderHead.h"
#import "TemplateOrderLine.h"
#import "Tour.h"
#import "Trace_Log.h"

extern NSString * const UserFunctionGoodsIssueEmployee;
extern NSString * const UserFunctionDriver;

@interface User :  NSManagedObject<DPHSynchronizable> {
}

+ (User *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userWithTraceData:(NSDictionary *)traceData   inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userID:(NSNumber *)userID forOrderHead:(ArchiveOrderHead *)orderHead inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userID:(NSNumber *)userID forOrderLine:(ArchiveOrderLine *)orderLine inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userID:(NSNumber *)userID forTemplateHead:(TemplateOrderHead *)orderHead inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userID:(NSNumber *)userID forTemplateLine:(TemplateOrderLine *)orderLine inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userID:(NSNumber *)userID forInventoryLine:(InventoryLine *)inventoryLine inCtx:(NSManagedObjectContext *)aCtx;
+ (User *)userWithUserID:(NSNumber *)userID inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)usersWithPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * functions;
@property (nonatomic, strong) NSNumber * isEnabled;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * password;
@property (nonatomic, strong) NSNumber * user_id;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSSet *archiveOrderHead;
@property (nonatomic, strong) NSSet *archiveOrderLine;
@property (nonatomic, strong) NSSet *inventoryLine;
@property (nonatomic, strong) NSSet *inventoryLineCorrection;
@property (nonatomic, strong) NSSet *templateOrderHead;
@property (nonatomic, strong) NSSet *templateOrderLine;
@property (nonatomic, strong) NSSet *trace_log_id;
@property (nonatomic, strong) NSSet *tour_id;

- (BOOL) hasFunction:(NSString *) functionName;
- (BOOL) isInitialUser;
+ (User *) initialUserFromContext:(NSManagedObjectContext *) context; // used for the initial synchronization only
- (NSString *) firstAndLastName;
- (NSNumber *) menuConfiguredForDriver;

@end


@interface User (CoreDataGeneratedAccessors)

- (void)addArchiveOrderHeadObject:(ArchiveOrderHead *)value;
- (void)removeArchiveOrderHeadObject:(ArchiveOrderHead *)value;
- (void)addArchiveOrderHead:(NSSet *)values;
- (void)removeArchiveOrderHead:(NSSet *)values;

- (void)addArchiveOrderLineObject:(ArchiveOrderLine *)value;
- (void)removeArchiveOrderLineObject:(ArchiveOrderLine *)value;
- (void)addArchiveOrderLine:(NSSet *)values;
- (void)removeArchiveOrderLine:(NSSet *)values;

- (void)addInventoryLineObject:(InventoryLine *)value;
- (void)removeInventoryLineObject:(InventoryLine *)value;
- (void)addInventoryLine:(NSSet *)values;
- (void)removeInventoryLine:(NSSet *)values;

- (void)addInventoryLineCorrectionObject:(InventoryLine *)value;
- (void)removeInventoryLineCorrectionObject:(InventoryLine *)value;
- (void)addInventoryLineCorrection:(NSSet *)values;
- (void)removeInventoryLineCorrection:(NSSet *)values;

- (void)addTemplateOrderHeadObject:(TemplateOrderHead *)value;
- (void)removeTemplateOrderHeadObject:(TemplateOrderHead *)value;
- (void)addTemplateOrderHead:(NSSet *)values;
- (void)removeTemplateOrderHead:(NSSet *)values;

- (void)addTemplateOrderLineObject:(TemplateOrderLine *)value;
- (void)removeTemplateOrderLineObject:(TemplateOrderLine *)value;
- (void)addTemplateOrderLine:(NSSet *)values;
- (void)removeTemplateOrderLine:(NSSet *)values;

- (void)addTrace_log_idObject:(Trace_Log *)value;
- (void)removeTrace_log_idObject:(Trace_Log *)value;
- (void)addTrace_log_id:(NSSet *)values;
- (void)removeTrace_log_id:(NSSet *)values;

- (void)addTour_idObject:(Tour *)value;
- (void)removeTour_idObject:(Tour *)value;
- (void)addTour_id:(NSSet *)values;
- (void)removeTour_id:(NSSet *)values;

@end

