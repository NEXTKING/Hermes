//
//  DSPF_ItemTableViewCell.m
//  Hermes
//
//  Created by iLutz on 07.12.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DSPF_ItemTableViewCell.h"

#import "Item.h"
#import "ItemDescription.h"
#import "ItemCode.h"
#import "ArchiveOrderLine.h"

@implementation DSPF_ItemTableViewCell

@synthesize itemLink;
@synthesize itemDescriptionLabel;
@synthesize itemIDLabel;
@synthesize itemCodeLabel;
@synthesize itemPriceLabel;
@synthesize itemOrderLineLabel;
@synthesize itemTask;
@synthesize currencyFormatter;


- (NSNumberFormatter *)currencyFormatter { 
    if (!currencyFormatter) {
        currencyFormatter = [[NSNumberFormatter alloc] init];
        [currencyFormatter  setNumberStyle:NSNumberFormatterCurrencyStyle]; 
        [currencyFormatter  setGeneratesDecimalNumbers:YES];
        [currencyFormatter  setFormatterBehavior:NSNumberFormatterBehavior10_4];
    }
    return currencyFormatter;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        // Initialization code
//      imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
//      imageView.contentMode = UIViewContentModeScaleAspectFit;
//      [self.contentView addSubview:imageView];
        
        itemDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemDescriptionLabel.backgroundColor = self.contentView.backgroundColor;
        [itemDescriptionLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:15]];
        [itemDescriptionLabel setTextColor:[UIColor blackColor]];
        [itemDescriptionLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemDescriptionLabel.minimumFontSize = 7.0;
        itemDescriptionLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        [self.contentView addSubview:itemDescriptionLabel];

        itemIDLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemIDLabel.backgroundColor = self.contentView.backgroundColor;
        [itemIDLabel setFont:[UIFont  fontWithName:@"HelveticaNeue-CondensedBold" size:14]];
        [itemIDLabel setTextColor:[UIColor darkGrayColor]];
        [itemIDLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemIDLabel.minimumFontSize = 7.0;
        itemIDLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemIDLabel];
        
        itemCodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemCodeLabel.backgroundColor = self.contentView.backgroundColor;
        [itemCodeLabel setFont:[UIFont systemFontOfSize:14.0]];
        [itemCodeLabel setTextColor:[UIColor darkGrayColor]];
        [itemCodeLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemCodeLabel.minimumFontSize = 7.0;
        itemCodeLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemCodeLabel];
        
        itemPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemPriceLabel.backgroundColor = self.contentView.backgroundColor;
        [itemPriceLabel setFont:[UIFont systemFontOfSize:14.0]];
        [itemPriceLabel setTextColor:[UIColor grayColor]];
        [itemPriceLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemPriceLabel.minimumFontSize = 8.0;
        itemPriceLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemPriceLabel];
        
        itemOrderLineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        itemOrderLineLabel.backgroundColor = self.contentView.backgroundColor;
        [itemOrderLineLabel setFont:[UIFont systemFontOfSize:14.0]];
        [itemOrderLineLabel setTextColor:[UIColor darkGrayColor]];
        [itemOrderLineLabel setHighlightedTextColor:[UIColor whiteColor]];
        itemOrderLineLabel.minimumFontSize = 8.0;
        itemOrderLineLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:itemOrderLineLabel];
    }
    return self;
}

#pragma mark - Laying out subviews

#define TEXT_LEFT_MARGIN    8.0
#define TEXT_RIGHT_MARGIN  42.0

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [itemDescriptionLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN,  
                14.0,
                self.frame.size.width
                - TEXT_LEFT_MARGIN
                - TEXT_RIGHT_MARGIN
                - [self.itemIDLabel.text sizeWithFont:self.itemIDLabel.font].width,
//              [self.itemDescriptionLabel.text sizeWithFont:self.itemDescriptionLabel.font].width,
                [self.itemDescriptionLabel.text sizeWithFont:self.itemDescriptionLabel.font].height)];
    [itemIDLabel setFrame:
     CGRectMake(self.frame.size.width
                - TEXT_RIGHT_MARGIN 
                - [self.itemIDLabel.text sizeWithFont:self.itemIDLabel.font].width, 
                14.0, 
                TEXT_RIGHT_MARGIN 
                + [self.itemIDLabel.text sizeWithFont:self.itemIDLabel.font].width, 
                [self.itemIDLabel.text sizeWithFont:self.itemIDLabel.font].height)];
    [itemCodeLabel setFrame:
     CGRectMake(TEXT_LEFT_MARGIN, 
                35.0, 
                [self.itemCodeLabel.text sizeWithFont:self.itemCodeLabel.font].width, 
                [self.itemCodeLabel.text sizeWithFont:self.itemCodeLabel.font].height)];
    [itemPriceLabel setFrame:
     CGRectMake(2 * TEXT_LEFT_MARGIN + [self.itemCodeLabel.text sizeWithFont:self.itemCodeLabel.font].width, 
                35.0, 
                [self.itemPriceLabel.text sizeWithFont:self.itemPriceLabel.font].width, 
                [self.itemPriceLabel.text sizeWithFont:self.itemPriceLabel.font].height)];
    [itemOrderLineLabel setFrame:
     CGRectMake(self.frame.size.width
                - TEXT_RIGHT_MARGIN 
                - [self.itemOrderLineLabel.text sizeWithFont:self.itemOrderLineLabel.font].width, 
                35.0, 
                [self.itemOrderLineLabel.text sizeWithFont:self.itemOrderLineLabel.font].width, 
                [self.itemOrderLineLabel.text sizeWithFont:self.itemOrderLineLabel.font].height)];
}

