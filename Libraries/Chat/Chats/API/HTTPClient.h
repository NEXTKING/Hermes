//
//  HTTPClient.h
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "JSONResponseSerializerWithData.h"
#import "ChatData.h"

#define SERVER_URL @"http://213.247.249.74:8080"


@interface HTTPClient : NSObject

+ (HTTPClient *)sharedinstance;
- (AFHTTPSessionManager *)getSessionManager;
- (id)inputError:(id)error;

- (void)getChatByOrder:(NSString *)order_id forUser:(NSInteger)user_id
             onSuccess:(void(^)(ChatData *response))success
             onFailure:(void(^)(NSError *error)) failure;

- (void)getCommonChatForUser:(NSInteger)user_id
                   onSuccess:(void(^)(ChatData *response))success
                   onFailure:(void(^)(NSError *error)) failure;

- (void)sendMessage:(NSDictionary *)message forChat:(NSString *)chat_id fromUser:(NSInteger)user_id
          onSuccess:(void(^)(id response))success
          onFailure:(void(^)(NSError *error)) failure;

@end
