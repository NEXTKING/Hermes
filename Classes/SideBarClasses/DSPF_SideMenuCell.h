//
//  DSPF_SideMenuCell.h
//  dphHermes
//
//  Created by Denis Kurochkin on 05.11.15.
//
//

#import <UIKit/UIKit.h>

@interface DSPF_SideMenuCell : UITableViewCell

@property (copy) void (^cellAction)(void);
@property (nonatomic, retain) IBOutlet UIImageView  *menuIcon;
@property (nonatomic, retain) IBOutlet UILabel      *menuTitle;

@end
