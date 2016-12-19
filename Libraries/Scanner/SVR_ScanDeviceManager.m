//
//  SVR_ScanDeviceManager.m
//  Hermes
//
//  Created by Lutz  Thalmann on 29.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SVR_ScanDeviceManager.h"
#import "NSDataCrypto.h"
#import "DSPF_Activity.h"
#import "DSPF_Error.h"

@interface SVR_CameraBarcodeScanner : UIViewController <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureSession *session;
    AVCaptureMetadataOutput *output;
    AVCaptureVideoPreviewLayer *prevLayer;
    
    AVCaptureDeviceInput *input;
    NSString *settingsPrefix;
}
@property (nonatomic, assign) id<SVR_CameraBarcodeScannerDelegate> delegate;

@end

@implementation SVR_CameraBarcodeScanner
@synthesize delegate;

- (instancetype)initWithSettingsPrefix:(NSString *) prefix {
    self = [super init];
    if (self) {
        settingsPrefix = [prefix retain];
        self.title = NSLocalizedString(@"COMMON_ScanBarcode_T", nil);
        
        session = [[AVCaptureSession alloc] init];
        NSError *error = nil;
        
        input = [[AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error] retain];
        if (input) {
            [session addInput:input];
        } else {
            NSLog(@"Error: %@", error);
        }
        
        output = [[AVCaptureMetadataOutput alloc] init];
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [session addOutput:output];
        
        output.metadataObjectTypes = [output availableMetadataObjectTypes];
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    prevLayer = [[AVCaptureVideoPreviewLayer layerWithSession:session] retain];
    prevLayer.frame = self.view.bounds;
    prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:prevLayer];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
    self.navigationItem.leftBarButtonItem = cancel;
    [cancel release];
    
    [session startRunning];
}

- (void)viewDidUnload {
    [super viewDidUnload];

    [prevLayer release];
    prevLayer = nil;
}

