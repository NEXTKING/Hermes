//
//  TerminalViewController.m
//  Technopark
//
//  Created by Denis Kurochkin on 08/10/15.
//  Copyright © 2015 Denis Kurochkin. All rights reserved.
//

#import "DSPF_Terminal_technopark.h"
#import "DTDevices.h"
#import "DSPF_Printer_technopark.h"
#import "DSPF_Payment_technopark.h"

#define ACTIVE_COLOR [UIColor colorWithRed:39 green:129 blue:55 alpha:1.0]
#define INACTIVE_COLOR [UIColor redColor]

@interface DSPF_Terminal_technopark () <UITextFieldDelegate, DTDeviceDelegate, DSPF_Printer_Protocol>
{
    DSPF_Printer_technopark *printerCont;
}

@property (nonatomic, retain) NSArray *completedTransports;

@end

@implementation DSPF_Terminal_technopark

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"Касса";
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    DTDevices *dtDev = [DTDevices sharedDevice];
    [dtDev addDelegate:self];
    [dtDev connect];
    
    NSArray *connectedDevices = [[DTDevices sharedDevice] getConnectedDevicesInfo:nil];
    
    if (connectedDevices.count>0)
    {
        _statusLabel.text = @"Подключен";
        _statusLabel.textColor = ACTIVE_COLOR;
        _printerBindButton.enabled = YES;
    }
    else
    {
        _printerBindButton.enabled = NO;
        _statusLabel.text = @"Отключен";
        _statusLabel.textColor = INACTIVE_COLOR;
    }
    // Do any additional setup after loading the view from its nib.
    
    NSString *currentPrinterID = [NSUserDefaults currentPrinterID];
    [self updateUIForPrinterID:currentPrinterID];
    
    
    printerCont = [DSPF_Printer_technopark new];
    [self addChildViewController:printerCont];
    printerCont.delegate = self;
    [printerCont release];
    
    [self switchUIToEnabled:YES];
}



