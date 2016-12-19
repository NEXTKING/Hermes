//
//  DPHDateFormatter.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 16.07.15.
//
//

#import "DPHDateFormatter.h"

NSLocale * de_CH_Locale(void) {
    return [[NSLocale alloc] initWithLocaleIdentifier:@"de_CH"];
}

static DPHDateFormatter * sharedInstance = nil;

@interface DPHDateFormatter()
@property (nonatomic) NSDateFormatter *defaultFormatter;
@end

@implementation DPHDateFormatter
@synthesize defaultFormatter;       //dynamic getter

- (NSDateFormatter *) defaultFormatter {
    if(!defaultFormatter) {
        @synchronized(self) {
            if (!defaultFormatter) {
                defaultFormatter = [[NSDateFormatter alloc] init];
            }
        }
    }
    return defaultFormatter;
}

#pragma mark - Default Formatter

+ (NSDate *) dateFromString:(NSString *)dateString  withFomat:(NSString *) dateFormat locale:(NSLocale *) locale {
    return [[self.class sharedInstance] dateFromString:dateString withFomat:dateFormat locale:locale];
}

- (NSDate *) dateFromString:(NSString *)dateString  withFomat:(NSString *) dateFormat locale:(NSLocale *) locale {
   	if ([dateString length] == 0) {
        return nil;
    }
    @synchronized(self.defaultFormatter) {
        NSString *oldDateFormat = [self.defaultFormatter dateFormat];
        NSLocale *oldLocale = self.defaultFormatter.locale;
        if (locale != nil) {
            [self.defaultFormatter setLocale:locale];
        }
        [self.defaultFormatter setDateFormat:dateFormat];
        NSDate *date = [self.defaultFormatter dateFromString:dateString];
        if (locale != nil) {
            [self.defaultFormatter setLocale:oldLocale];
        }
        [self.defaultFormatter setDateFormat:oldDateFormat];
        return date;
    }
}

- (NSDate *) dateFromString:(NSString *)dateString  withFomat:(NSString *) dateFormat {
    return [self dateFromString:dateString withFomat:dateFormat locale:nil];
}

+ (NSDate *) dateFromString:(NSString *)dateString withDateStyle:(NSDateFormatterStyle)dStyle timeStyle:(NSDateFormatterStyle)tStyle locale:(NSLocale *)locale {
    return [[self.class sharedInstance] dateFromString:dateString withDateStyle:dStyle timeStyle:tStyle locale:locale];
}

- (NSDate *) dateFromString:(NSString *)dateString withDateStyle:(NSDateFormatterStyle)dStyle timeStyle:(NSDateFormatterStyle)tStyle locale:(NSLocale *)locale {
    if ([dateString length] == 0) {
        return nil;
    }
    @synchronized(self.defaultFormatter) {
        NSLocale *oldLocale = self.defaultFormatter.locale;
        NSDateFormatterStyle oldDateStyle = self.defaultFormatter.dateStyle;
        NSDateFormatterStyle oldTimeStyle = self.defaultFormatter.timeStyle;
        if (locale != nil) {
            [self.defaultFormatter setLocale:locale];
        }
        [self.defaultFormatter setDateStyle:dStyle];
        [self.defaultFormatter setTimeStyle:tStyle];
        NSDate *date = [self.defaultFormatter dateFromString:dateString];
        if (locale != nil) {
            [self.defaultFormatter setLocale:oldLocale];
        }
        [self.defaultFormatter setDateStyle:oldDateStyle];
        [self.defaultFormatter setTimeStyle:oldTimeStyle];
        return date;
    }
}

+ (NSString *) stringFromDate:(NSDate *) date withFormat:(NSString *) dateFormat locale:(NSLocale *) locale {
    return [[self.class sharedInstance] stringFromDate:date withFormat:dateFormat locale:locale];
}

- (NSString *) stringFromDate:(NSDate *) date withFormat:(NSString *) dateFormat locale:(NSLocale *) locale {
    @synchronized(self.defaultFormatter) {
        NSLocale *oldLocale = self.defaultFormatter.locale;
        if (locale != nil) {
            [self.defaultFormatter setLocale:locale];
        }
        NSString *oldDateFormat = [self.defaultFormatter dateFormat];
        [self.defaultFormatter setDateFormat:dateFormat];
        NSString *formattedDate = [self.defaultFormatter stringFromDate:date];
        if (locale != nil) {
            [self.defaultFormatter setLocale:oldLocale];
        }
        [self.defaultFormatter setDateFormat:oldDateFormat];
        return formattedDate;
    }
}