- (void) cancelClicked:(id)sender {
    [self.delegate barcodeController:self didFinishWithBarcode:nil];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // AVMetadataObjectTypeUPCECode
    // AVMetadataObjectTypeCode39Code
    // AVMetadataObjectTypeCode39Mod43Code
    // AVMetadataObjectTypeCode93Code
    // AVMetadataObjectTypeCode128Code
    // AVMetadataObjectTypeEAN8Code
    // AVMetadataObjectTypeEAN13Code
    // AVMetadataObjectTypePDF417Code
    // AVMetadataObjectTypeAztecCode
    // AVMetadataObjectTypeQRCode
    NSString *barcode = nil;
    for(AVMetadataObject *metadataObject in metadataObjects) {
        NSString *metadataObjectType = [metadataObject type];
        if (metadataObjectType &&
            (([metadataObjectType isEqualToString:@"org.gs1.UPC-E"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_UPC"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.Code39"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE39"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.Code39Mod43"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE39"]]) ||
             ([metadataObjectType isEqualToString:@"com.intermec.Code93"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE93"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.Code128"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE128"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.Code128"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN128"]]) ||
             ([metadataObjectType isEqualToString:@"org.gs1.EAN-8"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"]]) ||
             ([metadataObjectType isEqualToString:@"org.gs1.EAN-13"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN13"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.PDF417"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PDF417"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.Aztec"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_AZTEK"]]) ||
             ([metadataObjectType isEqualToString:@"org.iso.QRCode"] &&
              [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_QRCODE"]]))) {
                 id object = metadataObject;
                 NSString *data = [object stringValue];
                 if (data) {
                     if ([data rangeOfString:@" "].location == NSNotFound && [data longLongValue] != 0) {
                         barcode = [NSString stringWithFormat:@"%lld", [data longLongValue]];
                     } else {
                         barcode = [NSString stringWithFormat:@"%@", data];
                     }
                     break;
                 }
             }
    }
    if (barcode) {
        [session stopRunning];
        [self.delegate barcodeController:self didFinishWithBarcode:barcode];
    }
}

- (NSString *) settingFromKey:(NSString *) key {
    return [settingsPrefix stringByAppendingString:key];
}

- (void)dealloc {
    [super dealloc];
    
    delegate = nil;
    [settingsPrefix release];
    [input release];
    [output release];
    [session release];
    [prevLayer release];
}


@end

#pragma mark -

static NSInteger const BarcodeEngineNone = 0;

@interface SVR_ScanDeviceManager()
@property (nonatomic, retain) NSString *linea2Dengine;
@end

@implementation SVR_ScanDeviceManager {
    FEAT_BARCODES barcodeEngine;
    NSString *settingsPrefix;
}
@synthesize linea2Dengine;
@synthesize cameraCaptureSession;
@synthesize cameraCapturePreviewLayer;
@synthesize currentAccessory;
@synthesize linea;
@synthesize lineaWithBluetooth;
@synthesize cameraUser;
@synthesize scannerDaten;
@synthesize firmwareFileName;

#pragma mark - Initialization

+ (NSString *) firmwareDirectoryPath {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Firmware"];
}

- (NSString *) settingFromKey:(NSString *) key {
    return [settingsPrefix stringByAppendingString:key];
}

-(NSString *)firmwareFileName {
    if (!firmwareFileName) {
        NSString *name = [[[self.linea deviceName] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        if ((!name || name.length == 0) && currentAccessory) {
            name = [[currentAccessory.name stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        }
        if (name && name.length != 0) {
            // && (name.length < 9 || ![[[name substringToIndex:9] uppercaseString] isEqualToString:@"LINEAPRO5"])) {
            NSString *firmwareDirectory = [SVR_ScanDeviceManager firmwareDirectoryPath];
            NSError  *err;
            NSArray  *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:firmwareDirectory error:&err];
            firmwareRevisionNumber = 0;
            NSString *lastPath;
            for(int i=0; i < [files count]; i++) {
                if([[[[files objectAtIndex:i] lastPathComponent] lowercaseString] rangeOfString:name].location != NSNotFound) {
                    NSString    *path =[firmwareDirectory stringByAppendingPathComponent:[files objectAtIndex:i]];
                    NS_DURING
                    /* old
                     if ([self.linea respondsToSelector:@selector(getFirmwareFileInformation:firmwareInfo:)]) {
                     firmwareInfo info;
                     [self.linea getFirmwareFileInformation:path firmwareInfo:&info];
                     if([info.deviceName  isEqualToString:self.linea.deviceName]  &&
                     [info.deviceModel isEqualToString:self.linea.deviceModel] &&
                     info.firmwareRevisionNumber > firmwareRevisionNumber) {
                     firmwareRevisionNumber = info.firmwareRevisionNumber;
                     lastPath = path;
                     }
                     } else {
                     */
                    NSError *error = nil;
                    NSDictionary *info = [self.linea getFirmwareFileInformation:[NSData dataWithContentsOfFile:path] error:&error];
                    if(info &&
                       (([self.linea deviceName] &&
                         [[info objectForKey:@"deviceName"] isEqualToString:[self.linea deviceName]]) ||
                        (![self.linea deviceName] && currentAccessory &&
                         [[info objectForKey:@"deviceName"] isEqualToString:currentAccessory.name])) &&
                       (([self.linea deviceModel] &&
                         [[info objectForKey:@"deviceModel"] isEqualToString:[self.linea deviceModel]]) ||
                        (![self.linea deviceModel] && currentAccessory &&
                         [[info objectForKey:@"deviceModel"] isEqualToString:currentAccessory.modelNumber])) &&
                       [[info objectForKey:@"firmwareRevisionNumber"] intValue] > firmwareRevisionNumber) {
                        firmwareRevisionNumber = [[info objectForKey:@"firmwareRevisionNumber"] intValue];
                        lastPath = path;
                    }
                    NS_HANDLER
                    NS_ENDHANDLER
                }
            }
            if (firmwareRevisionNumber > 0) {
                firmwareFileName = [lastPath retain];
            }
        }
    }
	return firmwareFileName;
}

-(void)checkForFirmwareUpdate {
	if(self.firmwareFileName) {
/* old 
        if ([self.linea respondsToSelector:@selector(getFirmwareFileInformation:firmwareInfo:)]) {
            firmwareInfo info;
            [self.linea getFirmwareFileInformation:file firmwareInfo:&info];
            if([info.deviceName isEqualToString:[self.linea deviceName]] &&
               [info.deviceModel isEqualToString:[self.linea deviceModel]]) {
                if(![info.firmwareRevision isEqualToString:[self.linea firmwareRevision]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DSPF_Warning messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                       messageText:[NSString stringWithFormat:NSLocalizedString(@"ERROR_MESSAGE_026", @"\nFirmware-Version:\naktuell:\t\t\t\t%@\nverfügbar:\t%@\n\nJetzt aktualisieren ?"),
                                                    [self.linea firmwareRevision], info.firmwareRevision]
                                              item:@"updateFirmware"
                                          delegate:self];
                    });
                }
            }
        } else {
*/
        NSError *error = nil;
        NSDictionary *info = [self.linea getFirmwareFileInformation:[NSData dataWithContentsOfFile:self.firmwareFileName] error:&error];
        if(info &&
           (([self.linea deviceName] &&
             [[info objectForKey:@"deviceName"] isEqualToString:[self.linea deviceName]]) ||
            (![self.linea deviceName] && currentAccessory &&
             [[info objectForKey:@"deviceName"] isEqualToString:currentAccessory.name])) &&
           (([self.linea deviceModel] &&
             [[info objectForKey:@"deviceModel"] isEqualToString:[self.linea deviceModel]]) ||
            (![self.linea deviceModel] && currentAccessory &&
             [[info objectForKey:@"deviceModel"] isEqualToString:currentAccessory.modelNumber]))) {
            if(([self.linea firmwareRevision] &&
               [[info objectForKey:@"firmwareRevision"] compare:[self.linea firmwareRevision] options:NSNumericSearch] == NSOrderedDescending) ||
               (![self.linea firmwareRevision] && currentAccessory &&
                [[info objectForKey:@"firmwareRevision"] compare:currentAccessory.firmwareRevision options:NSNumericSearch] == NSOrderedDescending)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DSPF_Warning messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                   messageText:[NSString stringWithFormat:NSLocalizedString(@"COMMON_NewFirmwareAvailableUpdateNow_M", nil),
                                                (([self.linea firmwareRevision]) ?
                                                 [self.linea firmwareRevision] : currentAccessory.firmwareRevision),
                                                [info objectForKey:@"firmwareRevision"]]
                                          item:@"updateFirmware"
                                      delegate:self cancelButtonTitle:NSLocalizedString(@"COMMON_NEIN", nil) otherButtonTitle:NSLocalizedString(@"COMMON_JA", nil)];
                });
            }
        }
	}
}

- (void)applySettings {
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    NSError *error = nil;
    if (![self.linea setAutoOffWhenIdle:604800.00 whenDisconnected:604800.00 error:&error]) {
        NSLog(@"[Scanner] Could not set AutoOffWhenIdle. Reason: %@", error);
    }
    // one week until awake by reset-button
    if (!justOnce) {
        justOnce = YES;
        self.firmwareFileName = nil;
        [self checkForFirmwareUpdate];
    }
    [operationQueue addOperationWithBlock:^{
        NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
        NSError *error = nil;
        NS_DURING
        [self.linea setBarcodeTypeMode:BARCODE_TYPE_DEFAULT error:&error];
        if (![[NSUserDefaults standardUserDefaults] boolForKey: [self settingFromKey:@"SYSVAL_BEEP"]]){
            [self.linea setScanBeep:FALSE volume:100 beepData: nil length: 0 error:&error];
        }else{
            if ([[NSUserDefaults standardUserDefaults] boolForKey: [self settingFromKey:@"SYSVAL_DEFAULT_BEEP"]]){
                int beep[]={2730,250};
                [self.linea setScanBeep:TRUE volume:100 beepData:beep length:sizeof(beep) error:&error];
            }else{
                int beep[]={2730,150,65000,20,2730,150};
                [self.linea setScanBeep:TRUE volume:100 beepData:beep length:sizeof(beep) error:&error];
            }
        }
        /* only used in method "connectScanDevice"
        if ([[NSUserDefaults standardUserDefaults] boolForKey: [self settingFromKey:@"SYSVAL_ENABLE_SCAN_BUTTON"]]){
            [self.linea setScanButtonMode: BUTTON_ENABLED];
        }else{
            [self.linea setScanButtonMode: BUTTON_DISABLED];
        }
        */
        /* feature removed since SDK version 1.60 / now the firmware layer will control this automatically 
        if ([[NSUserDefaults standardUserDefaults] boolForKey: [self settingFromKey:@"SYSVAL_SYNC_BUTTON"]]){
            [self.linea setSyncButtonMode: BUTTON_ENABLED error:&error];
        }else{
            [self.linea setSyncButtonMode: BUTTON_DISABLED error:&error];
        }
        */
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"SYSVAL_SCAN_MODE"]] isEqualToString:@"MODE_SINGLE_SCAN"]){
            [self.linea setScanMode: MODE_SINGLE_SCAN error:&error];
        } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"SYSVAL_SCAN_MODE"]] isEqualToString:@"MODE_MULTI_SCAN"]){
            [self.linea setScanMode: MODE_MULTI_SCAN error:&error];
        } else if (firmwareRevisionNumber < 257){
            [self.linea setScanMode: MODE_SINGLE_SCAN error:&error];
        } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"SYSVAL_SCAN_MODE"]] isEqualToString:@"MODE_MOTION_DETECT"]){
            [self.linea setScanMode: MODE_MOTION_DETECT error:&error];
        } else if ([[[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"SYSVAL_SCAN_MODE"]] isEqualToString:@"MODE_SINGLE_SCAN_RELEASE"]){
            [self.linea setScanMode: MODE_SINGLE_SCAN_RELEASE error:&error];
        }
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"SYSVAL_MSR_RAW"]] isEqualToString:@"TRUE"]){
            [self.linea setMSCardDataMode: MS_RAW_CARD_DATA error:&error];
        }else{
            [self.linea setMSCardDataMode: MS_PROCESSED_CARD_DATA error:&error];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_ENABLE_AKKU"]]){
            [self.linea setCharging:TRUE error:&error];
        }else{
            [self.linea setCharging:FALSE error:&error];
        }
        BOOL enablePassthrough = [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_PASSTHROUGH_SYNC"]];
        NSError *error = nil;
        if(![self.linea setPassThroughSync:enablePassthrough error:&error]) {
            NSLog(@"Could not enale pass Through Sync on the case. Reason: %@", error);
        }
        /* now in method "connectScanDevice"
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_ENABLE_ENGINE"]){
            [self.linea barcodeEnginePowerControl: YES];
        }else{
            [self.linea barcodeEnginePowerControl: NO];
        }
        */
        BOOL isLineaWithOpticon = ![linea2Dengine isEqual:nil];
        if(isLineaWithOpticon) {
            //  [self.linea enableBarcode: BAR_ALL enabled: FALSE];
            /*
            if ([self.linea isBarcodeSupported:BAR_UPC]) {
                [self.linea enableBarcode: BAR_UPC
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_UPC"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODABAR]) {
                [self.linea enableBarcode: BAR_CODABAR
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODABAR"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODE25_NI2OF5]) {
                [self.linea enableBarcode: BAR_CODE25_NI2OF5
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE25_NI2OF5"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODE25_I2OF5]) {
                [self.linea enableBarcode: BAR_CODE25_I2OF5
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE25_I2OF5"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODE39]) {
                [self.linea enableBarcode: BAR_CODE39
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE39"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODE93]) {
                [self.linea enableBarcode: BAR_CODE93
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE93"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODE128]) {
                [self.linea enableBarcode: BAR_CODE128
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE128"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CODE11]) {
                [self.linea enableBarcode: BAR_CODE11
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE11"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_CPCBINARY]) {
                [self.linea enableBarcode: BAR_CPCBINARY
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CPCBINARY"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_DUN14]) {
                [self.linea enableBarcode: BAR_DUN14
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_DUN14"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_EAN2]) {
                [self.linea enableBarcode: BAR_EAN2
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN2"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_EAN5]) {
                [self.linea enableBarcode: BAR_EAN5
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN5"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_EAN8]) {
                [self.linea enableBarcode: BAR_EAN8
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_EAN13]) {
                [self.linea enableBarcode: BAR_EAN13
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN13"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_EAN128]) {
                [self.linea enableBarcode: BAR_EAN128
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN128"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_GS1DATABAR]) {
                [self.linea enableBarcode: BAR_GS1DATABAR
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_GS1DATABAR"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_ITF14]) {
                [self.linea enableBarcode: BAR_ITF14
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_ITF14"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_LATENT_IMAGE]) {
                [self.linea enableBarcode: BAR_LATENT_IMAGE
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_LATENT_IMAGE"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_PHARMACODE]) {
                [self.linea enableBarcode: BAR_PHARMACODE
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PHARMACODE"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_PLANET]) {
                [self.linea enableBarcode: BAR_PLANET
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PLANET"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_POSTNET]) {
                [self.linea enableBarcode: BAR_POSTNET
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_POSTNET"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_INTELLIGENT_MAIL]) {
                [self.linea enableBarcode: BAR_INTELLIGENT_MAIL
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_INTELLIGENT_MAIL"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_MSI]) {
                [self.linea enableBarcode: BAR_MSI
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_MSI"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_POSTBAR]) {
                [self.linea enableBarcode: BAR_POSTBAR
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_POSTBAR"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_RM4SCC]) {
                [self.linea enableBarcode: BAR_RM4SCC
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_RM4SCC"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_TELEPEN]) {
                [self.linea enableBarcode: BAR_TELEPEN
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_TELEPEN"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_PLESSEY]) {
                [self.linea enableBarcode: BAR_PLESSEY
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PLESSEY"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_PDF417]) {
                [self.linea enableBarcode: BAR_PDF417
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PDF417"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_MICROPDF417]) {
                [self.linea enableBarcode: BAR_MICROPDF417
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_MICROPDF417"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_DATAMATRIX]) {
                [self.linea enableBarcode: BAR_DATAMATRIX
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_DATAMATRIX"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_AZTEK]) {
                [self.linea enableBarcode: BAR_AZTEK
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_AZTEK"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_QRCODE]) {
                [self.linea enableBarcode: BAR_QRCODE
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_QRCODE"] error:&error];
            }
            if ([self.linea isBarcodeSupported:BAR_MAXICODE]) {
                [self.linea enableBarcode: BAR_MAXICODE
                                                  enabled:[[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_MAXICODE"] error:&error];
            }
            */
            NSString *opticonSettings = @"B0"; // disable all codes
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_UPC"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"R1"];
                opticonSettings = [opticonSettings stringByAppendingString:@"R2"];
                opticonSettings = [opticonSettings stringByAppendingString:@"R3"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODABAR"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"B3"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE25_NI2OF5"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"R7"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE25_I2OF5"]] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_ITF14"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"R8"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE39"]] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PHARMACODE"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"B2"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE93"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"B5"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE128"]] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN128"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"B6"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE11"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BLC"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CPCBINARY"]]) {
                // Canada Post's proprietary symbology 
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_DUN14"]]) {
                // DUN-14 numbers may be represented by CODE25_I2OF5 or CODE128/EAN128 barcodes,
                // and modern implementation should use GS1-128.
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"]]) {
                // EAN8 = EAN + EAN2 + EAN5
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"]] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN13"]]) {
                // R4 = EAN
                opticonSettings = [opticonSettings stringByAppendingString:@"R4"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"]] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN2"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"R5"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"]] ||
                [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN5"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"R6"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN128"]]) {
                // EAN128 = CODE128
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_GS1DATABAR"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"JX"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_ITF14"]]) {
                // ITF14 = CODE25_I2OF5
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_LATENT_IMAGE"]]) {
                // The latent image barcode is a manner of storing bar code data at the edge of a filmstrip
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PHARMACODE"]]) {
                // PHARMACODE = CODE39
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PLANET"]]) {
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_POSTNET"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[D6A"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_INTELLIGENT_MAIL"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[D5F"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_MSI"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"B7"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_POSTBAR"]]) {
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_RM4SCC"]]) {
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_TELEPEN"]]) {
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PLESSEY"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"B1"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PDF417"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BCF"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_MICROPDF417"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BCG"];
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_DATAMATRIX"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BG0"]; // ECC000 - 140
                opticonSettings = [opticonSettings stringByAppendingString:@"[BCC"]; // ECC200
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_AZTEK"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BCH"]; // Aztec
                opticonSettings = [opticonSettings stringByAppendingString:@"[BF2"]; // Aztec runes
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_QRCODE"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BCD"]; // QR-Code
                opticonSettings = [opticonSettings stringByAppendingString:@"[D2U"]; // Micro-QR-Code
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_MAXICODE"]]) {
                opticonSettings = [opticonSettings stringByAppendingString:@"[BCE"];
            }
            // opticonSettings = @"B0A0" <- disable all codes + enable all codes excl. add-on
            //                  [dtdev barcodeOpticonSetInitString:@"JXJYDR" error:&error];
            //                  [dtdev barcodeOpticonSetInitString:@"VE" error:&error];
            //                  [dtdev barcodeOpticonSetInitString:@"B6" error:&error];
            //                  [dtdev barcodeOpticonSetInitString:@"OF" error:&error];
            //                  [dtdev barcodeOpticonSetInitString:@"V4[D01[DM2[D00" error:&error];
            //                  [dtdev barcodeOpticonSetInitString:@"[DM2[D00YQ[BCDE6" error:&error];
            // "barcodeOpticonSetInitString:" will not persist after idleTimer "sleep”
            NSLog(@"Opticon: %@ Settings: %@", linea2Dengine, opticonSettings);
            if (![self.linea barcodeOpticonSetParams:opticonSettings saveToFlash:YES error:&error]) {
                NSLog(@"barcodeOpticonSetParams:%@ %@", opticonSettings,[error localizedDescription]);
            } else if (![self.linea barcodeOpticonSetInitString:opticonSettings error:&error]) {
                NSLog(@"barcodeOpticonSetInitString:%@ %@", opticonSettings,[error localizedDescription]);
            }
        }
        /* feature removed since SDK version 1.60 / now the firmware layer will control this automatically
        if([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_ENABLE_MSR"]){
            [self.linea msStopScan:&error];
        }else{
            [self.linea msStartScan:&error];
        }
        */
        NS_HANDLER
        NSLog(@"*ERR SVR_ScanDeviceManager applySettings %@: %@", [localException name], [localException reason]);
        NS_ENDHANDLER
        [tmpPool drain];
        NSString *model  = [[[self.linea deviceModel] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        if ((!model || model.length == 0) && currentAccessory) {
            model        = [[currentAccessory.modelNumber stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        }
        self.lineaWithBluetooth = (model && model.length > 1 && !([model rangeOfString:@"BL"].location == NSNotFound));
        if (!self.lineaWithBluetooth) {
            if([self.linea getSupportedFeature:FEAT_BLUETOOTH error:nil]!=FEAT_UNSUPPORTED) {
                self.lineaWithBluetooth = YES;
            }
        }
    }];
    [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
}

- (instancetype)initWithSettingsPrefix:(NSString *) prefix {
    self = [super init];
    if (self != nil) {
        settingsPrefix = [prefix retain];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(connectScanDevice)	   name:@"connectScanDevice"    object:nil];
        [notificationCenter addObserver:self selector:@selector(disconnectScanDevice:) name:@"disconnectScanDevice" object:nil];
        [notificationCenter addObserver:self selector:@selector(startScan:)            name:@"startScan"			object:nil];
        [notificationCenter addObserver:self selector:@selector(stopScan)              name:@"stopScan"			    object:nil];
        [notificationCenter addObserver:self selector:@selector(print:)                name:@"print"                object:nil];
        [notificationCenter addObserver:self selector:@selector(eaConnected:)    name:EAAccessoryDidConnectNotification    object:nil];
        [notificationCenter addObserver:self selector:@selector(eaDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];
        scannerDaten   = [[NSString alloc] initWithString:@""];
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:1];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        barcodeEngine = BarcodeEngineNone;
        self.linea2Dengine = nil;
        linea = [[DTDevices sharedDevice] retain]; // linea = [[DTDevices alloc] init];
        [linea addDelegate:self]; // [linea setDelegate:self];
        [linea connect];
        [linea setScanButtonMode:BUTTON_DISABLED error:nil];
        [NSTimer scheduledTimerWithTimeInterval:0.618 target:self selector:@selector(eaCheckScanDevice:) userInfo:nil repeats:NO];
    }
    return self;
}


#pragma mark - Object lifecycle

-(void)startScan:(NSNotification *)aNotification {
    if (self.linea.connstate == CONN_CONNECTED) {
        // The blocks are executed serially in the main queue.
        // This is needed keep the different runtimes of startScan() and stopScan() in the right order.
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            [self.linea startScan:&error];
        });
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraUser = aNotification.object;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
                SVR_CameraBarcodeScanner *camera = [[SVR_CameraBarcodeScanner alloc] initWithSettingsPrefix:settingsPrefix];
                camera.delegate = self;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:camera];
                [camera release];
                [self.cameraUser presentModalViewController:navigationController animated:YES];
                [navigationController release];
            } else {
                ZBarReaderViewController *camera = [ZBarReaderViewController new];
                camera.readerDelegate    = self;
                camera.showsZBarControls = YES;
                camera.scanCrop          = CGRectMake(0, .35, 1, 1);
                camera.supportedOrientationsMask = ZBarOrientationMaskAll;
                [camera.scanner setSymbology: 0 config: ZBAR_CFG_ENABLE to: 0];
                NSMutableSet *enabledBarcodes = [NSMutableSet set];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_UPC"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_UPCA]];
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_UPCE]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODABAR"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_CODABAR]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE25_I2OF5"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_I25]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE39"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_CODE39]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE93"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_CODE93]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_CODE128"]] ||
                    [[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN128"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_CODE128]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN2"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_EAN2]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN5"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_EAN5]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN8"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_EAN8]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_EAN13"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_EAN13]];
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_ISBN10]];
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_ISBN13]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_GS1DATABAR"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_DATABAR]];
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_DATABAR_EXP]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_PDF417"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_PDF417]];
                }
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[self settingFromKey:@"SYSVAL_BAR_QRCODE"]]) {
                    [enabledBarcodes addObject:[NSNumber numberWithInteger:ZBAR_QRCODE]];
                }
                for(NSNumber *sym in enabledBarcodes) {
                    [camera.scanner setSymbology: sym.integerValue config: ZBAR_CFG_ENABLE to: 1];
                }
                NSInteger xDensity, yDensity;
                [camera.scanner setSymbology: 0 config: ZBAR_CFG_X_DENSITY to: (xDensity = 3)];
                [camera.scanner setSymbology: 0 config: ZBAR_CFG_Y_DENSITY to: (yDensity = 2)];
                [self.cameraUser presentModalViewController:camera animated:YES];
                [camera release];
            }
        });
    }
}

