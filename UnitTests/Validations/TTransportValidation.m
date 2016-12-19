//
//  TTransportValidation+Unilabs.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 12.08.15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Transport.h"
#import "NSUserDefaults+Additions.h"
#import "NSString+Additions.h"

static NSString * const BarcodeSeparator_C = @"$C$";
static NSString * const BarcodeSeparator_c = @"$c$";
static NSString * const BarcodeSeparator_coma = @"$;$";
static NSString * const BarcodeSeparator_I = @"$I$";
static NSString * const BarcodeSeparator_i = @"$i$";

static NSString * barcode(NSString *code, NSString *separator, NSString *locationSuffix) {
    return FmtStr(@"%@%@%@", code, separator, locationSuffix);
}

@interface TTransportValidation : XCTestCase

@end


@implementation TTransportValidation

- (void)setUp {
    [super setUp];
    
    [NSUserDefaults setBranding:nil];
}

- (void)testBagBarcodeValidationETA {
    // given
    [NSUserDefaults setBranding:BrandingETA];
    
    // when
    
    // then
    XCTAssertTrue([Transport validateTransportWithCode:@"H000001"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"H123456"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"H123456$;$12"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"H123456$I$12"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"8000123"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"HU123456"]);

    
    XCTAssertFalse([Transport validateTransportWithCode:@"H1234567"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"H123"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"H12345"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"H1234$4345%5"]);
}

- (void)testBagBarcodeValidationUnilabs {
    // given
    [NSUserDefaults setBranding:BrandingUnilabs];
    
    // when
    
    // then
    XCTAssertTrue([Transport validateTransportWithCode:@"S:A1"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:B12"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:C123"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:D1234567"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:E1234567"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:F12345"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:X12345"]);
    XCTAssertTrue([Transport validateTransportWithCode:@"S:Z12345"]);
    
    XCTAssertFalse([Transport validateTransportWithCode:@"S:A12345678"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"S:12345"]);
    XCTAssertFalse([Transport validateTransportWithCode:@":A12345"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"S:AB1234567"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"S:A12345$;$01"]);
    XCTAssertFalse([Transport validateTransportWithCode:@"1S:A12345$;$01"]);
}

- (void)testTransportBoxBarcodeValidationUnilabs {
    // given
    [NSUserDefaults setBranding:BrandingUnilabs];
    
    // when
    
    // then
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:D12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:AB12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:ABC12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:ABCE12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:ABCE1$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:ECBA1$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:ABCD12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:ABCD1$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:A12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:X12345$;$01"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"T:AGHZ12345$;$01"]);
    
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:ABCEF1$;$01"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:ABCD$;$01"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:ABCX123456$;$01"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:ABCD1234567$;$01"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:12345$;$01"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:A12345;$01"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:A12345$;$0"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:A12345$;$111"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"T:A12345"]);
}

- (void)testTransportBoxBarcodeValidationViollier {
    // given
    [NSUserDefaults setBranding:BrandingViollier];
    
    // when
    
    // then
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"V005:0"]);
    XCTAssertTrue([Transport_Box validateTransportBoxBarcode:@"V005:123456"]);
    
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"12V005:123456"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"V005"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"V00"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"V0"]);
    XCTAssertFalse([Transport_Box validateTransportBoxBarcode:@"V"]);
}

- (void)testPlacingBagInBagUnilabs {
    // given
    [NSUserDefaults setBranding:BrandingUnilabs];
    NSString *whiteBag = @"S:A1234567";
    // when
    
    // then
    XCTAssertFalse([Transport canPlaceTransportWithCode:whiteBag toTransportWithCode:whiteBag]);
}

- (void)testPlacingShippingBagInShippingBagUnilabs {
    // given
    [NSUserDefaults setBranding:BrandingUnilabs];
    NSString *whiteShippingBag = @"T:A12345$;$01";
    
    // when
    
    // then
    XCTAssertFalse([Transport canPlaceTransportWithCode:whiteShippingBag toTransportWithCode:whiteShippingBag]);
}

- (void)testPlacingTransportInTransportBoxNonUnilabs {
    // given
    [NSUserDefaults setBranding:BrandingViollier];
    
    // when
    
    // then
    XCTAssertTrue([Transport canPlaceTransportWithCode:@"V005:13" toTransportWithCode:nil]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:@"V005:13" toTransportWithCode:@"V005:13"]);
}

