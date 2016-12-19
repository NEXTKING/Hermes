//
//  DSPF_TourLocationTechnopark.m
//  dphHermes
//
//  Created by Denis Kurochkin on 11.11.15.
//
//

#import "DSPF_TourLocationTechnopark.h"
#import "DSPF_Payment_technopark.h"
#import "DSPF_TransportCell_technopark.h"
#import "DSPF_SwitcherView.h"
#import "AppStyle.h"
#import "Departure.h"
#import "DSPF_Synchronisation.h"

@interface DSPF_TourLocationTechnopark () <UIActionSheetDelegate>
{
    BOOL isFirstLoad;
    BOOL servicesIncluded;
}

@property (nonatomic, retain) DSPF_SwitcherView* customHeader;

@end

@implementation DSPF_TourLocationTechnopark

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isFirstLoad         = YES;
    servicesIncluded = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    DSPF_SwitcherView *switcherView = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SwitcherView_technopark" owner:nil options:nil]objectAtIndex:0];
    self.customHeader = switcherView;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"technoparkBackground.png"]];
    self.tableView.backgroundView = backgroundImage;
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [backgroundImage release];
    
    self.tableView.tableFooterView = _footerView;
    _amountTitleLabel.textColor = [UIColor appMainTintColor];
    _amountLabel.textColor = [UIColor appMainFontColor];
    [_scanButton addTarget:_tableDataSource action:@selector(transportCodesShouldBeginUnloading) forControlEvents:UIControlEventTouchUpInside];
    [_payButton addTarget:self action:@selector(startPaymentWorkFlow) forControlEvents:UIControlEventTouchUpInside];
    [_cancelButton addTarget:_tableDataSource action:@selector(shouldLeaveTourLocation) forControlEvents:UIControlEventTouchUpInside];
    
    //cell customisation
    _addressTitleLabel.textColor    = [UIColor appMainTintColor];
    _addressLabel.textColor         = [UIColor appMainFontColor];
    _contactTitleLabel.textColor    = [UIColor appMainTintColor];
    _contactLabel.textColor         = [UIColor appMainFontColor];
    _commentTitleLabel.textColor    = [UIColor appMainTintColor];
    _commentLabel.textColor         = [UIColor appMainFontColor];
    
    _helperTextField.inputView = _timeAccessoryView;
    _helperTextField.inputAccessoryView = _accessoryToolbar;
    
    if ([DSPF_Synchronisation isLoading])
    {
        _scanButton.enabled = NO;
        _cancelButton.enabled = NO;
        _payButton.enabled = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tourHasBeenLoadedAction) name:@"syncTOURdoneTotal" object:nil];
    }
    
    Departure *currentDeparture = (Departure*)_tableDataSource.item;
    if (currentDeparture.currentTourStatus.intValue == 70 || currentDeparture.canceled.boolValue)
    {
        _scanButton.enabled = NO;
        _cancelButton.enabled = NO;
        _payButton.enabled = NO;
    }
    
    [switcherView addStateWithTitle:[NSString stringWithFormat:@"Заказ №%@", currentDeparture.transport_group_id.contractee_code] options:nil];
}

- (void) tourHasBeenLoadedAction
{
    _scanButton.enabled = YES;
    _cancelButton.enabled = YES;
    _payButton.enabled = YES;
}