-(void)stopScan {
	if (self.linea.connstate==CONN_CONNECTED) {
        // The blocks are executed serially in the main queue.
        // This is needed keep the different runtimes of startScan() and stopScan() in the right order.
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            [self.linea stopScan:&error];
        });
	}
}

typedef void (^printLinesUsingBlock)(DTDevices *);

-(void)print:(NSNotification *)aNotification {
    if(!self.lineaWithBluetooth) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DSPF_Error messageTitle:NSLocalizedString(@"Bluetooth Drucker", @"Bluetooth Drucker")
                         messageText:NSLocalizedString(@"Die erforderliche LineaPro Bluetooth Hardware fehlt.",
                                                       @"Die erforderliche LineaPro Bluetooth Hardware fehlt.")
                            delegate:nil];
        });
		return;
	}
	NSString *printer = [[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"DTDEV_PRINTER"]];
    if(!printer || printer.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DSPF_Error messageTitle:NSLocalizedString(@"Bluetooth Drucker", @"Bluetooth Drucker")
                         messageText:NSLocalizedString(@"Aktuell ist kein Drucker konfiguriert.",
                                                       @"Aktuell ist kein Drucker konfiguriert.")
                            delegate:nil];
        });
		return;
	}
    NSError *error = nil;
	if([self.linea getSupportedFeature:FEAT_BLUETOOTH error:&error] != FEAT_UNSUPPORTED) {
        if([linea btConnectSupportedDevice:printer pin:[[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"DTDEV_PRINTER_PIN"]] error:&error]) {
            DTDevices *prn=[DTDevices sharedDevice];
            prn.delegate=self;
            ((printLinesUsingBlock )[aNotification userInfo])(prn);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DSPF_Error messageTitle:NSLocalizedString(@"Bluetooth Drucker", @"Bluetooth Drucker")
                               messageText:[NSString stringWithFormat:@"No connection! Please check\nhardware and settings for\nprinter '%@'\nwith PIN '%@'.",
                                            printer, [[NSUserDefaults standardUserDefaults] stringForKey:[self settingFromKey:@"DTDEV_PRINTER_PIN"]]]
                                  delegate:nil];
            });
        }
        [self.linea btDisconnect:printer error:&error];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DSPF_Error messageTitle:NSLocalizedString(@"Bluetooth Drucker", @"Bluetooth Drucker")
                         messageText:[error localizedDescription]
                            delegate:nil];
        });
    }
}

