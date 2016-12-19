//
//  NSString+Addtions.m
//  dphHermes
//
//  Created by Tomasz Kransyk on 29.04.15.
//
//

#import "NSString+Additions.h"

NSString * NotNullString(NSString *textOrNil) {
    return textOrNil == nil ? @"" : textOrNil;
}

@implementation NSString (Addtions)

- (BOOL) hasAnyPrefix:(NSArray *) prefixes {
    BOOL hasPrefix = NO;
    for (NSString *prefix in prefixes) {
        hasPrefix = [self hasPrefix:prefix];
        if (hasPrefix) {
            break;
        }
    }
    return hasPrefix;
}

@end
