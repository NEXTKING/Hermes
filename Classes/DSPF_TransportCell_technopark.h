//
//  DSPF_TransportCell_technopark.h
//  dphHermes
//
//  Created by Denis Kurochkin on 13.11.15.
//
//

#import <UIKit/UIKit.h>
#import "Transport.h"

@interface DSPF_TransportCell_technopark : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *mainLabel;

- (void) setTransport:(Transport*) transport isLoad:(BOOL) isLoad;

@end
