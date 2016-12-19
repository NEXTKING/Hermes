//
//  NSDictionary+Addtions.m
//  dphHermes
//
//  Created by Lutz Thalmann on 30.04.15.
//
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (ServerSynchronization)

- (NSDecimalNumber *)decimalForKey:(NSString *)key {
    NSDecimalNumber *returnValue = nil;
    if ([self valueForKey:key]) {
        returnValue = [NSDecimalNumber decimalNumberWithDecimal:[[self valueForKey:key] decimalValue]];
    }
    return returnValue;
}

- (NSNumber *) boolFromNumberForKey:(NSString *) key {
    NSNumber *value = nil;
    id dictValue = [self objectForKey:key];
    if (dictValue) {
        value = [NSNumber numberWithBool:[dictValue boolValue]];
    }
    return value;
}

- (NSString *) stringForKey:(NSString *) key {
    NSString *value = nil;
    id dictValue = [self objectForKey:key];
    if (dictValue) {
        value = [NSString stringWithFormat:@"%@", dictValue];
    }
    return value;
}

@end

#pragma mark - 

@implementation NSDictionary (Additions)

- (void) setValueOrSkip:(id) value forKey:(NSString *) key {
    if (value == nil) {
        return;
    }
    [self setValue:value forKey:key];
}

- (NSDictionary *) dictionaryByAddingEntriesFromDictionary:(nullable NSDictionary *) dictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[self count] + [dictionary count]];
    [dict addEntriesFromDictionary:self];
    if (dictionary != nil) {
        [dict addEntriesFromDictionary:dictionary];
    }
    return [dict copy];
}

@end