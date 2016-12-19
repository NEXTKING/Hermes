//
//  Location_Alias.h
//  Hermes
//
//  Created by Lutz  Thalmann on 19.04.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Location;

@interface Location_Alias : NSManagedObject<DPHSynchronizable> {
}

+ (Location_Alias *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSString *)locationCodeFromAlias:(NSString *)aAlias                      inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)location_AliasesWithPredicate:(NSPredicate *)aPredicate       inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * alias;
@property (nonatomic, strong) NSNumber * location_alias_id;
@property (nonatomic, strong) NSSet* location_id;

@end
