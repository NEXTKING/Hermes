//
//  NSDictionary+Addtions.h
//  dphHermes
//
//  Created by Lutz Thalmann on 30.04.15.
//
//

#import <Foundation/Foundation.h>


@interface NSDictionary (ServerSynchronization)

- (NSDecimalNumber *) decimalForKey:(NSString *) key;
- (NSNumber *) boolFromNumberForKey:(NSString *) key;
- (NSString *) stringForKey:(NSString *) key;

@end


@interface NSDictionary (Additions)

- (void) setValueOrSkip:(id) value forKey:(NSString *) key;
- (NSDictionary *) dictionaryByAddingEntriesFromDictionary:(nullable NSDictionary *) dictionary;

@end