- (void) startPaymentWorkFlow
{
    Departure *currentDeparture = (Departure*)_tableDataSource.item;
    if ([Transport transportsPickCountForTourLocation:currentDeparture.location_id.location_id
                                       transportGroup:currentDeparture.transport_group_id.transport_group_id
                                                inCtx:ctx()] > 0)
    {
        [DSPF_Warning messageTitle:NSLocalizedString(@"TITLE_028", @"Haltestellen-Status")
                       messageText:NSLocalizedString(@"ERROR_MESSAGE_009", @"Es soll hier noch Ware geladen werden !")
                              item:@"confirmIncompleteLOAD"
                          delegate:self];
    }

    NSPredicate *bonusPredicate = [NSPredicate predicateWithFormat: @"transport_group_id.transport_group_id = %lld && trace_type_id.code = %@ && requestType = 6 && itemQTY < 0", currentDeparture.transport_group_id.transport_group_id.longLongValue, TraceTypeStringLoad];
    NSArray *unloadedBonusCards = [Transport withPredicate:bonusPredicate inCtx:ctx()];
    if (unloadedBonusCards.count > 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Необходимо отсканировать бонусную карту клиента. Перейдите на экран отгрузки" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    DSPF_Payment_technopark* paymentVC = [[DSPF_Payment_technopark alloc] initWithParameters:@{@"amount":[NSNumber numberWithDouble:[_amountLabel.text doubleValue]], @"transportGroup":currentDeparture.transport_group_id}];
    paymentVC.tableDataSource = _tableDataSource;
    [self.navigationController pushViewController:paymentVC animated:YES];
    [paymentVC release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [self updateCompletedItems];
    [super viewWillAppear:animated];
    
    Departure *currentOrder = (Departure*)_tableDataSource.item;
    [self updateTimeTable];
    
    if (currentOrder.transport_group_id.deliveryFrom)
        _fromDatePicker.date    = currentOrder.transport_group_id.deliveryFrom;
    if (currentOrder.transport_group_id.deliveryUntil)
        _toDatePicker.date      = currentOrder.transport_group_id.deliveryUntil;
    
    _contactLabel.text = [NSString stringWithFormat:@"%@\n%@", currentOrder.location_id.contact_name, currentOrder.location_id.contact_phone];
    self.title = currentOrder.transport_group_id.code;
    _payButton.hidden = ([NSUserDefaults currentPrinterID] == nil);
}

- (void) updateTimeTable
{
    Departure *currentOrder = (Departure*)_tableDataSource.item;
    if (!currentOrder.transport_group_id.deliveryFrom || !currentOrder.transport_group_id.deliveryUntil)
        return;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* fromComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentOrder.transport_group_id.deliveryFrom];
    NSDateComponents* toComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentOrder.transport_group_id.deliveryUntil];
    NSString *timeString = [NSString stringWithFormat:@"с %d.%02d - %d.%02d", fromComponents.hour, fromComponents.minute, toComponents.hour, toComponents.minute];
    
    _addressLabel.text = [NSString stringWithFormat:@"%@\n%@, %@", timeString, currentOrder.location_id.city, currentOrder.location_id.street];
}

