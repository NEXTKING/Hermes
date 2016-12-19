//
//  DSPF_Finish.h
//  Hermes
//
//  Created by Lutz on 04.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Warning.h"
#import "DSPF_StatusReady.h"
#import "Departure.h"
#import "DSPF_Deadhead.h"

@interface DSPF_Finish : UIViewController <DSPF_WarningDelegate, DSPF_StatusReadyDelegate, UIViewControllerJumpThrough, DSPF_DeadheadDelegate> {
	IBOutlet UILabel	*currentStintStart;
	IBOutlet UILabel    *currentStintPauseTime;
	IBOutlet UILabel    *currentStintEnd;

@private
             BOOL           tourIsDone;
    NSArray			       *tourDeparturesAtWork;
    IBOutlet UILabel    *tourStartLabel;
    IBOutlet UILabel    *tourEndeLabel;
    IBOutlet UILabel    *pauseLabel;
    IBOutlet UIButton   *abmeldenButton;
    IBOutlet UIButton   *abschliessenButton;
}
@property (retain) IBOutlet UILabel	*currentStintStart;
@property (retain) IBOutlet UILabel *currentStintPauseTime;
@property (retain) IBOutlet UILabel *currentStintEnd;

@property (nonatomic)         BOOL			          tourIsDone;
@property (nonatomic, retain) NSArray			     *tourDeparturesAtWork;
@property (nonatomic, retain) UILabel			     *tourStartLabel;
@property (nonatomic, retain) UILabel			     *tourEndeLabel;
@property (nonatomic, retain) UILabel			     *pauseLabel;
@property (nonatomic, retain) UIButton			     *abmeldenButton;
@property (nonatomic, retain) UIButton			     *abschliessenButton;
- (IBAction)finishTOUR;
- (IBAction)logout;

+ (void) finishTourWithDepartures:(NSArray *) departures;
+ (void) unbindTruckFromDevice;
+ (BOOL) canCloseTourWithDepartures:(NSArray *) departuresToCheck error:(NSError **) error;

@end