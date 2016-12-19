//
//  NSDate.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 03.07.15.
//
//

#import <UIKit/UIKit.h>

@interface NSDate (Additions)

- (BOOL) isSameDay:(NSDate*)anotherDate;
- (BOOL) isSameDay:(NSDate*)anotherDate timeZone:(NSTimeZone*)timeZone;

@end
