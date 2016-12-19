//
//  DSPF_Error.h
//  Hermes
//
//  Created by Lutz  Thalmann on 28.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_ColoredAlert.h"

typedef NS_ENUM(NSInteger, AlertViewTag) {
    AlertViewNoDriverGoodIssuePermissionsTag = 0,
};

@interface DSPF_Error : NSObject <DSPF_ColoredAlertDelegate,
                                  UIAlertViewDelegate> {

@private
    id alertView;
}

+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText;
+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate;
+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate cancelButtonTitle:(NSString *) cancelTitle;
+ (DSPF_Error *)messageTitle:(NSString *)messageTitle messageText:(NSString *)messageText delegate:(id)delegate cancelButtonTitle:(NSString *) cancelButtonTitle otherButtonTitle:(NSString *) otherButtonTitle;

@property (nonatomic, retain) id alertView;

@end


@interface DSPF_Error(StandardMessages)

+ (DSPF_Error *) messageFromError:(NSError *) error;

+ (DSPF_Error *) messageForInvalidTransportWithBarcode:(NSString *) barcode;
+ (DSPF_Error *) messageForInvalidTransportBoxWithBarcode:(NSString *) transportBoxBarcode;
+ (DSPF_Error *) messageForInvalidTransportCode:(NSString *) transportCode intendedToBePlacedInBoxWithCode:(NSString *) boxCode;

+ (DSPF_Error *) messageForMissingDriverGoodsIssuePermissionsWithCancelButtonTitle:(NSString *) buttonTitle delegate:(id<UIAlertViewDelegate>) delegate;
+ (DSPF_Error *) messageForUploadFailureWithTitle:(NSString *) title errorString:(NSString *) errorString;

@end