- (NSString *) stringFromDate:(NSDate *) date withFormat:(NSString *) dateFormat {
    return [self stringFromDate:date withFormat:dateFormat locale:nil];
}

+ (NSString *) stringFromDate:(NSDate *) date withDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle) timeStyle locale:(NSLocale *) locale {
    return [[self.class sharedInstance] stringFromDate:date withDateStyle:dateStyle timeStyle:timeStyle locale:locale];
}

- (NSString *) stringFromDate:(NSDate *) date withDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle) timeStyle locale:(NSLocale *) locale {
    @synchronized(self.defaultFormatter) {
        NSLocale *oldLocale = self.defaultFormatter.locale;
        if (locale != nil) {
            [self.defaultFormatter setLocale:locale];
        }
        [self.defaultFormatter setDateStyle:dateStyle];
        [self.defaultFormatter setTimeStyle:timeStyle];
        NSString *result = [self.defaultFormatter stringFromDate:date];
        if (locale != nil) {
            [self.defaultFormatter setLocale:oldLocale];
        }
        return result;
    }
}

- (NSString *) stringFromDate:(NSDate *) date withDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle) timeStyle {
    return [self stringFromDate:date withDateStyle:dateStyle timeStyle:timeStyle locale:nil];
}

#pragma mark - 

+ (NSNumber *) dayOfWeekFromDate:(NSDate *)date {
    return [[self.class sharedInstance] dayOfWeekFromDate:date];
}

- (NSNumber *) dayOfWeekFromDate:(NSDate *)date {
    @synchronized(self.defaultFormatter) {
        NSLocale *oldLocale = self.defaultFormatter.locale;
        NSString *oldDateFormat = self.defaultFormatter.dateFormat;
        [self.defaultFormatter setLocale:de_CH_Locale()];
        [self.defaultFormatter setDateFormat:@"e"];
        NSNumber *result = [NSNumber numberWithInt:[[self.defaultFormatter stringFromDate:date] intValue]];
        [self.defaultFormatter setLocale:oldLocale];
        [self.defaultFormatter setDateFormat:oldDateFormat];
        return result;
    }
}

+ (NSDate *) dayOfWeekDateFromString:(NSString *)string {
    return [[self.class sharedInstance] dayOfWeekDateFromString:string];
}

- (NSDate *) dayOfWeekDateFromString:(NSString *)string {
    @synchronized(self.defaultFormatter) {
        NSLocale *oldLocale = self.defaultFormatter.locale;
        NSString *oldDateFormat = self.defaultFormatter.dateFormat;
        [self.defaultFormatter setLocale:de_CH_Locale()];
        [self.defaultFormatter setDateFormat:@"e"];
        NSDate *result = [self.defaultFormatter dateFromString:string];
        [self.defaultFormatter setLocale:oldLocale];
        [self.defaultFormatter setDateFormat:oldDateFormat];
        return result;
    }
}

+ (NSString *) dayOfWeekNameFromDate:(NSDate *)date {
    return [[self.class sharedInstance] dayOfWeekNameFromDate:date];
}

- (NSString *) dayOfWeekNameFromDate:(NSDate *)date {
    @synchronized(self.defaultFormatter) {
        NSLocale *oldLocale = self.defaultFormatter.locale;
        NSString *oldDateFormat = self.defaultFormatter.dateFormat;
        [self.defaultFormatter setLocale:[NSLocale currentLocale]];
        [self.defaultFormatter setDateFormat:@"EEE"];
        NSString *result = [[self.defaultFormatter stringFromDate:date] substringToIndex:2];
        [self.defaultFormatter setLocale:oldLocale];
        [self.defaultFormatter setDateFormat:oldDateFormat];
        return result;
    }
}

#pragma mark - Singleton

// Thread safe singleton. DO NOT remove synchronize!
+ (DPHDateFormatter *)sharedInstance {
    if (sharedInstance == nil) {
        @synchronized(self) {
            if (sharedInstance == nil) {
                sharedInstance = [[super allocWithZone:NULL] init];
            }
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


@end