- (void)connectScanDevice {
    
    if (self.linea.connstate == CONN_CONNECTED &&
        [[NSUserDefaults standardUserDefaults] boolForKey: [self settingFromKey:@"SYSVAL_ENABLE_SCAN_BUTTON"]]) {
        // The blocks are executed serially in the main queue.
        // This is needed keep sequence of ENABLED and DISABLED in the right order.
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
//          [theSingletonInstance.linea barcodeEnginePowerControl:YES error:&error]; // 2D engine ! Avoid the wake up time.
//          feature removed since SDK version 1.60 / now the firmware layer will control this automatically
            [self.linea setScanButtonMode:BUTTON_ENABLED error:&error];
        });
	}
}

- (void)disconnectScanDevice:(NSNotification *)aNotification {
    
    if (self.linea.connstate == CONN_CONNECTED) {
        // The blocks are executed serially in the main queue.
        // This is needed keep sequence of ENABLED and DISABLED in the right order.
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            [self.linea setScanButtonMode:BUTTON_DISABLED error:&error];
//          [theSingletonInstance.linea barcodeEnginePowerControl:NO error:&error]; // 2D engine ! Allow battery-saving mode.
//          feature removed since SDK version 1.60 / now the firmware layer will control this automatically
        });
	}
    if (self.cameraCaptureSession) {
        self.cameraUser = aNotification.object;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.cameraCaptureSession stopRunning];
            [self.cameraCapturePreviewLayer removeFromSuperlayer];
            [self.cameraUser.view setNeedsDisplay];
            [cameraCapturePreviewLayer release]; cameraCapturePreviewLayer = nil;
            [cameraCaptureSession release]; cameraCaptureSession = nil;
        });
    }
}