- (void) updateCompletedItems
{
    
    Departure *currentDeparture = (Departure*)_tableDataSource.item;
    
    self.completedTransports = [Transport transportsWithPredicate:
                                [NSPredicate predicateWithFormat:
                                 @"transport_group_id.transport_group_id = %lld && trace_type_id.code = %@",
                                 [currentDeparture.transport_group_id.transport_group_id longLongValue], TraceTypeStringUnload] sortDescriptors:nil inCtx:currentDeparture.managedObjectContext];
    
    if (_completedTransports.count > 0 && !servicesIncluded)
    {
        NSArray *serviceTransports = [Transport transportsWithPredicate:
                                      [NSPredicate predicateWithFormat:
                                       @"transport_group_id.transport_group_id = %lld && requestType = 2",
                                       [currentDeparture.transport_group_id.transport_group_id longLongValue], TraceTypeStringUnload] sortDescriptors:nil inCtx:currentDeparture.managedObjectContext];
        for (Transport *serviceTransport in serviceTransports) {
            
            
            NSRange realRange = {.location = 1, .length = serviceTransport.code.length-2};
            NSString *realCode = [serviceTransport.code substringWithRange:realRange];
            
                NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:realCode traceType:TraceTypeValueUnload fromDeparture:currentDeparture toLocation:currentDeparture.location_id];
                
                [currentTransport setValue:@NO forKey:@"loading_operation"];
                
                Transport * transport = [Transport transportWithDictionaryData:currentTransport inCtx:currentDeparture.managedObjectContext];
                Transport_Group *transportGroup = [Transport_Group transportGroupForItem:currentDeparture ctx:currentDeparture.managedObjectContext createWhenNotExisting:YES];
                    [transportGroup addTransport_idObject:transport];
        
        }
        
        [currentDeparture.managedObjectContext saveIfHasChanges];
        self.completedTransports = [Transport transportsWithPredicate:
                                    [NSPredicate predicateWithFormat:
                                     @"transport_group_id.transport_group_id = %lld && trace_type_id.code = %@",
                                     [currentDeparture.transport_group_id.transport_group_id longLongValue], TraceTypeStringUnload] sortDescriptors:nil inCtx:currentDeparture.managedObjectContext];
        servicesIncluded = YES;
    }
    
    double amount = 0;
    double giftCardAmount = 0;
    
    //NSMutableString *mutablestring = [NSMutableString new];
    
    for (Transport *transport in _completedTransports) {
        if (transport.item_id.paymentOnDelivery && transport.itemQTY.intValue > 0)
            amount+=(transport.item_id.paymentOnDelivery.doubleValue * transport.itemQTY.intValue - transport.itemQTYUnit.doubleValue);
        else if (transport.item_id.paymentOnDelivery && transport.itemQTY.intValue < 0 && transport.requestType.intValue == 3)
            giftCardAmount+=transport.item_id.paymentOnDelivery.doubleValue;
        
        //[mutablestring appendFormat:@"reqType = %d, itemQTY = %d\n", transport.requestType.intValue, transport.itemQTY.intValue];
    }
    
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"123" message:currentDeparture.transport_group_id.deliveryInfoText delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    //[alert show];
    
    if (currentDeparture.transport_group_id.paymentOnDelivery.doubleValue >= 0)
        amount = currentDeparture.transport_group_id.paymentOnDelivery.doubleValue;
    amount =  MAX((amount - giftCardAmount),0);
    
    _amountLabel.text = [NSString stringWithFormat:@"%.2f руб.", amount];
    
    if (currentDeparture.transport_group_id.paymentOnDelivery.doubleValue < 0 && amount == 0)
        _amountLabel.text = [NSString stringWithFormat:@"-.-- руб."];

    
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test :)" message:[NSString stringWithFormat:@"%d", _completedTransports.count] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
     */
}

- (IBAction) switchToPhone {
    
    Departure *currentOrder = (Departure*)_tableDataSource.item;
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:nil];
    NSArray *matches = [dataDetector matchesInString:currentOrder.location_id.contact_phone
                                         options:0
                                           range:NSMakeRange(0, [currentOrder.location_id.contact_phone length])];
    NSMutableArray* phones = [NSMutableArray new];
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            [phones addObject:phoneNumber];
        }
    }
    
    if (phones.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Не удалось найти номер контактного телефона" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if (phones.count == 1)
    {
        [self openPhoneAppWithNumber:phones[0]];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Выберите контактный телефон" delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:nil];
        for (NSString *phone in phones) {
            [actionSheet addButtonWithTitle:phone];
        }
        [actionSheet showInView:self.view];
    }
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    [self openPhoneAppWithNumber:[actionSheet buttonTitleAtIndex:buttonIndex]];
}

- (void) openPhoneAppWithNumber:(NSString*) number
{
    NSString* cleanString = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@")" withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@" " withString:@""];
    cleanString = [cleanString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",
                                                                     cleanString]]];
}

- (IBAction)timeChangeAction:(id)sender
{
    [_helperTextField becomeFirstResponder];
}

- (IBAction)toolBarDoneAction:(id)sender
{
    [_helperTextField resignFirstResponder];
    Departure *currentOrder = (Departure*)_tableDataSource.item;
    BOOL isTimeTheSame = [currentOrder.transport_group_id.deliveryFrom isEqualToDate:_fromDatePicker.date]
                        && [currentOrder.transport_group_id.deliveryUntil isEqualToDate:_toDatePicker.date];
    currentOrder.transport_group_id.deliveryFrom    = _fromDatePicker.date;
    currentOrder.transport_group_id.deliveryUntil   = _toDatePicker.date;
    [self updateTimeTable];
    if (!isTimeTheSame)
        [self sendTimeUpdateToServer];
}

