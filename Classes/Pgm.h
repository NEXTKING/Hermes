//
//  Pgm.h
//  dphHermes
//
//  Created by iLutz on 09.06.15.
//
//

#import <Foundation/Foundation.h>

extern NSDictionary * ProgramLibrary;
extern NSString * const CPFErrorDomain;

@interface Pgm : NSObject

+ (NSError *)execute:(NSString *)program withParameters:(NSDictionary *)parameters;

@end
