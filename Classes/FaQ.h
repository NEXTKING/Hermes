//
//  FaQ.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Keyword;

@interface FaQ : NSManagedObject

+ (FaQ *)faqWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray *)faqWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * localeCode;
@property (nonatomic, strong) NSString * answer;
@property (nonatomic, strong) NSString * question;
@property (nonatomic, strong) NSString * faqID;
@property (nonatomic, strong) NSNumber * faqPositionNumber;
@property (nonatomic, strong) NSSet *answerKeywords;
@property (nonatomic, strong) NSSet *questionKeywords;
@end

@interface FaQ (CoreDataGeneratedAccessors)

- (void)addAnswerKeywordsObject:(Keyword *)value;
- (void)removeAnswerKeywordsObject:(Keyword *)value;
- (void)addAnswerKeywords:(NSSet *)values;
- (void)removeAnswerKeywords:(NSSet *)values;
- (void)addQuestionKeywordsObject:(Keyword *)value;
- (void)removeQuestionKeywordsObject:(Keyword *)value;
- (void)addQuestionKeywords:(NSSet *)values;
- (void)removeQuestionKeywords:(NSSet *)values;
@end
