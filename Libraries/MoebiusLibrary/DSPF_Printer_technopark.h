//
//  DSPF_Printer_technopark.h
//  dphHermes
//
//  Created by Denis Kurochkin on 11.12.15.
//
//

#import <UIKit/UIKit.h>
#import "Transport_Group.h"

@class DSPF_Printer_technopark;

@protocol DSPF_Printer_Protocol <NSObject>

- (void) printerController: (DSPF_Printer_technopark*) printerCont DidFinishBindingPrinter:(NSString*) printerID;
- (void) printerControllerDidPrintReceipt: (DSPF_Printer_technopark*) printerCont;
- (void) printerController: (DSPF_Printer_technopark*) printerCont didFailedPrintingWithError:(NSError*) error;
- (void) printerController: (DSPF_Printer_technopark*) printerCont didFailedBindingWithError:(NSError*) error;

@end

@interface DSPF_Printer_technopark : UIViewController

@property (nonatomic, assign) id<DSPF_Printer_Protocol> delegate;

- (void) bindPrinterWithId:(NSString*) printerId;
- (void) printTransportGroup:(Transport_Group*) transportGroup;
- (void) printSample:(NSString*) amount;
- (void) xReport;
- (void) zReport;
- (void) openShift;
- (void) stopActivities;


@end
