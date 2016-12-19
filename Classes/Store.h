//
//  Store.h
//  Hermes
//
//  Created by Lutz  Thalmann on 05.01.12.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Store : NSManagedObject {
}

+ (Store   *)storeWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (Store   *)storeID:(NSNumber *)storeID                    inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)storesWithPredicate:(NSPredicate  *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * countryCode;
@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSNumber * store_id;
@property (nonatomic, strong) NSString * storeName;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSNumber * accountsReceivableNumber;
@property (nonatomic, strong) NSNumber * accountsPayableNumber;
@property (nonatomic, strong) NSString * associatedLocation;

@end
