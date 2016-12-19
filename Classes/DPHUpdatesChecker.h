//
//  DPHUpdatesChecker.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 02.11.15.
//
//

#import <Foundation/Foundation.h>

@interface DPHUpdatesChecker : NSObject
@property (nonatomic, readonly) NSString *URLToApplicationPlist;

- (instancetype)initWithURLToApplicationPlist:(NSString *) url;
- (void)checkForApplicationUpdates;

+ (BOOL) isVersion:(NSString *)version1 newerThan:(NSString *) version2;

@end
