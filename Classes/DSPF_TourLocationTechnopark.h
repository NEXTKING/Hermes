//
//  DSPF_TourLocationTechnopark.h
//  dphHermes
//
//  Created by Denis Kurochkin on 11.11.15.
//
//

#import <UIKit/UIKit.h>
#import "DSPF_TourLocation.h"

@interface DSPF_TourLocationTechnopark : UITableViewController

@property (nonatomic, assign) DSPF_TourLocation *tableDataSource;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet UILabel *amountTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *amountLabel;
@property (retain, nonatomic) IBOutlet UIButton *scanButton;
@property (retain, nonatomic) IBOutlet UIButton *payButton;
@property (retain, nonatomic) IBOutlet UIButton *cancelButton;
@property (retain, nonatomic) IBOutlet UIView *timeAccessoryView;
@property (retain, nonatomic) IBOutlet UITextField *helperTextField;
@property (retain, nonatomic) IBOutlet UIToolbar *accessoryToolbar;
@property (retain, nonatomic) IBOutlet UIDatePicker *fromDatePicker;
@property (retain, nonatomic) IBOutlet UIDatePicker *toDatePicker;

//Custom cells

//AddressCell
@property (retain, nonatomic) IBOutlet UITableViewCell *addressCell;
@property (retain, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UIButton *timeButton;

//Contact Cell

@property (retain, nonatomic) IBOutlet UITableViewCell *contactCell;
@property (retain, nonatomic) IBOutlet UILabel *contactTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *contactLabel;
@property (retain, nonatomic) IBOutlet UIButton *contactButton;

//Comment Cell

@property (retain, nonatomic) IBOutlet UITableViewCell *commentCell;
@property (retain, nonatomic) IBOutlet UILabel *commentTitleLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentLabel;

@property (nonatomic, retain) NSArray *completedTransports;



@end
