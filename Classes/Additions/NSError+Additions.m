//
//  NSError+Additions.m
//  dphHermes
//
//  Created by Tomasz Krasnyk on 23.10.15.
//
//

#import "NSError+Additions.h"

void SetError(NSError **errorTarget, NSError *actualError) {
    if (errorTarget == nil) {
        return;
    }
    *errorTarget = actualError;
}

// error domains
NSString * const DPHLoadDomain = @"DPHLoadDomain";
NSString * const DPHUnloadDomain = @"DPHUnloadDomain";
NSString * const DPHFinishTourDomain = @"DPHFinishTourDomain";

// error userInfoKeys
NSString * const NSErrorParameterItem = @"NSErrorParameterItem";
NSString * const NSErrorParameterTitle = @"NSErrorParameterTitle";
NSString * const NSErrorParameterTransportCode = @"NSErrorParameterTransportCode";
NSString * const NSErrorParameterLocation = @"NSErrorParameterLocation";
NSString * const NSErrorParameterDeparture = @"NSErrorParameterLocation";
NSString * const NSErrorParameterTransportGroup = @"NSErrorParameterTransportGroup";

@implementation NSError(Additions)

+ (NSError *) errorForAlreadyLoadedTransportCode:(NSString *)transportCode domain:(NSString *) domain {
    NSDictionary *userInfo = @{ NSErrorParameterTitle : transportCode,
                                NSLocalizedDescriptionKey: NSLocalizedString(@"MESSAGE_010", @"ist bereits geladen.\nDiese Eingabe wird ignoriert!") };
    return [NSError errorWithDomain:domain code:DPHErrorCodeInputIgnored userInfo:userInfo];
}

+ (NSError *) errorForNotOnTheTourTransportCode:(NSString *)transportCode domain:(NSString *) domain {
    NSDictionary *userInfo = @{ NSErrorParameterTitle : transportCode,
                                NSLocalizedDescriptionKey: NSLocalizedString(@"ERROR_MESSAGE_017", @"ist nicht für diese Tour.\nDiese Eingabe wird ignoriert!") };
    return [NSError errorWithDomain:domain code:DPHErrorCodeInputIgnored userInfo:userInfo];
}

+ (NSError *) errorForEnteringUnexpectedTransportBoxCode:(NSString *)transportCode domain:(NSString *) domain {
    NSDictionary *userInfo = @{ NSErrorParameterTitle : transportCode,
                                NSLocalizedDescriptionKey: NSLocalizedString(@"ist ein Transportbox-Code.\nDiese Eingabe wird ignoriert!",
                                                                             @"ist ein Transportbox-Code.\nDiese Eingabe wird ignoriert!") };
    return [NSError errorWithDomain:domain code:DPHErrorCodeInputIgnored userInfo:userInfo];
}

@end
