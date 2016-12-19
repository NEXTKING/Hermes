//
//  NSManagedObject+Additions.h
//  dphHermes
//
//  Created by Tomasz Kransyk on 30.04.15.
//
//

#import <Foundation/Foundation.h>

@interface NSManagedObjectContext (Additions)

- (void)deleteObjects:(NSArray *) objectsToDelete;
- (void)saveIfHasChanges;

@end

@interface NSManagedObject (Additions)

+ (NSPredicate *) predicateForObjectsWithValue:(NSString *) udid forProperty:(NSString *) property;

@end