#pragma mark - EAAccessoryNotifications

- (void)eaCheckScanDevice:(NSTimer *)aTimer {
    BOOL lineaOK = NO;
    for (EAAccessory *tmpAccessory in [[EAAccessoryManager sharedAccessoryManager] connectedAccessories]) {
        if (tmpAccessory.name.length > 4 && tmpAccessory.manufacturer.length > 5 &&
            [[[tmpAccessory.name substringToIndex:5] uppercaseString] isEqualToString:@"LINEA"] &&
            [[[tmpAccessory.manufacturer substringToIndex:6] uppercaseString] isEqualToString:@"DATECS"]) {
            lineaOK = YES;
            self.currentAccessory = tmpAccessory;
            break;
        }
    }
    if (!lineaOK) {
        self.currentAccessory = nil;
        justOnce = NO;
    }
}

- (void)eaConnected:(NSNotification *)notification {
    EAAccessory *accessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    if (accessory.name.length > 4 && accessory.manufacturer.length > 5 &&
        [[[accessory.name substringToIndex:5] uppercaseString] isEqualToString:@"LINEA"] &&
        [[[accessory.manufacturer substringToIndex:6] uppercaseString] isEqualToString:@"DATECS"]) {
        self.currentAccessory = accessory;
    }
}

- (void)eaDisconnected:(NSNotification *)notification {
    EAAccessory *accessory = [[notification userInfo] objectForKey:EAAccessoryKey];
    if (accessory.name.length > 4 && accessory.manufacturer.length > 5 &&
        [[[accessory.name substringToIndex:5] uppercaseString] isEqualToString:@"LINEA"] &&
        [[[accessory.manufacturer substringToIndex:6] uppercaseString] isEqualToString:@"DATECS"]) {
        // do the stuff here because the linea delegate will keep pending in state CONN_CONNECTING
        // ... so wait a moment because iOS sends disconnect "old" session and connect "new" session
        [NSTimer scheduledTimerWithTimeInterval:0.618 target:self selector:@selector(eaCheckScanDevice:) userInfo:nil repeats:NO];
    }
}


