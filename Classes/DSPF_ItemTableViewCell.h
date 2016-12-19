//
//  DSPF_ItemTableViewCell.h
//  Hermes
//
//  Created by iLutz on 08.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPF_ItemTableViewCell : UITableViewCell {
    id                 itemLink;
    NSString          *itemTask;

@private
    UILabel           *itemDescriptionLabel;
    UILabel           *itemIDLabel;
    UILabel           *itemCodeLabel;
    UILabel           *itemPriceLabel;
    UILabel           *itemOrderLineLabel;
    NSNumberFormatter *currencyFormatter;
}

@property (nonatomic, strong) id                 itemLink;
@property (nonatomic, strong) NSString          *itemTask;

@property (nonatomic, strong) UILabel           *itemDescriptionLabel;
@property (nonatomic, strong) UILabel           *itemIDLabel;
@property (nonatomic, strong) UILabel           *itemCodeLabel;
@property (nonatomic, strong) UILabel           *itemPriceLabel;
@property (nonatomic, strong) UILabel           *itemOrderLineLabel;
@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;

@end
