//
//  Newsletter.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Keyword;

@interface Newsletter : NSManagedObject
+ (Newsletter *)newsletterWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)newsletterWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * newsletterID;
@property (nonatomic, strong) NSNumber * newsletterPositionNumber;
@property (nonatomic, strong) NSNumber * alertBit;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSSet *newsletterKeywords;
@end

@interface Newsletter (CoreDataGeneratedAccessors)

- (void)addNewsletterKeywordsObject:(Keyword *)value;
- (void)removeNewsletterKeywordsObject:(Keyword *)value;
- (void)addNewsletterKeywords:(NSSet *)values;
- (void)removeNewsletterKeywords:(NSSet *)values;
@end
