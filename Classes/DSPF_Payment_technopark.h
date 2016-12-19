//
//  PaymentViewController.h
//  Technopark
//
//  Created by Denis Kurochkin on 08/10/15.
//  Copyright © 2015 Denis Kurochkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Transport_Group.h"
#import "DSPF_TourLocation.h"

@interface DSPF_Payment_technopark : UIViewController

@property (retain, nonatomic) IBOutlet UITapGestureRecognizer *cashGestureRecognizer;
@property (nonatomic, assign) DSPF_TourLocation *tableDataSource;
@property (assign, nonatomic) double amount;
@property (retain, nonatomic) Transport_Group* currentTransportGroup;
@property (retain, nonatomic) IBOutlet UITextField *cardTextField;
@property (retain, nonatomic) IBOutlet UITextField *cashTextField;
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;
@property (retain, nonatomic) IBOutlet UILabel *printerInfoLabel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *printerActivityIndicator;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *controlsContainerHeightConstraint;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIView *controlsContainer;
@property (retain, nonatomic) IBOutlet UIToolbar *accessoryToolbar;

- (instancetype) initWithParameters:(NSDictionary *)parameters;

@end