- (void)testPlacingBagInShippingBagUnilabs {
    // given
    [NSUserDefaults setBranding:BrandingUnilabs];
    NSString *whiteBag = @"S:A1234567";
    NSString *redBag = @"S:B1234567";
    NSString *greenBag = @"S:C1234567";
    NSString *yellowBag = @"S:D1234567";
    NSString *microbiologyBag = @"S:E1234567";
    
    NSString *organgeWhiteShippingBag = @"T:ABCE12345";
    NSString *pinkShippingBag = @"T:ABC12345";
    NSString *plainWhiteShippingBag = @"T:D12345";
    NSString *greenShippingBag = @"T:AB12345";
    NSString *xShippingBag = @"T:X12345";
    
    // when
    
    // then
    XCTAssertTrue([Transport canPlaceTransportWithCode:whiteBag toTransportWithCode:organgeWhiteShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:whiteBag toTransportWithCode:pinkShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:whiteBag toTransportWithCode:greenShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:whiteBag toTransportWithCode:xShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:whiteBag toTransportWithCode:plainWhiteShippingBag]);
    
    XCTAssertTrue([Transport canPlaceTransportWithCode:redBag toTransportWithCode:organgeWhiteShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:redBag toTransportWithCode:pinkShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:redBag toTransportWithCode:greenShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:redBag toTransportWithCode:xShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:redBag toTransportWithCode:plainWhiteShippingBag]);
    
    XCTAssertTrue([Transport canPlaceTransportWithCode:greenBag toTransportWithCode:organgeWhiteShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:greenBag toTransportWithCode:pinkShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:greenBag toTransportWithCode:xShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:greenBag toTransportWithCode:greenShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:greenBag toTransportWithCode:plainWhiteShippingBag]);
    
    XCTAssertTrue([Transport canPlaceTransportWithCode:yellowBag toTransportWithCode:plainWhiteShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:yellowBag toTransportWithCode:xShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:yellowBag toTransportWithCode:greenShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:yellowBag toTransportWithCode:organgeWhiteShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:yellowBag toTransportWithCode:pinkShippingBag]);
    
    XCTAssertTrue([Transport canPlaceTransportWithCode:microbiologyBag toTransportWithCode:organgeWhiteShippingBag]);
    XCTAssertTrue([Transport canPlaceTransportWithCode:microbiologyBag toTransportWithCode:xShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:microbiologyBag toTransportWithCode:plainWhiteShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:microbiologyBag toTransportWithCode:greenShippingBag]);
    XCTAssertFalse([Transport canPlaceTransportWithCode:microbiologyBag toTransportWithCode:pinkShippingBag]);
    
    // extra tests
    XCTAssertFalse([Transport canPlaceTransportWithCode:@"S:T1" toTransportWithCode:@"T:AB1"]);
}

- (void)testBarcodeTrailerMatching {
    // given
    NSString *prefix = @"H123445";
    NSString *locationSuffix = @"CH01";
    
    // when
    
    // then
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:nil].location == NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:barcode(prefix, @"$C", locationSuffix)].location == NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:barcode(prefix, @"C$", locationSuffix)].location == NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:barcode(prefix, @"$c", locationSuffix)].location == NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:barcode(prefix, @"c$", locationSuffix)].location == NSNotFound);
    
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:barcode(prefix, BarcodeSeparator_C, locationSuffix)].location != NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$C\\$|\\$c\\$)" fromBarcode:barcode(prefix, BarcodeSeparator_c, locationSuffix)].location != NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$I\\$|\\$i\\$)" fromBarcode:barcode(prefix, BarcodeSeparator_i, locationSuffix)].location != NSNotFound);
    XCTAssertTrue([Transport rangeOfTrailerPattern:@"(\\$I\\$|\\$i\\$)" fromBarcode:barcode(prefix, BarcodeSeparator_I, locationSuffix)].location != NSNotFound);
}

- (void)testGettingCodeFromBarcode {
    // given
    NSString *prefix = @"H123445";
    NSString *locationSuffix = @"CH01";
    // when
    
    // then
    
    XCTAssertEqualObjects([Transport transportCodeFromBarcode:barcode(prefix, BarcodeSeparator_coma, locationSuffix)], prefix);
    XCTAssertEqualObjects([Transport transportCodeFromBarcode:barcode(prefix, BarcodeSeparator_C, locationSuffix)], prefix);
    XCTAssertEqualObjects([Transport transportCodeFromBarcode:barcode(prefix, BarcodeSeparator_c, locationSuffix)], prefix);
    XCTAssertEqualObjects([Transport transportCodeFromBarcode:barcode(prefix, BarcodeSeparator_I, locationSuffix)], prefix);
    XCTAssertEqualObjects([Transport transportCodeFromBarcode:barcode(prefix, BarcodeSeparator_i, locationSuffix)], prefix);
}

- (void)testGettingLocationFromBarcode {
    // given
    NSString *prefix = @"H123445";
    NSString *locationSuffix = @"CH01";
    // when
    
    // then
    XCTAssertEqualObjects([Transport transportDestinationFromBarcode:barcode(prefix, BarcodeSeparator_coma, locationSuffix)], locationSuffix);
    XCTAssertEqualObjects([Transport transportDestinationFromBarcode:barcode(prefix, BarcodeSeparator_C, locationSuffix)], locationSuffix);
    XCTAssertEqualObjects([Transport transportDestinationFromBarcode:barcode(prefix, BarcodeSeparator_c, locationSuffix)], locationSuffix);
    XCTAssertEqualObjects([Transport transportDestinationFromBarcode:barcode(prefix, BarcodeSeparator_I, locationSuffix)], locationSuffix);
    XCTAssertEqualObjects([Transport transportDestinationFromBarcode:barcode(prefix, BarcodeSeparator_i, locationSuffix)], locationSuffix);
}


@end
