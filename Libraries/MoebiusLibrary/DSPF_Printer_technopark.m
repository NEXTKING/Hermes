//
//  DSPF_Printer_technopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 11.12.15.
//
//

#import "DSPF_Printer_technopark.h"
#import "MoebiusPrinterManager.h"
#import "ItemDescription.h"
#import "User.h"
#import "DSPF_Activity.h"

typedef enum PrintingTask
{
    PTNone = 0,
    PTReceipt = 1,
    PTXReport = 2,
    PTZReport = 3,
    PTOpenShift = 4,
    PTRealReceipt = 5
    
}PrintingTask;

@interface DSPF_Printer_technopark () <MoebiusPrinterManagerProtocol, DTDeviceDelegate, UIAlertViewDelegate>
{
    MoebiusPrinterManager *printerManager;
    NSInteger lastErrorCode;
    DTDevices *dtDev;
    BOOL bluetoothStopFlag;
    PrintingTask currentTask;
    DSPF_Activity *currentActivity;
}

@property (nonatomic, copy) NSString* printerId;
@property (nonatomic, copy) NSString* discoveredPrinter;
@property (nonatomic, retain) Transport_Group* currentTransportGroup;
@property (nonatomic, copy) NSString* currentSampleAmount;

@end

@implementation DSPF_Printer_technopark

- (id) init
{
    self = [super init];
    if(self)
    {
        printerManager = [MoebiusPrinterManager new];
        [dtDev addDelegate:self];
        lastErrorCode = 0;
        dtDev = [DTDevices sharedDevice];
        bluetoothStopFlag = NO;
        currentTask = PTNone;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showAlert:(NSString*)title message: (NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark - Interface Methods

- (void) tryConnectAndPrint
{
    currentActivity = [DSPF_Activity messageTitle:@"Пожалуйста, подождите"
                                                                     messageText:@"Подключение к принтеру..."
                                                               cancelButtonTitle:@"Отмена"
                                                                        delegate:self];
    currentActivity.alertView.delegate = self;
    
    if (dtDev.btConnectedDevices.count > 0)
        [self doPrinting];
    else if (![NSUserDefaults currentPrinterID])
        [self bindPrinterWithId:[NSUserDefaults currentPrinterID]];
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            while (dtDev.btConnectedDevices.count < 1 && !bluetoothStopFlag) {
                [dtDev btConnect:[NSUserDefaults currentPrinterAddress] pin:@"0000" error:nil];
            }
            
            if (bluetoothStopFlag)
                return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doPrinting];
            });
        });
    }
}

- (void) printTransportGroup:(Transport_Group *)transportGroup
{
    bluetoothStopFlag = NO;
    currentTask = PTRealReceipt;
    self.currentTransportGroup = transportGroup;
    [self tryConnectAndPrint];
}

- (void) printSample:(NSString *)amount
{
    bluetoothStopFlag = NO;
    self.currentSampleAmount = amount;
    currentTask = PTReceipt;
    [self tryConnectAndPrint];
    
}

- (void) xReport
{
    bluetoothStopFlag = NO;
    currentTask = PTXReport;
    [self tryConnectAndPrint];
}

- (void) zReport
{
    bluetoothStopFlag = NO;
    currentTask = PTZReport;
    [self tryConnectAndPrint];
}

- (void) openShift
{
    bluetoothStopFlag = NO;
    currentTask = PTOpenShift;
    [self tryConnectAndPrint];
}

- (void) bindPrinterWithId:(NSString *)printerId
{
    //[self showAlert:@"Discover started" message:printerId];
    
    [dtDev addDelegate:self];
    
    bluetoothStopFlag = NO;
    self.discoveredPrinter = nil;
    
    self.printerId = printerId;
    
    NSError* error = nil;
    [dtDev btDiscoverDevicesInBackground:5 maxTime:5 codTypes:0 error:&error];
    if (error)
    {
        if (_delegate)
            [_delegate printerController:self didFailedBindingWithError:error];
    }
    
}

