//
//  TerminalViewController.h
//  Technopark
//
//  Created by Denis Kurochkin on 08/10/15.
//  Copyright © 2015 Denis Kurochkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPF_Terminal_technopark : UIViewController <UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *statusLabel;

@property (retain, nonatomic) IBOutlet UILabel *printerBindLabel;
@property (retain, nonatomic) IBOutlet UIButton *printerBindButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *printerActivityInicator;
@property (retain, nonatomic) IBOutlet UITextField *amountTextField;
@property (retain, nonatomic) IBOutlet UIButton *printSampleButton;
@property (retain, nonatomic) IBOutlet UIButton *openShiftButton;
@property (retain, nonatomic) IBOutlet UIButton *zReportButton;
@property (retain, nonatomic) IBOutlet UIButton *xReportButton;

@end
