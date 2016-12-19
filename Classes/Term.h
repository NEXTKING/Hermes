//
//  Term.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.01.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Transport;

@interface Term :  NSManagedObject {
}

+ (Term *)termWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx;
+ (NSArray  *)termsWithPredicate:(NSPredicate  *)aPredicate inCtx:(NSManagedObjectContext *)aCtx;

@property (nonatomic, strong) NSString * code;
@property (nonatomic, strong) NSNumber * term_id;
@property (nonatomic, strong) NSString * description_text;
@property (nonatomic, strong) NSSet* transprot_id;

@end


@interface Term (CoreDataGeneratedAccessors)
- (void)addTransprot_idObject:(Transport *)value;
- (void)removeTransprot_idObject:(Transport *)value;
- (void)addTransprot_id:(NSSet *)value;
- (void)removeTransprot_id:(NSSet *)value;

@end

