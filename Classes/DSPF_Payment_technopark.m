//
//  PaymentViewController.m
//  Technopark
//
//  Created by Denis Kurochkin on 08/10/15.
//  Copyright © 2015 Denis Kurochkin. All rights reserved.
//

#import "DSPF_Payment_technopark.h"
#import "DSPF_Printer_technopark.h"
#import "DSPF_PaymentSuccess_technopark.h"

@interface DSPF_Payment_technopark () <DSPF_Printer_Protocol, UIAlertViewDelegate, UITextFieldDelegate>
{
    BOOL mixedPaymentEnabled;
    BOOL paymentFromCard;
    DSPF_Printer_technopark *printerManager;
}

@end

@implementation DSPF_Payment_technopark

- (instancetype) initWithParameters:(NSDictionary *)parameters
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])
    {
        self.amount = [nilOrObject([parameters objectForKey:@"amount"]) doubleValue];
        self.currentTransportGroup = nilOrObject([parameters objectForKey:@"transportGroup"]);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    mixedPaymentEnabled = NO;
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Оплата заказа";
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _amountLabel.text = [NSString stringWithFormat:@"%.2f руб", _amount];
    printerManager = [DSPF_Printer_technopark new];
    printerManager.delegate = self;
    _printerInfoLabel.text = @"";
    _controlsContainerHeightConstraint.constant = 120;
    _cardTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _cashTextField.keyboardType = UIKeyboardTypeDecimalPad;
    _cardTextField.inputAccessoryView = _accessoryToolbar;
    _cashTextField.inputAccessoryView = _accessoryToolbar;
    
    paymentFromCard = NO;
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    formatter.decimalSeparator = @".";
    _cashTextField.text = [formatter stringFromNumber:[NSNumber numberWithFloat:_amount]];
    _cardTextField.text = [formatter stringFromNumber:[NSNumber numberWithFloat:0.0f]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mixedPaymentAction:(id)sender
{
    [_scrollView layoutSubviews];
    [_controlsContainer layoutSubviews];
    _controlsContainerHeightConstraint.constant = mixedPaymentEnabled ? 120:157;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void) {
                         //Leave it empty
                         if (mixedPaymentEnabled)
                         {
                             _cardTextField.alpha = 0.0;
                             _cashTextField.alpha = 0.0;
                         }
                         else
                         {
                             _cardTextField.alpha = 1.0;
                             _cashTextField.alpha = 1.0;
                         }
                         [_scrollView layoutSubviews];
                         [_controlsContainer layoutSubviews];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    mixedPaymentEnabled = !mixedPaymentEnabled;
    
    SEL selector = mixedPaymentEnabled ? @selector(cardAction:):@selector(printAction:);
    [_cashGestureRecognizer removeTarget:nil action:NULL];
    [_cashGestureRecognizer addTarget:self action:selector];
}

- (IBAction)printAction:(id)sender
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    formatter.decimalSeparator = @".";
    
    if (![NSUserDefaults currentPrinterID])
    {
        _printerInfoLabel.text = @"Пожалуйста, привяжите принтер";
        return;
    }
    
    if (mixedPaymentEnabled)
    {
        [[NSUserDefaults standardUserDefaults] setFloat:[formatter numberFromString:_cardTextField.text].doubleValue forKey:@"PrinterCardAmount"];
        [[NSUserDefaults standardUserDefaults] setFloat:[formatter numberFromString:_cashTextField.text].doubleValue forKey:@"PrinterCashAmount"];
    }
    else
    {
        CGFloat cashAmount = paymentFromCard ? 0.0f:_amount;
        CGFloat cardAmount = paymentFromCard ? _amount:0.0f;
        [[NSUserDefaults standardUserDefaults] setFloat:cardAmount forKey:@"PrinterCardAmount"];
        [[NSUserDefaults standardUserDefaults] setFloat:cashAmount forKey:@"PrinterCashAmount"];
    }
    
    _printerInfoLabel.text = @"Печатаем чек...";
    [_printerActivityIndicator startAnimating];
    if (_currentTransportGroup)
        [printerManager printTransportGroup:_currentTransportGroup];
    else
        [printerManager printSample:[NSString stringWithFormat:@"%.2f", _amount]];
}

- (IBAction)cardAction:(id)sender
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    formatter.decimalSeparator = @".";
    CGFloat cardAmount = !mixedPaymentEnabled ? _amount:[formatter numberFromString:_cardTextField.text].doubleValue;
    NSString *formattedAmount = [formatter stringFromNumber:[NSNumber numberWithFloat:cardAmount]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание" message:[NSString stringWithFormat:@"Провести оплату по карте на сумму %@?", formattedAmount] delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Провести", nil];
    [alert show];
}

- (IBAction)toolbarDoneAction:(id)sender
{
    [self.view endEditing:YES];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    formatter.minimumFractionDigits = 2;
    formatter.maximumFractionDigits = 2;
    formatter.decimalSeparator = @".";
    
    if (textField == _cashTextField)
    {
        CGFloat enteredCashAmount = _cashTextField.text.doubleValue;
        CGFloat cardAmount = 0.0f;
        if (enteredCashAmount > _amount)
            enteredCashAmount = _amount;
        cardAmount = _amount - enteredCashAmount;
        _cashTextField.text = [formatter stringFromNumber:[NSNumber numberWithFloat:enteredCashAmount]];
        _cardTextField.text = [formatter stringFromNumber:[NSNumber numberWithFloat:cardAmount]];
        
    }
    else
    {
        CGFloat enteredCardAmount = _cardTextField.text.doubleValue;
        CGFloat cashAmount = 0.0f;
        if (enteredCardAmount > _amount)
            enteredCardAmount = _amount;
        cashAmount = _amount - enteredCardAmount;
        _cardTextField.text = [formatter stringFromNumber:[NSNumber numberWithFloat:enteredCardAmount]];
        _cashTextField.text = [formatter stringFromNumber:[NSNumber numberWithFloat:cashAmount]];
    }
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont didFailedBindingWithError:(NSError *)error
{
    _printerInfoLabel.text = @"Ошибка печати чека. Попробуйте еще раз";
    [_printerActivityIndicator stopAnimating];
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont DidFinishBindingPrinter:(NSString *)printerID
{
}

- (void) printerControllerDidPrintReceipt:(DSPF_Printer_technopark *)printerCont
{
    _printerInfoLabel.text = @"Чек распечатан!";
    [_printerActivityIndicator stopAnimating];
    
    if (_currentTransportGroup)
    {
        DSPF_PaymentSuccess_technopark* paymentSuccess = [[[DSPF_PaymentSuccess_technopark alloc] initWithNibName:@"DSPF_PaymentSuccess_technopark" bundle:[NSBundle mainBundle] ]autorelease];
        paymentSuccess.tableDataSource = _tableDataSource;
        [self.navigationController pushViewController:paymentSuccess animated:YES];
    }
    
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont didFailedPrintingWithError:(NSError *)error
{
    _printerInfoLabel.text = @"Ошибка печати чека. Попробуйте еще раз";
    [_printerActivityIndicator stopAnimating];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        paymentFromCard = NO;
        return;
    }
    else
    {
        paymentFromCard = YES;
        [self printAction:nil];
        paymentFromCard = NO;
    }
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
    [_cardTextField release];
    [_cashTextField release];
    [_amountLabel release];
    [_printerInfoLabel release];
    [_printerActivityIndicator release];
    [_controlsContainerHeightConstraint release];
    [_scrollView release];
    [_controlsContainer release];
    [_accessoryToolbar release];
    [_cashGestureRecognizer release];
    [super dealloc];
}
@end
