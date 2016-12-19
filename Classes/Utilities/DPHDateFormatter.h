//
//  DPHDateFormatter.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 16.07.15.
//
//

#import <Foundation/Foundation.h>

extern NSLocale * de_CH_Locale(void);

@interface DPHDateFormatter : NSObject

+ (DPHDateFormatter *)sharedInstance;

+ (NSNumber *) dayOfWeekFromDate:(NSDate *)date;
+ (NSDate *) dayOfWeekDateFromString:(NSString *)string;

+ (NSString *) dayOfWeekNameFromDate:(NSDate *)date;


+ (NSDate *) dateFromString:(NSString *)dateString withDateStyle:(NSDateFormatterStyle)dStyle timeStyle:(NSDateFormatterStyle)tStyle locale:(NSLocale *)locale;
+ (NSDate *) dateFromString:(NSString *)dateString  withFomat:(NSString *) dateFormat locale:(NSLocale *) locale;

+ (NSString *) stringFromDate:(NSDate *) date withFormat:(NSString *) dateFormat locale:(NSLocale *) locale;
+ (NSString *) stringFromDate:(NSDate *) date withDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle) timeStyle locale:(NSLocale *) locale;

@end