#pragma mark - self.linea delegate

-(void)connectionState:(int)state {
	switch (state) {
		case CONN_DISCONNECTED:
            self.linea2Dengine = nil;
            barcodeEngine = BarcodeEngineNone;
            break;
		case CONN_CONNECTING:
            self.linea2Dengine = nil;
            barcodeEngine = BarcodeEngineNone;
			break;
		case CONN_CONNECTED:
            [self.linea btDisconnect:nil error:nil];
            barcodeEngine = [self.linea getSupportedFeature:FEAT_BARCODE error:nil];
            if(barcodeEngine == BARCODE_OPTICON){
               	self.linea2Dengine = [self.linea barcodeOpticonGetIdent:nil];
            }
            [self performSelectorOnMainThread:@selector(applySettings) withObject:nil waitUntilDone:NO];
			break;
	}
}

-(void)barcodeData:(NSString *)barcode type:(int)type { 
//  the type from the input parameter does not match the type from [self.linea enableBarcode:TYPE enabled:YES];
//  [self.linea barcodeType2Text:type] == @"Unknown"
//  BUT IF A TYPE IS DISABLED, THIS METHOD IS NOT CALLED
//  So it is ok to disable this if until this self.linea bug is fixed
//	if ([self.linea isBarcodeEnabled:type]) { 
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"barcodeData" object:self
                                                                                        userInfo:
        [NSDictionary dictionaryWithObject:barcode forKey:@"barcodeData"]] 
                                               postingStyle:NSPostNow];
//	}
}

-(void)barcodeData:(NSString *)barcode isotype:(NSString *)isotype { 
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"barcodeData" object:self
                                                                                        userInfo:
        [NSDictionary dictionaryWithObject:barcode forKey:@"barcodeData"]] 
                                               postingStyle:NSPostNow];    
}

-(void)magneticCardData:(NSString *)track1 track2:(NSString *)track2 track3:(NSString *)track3 {
    NSError *error = nil;
	int sound[]={2730,150,0,30,2730,150};
	[self.linea playSound:100 beepData:sound length:sizeof(sound) error:&error];
	self.scannerDaten = [NSString stringWithString:track2];
}

-(NSString *)toHexString:(void *)data length:(int)length {
	const char HEX[]="0123456789ABCDEF";
	char s[2000];
	
	int len=0;
	for(int i=0;i<length;i++)
	{
		s[len++]=HEX[((uint8_t *)data)[i]>>4];
		s[len++]=HEX[((uint8_t *)data)[i]&0x0f];
		s[len++]=' ';
	}
	s[len]=0;
	return [NSString stringWithCString:s encoding:NSASCIIStringEncoding];
}


-(void)magneticCardRawData:(NSData *)tracks {
    NSError *error = nil;
	int sound[]={2700,150,5400,150};
	[self.linea playSound:100 beepData:sound length:sizeof(sound) error:&error];
	self.scannerDaten = [self toHexString:(void *)[tracks bytes] length:[tracks length]];
}


-(uint16_t)crc16:(uint8_t *)data  length:(int)length crc16:(uint16_t)crc16 {
	if(length==0) return 0;
	while(length--)
	{
		crc16=(uint8_t)(crc16>>8)|(crc16<<8);
		crc16^=*data++;
		crc16^=(uint8_t)(crc16&0xff)>>4;
		crc16^=(crc16<<8)<<4;
		crc16^=((crc16&0xff)<<4)<<1;
	}
	return crc16;
}


