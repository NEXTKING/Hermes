//
//  ChatData.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseData.h"

@interface ChatData : BaseData

@property (nonatomic, strong) NSString *chat_id;
@property (nonatomic, strong) NSMutableArray *messages;

- (ChatData *)initWithJSON:(NSDictionary *)json;

@end
