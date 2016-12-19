//
//  Keyword.h
//  StoreOnline
//
//  Created by iLutz on 14.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FaQ, ItemDescription, ItemProductInformation, Newsletter;

@interface Keyword : NSManagedObject

@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * word;
@property (nonatomic, strong) NSSet *descriptionHits;
@property (nonatomic, strong) NSSet *faqAnswerHits;
@property (nonatomic, strong) NSSet *faqQuestionHits;
@property (nonatomic, strong) NSSet *newsletterHits;
@property (nonatomic, strong) NSSet *productInformationHits;
@end

@interface Keyword (CoreDataGeneratedAccessors)

- (void)addDescriptionHitsObject:(ItemDescription *)value;
- (void)removeDescriptionHitsObject:(ItemDescription *)value;
- (void)addDescriptionHits:(NSSet *)values;
- (void)removeDescriptionHits:(NSSet *)values;
- (void)addFaqAnswerHitsObject:(FaQ *)value;
- (void)removeFaqAnswerHitsObject:(FaQ *)value;
- (void)addFaqAnswerHits:(NSSet *)values;
- (void)removeFaqAnswerHits:(NSSet *)values;
- (void)addFaqQuestionHitsObject:(FaQ *)value;
- (void)removeFaqQuestionHitsObject:(FaQ *)value;
- (void)addFaqQuestionHits:(NSSet *)values;
- (void)removeFaqQuestionHits:(NSSet *)values;
- (void)addNewsletterHitsObject:(Newsletter *)value;
- (void)removeNewsletterHitsObject:(Newsletter *)value;
- (void)addNewsletterHits:(NSSet *)values;
- (void)removeNewsletterHits:(NSSet *)values;
- (void)addProductInformationHitsObject:(ItemProductInformation *)value;
- (void)removeProductInformationHitsObject:(ItemProductInformation *)value;
- (void)addProductInformationHits:(NSSet *)values;
- (void)removeProductInformationHits:(NSSet *)values;
@end