- (void) sendTimeUpdateToServer
{
    Departure *currentDeparture = (Departure*)_tableDataSource.item;
    currentDeparture.transport_group_id = currentDeparture.transport_group_id;
    NSMutableDictionary *currentTransport = [Transport dictionaryWithCode:@"time_change" traceType:TraceTypeValueTimeChange
                                                            fromDeparture:currentDeparture toLocation:currentDeparture.location_id];
    
    NSMutableDictionary *timeChangeDict = [NSMutableDictionary new];
    
    NSDateFormatter *dateFMT  = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFMT  = [[NSDateFormatter alloc] init];
    [dateFMT setDateFormat:@"yyyy-MM-dd"];
    [timeFMT setDateFormat:@"HH:mm:sszzz"];
    NSString* currentDateString = [dateFMT stringFromDate:[NSDate date]];
    NSString* fromDateString = [NSString stringWithFormat:@"%@'T'%@",currentDateString,[timeFMT stringFromDate:_fromDatePicker.date]];
    NSString* toDateString = [NSString stringWithFormat:@"%@'T'%@",currentDateString,[timeFMT stringFromDate:_toDatePicker.date]];
    [timeChangeDict setObject:fromDateString forKey:@"deliveryFrom"];
    [timeChangeDict setObject:toDateString forKey:@"deliveryUntil"];
    
    
    [currentTransport setValue:[@{@"time_change":timeChangeDict} dictionaryByAddingEntriesFromDictionary:[currentTransport valueForKey:@"userInfo"]] forKey:@"userInfo"];
    
    [Transport transportWithDictionaryData:currentTransport inCtx:ctx()];
    [ctx() saveIfHasChanges];
    
    [SVR_SyncDataManager triggerSendingTraceLogDataOnlyWithUserInfo:nil];
}

#pragma mark - Table view data source

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return _customHeader;
    else
    {
        UIView *view = [[UIView new] autorelease];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return _customHeader.frame.size.height;
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0)
        return 3;
    
    return _completedTransports.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
        switch (indexPath.row) {
            case 0:
                return _addressCell.frame.size.height;
                break;
            case 1:
                return _contactCell.frame.size.height;
                break;
            case 2:
                return _commentCell.frame.size.height;
                break;
                
            default:
                break;
    }
    else if (indexPath.section == 1)
    {
        return UITableViewAutomaticDimension;
    }
    
    return UITableViewAutomaticDimension;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
            cell = _addressCell;
        else if (indexPath.row == 1)
            cell = _contactCell;
        else if (indexPath.row == 2)
            cell = _commentCell;
    }
    else if (indexPath.section == 1)
    {
        static NSString *CellIdentifier = @"DSPF_TourList";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_TransportCell_technopark" owner:nil options:nil] objectAtIndex:0];
        }
        
        [(DSPF_TransportCell_technopark*)(cell) setTransport:_completedTransports[indexPath.row] isLoad:YES];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_footerView release];
    [_amountTitleLabel release];
    [_amountLabel release];
    [_scanButton release];
    [_payButton release];
    [_cancelButton release];
    [_addressCell release];
    [_addressTitleLabel release];
    [_addressLabel release];
    [_timeButton release];
    [_contactCell release];
    [_contactTitleLabel release];
    [_contactLabel release];
    [_contactButton release];
    [_commentCell release];
    [_commentTitleLabel release];
    [_commentLabel release];
    [_timeAccessoryView release];
    [_helperTextField release];
    [_accessoryToolbar release];
    [_completedTransports release];
    [_fromDatePicker release];
    [_toDatePicker release];
    [super dealloc];
}
@end
