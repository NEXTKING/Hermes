//
//  DSPF_QuitLoading.h
//  Hermes
//
//  Created by Lutz on 03.07.14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Warning.h"
#import "DSPF_Confirm.h"
#import "Departure.h"
#import "DSPF_SignatureForName.h"

@interface DSPF_QuitLoading : UIViewController <DSPF_WarningDelegate,
                                                DSPF_SignatureForNameDelegate> {
    IBOutlet UILabel    *currentTourTitle;
	IBOutlet UILabel	*currentStintStart;
	IBOutlet UILabel    *currentStintEnd;

@private
	NSManagedObjectContext *ctx;
    NSString			   *tourTitle;
    NSString			   *udid;
    NSArray			       *tourDeparturesAtWork;
    IBOutlet UILabel       *tourStartLabel;
    IBOutlet UILabel       *tourEndeLabel;
    IBOutlet UIButton      *abschliessenButton;
    BOOL                    didItOnce;
}
@property (retain) IBOutlet UILabel	*currentStintStart;
@property (retain) IBOutlet UILabel *currentStintEnd;

@property (nonatomic, retain) NSManagedObjectContext *ctx;
@property (retain)			  NSString				 *tourTitle;
@property (retain)			  NSString				 *udid;
@property (nonatomic, retain) NSArray			     *tourDeparturesAtWork;
@property (nonatomic, retain) UILabel			     *currentTourTitle;;
@property (nonatomic, retain) UILabel			     *tourStartLabel;
@property (nonatomic, retain) UILabel			     *tourEndeLabel;
@property (nonatomic, retain) UIButton			     *abschliessenButton;
@property (nonatomic)         BOOL                    didItOnce;

- (IBAction)quitLoadingTOUR;

@end