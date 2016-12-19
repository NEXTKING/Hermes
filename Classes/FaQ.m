//
//  FaQ.m
//  StoreOnline
//
//  Created by Lutz  Thalmann on 06.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FaQ.h"
#import "Keyword.h"


@implementation FaQ

+ (FaQ *)faqWithServerData:(NSDictionary *)serverData inCtx:(NSManagedObjectContext *)aCtx {
	FaQ       *faq = nil;
	NSError   *error = nil;
    if ([serverData valueForKey:@"lang"] && [serverData valueForKey:@"ask"] && [serverData valueForKey:@"answer"]) { 
        NSRange    tmpRange;
        NSString  *tmpQuestion = [NSString stringWithString:[serverData valueForKey:@"ask"]];
        NSString  *tmpAnswer   = [NSString stringWithString:[serverData valueForKey:@"answer"]];
        tmpQuestion            = [tmpQuestion stringByReplacingOccurrencesOfString:@"<br/>" withString:@" "];
        tmpAnswer              = [tmpAnswer   stringByReplacingOccurrencesOfString:@"<br/>" withString:@" "];
        while ((tmpRange = [tmpQuestion rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) { 
            // remove HTML tags from string
            tmpQuestion = [tmpQuestion stringByReplacingCharactersInRange:tmpRange withString:@""];
        }
        while ((tmpRange = [tmpAnswer rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
            // remove HTML tags from string
            tmpAnswer = [tmpAnswer stringByReplacingCharactersInRange:tmpRange withString:@""];
        }
        
        // If-Abfrage, ob die Schnittstelle a) die Spalte überhaupt hat und b) in der Spalte überhaupt einen Inhalt
        if ([[NSString stringWithString:[serverData valueForKey:@"lang"]] length] > 0 && 
            [tmpQuestion length] > 0 && [tmpAnswer length] > 0) { 
            NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
            // db_handle.entity    = SQL-TABLE-Name
            db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
            // db_handle.predicate = SQL-WHERE-Condition
            db_handle.predicate    = [NSPredicate predicateWithFormat:@"faqID = %@ && localeCode = %@", 
                                      [serverData valueForKey:@"entryno"], [serverData valueForKey:@"lang"]]; 
            // lastObject returns nil, if no data in db_handle
            faq                    = [[aCtx executeFetchRequest:db_handle error:&error] lastObject];
            
            if (!error) {
                if (!faq) {
                    // INSERT new Object (db_handle returns nil without an error)
                    faq = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
                    faq.faqID      = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"entryno"]];
                    faq.localeCode = [NSString stringWithFormat:@"%@", [serverData valueForKey:@"lang"]];
                }
                if ([serverData valueForKey:@"activ"] && [[serverData valueForKey:@"activ"]intValue] == 0) { 
                    // DELETE existing Object
                    [aCtx deleteObject:faq];
                } else { 
                    // UPDATE properties for existing Object
                    faq.question = tmpQuestion;
                    faq.answer   = tmpAnswer;
                    if ([serverData valueForKey:@"positionno"]) {
                        faq.faqPositionNumber = [NSNumber numberWithInt:[[serverData valueForKey:@"positionno"]intValue] ];
                    } else {
                        faq.faqPositionNumber = nil;
                    }
                }
            }
        } 
    }
    
	return faq;
}

+ (NSArray *)faqWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)sortDescriptors inCtx:(NSManagedObjectContext *)aCtx {
	NSArray  *faq = nil;
	NSError  *error        = nil;
	
	NSFetchRequest *db_handle = [[NSFetchRequest alloc] init];
	db_handle.entity       = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:aCtx];
	db_handle.predicate    = aPredicate;
    // db_handle.sortDescriptor = SQL-ORDER-BY-Clause
	if (sortDescriptors) {
		[db_handle setSortDescriptors:sortDescriptors];
	}
	
	// lastObject returns nil, if no data in db_handle
	faq        = [aCtx executeFetchRequest:db_handle error:&error];
    //	if (aPredicate) {
    //		if (!departures || departures.count == 0) {
    //			NSLog(@"Departure has no records for %@", [aPredicate predicateFormat]);
    //		}
    //	}
	return faq;
}

@dynamic localeCode;
@dynamic answer;
@dynamic question;
@dynamic faqID;
@dynamic faqPositionNumber;
@dynamic answerKeywords;
@dynamic questionKeywords;

@end
