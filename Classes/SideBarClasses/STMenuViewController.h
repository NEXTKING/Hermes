//
//  STMenuViewController.h
//  MobileBanking
//
//  Created by Kurochkin on 20/01/14.
//  Copyright (c) 2014 BPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DSPF_Workspace.h"
#import "STMenuDataSource.h"

@interface STMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    @protected
    NSMutableArray *_itemsMyBanking;
    NSMutableArray *_itemsTools;
    int _itemsRowHeight;
}

//@property (assign, nonatomic) id <SimpleTableItemsDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableViewCell *menuCell;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIView *layoutView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *viewConstraint;

@property (retain, nonatomic) STMenuDataSource *menuDataSource;

@end
