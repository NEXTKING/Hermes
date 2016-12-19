//
//  DSPF_OrderTableViewCell_biopartner.h
//  Hermes
//
//  Created by iLutz on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSPF_OrderTableViewCell_biopartner : UITableViewCell {
    id                      dataLine;
    NSString               *orderTask;
@private
    UILabel                *dataLineQTYLabel;
    UILabel                *itemDescriptionLabel;
    UILabel                *itemTrademarkHolderLabel;
    UILabel                *itemPackageLabel;
    UILabel                *currentOrderQTYLabel;
    UILabel                *itemInfoLabel;
    UILabel                *itemIDLabel;
    UILabel                *itemPriceLabel;
    NSNumberFormatter      *currencyFormatter;
    NSManagedObjectContext *ctx;
}

@property (nonatomic, strong) id                 dataLine;
@property (nonatomic, strong) UILabel           *dataLineQTYLabel;
@property (nonatomic, strong) UILabel           *itemDescriptionLabel;
@property (nonatomic, strong) UILabel           *itemTrademarkHolderLabel;
@property (nonatomic, strong) UILabel           *itemPackageLabel;
@property (nonatomic, strong) UILabel           *currentOrderQTYLabel;
@property (nonatomic, strong) UILabel           *itemInfoLabel;
@property (nonatomic, strong) UILabel           *itemIDLabel;
@property (nonatomic, strong) UILabel           *itemPriceLabel;
@property (nonatomic, strong) NSString          *orderTask;

@property (nonatomic, strong) NSNumberFormatter      *currencyFormatter;
@property (nonatomic, strong) NSManagedObjectContext *ctx;

@end
