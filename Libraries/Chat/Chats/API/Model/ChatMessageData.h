//
//  ChatMessageData.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseData.h"
#import "ChatUserData.h"

@interface ChatMessageData : BaseData

@property (nonatomic, strong) NSString  *text;
@property (nonatomic, strong) NSDate    *date;
@property (nonatomic, strong) NSString  *photo_url;
@property (nonatomic, strong) UIImage   *local_photo;
@property (nonatomic, strong) ChatUserData *user_data;

- (ChatMessageData *)initWithJSON:(NSDictionary *)json;

@end
