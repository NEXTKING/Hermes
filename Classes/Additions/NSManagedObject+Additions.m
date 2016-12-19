//
//  NSManagedObject+Additions.m
//  dphHermes
//
//  Created by Tomasz Kransyk on 30.04.15.
//
//

@implementation NSManagedObjectContext (Additions)

- (void)deleteObjects:(NSArray *) objectsToDelete {
    for (NSManagedObject *object in [NSArray arrayWithArray:objectsToDelete]) {
        [self deleteObject:object];
    }
}

- (void)saveIfHasChanges {
    NSError *error = nil;
    if ([self hasChanges] && ![self save:&error]) {
        NSLog(@"Could not save context. Error %@\nUserInfo: %@", error, [error userInfo]);
        abort();
    }
}

@end

@implementation NSManagedObject (Additions)

+ (NSPredicate *) predicateForObjectsWithValue:(NSString *) value forProperty:(NSString *) property {
    return [NSPredicate predicateWithFormat:@"%K = %@", property, value];
}

@end