-(void)magneticCardEncryptedData:(int)encryption data:(NSData *)data {
	//try to decrypt the data
	NSData *decrypted=[data AESDecryptWithKey:[@"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" dataUsingEncoding:NSUTF8StringEncoding]];
	//basic check if the decrypted data is valid
	if(decrypted)
	{
		uint8_t *bytes=(uint8_t *)[decrypted bytes];
		for(int i=0;i<([decrypted length]-2);i++)
		{
			if(i>4 && !bytes[i])
			{
				uint16_t crc16=[self crc16:bytes length:(i+1) crc16:0];
				uint16_t crc16Data=(bytes[i+1]<<8)|bytes[i+2];
				
				if(crc16==crc16Data)
				{
					//crc matches, extract the tracks then
					NSString *track1=nil,*track2=nil,*track3=nil;
					int t1=-1,t2=-1,t3=-1,tend;
					//find the tracks offset
					int dataLen=i;
					for(int j=4;j<dataLen;j++)
					{
						if(bytes[j]==0xF1)
							t1=j;
						if(bytes[j]==0xF2)
							t2=j;
						if(bytes[j]==0xF3)
							t3=j;
					}
					if(t1!=-1)
					{
						if(t2!=-1)
							tend=t2;
						else
							if(t3!=-1)
								tend=t3;
							else
								tend=dataLen;
						track1=[[[NSString alloc] initWithBytes:&bytes[t1+1] length:(tend-t1-1) encoding:NSASCIIStringEncoding] autorelease];
					}
					if(t2!=-1)
					{
						if(t3!=-1)
							tend=t3;
						else
							tend=dataLen;
						track2=[[[NSString alloc] initWithBytes:&bytes[t2+1] length:(tend-t2-1) encoding:NSASCIIStringEncoding] autorelease];
					}
					if(t3!=-1)
					{
						tend=dataLen;
						track3=[[[NSString alloc] initWithBytes:&bytes[t3+1] length:(tend-t3-1) encoding:NSASCIIStringEncoding] autorelease];
					}
					
					//pass to the non-encrypted function to display tracks
					[self magneticCardData:track1 track2:track2 track3:track3];
					return;
				}
			}
		}
	}
	self.scannerDaten = @"DECRYPTION_ERROR";
}


#pragma mark - linea delegate

- (void) imagePickerController:(UIImagePickerController *)cameraScanner didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSAutoreleasePool *tmpPool = [[NSAutoreleasePool alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cameraUser dismissModalViewControllerAnimated:YES];
    });
    for(ZBarSymbol *symbol in [info objectForKey:ZBarReaderControllerResults]) {
        if (symbol.data) {
            NSDictionary *userInfo = nil;
            if ([symbol.data rangeOfString:@" "].location == NSNotFound && [symbol.data longLongValue] != 0) {
                userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%lld", [symbol.data longLongValue]] forKey:@"barcodeData"];
            } else { 
                NSString *barcodeData = [NSString stringWithFormat:@"%@", symbol.data];
                if (symbol.type == ZBAR_CODE39) { 
                    barcodeData = [barcodeData stringByReplacingOccurrencesOfString:@"/J" withString:@""];                    
                }
                userInfo = [NSDictionary dictionaryWithObject:barcodeData forKey:@"barcodeData"];
            }
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"barcodeData" object:self userInfo:userInfo] postingStyle:NSPostNow];
            // Just grab the first barcode.
            break;
        }
    }
    [tmpPool drain];
}

- (void) barcodeController:(UIViewController *)barcodeController didFinishWithBarcode:(NSString *) barcode {
    [barcodeController dismissViewControllerAnimated:YES completion:^{
        if (barcode) {
            NSDictionary *userInfoToPost = [NSDictionary dictionaryWithObject:barcode forKey:@"barcodeData"];
            [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"barcodeData" object:nil userInfo:userInfoToPost] postingStyle:NSPostWhenIdle];
        }
    }];
}

-(void)firmwareUpdateThread:(NSArray *)firmwareUpdateThreadInput {
    @autoreleasepool {
        DSPF_Activity *showActivity = [firmwareUpdateThreadInput objectAtIndex:0];
        if (firmwareUpdateThreadInput.count < 2) {
            [showActivity closeActivityInfo];
            return;
        }
        [showActivity retain];
        //
        // Start
        [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
        BOOL idleTimerDisabled_Old=[UIApplication sharedApplication].idleTimerDisabled;
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
        NSError *error = nil;
        NSString *firmwareFileNameToUpdate = [firmwareUpdateThreadInput objectAtIndex:1];
        NSLog(@"Updating firmware: %@", firmwareFileNameToUpdate);
        NSLog(@"Updating firmware: %@", [[NSURL fileURLWithPath:firmwareFileNameToUpdate] lastPathComponent]);
        if ([self.linea updateFirmwareData:[NSData dataWithContentsOfFile:firmwareFileNameToUpdate] error:&error]) {
            NSLog(@"Firmware updated");
        }
        /*
        // sample default authenticationKey = @"11111111111111111111111111111111"
        NSLog(@"Updating firmware - cryptoSetKey ");
        NSLog(@"%i", [@"11111111111111111111111111111111" length]);
        if([theSingletonInstance.linea cryptoSetKey:KEY_AUTHENTICATION
                                                key:[@"11111111111111111111111111111111" dataUsingEncoding:NSASCIIStringEncoding]
                                             oldKey:nil
                                         keyVersion:0x00000000
                                           keyFlags:0 error:&error]) {
            NSLog(@"Updating firmware - cryptoUseKey ");
            if ([theSingletonInstance.linea cryptoAuthenticateHost:[@"11111111111111111111111111111111" dataUsingEncoding:NSASCIIStringEncoding] error:&error]) {
                NSString *firmwareFileName = [firmwareUpdateThreadInput objectAtIndex:1];
                NSLog(@"Updating firmware: %@", firmwareFileName);
                NSLog(@"Updating firmware: %@", [[NSURL fileURLWithPath:firmwareFileName] lastPathComponent]);
                if ([theSingletonInstance.linea updateFirmwareData:[NSData dataWithContentsOfFile:firmwareFileName] error:&error]) {
                    NSLog(@"Firmware updated"); 
                }
                NSLog(@"Updating firmware - cryptoRemoveKey ");
                NSError *err = nil;
                if ([theSingletonInstance.linea cryptoSetKey:KEY_AUTHENTICATION
                                                         key:[NSData dataWithBytes:KEY_AES256_EMPTY length:sizeof(KEY_AES256_EMPTY)]
                                                      oldKey:[@"11111111111111111111111111111111" dataUsingEncoding:NSASCIIStringEncoding]
                                                  keyVersion:0x00000000
                                                    keyFlags:0 error:&err]) {
                    NSLog(@"AuthenticationKey removed");
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [DSPF_Error messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                     messageText:[NSString stringWithFormat:@"cryptoRemoveKey: %@",[err localizedDescription]]
                                        delegate:nil];
                    });
                }
            }
        }
        */
        if (linea2Dengine && linea2Dengine.length > 6 &&
            [linea2Dengine rangeOfString:@"FL49J0"].location != NSNotFound) {
            NSLog(@"Updating opticon barcode engine: %@", linea2Dengine);
            NS_DURING
            NSError *err = nil;
            [self.linea barcodeOpticonUpdateFirmware:
             [NSData dataWithContentsOfFile:[[SVR_ScanDeviceManager firmwareDirectoryPath] stringByAppendingPathComponent:@"Opticon_BOOT.bin"]]
                                          bootLoader:YES error:nil];
            NSLog(@"Opticon_BOOT.bin %@", err);
            [self.linea barcodeOpticonUpdateFirmware:
             [NSData dataWithContentsOfFile:[[SVR_ScanDeviceManager firmwareDirectoryPath] stringByAppendingPathComponent:@"Opticon_FL49J09.bin"]]
                                          bootLoader:NO error:nil];
            NSLog(@"Opticon_FL49J09.bin %@", err);
            NS_HANDLER
            dispatch_async(dispatch_get_main_queue(), ^{
                [DSPF_Error messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                             messageText:[NSString stringWithFormat:@"Opticon_FL49J09: %@ - %@",[localException name],[localException reason]]
                                delegate:nil];
            });
            NS_ENDHANDLER
        }
        [[UIApplication sharedApplication] setIdleTimerDisabled: idleTimerDisabled_Old];
        [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
        // End
        //
        dispatch_async(dispatch_get_main_queue(), ^{
            [showActivity closeActivityInfo];
            [showActivity release];
        });
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [DSPF_Error messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                             messageText:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                delegate:nil];
            });
        }
    }
}

