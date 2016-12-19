//
//  NSError+Additions.h
//  dphHermes
//
//  Created by Tomasz Krasnyk on 23.10.15.
//
//

#import <Foundation/Foundation.h>

void SetError(NSError **errorTarget, NSError *actualError);

// error domains
extern NSString * const DPHLoadDomain;
extern NSString * const DPHUnloadDomain;
extern NSString * const DPHFinishTourDomain;

// error userInfoKeys
extern NSString * const NSErrorParameterItem;
extern NSString * const NSErrorParameterTitle;
extern NSString * const NSErrorParameterTransportCode;
extern NSString * const NSErrorParameterLocation;
extern NSString * const NSErrorParameterDeparture;
extern NSString * const NSErrorParameterTransportGroup;

// error codes
typedef enum : NSInteger {
    DPHErrorCodeSuccess = 0,                    // not used but reserved in case of checking for code on NSError == nil
    DPHErrorCodeShouldSwitchToLoad = 1,
    DPHErrorCodeShouldSwitchToUnload = 2,
    DPHErrorCodeInputIgnored = 3,
    DPHErrorDestinationCouldNotBeInferred = 4,
    DPHErrorLoadingTransportAnywayNotConfirmed = 5,
    DPHErrorPickupNotPickedUpOrNotAllItemsUnloaded = 6,
    DPHErrorDirectDeliveryNotLoaded = 7,
    DPHErrorDeliveryNotLoaded = 8,
    DPHErrorTourStopNotFulfilled = 9,
} DPHErrorCode;

@interface NSError (Additions)

+ (NSError *) errorForAlreadyLoadedTransportCode:(NSString *)transportCode domain:(NSString *) domain;
+ (NSError *) errorForNotOnTheTourTransportCode:(NSString *)transportCode domain:(NSString *) domain;
+ (NSError *) errorForEnteringUnexpectedTransportBoxCode:(NSString *)transportCode domain:(NSString *) domain;

@end