#pragma mark - Departure set accessor

- (void)setItemLink:(id )newItemLink {
    if (newItemLink != itemLink) {
        itemLink = newItemLink;
    }
    NSUInteger currentOrderQTY      = 0;
    if ([itemLink isKindOfClass:[Item class]]) {         
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", [Item localDescriptionTextForItem:(Item *)itemLink]];
        self.itemIDLabel.text           = [NSString stringWithFormat:@"     %@", ((Item *)itemLink).itemID];
        self.itemCodeLabel.text         = [NSString stringWithFormat:@"EAN: %@", [ItemCode salesUnitItemCodeForItemID:((Item *)itemLink).itemID 
                                                                                               inCtx:[itemLink ctx]]];
        self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:((Item *)itemLink).price];
        currentOrderQTY                 = [ArchiveOrderLine currentOrderQTYForItem:((Item *)itemLink).itemID 
                                                            inCtx:[itemLink ctx]];
    } else if ([itemLink isKindOfClass:[ItemDescription class]]) { 
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", ((ItemDescription *)itemLink).text];
        self.itemIDLabel.text           = [NSString stringWithFormat:@"     %@", ((ItemDescription *)itemLink).item.itemID];
        self.itemCodeLabel.text         = [NSString stringWithFormat:@"EAN: %@", [ItemCode salesUnitItemCodeForItemID:((ItemDescription *)itemLink).item.itemID 
                                                                                               inCtx:[itemLink ctx]]];
        self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:((ItemDescription *)itemLink).item.price];
        currentOrderQTY                 = [ArchiveOrderLine currentOrderQTYForItem:((ItemDescription *)itemLink).item.itemID 
                                                            inCtx:[itemLink ctx]];
    } else if ([itemLink isKindOfClass:[ItemCode class]]) { 
        self.itemDescriptionLabel.text  = [NSString stringWithFormat:@"%@", [Item localDescriptionTextForItem:((ItemCode *)itemLink).item]];
        self.itemIDLabel.text           = [NSString stringWithFormat:@"     %@", ((ItemCode *)itemLink).item.itemID];
        self.itemCodeLabel.text         = [NSString stringWithFormat:@"EAN: %@", ((ItemCode *)itemLink).code];
        self.itemPriceLabel.text        = [self.currencyFormatter stringFromNumber:((ItemCode *)itemLink).item.price];
        currentOrderQTY                 = [ArchiveOrderLine currentOrderQTYForItem:((ItemCode *)itemLink).item.itemID 
                                                            inCtx:[itemLink ctx]];
    }
    if (currentOrderQTY != 0) { 
        NSDecimalNumber *tmpItemQTYdecimal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%i", currentOrderQTY]];
        Item *item = nil;
        if ([itemLink isKindOfClass:[Item class]]) {
            item = (Item *)itemLink;
        } else {
            item = [(id<ItemHolder>)itemLink item];
        }
        if ([item.orderUnitCode isEqualToString:@"KG"] || [item.orderUnitCode isEqualToString:@"LT"]) {
            tmpItemQTYdecimal = [tmpItemQTYdecimal decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]];
        }
        self.itemOrderLineLabel.text    = [NSString stringWithFormat:@"📝 %@", tmpItemQTYdecimal];
        if (self.accessoryView && 
            [(UIButton *)self.accessoryView imageForState:UIControlStateNormal] == [UIImage imageNamed:@"addButton.png"]) { 
            [(UIButton *)self.accessoryView setImage:[UIImage imageNamed:@"addButton_m.png"] forState:UIControlStateNormal];
        }
    } else { 
        self.itemOrderLineLabel.text    = @"";     
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}


@end