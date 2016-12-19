//
//  STMenuDataSource.m
//  dphHermes
//
//  Created by Denis Kurochkin on 05.11.15.
//
//

#import "STMenuDataSource.h"
#import "DSPF_SideMenuCell_technopark.h"
#import "HermesAppDelegate.h"
#import "DSPF_PersonalData_technopark.h"
#import "DSPF_Finish.h"
#import "HermesAppDelegate.h"
#import "DSPF_SideMenuHeader_technopark.h"
#import "DSPF_PersonalData_technopark.h"
#import "DSPF_Terminal_technopark.h"
#import "User.h"
#import "Tour.h"
#import "ChatInteractorViewController.h"
#import "DSPF_Printer_technopark.h"

@interface STMenuDataSource() <DSPF_Printer_Protocol>
{
    DSPF_Finish *finishCont;
    DSPF_Printer_technopark* printerManager;
}

@end

@implementation STMenuDataSource

@synthesize headerView = _headerView;

- (id) init
{
    self = [super init];
    if (self)
    {
        NSMutableArray *cellsArray          = [[NSMutableArray new] autorelease];
        HermesAppDelegate *appDelegate      = (HermesAppDelegate*)[[UIApplication sharedApplication]delegate];
        DSPF_Workspace *currentWorkspace    = [appDelegate workspace];
        printerManager = [DSPF_Printer_technopark new];
        printerManager.delegate = self;
        
        if (PFBrandingSupported(BrandingTechnopark, nil))
        {
            {
                DSPF_SideMenuCell_technopark *cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SideMenuCell_technopark" owner:nil options:nil] objectAtIndex:0];
                cell.menuTitle.text = @"Текущий заказ";
                cell.menuIcon.image = [UIImage imageNamed:@"hose.png"];
                cell.cellAction = ^{
                    [currentWorkspace switchBackToWorkspace];
                };
                
                [cellsArray addObject:cell];
            }
            {
                DSPF_SideMenuCell_technopark *cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SideMenuCell_technopark" owner:nil options:nil] objectAtIndex:0];
                cell.menuTitle.text = @"Заполнить данные";
                cell.menuIcon.image = [UIImage imageNamed:@"data.png"];
                cell.cellAction = ^{
                    DSPF_PersonalData_technopark *truckInfo = [[DSPF_PersonalData_technopark alloc] init];
                    [currentWorkspace switchToExternalViewController:truckInfo];
                    [truckInfo release];
                };
                
                [cellsArray addObject:cell];
            }
            {
                DSPF_SideMenuCell_technopark *cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SideMenuCell_technopark" owner:nil options:nil] objectAtIndex:0];
                cell.menuTitle.text = @"Общий чат";
                cell.menuIcon.image = [UIImage imageNamed:@"chat.png"];
                cell.cellAction = ^{
                    
                    ChatInteractorViewController *chatInteractor = [[ChatInteractorViewController alloc] initCommon];
                    [currentWorkspace switchToExternalViewController:chatInteractor.commonChat];

                };
                
                [cellsArray addObject:cell];
            }
            {
                DSPF_SideMenuCell_technopark *cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SideMenuCell_technopark" owner:nil options:nil] objectAtIndex:0];
                cell.menuTitle.text = @"Оборудование";
                cell.menuIcon.image = [UIImage imageNamed:@"equipment.png"];
                cell.cellAction = ^{
                    DSPF_Terminal_technopark *truckInfo = [[DSPF_Terminal_technopark alloc] init];
                    [currentWorkspace switchToExternalViewController:truckInfo];
                    [truckInfo release];
                };
                
                [cellsArray addObject:cell];
            }
            {
                DSPF_SideMenuCell_technopark *cell = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SideMenuCell_technopark" owner:nil options:nil] objectAtIndex:0];
                cell.menuTitle.text = @"Завершить маршрут";
                cell.menuIcon.image = [UIImage imageNamed:@"exit.png"];
                cell.cellAction = ^{
                    
                    if (![NSUserDefaults currentPrinterID])
                    {
                        [self finishTour];
                        [cell setSelected:NO animated:YES];
                        return;
                    }
                    
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@"Завершение маршрута"
                                                  message:@"Закрыть смену?"
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"Да"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [printerManager zReport];
                                             [cell setSelected:NO animated:YES];
                                         }];
                    UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"Нет"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             //Do some thing here
                                             [self finishTour];
                                             [cell setSelected:NO animated:YES];
                                             
                                         }];
                    [alert addAction:ok];
                    [alert addAction:cancel];
                    
                    HermesAppDelegate *appDelegate = (HermesAppDelegate*)[[UIApplication sharedApplication] delegate];
                    [appDelegate.workspace presentViewController:alert animated:YES completion:nil];
                    

                };
                [cellsArray addObject:cell];
            }
        }
        
        _cells = [cellsArray retain];
        
        //HeaderView
        DSPF_SideMenuHeader_technopark* header = [[[NSBundle mainBundle] loadNibNamed:@"DSPF_SideMenuHeader_technopark" owner:nil options:nil] objectAtIndex:0];
        User* currentUser = [User userWithUserID:[NSUserDefaults currentUserID] inCtx:ctx()];
        header.nameLabel.text = [currentUser firstAndLastName];
        
        if (currentUser.tour_id.count > 0)
        {
            Tour *currentTour = currentUser.tour_id.allObjects[0];
            header.tourNumberLabel.text = [NSString stringWithFormat:@"Путевка № %@", currentTour.description_text];
            header.truckLabel.text = currentTour.truck_id.description_text;
        }
        else
            header.tourNumberLabel.text = @"";
        
        _headerView = [header retain];
        
    }
    
    return self;
}

- (void) finishTour
{
    finishCont = [DSPF_Finish new];
    
    HermesAppDelegate *appDelegate = (HermesAppDelegate*)[[UIApplication sharedApplication] delegate];

    [appDelegate.workspace toggleMenu:nil];
    
    //Nav Controller workaround!!!
    appDelegate.workspace.navigationController.visibleViewController.view.userInteractionEnabled = YES;
    //!!!
    
    [finishCont setNavigationController:appDelegate.workspace.navigationController];
    [finishCont finishTOUR];
}

#pragma mark - Printer Delegate

- (void) printerControllerDidPrintReceipt:(DSPF_Printer_technopark *)printerCont
{
    [self finishTour];
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont didFailedPrintingWithError:(NSError *)error
{
    
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont DidFinishBindingPrinter:(NSString *)printerID
{
    
}

- (void) printerController:(DSPF_Printer_technopark *)printerCont didFailedBindingWithError:(NSError *)error
{

}



- (void) dealloc
{
    [finishCont release];
    [_cells release];
    [_headerView release];
    [printerManager release];
    [super dealloc];
}

@end
