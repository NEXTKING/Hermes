//
//  Truck_Type.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Updated by Lutz  Thalmann on 19.09.14.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Truck.h"

@interface Truck_Type :  NSManagedObject<DPHSynchronizable> {
}

+ (Truck_Type *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Truck_Type *)truck_TypeWithTruckData:(NSDictionary *)truckData   inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)truck_TypesWithPredicate:(NSPredicate  *)aPredicate   inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSNumber * truck_type_id;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSString * truck_type;
@property (nonatomic, strong) NSNumber * isTrailer;
@property (nonatomic, strong) NSSet* truck_id;

@end


@interface Truck_Type (CoreDataGeneratedAccessors)

- (void)addTruck_idObject:(Truck *)value;
- (void)removeTruck_idObject:(Truck *)value;
- (void)addTruck_id:(NSSet *)value;
- (void)removeTruck_id:(NSSet *)value;

@end