- (void) stopActivities
{
    bluetoothStopFlag = YES;
}

#pragma mark - DtDevice Delegate

- (void) bluetoothDeviceDiscovered:(NSString *)address name:(NSString *)name
{
    BOOL hasZebraPrefix     = NO;
    BOOL hasSerialPrefix    = NO;
    NSRange zebraRange  = [name rangeOfString:@"ZEBRA"];
    NSRange serialRange = [name rangeOfString:_printerId];
    
    hasZebraPrefix  = (zebraRange.location != NSNotFound);
    hasSerialPrefix = (serialRange.location != NSNotFound);
    
   // [self showAlert:@"Device discovered" message:name];
    
    if (hasZebraPrefix && hasSerialPrefix)
    {
        NSError* error = nil;
        self.discoveredPrinter = name;
        [dtDev btConnect:address pin:@"0000" error:&error];
        if (error)
        {
            if (currentTask == PTNone)
                [_delegate printerController:self didFailedBindingWithError:error];
            else
                [self bindPrinterWithId:[NSUserDefaults currentPrinterID]];
        }
    }
}

- (void) bluetoothDeviceConnected:(NSString *)address
{
    if (currentTask != PTNone)
    {
        [self doPrinting];
        return;
    }
    
    if (_delegate && currentTask == PTNone)
    {
        NSString *deviceName = [dtDev btGetDeviceName:address error:nil];
        [NSUserDefaults setCurrentPrinterID:deviceName];
        [NSUserDefaults setCurrentPrinterAddress:address];
        [_delegate printerController:self DidFinishBindingPrinter:deviceName];
    }
}

- (void) bluetoothDeviceDisconnected:(NSString *)address
{
    //[self showAlert:@"Discover disconnected" message:[NSString stringWithFormat:@"%@", address]];
}

- (void) bluetoothDiscoverComplete:(BOOL)success
{
    //[self showAlert:@"Discover complete" message:[NSString stringWithFormat:@"%d", success]];
    
    if (!success)
    {
        if (_delegate && currentTask == PTNone)
            [_delegate printerController:self didFailedBindingWithError:nil];
        if (currentTask != PTNone)
            [self bindPrinterWithId:[NSUserDefaults currentPrinterID]];
    }
    
    if (!self.discoveredPrinter && !bluetoothStopFlag)
    {
        [self bindPrinterWithId:_printerId];
    }
}

#pragma mark - Printer Manager Delegate

- (void) moebiusPrinterDidFinishPrinting:(MoebiusPrinterManager *)printer
{
    currentTask = PTNone;
}

- (void) doPrinting
{
    currentActivity.alertView.message = @"Выполняется печать...";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger returnCode = 0;
        
        if (!printerManager)
            printerManager = [MoebiusPrinterManager new];
        
        switch (currentTask) {
            case PTXReport:
                returnCode = [printerManager xReport];
                break;
            case PTZReport:
                returnCode = [printerManager zReport];
                break;
            case PTReceipt:
                if (![printerManager isShiftOpen])
                {
                    User* currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
                    NSString *lastName = currentUser.lastName ? currentUser.lastName:@"Технопарк";
                    returnCode = [printerManager openShift:lastName];
                }
                returnCode = [printerManager sampleReceipt:[_currentSampleAmount doubleValue]];
                break;
            case PTOpenShift:
            {
                User* currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
                NSString *lastName = currentUser.lastName ? currentUser.lastName:@"Технопарк";
                returnCode = [printerManager openShift:lastName];
                break;
            }
            case PTRealReceipt:
            {
                if (![printerManager isShiftOpen])
                {
                    User* currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
                    NSString *lastName = currentUser.lastName ? currentUser.lastName:@"Технопарк";
                    returnCode = [printerManager openShift:lastName];
                }
                
                double orderAmount = _currentTransportGroup.paymentOnDelivery.doubleValue;
                NSArray *printerArray = [self generatePrinterArray];
                BOOL shouldPrintVariableFooter = [self shouldPrintVariableFooter:printerArray.count];
                
                returnCode = [printerManager realReceipt:[self generatePrinterArray] footer:_currentTransportGroup.deliveryInfoText orderAmount:orderAmount giftAmount:[self calculateGiftValue] shouldPrintVarFooter:shouldPrintVariableFooter];
            }
                break;
                
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (_delegate)
            {
                if (returnCode)
                    [_delegate printerController:self didFailedPrintingWithError:nil];
                else
                    [_delegate printerControllerDidPrintReceipt:self];
            }
            
            currentTask = PTNone;
            [dtDev btDisconnect:[NSUserDefaults currentPrinterAddress] error:nil];
            
            [currentActivity closeActivityInfo];
            [currentActivity release];
            currentActivity = nil;
            //[printerManager release];
            //printerManager = nil;
        });
        
    });
}