-(void)firmwareUpdateProgress:(int)phase percent:(int)percent {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (phase) {
            case UPDATE_INIT:
                NSLog(@"Initializing update...");
                break;
            case UPDATE_ERASE:
                NSLog(@"Erasing flash...");
                break;
            case UPDATE_WRITE:
                 NSLog(@"Writing firmware...");
                break;
            case UPDATE_COMPLETING:
                NSLog(@"Completing operation...");
                break;
            case UPDATE_FINISH:
                 NSLog(@"Complete!");
                break;
        }
    });
}

- (void) dspf_Warning:(DSPF_Warning *)sender didConfirmMessageTitle:(NSString *)messageTitle item:(id )item withButtonTitle:(NSString *)buttonTitle buttonIndex:(NSInteger) buttonIndex {
	if ([[sender alertView] cancelButtonIndex] != buttonIndex) {
        if ([item isEqual:@"updateFirmware"]) {
            [NSThread detachNewThreadSelector:@selector(firmwareUpdateThread:) toTarget:self
                                   withObject:[NSArray arrayWithObjects:
                                               [DSPF_Activity messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                                               messageText:NSLocalizedString(@"COMMON_PleaseWait_M", nil)
                                                                  delegate:self],
                                               self.firmwareFileName,
                                               nil]];
//          [DPHUtilities waitForAlertToShow:0.236f];
/*
            DSPF_Activity  *showActivity   = [[DSPF_Activity messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                                              messageText:NSLocalizedString(@"COMMON_PleaseWait_M", nil)
                                                                 delegate:self] retain];
            [DPHUtilities waitForAlertToShow:0.236f];
            NSLog(@"Updating firmware: %@", [[NSURL fileURLWithPath:[self getFirmwareFileName]] lastPathComponent]);
            // sample default authenticationKey = @"11111111111111111111111111111111"
            [self.linea cryptoAuthenticateHost:[@"11111111111111111111111111111111" dataUsingEncoding:NSASCIIStringEncoding] error:nil];
            NSError *error = nil;
            [self.linea updateFirmwareData:[NSData dataWithContentsOfFile:[self getFirmwareFileName]] error:&error];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DSPF_Error messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                 messageText:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                    delegate:nil];
                });
            }
            if (linea2Dengine && linea2Dengine.length > 6 &&
                [linea2Dengine rangeOfString:@"FL49J0"].location != NSNotFound) {
                NSLog(@"Updating opticon barcode engine: %@", linea2Dengine);
                NS_DURING
                NSError *err = nil;
                [self.linea barcodeOpticonUpdateFirmware:
                 [NSData dataWithContentsOfFile:[[SVR_ScanDeviceManager firmwareDirectoryPath] stringByAppendingPathComponent:@"Opticon_BOOT.bin"]]
                                                              bootLoader:YES error:nil];
                NSLog(@"Opticon_BOOT.bin %@", err);
                [self.linea barcodeOpticonUpdateFirmware:
                 [NSData dataWithContentsOfFile:[[SVR_ScanDeviceManager firmwareDirectoryPath] stringByAppendingPathComponent:@"Opticon_FL49J09.bin"]]
                                              bootLoader:NO error:nil];
                NSLog(@"Opticon_FL49J09.bin %@", err);
                NS_HANDLER
                dispatch_async(dispatch_get_main_queue(), ^{
                    [DSPF_Error messageTitle:NSLocalizedString(@"COMMON_ScannerUpdate_T", nil)
                                 messageText:[NSString stringWithFormat:@"%@ - %@",[localException name],[localException reason]]
                                    delegate:nil];
                });
                NS_ENDHANDLER
            }
            [showActivity closeActivityInfo];
            [showActivity release];
*/
        }
    }
}

- (void)dealloc {
    [settingsPrefix release];
    [operationQueue release]; operationQueue = nil;
    [[EAAccessoryManager sharedAccessoryManager] unregisterForLocalNotifications];
    [linea setScanButtonMode:BUTTON_DISABLED error:nil];
//  [linea barcodeEnginePowerControl:NO error:nil];  feature removed since SDK version 1.60 / now the firmware layer will control this automatically
    [linea disconnect];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self	name:EAAccessoryDidConnectNotification    object:nil];
    [notificationCenter removeObserver:self	name:EAAccessoryDidDisconnectNotification object:nil];
    [notificationCenter removeObserver:self	name:@"connectScanDevice"    object:nil];
    [notificationCenter removeObserver:self name:@"disconnectScanDevice" object:nil];
    [notificationCenter removeObserver:self name:@"print"                object:nil];
    [notificationCenter removeObserver:self name:@"startScan"			 object:nil];
    [notificationCenter removeObserver:self name:@"stopScan"			 object:nil];
    [linea         removeDelegate:self];
    [linea                     release];
    [firmwareFileName          release];
    [scannerDaten              release];
    [linea2Dengine             release];
    [cameraCapturePreviewLayer release];
    [cameraCaptureSession      release];
    [super dealloc];
}

@end
