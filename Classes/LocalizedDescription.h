//
//  LocalizedDescription.h
//  StoreOnline
//
//  Created by iLutz on 09.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface LocalizedDescription : NSManagedObject<DPHSynchronizable>

+ (LocalizedDescription *)fromServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (LocalizedDescription *)localizedDescription:(NSString *)text
                                      withCode:(NSString *)code
                                        forKey:(NSString *)key
                                    localeCode:(NSString *)localeCode 
                        inCtx:(NSManagedObjectContext *)aCtx;
+ (NSString *)textForKey:(NSString *)aKey withCode:(NSString *)aCode inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)localizedDescriptionsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * text;

@end

@interface LocalizedDescription(Predicates)
+ (NSPredicate *) withCode:(NSString *) code language:(NSString *) language key:(NSString *) key;
@end
