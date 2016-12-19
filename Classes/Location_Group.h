//
//  Location_Group.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Updated by Lutz  Thalmann on 19.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Location.h"

@interface Location_Group :  NSManagedObject<DPHSynchronizable> {
}

+ (Location_Group *)fromServerData:(NSDictionary *)serverData     inCtx:(NSManagedObjectContext *)aCtx;
+ (Location_Group *)locationGroupWithLocationData:(NSDictionary *)locationData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)withPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSNumber * location_group_id;
@property (nonatomic, strong) NSNumber * isLogisticsCenter;
@property (nonatomic, strong) NSNumber * isExternalPartner;
@property (nonatomic, strong) NSNumber * isLogicalStructureElement;
@property (nonatomic, strong) NSSet    * location_id;

@end


@interface Location_Group (CoreDataGeneratedAccessors)
- (void)addLocation_idObject:(Location *)value;
- (void)removeLocation_idObject:(Location *)value;
- (void)addLocation_id:(NSSet *)value;
- (void)removeLocation_id:(NSSet *)value;

@end

