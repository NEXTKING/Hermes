//
//  DSPF_PaymentSuccess_technopark.h
//  dphHermes
//
//  Created by Denis Kurochkin on 30.12.15.
//
//

#import <UIKit/UIKit.h>
#import "DSPF_TourLocation.h"

@interface DSPF_PaymentSuccess_technopark : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *finishButton;
@property (nonatomic, assign) DSPF_TourLocation *tableDataSource;

@end
