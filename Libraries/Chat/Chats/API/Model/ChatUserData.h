//
//  ChatUserData.h
//  ChatModule
//
//  Created by Виктория on 27.04.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "BaseData.h"

@interface ChatUserData : BaseData

@property (nonatomic) NSInteger id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *position;

- (ChatUserData *)initWithJSON:(NSDictionary *)json;

@end
