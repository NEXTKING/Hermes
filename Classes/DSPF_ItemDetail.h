//
//  DSPF_ItemDetail.h
//  StoreOnline
//
//  Created by Lutz  Thalmann on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Item.h"

@interface DSPF_ItemDetail : UIViewController { 
    Item                *item;
@private
    IBOutlet UILabel    *itemDescriptionLabel;
    IBOutlet UILabel    *itemTrademarkHolderLabel;
    IBOutlet UILabel    *itemPackageLabel;
    IBOutlet UILabel    *itemQualityLabel;
    IBOutlet UILabel    *itemCategoryLabel;
    IBOutlet UILabel    *itemIDLabel;
    IBOutlet UILabel    *itemCodeLabel;
    IBOutlet UILabel    *itemPriceLabel;
    IBOutlet UILabel    *itemBuyingPriceLabel;
    IBOutlet UILabel    *itemOrderQTYLabel;
    IBOutlet UILabel    *itemOrderTotalCostLabel;
    IBOutlet UILabel    *itemArchiveOrderDateLabel;
    IBOutlet UILabel    *itemArchiveOrderQTYLabel;
    IBOutlet UILabel    *itemOrderUnitLabel;
    IBOutlet UILabel    *itemValueAddedTaxLabel;
    IBOutlet UILabel    *itemOG123ZLabel;
    IBOutlet UILabel    *bestBeforeDaysLabel;
    IBOutlet UILabel    *itemProductInformationLabel;
    IBOutlet UILabel    *itemPriceTextLabel;
    IBOutlet UILabel    *haltbarkeitLabel;
    IBOutlet UILabel    *tageLabel;
    IBOutlet UILabel    *mwstLabel;
    IBOutlet UILabel    *epLabel;    
    IBOutlet UILabel    *vpLabel;    
    NSNumberFormatter   *currencyFormatter;
    NSNumberFormatter   *percentageFormatter;
}

@property (nonatomic, retain) Item              *item;
@property (nonatomic, retain) UILabel           *itemDescriptionLabel;
@property (nonatomic, retain) UILabel           *itemTrademarkHolderLabel;
@property (nonatomic, retain) UILabel           *itemPackageLabel;
@property (nonatomic, retain) UILabel           *itemQualityLabel;
@property (nonatomic, retain) UILabel           *itemCategoryLabel;
@property (nonatomic, retain) UILabel           *itemIDLabel;
@property (nonatomic, retain) UILabel           *itemCodeLabel;
@property (nonatomic, retain) UILabel           *itemPriceLabel;
@property (nonatomic, retain) UILabel           *itemBuyingPriceLabel;
@property (nonatomic, retain) UILabel           *itemOrderQTYLabel;
@property (nonatomic, retain) UILabel           *itemOrderTotalCostLabel;
@property (nonatomic, retain) UILabel           *itemArchiveOrderDateLabel;
@property (nonatomic, retain) UILabel           *itemArchiveOrderQTYLabel;
@property (nonatomic, retain) UILabel           *itemOrderUnitLabel;
@property (nonatomic, retain) UILabel           *itemValueAddedTaxLabel;
@property (nonatomic, retain) UILabel           *itemOG123ZLabel;
@property (nonatomic, retain) UILabel           *bestBeforeDaysLabel;
@property (nonatomic, retain) UILabel           *itemProductInformationLabel;
@property (nonatomic, retain) UILabel           *itemPriceTextLabel;
@property (nonatomic, retain) UILabel           *haltbarkeitLabel;
@property (nonatomic, retain) UILabel           *tageLabel;
@property (nonatomic, retain) UILabel           *mwstLabel;
@property (nonatomic, retain) UILabel           *epLabel;
@property (nonatomic, retain) UILabel           *vpLabel;
@property (nonatomic, retain) NSNumberFormatter *currencyFormatter;
@property (nonatomic, retain) NSNumberFormatter *percentageFormatter;

@end
