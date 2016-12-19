//
//  NSString+Addtions.h
//  dphHermes
//
//  Created by Tomasz Kransyk on 29.04.15.
//
//

#import <Foundation/Foundation.h>

#define FmtStr(s, ...) [NSString stringWithFormat:(s), ##__VA_ARGS__]

extern NSString * NotNullString(NSString *textOrNil);

@interface NSString (Addtions)

- (BOOL) hasAnyPrefix:(NSArray *) prefixes;

@end