- (NSArray<PrintItem*>*) generatePrinterArray
{
    
    NSArray *transportArray = [Transport transportsWithPredicate:
                                [NSPredicate predicateWithFormat:
                                 @"transport_group_id.transport_group_id = %lld && trace_type_id.code = %@ && (requestType = 1 || requestType = 2 || requestType = 3) && itemQTY > 0",
                                 [_currentTransportGroup.transport_group_id longLongValue], TraceTypeStringUnload] sortDescriptors:nil inCtx:_currentTransportGroup.managedObjectContext];
    
    
    NSMutableArray *array = [NSMutableArray new];
    
    for (Transport *transport in transportArray) {
        
        ItemDescription *descriptionItem = transport.item_id.itemDescription.allObjects.firstObject;
        NSString *name = descriptionItem ? descriptionItem.text:@"Неизвестный товар";
        
        PrintItem *printItem = [[PrintItem new] autorelease];
        printItem.name = name;
        printItem.price = transport.item_id.paymentOnDelivery.doubleValue*transport.itemQTY.intValue;
        printItem.quantiny = transport.itemQTY.intValue;
        printItem.itemCode = transport.item_id.temperatureZone?transport.item_id.temperatureZone:@"";
        printItem.discount = transport.itemQTYUnit.doubleValue;
        
        [array addObject:printItem];
    }
    
    return array;
}

- (double) calculateGiftValue
{
    double finalValue = 0;
    
    for (Transport *transport in _currentTransportGroup.transport_id.allObjects) {
        if (transport.requestType.intValue == 3 && transport.itemQTY.intValue < 0 && [transport.trace_type_id.code isEqualToString:TraceTypeStringUnload])
            finalValue += transport.item_id.paymentOnDelivery.doubleValue;
        
       /* dispatch_async(dispatch_get_main_queue(), ^{
            NSString *stringToShow = [NSString stringWithFormat:@"groupAmount = %f", _currentTransportGroup.paymentOnDelivery.doubleValue];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание" message:stringToShow delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }); */
    }
    
    return finalValue;
}

- (BOOL) shouldPrintVariableFooter: (NSInteger) unloadedItems
{
    NSArray *transportArray = [Transport transportsWithPredicate:
                               [NSPredicate predicateWithFormat:
                                @"transport_group_id.transport_group_id = %lld && itemQTY > 0",
                                [_currentTransportGroup.transport_group_id longLongValue]] sortDescriptors:nil inCtx:_currentTransportGroup.managedObjectContext];
    
    if (transportArray.count == unloadedItems)
        return YES;
    
    return NO;
}

- (void) dealloc
{
    [_printerId release];
    [printerManager release];
    [_discoveredPrinter release];
    [_currentTransportGroup release];
    [_currentSampleAmount release];
    [super dealloc];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self stopActivities];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
