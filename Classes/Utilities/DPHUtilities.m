//
//  DPHUtilities.m
//  dphHermes
//
//  Created by Tomasz Kransyk on 04.05.15.
//
//

NSString * currentLocaleCode(void) {
    return [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
}

id nilOrObject(id objectOrNSNull) {
    id result = objectOrNSNull;
    if (objectOrNSNull == [NSNull null]) {
        result = nil;
    }
    return result;
}

id objectOrNSNull(id objectOrNil) {
    id result = objectOrNil;
    if (objectOrNil == nil) {
        result = [NSNull null];
    }
    return result;
}

NSPredicate * AndPredicates(NSPredicate *predicate, ...) {
    NSMutableArray *predicatesArray = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, predicate);
    for (NSPredicate *arg = predicate; arg != nil; arg = va_arg(args, NSPredicate*)) {
        [predicatesArray addObject:arg];
    }
    va_end(args);
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
}

NSPredicate * OrPredicates(NSPredicate *predicate, ...) {
    NSMutableArray *predicatesArray = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, predicate);
    for (NSPredicate *arg = predicate; arg != nil; arg = va_arg(args, NSPredicate*)) {
        [predicatesArray addObject:arg];
    }
    va_end(args);
    return [NSCompoundPredicate orPredicateWithSubpredicates:predicatesArray];
}

NSPredicate * NotPredicate(NSPredicate *predicate) {
    return [NSCompoundPredicate notPredicateWithSubpredicate:predicate];
}

@implementation DPHUtilities

+ (void) waitForAlertToShow:(CGFloat)waitingTime {
    if (iosVersion() < 7.0f) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:waitingTime]];
    }
}

@end

@implementation UITableView (Additions)

- (void) deselectSelectedRowAnimated:(BOOL) animated {
    NSIndexPath *selectedIndexPath = [self indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [self deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

@end
