//
//  DSPF_LocationInfo.h
//  Hermes
//
//  Created by Lutz on 22.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVR_LocationManager.h"
#import "DSPF_TourLocation.h"
#import "DSPF_Warning.h"

#import "Departure.h"
#import "Location.h"

@protocol DSPF_LocationInfoDelegate;

@interface DSPF_LocationInfo : UIViewController <UIScrollViewDelegate,
                                                 DSPF_WarningDelegate,
                                                 DSPF_TourLocationDelegate> {
             id                     <DSPF_LocationInfoDelegate> delegate;
             Departure              *departure;
             Location               *location;
             NSString               *tourTask;
             SVR_LocationManager    *svr_LocationManager;
    IBOutlet UILabel                *paletteAbzuladenLabel;
    IBOutlet UILabel                *paketeAbzuladenLabel; 
    IBOutlet UILabel                *nachnahmeBetragLabel;
    IBOutlet UILabel                *kontaktLabel; 
    IBOutlet UILabel                *contactName;
	IBOutlet UILabel                *streetAddress;
	IBOutlet UILabel                *zipCode;
	IBOutlet UILabel                *city;
    IBOutlet UILabel                *pallets;
	IBOutlet UILabel                *units;
    IBOutlet UILabel                *paymentOnDelivery;
    IBOutlet UITextView             *infoText; 
    IBOutlet UILabel                *contactPhone;
    IBOutlet UILabel                *contactSMS;
    IBOutlet UILabel                *contactEmail;
                                                     
    IBOutlet UIButton               *button_PHONE;
    IBOutlet UIButton               *button_SMS;
    IBOutlet UIButton               *button_MAIL;
    IBOutlet UIButton               *button_NAVIGON;
    IBOutlet UIView                 *buttonView;
    IBOutlet UIScrollView           *buttonSelection;
    IBOutlet UIPageControl          *buttonPage;

@private
			 NSManagedObjectContext	*ctx;
             NSNumberFormatter      *currencyFormatter;
}

@property (assign)            id		   <DSPF_LocationInfoDelegate> delegate;
@property (nonatomic, retain)              Departure                *departure;
@property (nonatomic, retain)              Location                 *location;
@property (nonatomic, retain)              NSString                 *tourTask;
@property (nonatomic, retain)              SVR_LocationManager      *svr_LocationManager;
@property (nonatomic, retain) IBOutlet     UILabel                  *paletteAbzuladenLabel;
@property (nonatomic, retain) IBOutlet     UILabel                  *paketeAbzuladenLabel;
@property (nonatomic, retain) IBOutlet     UILabel                  *nachnahmeBetragLabel;
@property (nonatomic, retain) IBOutlet     UILabel                  *kontaktLabel;
@property (nonatomic, retain) IBOutlet     UILabel                  *contactName;
@property (nonatomic, retain) IBOutlet     UILabel                  *streetAddress;
@property (nonatomic, retain) IBOutlet     UILabel                  *zipCode;
@property (nonatomic, retain) IBOutlet     UILabel                  *city;
@property (nonatomic, retain) IBOutlet     UILabel                  *pallets;
@property (nonatomic, retain) IBOutlet     UILabel                  *units;
@property (nonatomic, retain) IBOutlet     UILabel                  *paymentOnDelivery;
@property (nonatomic, retain) IBOutlet     UITextView               *infoText;
@property (nonatomic, retain) IBOutlet     UILabel                  *contactPhone;
@property (nonatomic, retain) IBOutlet     UILabel                  *contactSMS;
@property (nonatomic, retain) IBOutlet     UILabel                  *contactEmail;
@property (nonatomic, retain) IBOutlet     UIButton                 *button_PHONE;
@property (nonatomic, retain) IBOutlet     UIButton                 *button_SMS;
@property (nonatomic, retain) IBOutlet     UIButton                 *button_MAIL;
@property (nonatomic, retain) IBOutlet     UIButton                 *button_NAVIGON;
@property (nonatomic, retain) IBOutlet     UIView                   *buttonView;
@property (nonatomic, retain) IBOutlet     UIScrollView             *buttonSelection;
@property (nonatomic, retain) IBOutlet     UIPageControl            *buttonPage;

@property (nonatomic, retain)   NSNumberFormatter        *currencyFormatter;
@property (nonatomic, retain)   NSManagedObjectContext   *ctx;

- (IBAction)switchToPhone;
- (IBAction)switchToMail;
- (IBAction)switchToSMS;
- (IBAction)switchToNavigon;

@end

@protocol DSPF_LocationInfoDelegate

- (void) dspf_LocationInfo:(DSPF_LocationInfo *)sender didFinishTourForItem:(id )item;

@end