- (void) connectionState:(int)state
{
    if (state == CONN_CONNECTED)
    {
        _statusLabel.text = @"Подключен";
        _statusLabel.textColor = ACTIVE_COLOR;
        _printerBindButton.enabled = YES;
    }
    else
    {
        _statusLabel.text = @"Отключен";
        _statusLabel.textColor = INACTIVE_COLOR;
        _printerBindButton.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Printer Management

- (void) updateUIForPrinterID: (NSString*) printerID
{
    if (!printerID)
    {
        _printerBindLabel.text = @"В данный момент ни один принтер не привязан";
        [_printerBindButton setTitle:@"Привязать" forState:UIControlStateNormal];
    }
    else
    {
        _printerBindLabel.text = [NSString stringWithFormat:@"В данный момент привязан принтер %@", printerID];
        [_printerBindButton setTitle:@"Привязать другой" forState:UIControlStateNormal];
    }
}

- (IBAction)bindPrinterAction:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Привязка принтера" message:@"Введине серийный номер принтера:" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Привязать", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (IBAction)printSampleReceipt:(id)sender
{
    DSPF_Payment_technopark* paymentVC = [[DSPF_Payment_technopark alloc] initWithParameters:@{@"amount":[NSNumber numberWithDouble:[_amountTextField.text doubleValue]]}];
    //paymentVC.tableDataSource = _tableDataSource;
    [self.navigationController pushViewController:paymentVC animated:YES];
    [paymentVC release];
}


- (IBAction)openShiftAction:(id)sender
{
    [_printerActivityInicator startAnimating];
    _printerBindLabel.text = @"Открываем смену...";
    
    [printerCont openShift];
    [self switchUIToEnabled:NO];
}

- (IBAction)xReportAction:(id)sender
{
    [_printerActivityInicator startAnimating];
    _printerBindLabel.text = @"Печатаем промежуточный отчет...";
    
    [printerCont xReport];
    [self switchUIToEnabled:NO];
}

- (IBAction)zReportAction:(id)sender
{
    [_printerActivityInicator startAnimating];
    _printerBindLabel.text = @"Закрываем смену...";
    
    [printerCont zReport];
    [self switchUIToEnabled:NO];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
        return;
    
    UITextField *printerTextField = [alertView textFieldAtIndex:0];
    [printerCont bindPrinterWithId:printerTextField.text];
    [_printerActivityInicator startAnimating];
    _printerBindLabel.text = [NSString stringWithFormat:@"Привязка принтера %@", printerTextField.text];
    [self switchUIToEnabled:YES];
    
}

- (void) switchUIToEnabled:(BOOL) enabled
{
    
    if (enabled)
    {
        NSString* printerName = [NSUserDefaults currentPrinterID];
        NSString *buttonTitle = printerName?@"Привязать другой":@"Привязать";
        
        [_printerBindButton setTitle:buttonTitle forState:UIControlStateNormal];
        [_printerBindButton removeTarget:self action:@selector(cancelPrinterActions) forControlEvents:UIControlEventTouchUpInside];
        [_printerBindButton addTarget:self action:@selector(bindPrinterAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        
        [_printerBindButton setTitle:@"Отмена" forState:UIControlStateNormal];
        [_printerBindButton removeTarget:self action:@selector(bindPrinterAction:) forControlEvents:UIControlEventTouchUpInside];
        [_printerBindButton addTarget:self action:@selector(cancelPrinterActions) forControlEvents:UIControlEventTouchUpInside];
    }
    
    BOOL shouldEnable = enabled && [NSUserDefaults currentPrinterID];
    _printSampleButton.enabled = shouldEnable;
    _xReportButton.enabled = shouldEnable;
    _zReportButton.enabled = shouldEnable;
    _openShiftButton.enabled = shouldEnable;
    
}

- (void) cancelPrinterActions
{
    [printerCont stopActivities];
    [self switchUIToEnabled:YES];
    [_printerActivityInicator stopAnimating];
    
    if ([NSUserDefaults currentPrinterID])
        _printerBindLabel.text = [NSString stringWithFormat:@"В данный момент привязан принтер %@", [NSUserDefaults currentPrinterID]];
    else
        _printerBindLabel.text = @"В данный момент ни один принтер не привязан";
        
    
}

#pragma mark - Printer Protocol

- (void) printerController:(DSPF_Printer_technopark *)printerCont didFailedBindingWithError:(NSError *)error
{
    [_printerActivityInicator stopAnimating];
    _printerBindLabel.text = @"Ошибка привязки принтера";
    [self switchUIToEnabled:YES];
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont DidFinishBindingPrinter:(NSString *)printerID
{
    [_printerActivityInicator stopAnimating];
    _printerBindLabel.text = [NSString stringWithFormat:@"В данный момент привязан принтер %@", printerID];
    [NSUserDefaults setCurrentPrinterID:printerID];
    [self switchUIToEnabled:YES];
}

- (void) printerControllerDidPrintReceipt:(DSPF_Printer_technopark *)printerCont
{
     [_printerActivityInicator stopAnimating];
    _printerBindLabel.text = [NSString stringWithFormat:@"Чек распечатан\n\nВ данный момент привязан принтер %@", [NSUserDefaults currentPrinterID]];
    [self switchUIToEnabled:YES];
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont didFailedPrintingWithError:(NSError *)error
{
    [_printerActivityInicator stopAnimating];
    _printerBindLabel.text =  [NSString stringWithFormat:@"Ошибка печати чека\n\nВ данный момент привязан принтер %@", [NSUserDefaults currentPrinterID]];;
    [self switchUIToEnabled:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_statusLabel release];
    [_completedTransports release];
    [_printerBindLabel release];
    [_printerBindButton release];
    [_printerActivityInicator release];
    [_amountTextField release];
    [_printSampleButton release];
    [_openShiftButton release];
    [_zReportButton release];
    [_xReportButton release];
    [super dealloc];
}
@end
