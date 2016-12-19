//
//  DSPF_Payment.h
//  Hermes
//
//  Created by Lutz  Thalmann on 30.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DSPF_Confirm.h" 
#import "DSPF_StatusReady.h"
#import "Location.h"
#import "Departure.h"
#import "Transport_Group.h"

@protocol DSPF_PaymentDelegate;

@interface DSPF_Payment : UIViewController <DSPF_ConfirmDelegate, 
                                            DSPF_StatusReadyDelegate> {
				 id					<DSPF_PaymentDelegate> delegate;
	IBOutlet UIView					*textView; 
    IBOutlet UILabel				*currentCustomerID;
    IBOutlet UILabel				*currentCustomerName;
             NSDecimalNumber        *totalValue;
    IBOutlet UILabel                *total;
    IBOutlet UILabel                *todo;
    IBOutlet UIImageView            *mode;
    IBOutlet UIButton               *mode_get;
    IBOutlet UIButton               *mode_put;
    IBOutlet UIButton               *mode_clear;
    IBOutlet UIButton               *mode_storno;
    IBOutlet UILabel                *input;
    IBOutlet UIButton               *input_1;
    IBOutlet UIButton               *input_2;
    IBOutlet UIButton               *input_3;
    IBOutlet UIButton               *input_4;
    IBOutlet UIButton               *input_5;
    IBOutlet UIButton               *input_6;
    IBOutlet UIButton               *input_7;
    IBOutlet UIButton               *input_8;
    IBOutlet UIButton               *input_9;
    IBOutlet UIButton               *input_0;
    IBOutlet UIButton               *inputDecimalSeparator;
             Departure				*currentDeparture;
             Transport_Group        *currentTransportGroup;
@private
			 NSManagedObjectContext *ctx;
             NSNumberFormatter      *inputFormatter;
             NSNumberFormatter      *currencyFormatter;
             NSInteger               inputExponent;
             SystemSoundID           cashSound;
             NSString               *prvTotal;
}
@property (assign)	id <DSPF_PaymentDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView					*textView;
@property (nonatomic, retain) IBOutlet UILabel					*currentCustomerID; 
@property (nonatomic, retain) IBOutlet UILabel					*currentCustomerName; 
@property (nonatomic, retain)          NSDecimalNumber          *totalValue;
@property (nonatomic, retain) IBOutlet UILabel					*total;
@property (nonatomic, retain) IBOutlet UILabel					*todo;
@property (nonatomic, retain) IBOutlet UIImageView              *mode;
@property (nonatomic, retain) IBOutlet UIButton                 *mode_get;
@property (nonatomic, retain) IBOutlet UIButton                 *mode_put;
@property (nonatomic, retain) IBOutlet UIButton                 *mode_clear;
@property (nonatomic, retain) IBOutlet UIButton                 *mode_storno;
@property (nonatomic, retain) IBOutlet UILabel					*input;
@property (nonatomic, retain) IBOutlet UIButton					*input_1;
@property (nonatomic, retain) IBOutlet UIButton					*input_2;
@property (nonatomic, retain) IBOutlet UIButton					*input_3;
@property (nonatomic, retain) IBOutlet UIButton					*input_4;
@property (nonatomic, retain) IBOutlet UIButton					*input_5;
@property (nonatomic, retain) IBOutlet UIButton					*input_6;
@property (nonatomic, retain) IBOutlet UIButton					*input_7;
@property (nonatomic, retain) IBOutlet UIButton					*input_8;
@property (nonatomic, retain) IBOutlet UIButton					*input_9;
@property (nonatomic, retain) IBOutlet UIButton					*input_0;
@property (nonatomic, retain) IBOutlet UIButton					*inputDecimalSeparator;
@property (nonatomic, retain)		   NSNumberFormatter        *inputFormatter;
@property (nonatomic, retain)		   NSNumberFormatter        *currencyFormatter;
@property (nonatomic, retain)          NSString					*prvTotal;
@property (nonatomic, retain)		   Departure				*currentDeparture;
@property (nonatomic, retain)		   Transport_Group          *currentTransportGroup;
@property (nonatomic, retain)		   NSManagedObjectContext   *ctx;

- (IBAction)getInputFromButton:(UIButton *)aButton;

@end

@protocol DSPF_PaymentDelegate

- (void) dspf_Payment:(DSPF_Payment *)sender didReturnPayment:(BOOL )completed forTransportCode:(NSString *)transportCode;

@end