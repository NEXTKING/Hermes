//
//  NSDate.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 03.07.15.
//
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (BOOL) isSameDay:(NSDate*)anotherDate{
    return [self isSameDay:anotherDate timeZone:[NSTimeZone defaultTimeZone]];
}

- (BOOL) isSameDay:(NSDate*)anotherDate timeZone:(NSTimeZone*)timeZone{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = timeZone;
    NSDateComponents* components1 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSDateComponents* components2 = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:anotherDate];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

@end
