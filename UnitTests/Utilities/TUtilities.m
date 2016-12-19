//
//  TUtilities.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 23.07.15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ProgramFacility.h"

@interface TUtilities : XCTestCase

@end

@implementation TUtilities

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testIOSVersion {
    // given
    
    // when
    
    // then
    
    XCTAssertEqualObjects(iOSVersionFromString(@"8.4.1"), @"8.41");
    XCTAssertEqualObjects(iOSVersionFromString(@"8.4"), @"8.4");
    XCTAssertEqualObjects(iOSVersionFromString(@"8.0"), @"8.0");
}


@end
