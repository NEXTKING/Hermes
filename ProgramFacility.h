//
//  ProgramFacility.h
//  dphHermes
//
//  Created by Lutz Thalmann on 04.06.15.
//
//

#import "MTStatusBarOverlay.h"
#import "UIViewController+Additions.h"
#import "UIResponder+Additions.h"
#import "HermesAppDelegate.h"

/*
 MessageTypeInfo
    The message is sent as an informational message.
 MessageTypeInquiry
    The message is sent as an inquiry message.
 MessageTypeCompletion
    A completion message is sent to a call message queue. A completion message indicates the status of the work that is successfully performed.
 MessageTypeDiagnostic
    A diagnostic message is sent to a call message queue. Diagnostic messages provide information about errors detected by this program. The errors are either in the input sent to it, or are those that occurred while it was running the requested function. An escape or notify message should also be sent to inform the receiving program or procedure of the diagnostic messages that are on its message queue.
 MessageTypeNotify
    A notify exception message is sent to a call message queue. A notify message describes a condition for which corrective action must be taken before the sending program can continue. A reply message is sent back to the sending program. After corrective action is taken, the sending program can resume running and can receive the reply message from its message queue.
 MessageTypeEscape
    An escape exception message is sent to a call message queue. An escape message describes an irrecoverable error condition. The sending program does not continue to run.
 MessageTypeRequest
    A request message is sent to a call message queue. A request message allows request data received from device files to pass from this program to another program or procedure. An immediate message, specified by the MSG parameter, must be used to send the request.
 MessageTypeStatus
    A status exception message is sent to a call message queue. The status message describes the status of work performed by the sending program. The first 28 characters of message data in the MSGDTA parameter are used as the comparison data for message monitors (established by the Monitor Message (MONMSG) command). If the status exception message is not being monitored, control is returned to the sending program. If a status message is sent to the external message queue of an interactive job, the message is shown on line 24, processing continues, and no response is required.
*/
typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeInfo,
    MessageTypeInquiry,
    MessageTypeRequest,
    MessageTypeCompletion,
    MessageTypeDiagnostic,
    MessageTypeNotify,
    MessageTypeEscape,
    MessageTypeStatus
};

// Runtime APIs
extern NSDictionary * PFDebugGetCaller(void);
extern void PFDebugLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);
extern BOOL PFCurrentModeIsDemo(void);

// OperatingSystem APIs
extern CGFloat iosVersion(void);
extern NSString * iOSVersionFromString(NSString *iOSVersionString);
extern NSString * PFOsVersion(void);
extern BOOL PFOsVersionCompareLT(NSString *version);
extern BOOL PFOsVersionCompareLE(NSString *version);
extern BOOL PFOsVersionCompareEQ(NSString *version);
extern BOOL PFOsVersionCompareGE(NSString *version);
extern BOOL PFOsVersionCompareGT(NSString *version);

// Device APIs
extern NSString * PFDeviceId(void);
extern BOOL PFDeviceIsSimulator(void);

// Application APIs
extern BOOL PFTourTypeSupported(NSString *types, ...) NS_REQUIRES_NIL_TERMINATION;
extern BOOL PFBrandingSupported(NSString *brandings, ...) NS_REQUIRES_NIL_TERMINATION;
extern BOOL PFLanguageSupported(NSSet *languages);
extern UIImage *PFBrandingLogo(void);

// Settings APIs
extern NSInteger PFHermesServerVersion(void);