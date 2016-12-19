//
//  SVR_ScanDeviceManager.h
//  Hermes
//
//  Created by Lutz  Thalmann on 29.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import <AVFoundation/AVFoundation.h>
#import "DTDevices.h"
#import "ZBarSDK.h"
#import "DSPF_Warning.h"

@protocol SVR_CameraBarcodeScannerDelegate
- (void) barcodeController:(UIViewController *)barcodeController didFinishWithBarcode:(NSString *) barcode;
@end

@interface SVR_ScanDeviceManager : NSObject <DTDeviceDelegate,
                                             ZBarReaderDelegate,
                                             AVCaptureMetadataOutputObjectsDelegate,
                                             DSPF_WarningDelegate, SVR_CameraBarcodeScannerDelegate> {
@private
    AVCaptureSession            *cameraCaptureSession;
    AVCaptureVideoPreviewLayer  *cameraCapturePreviewLayer;
    EAAccessory                 *currentAccessory;
    DTDevices                   *linea;
    BOOL                         lineaWithBluetooth;
    UIViewController            *cameraUser;
    BOOL                         justOnce;
	NSString                    *scannerDaten;
    NSString                    *firmwareFileName;
    NSInteger                    firmwareRevisionNumber;
    NSOperationQueue            *operationQueue;
}

@property (retain, nonatomic) AVCaptureSession           *cameraCaptureSession;
@property (retain, nonatomic) AVCaptureVideoPreviewLayer *cameraCapturePreviewLayer;
@property (atomic, assign)    EAAccessory                *currentAccessory;
@property (retain, nonatomic) DTDevices                  *linea;
@property (nonatomic)         BOOL                        lineaWithBluetooth;
@property (atomic, assign)    UIViewController           *cameraUser;
@property (retain, atomic)    NSString                   *scannerDaten;
@property (retain, nonatomic) NSString                   *firmwareFileName;

- (instancetype)initWithSettingsPrefix:(NSString *) settingsPrefix;

- (void)connectScanDevice;
- (void)disconnectScanDevice:(NSNotification *)aNotification;
- (void)startScan:(NSNotification *)aNotification;
- (void)stopScan;

@end