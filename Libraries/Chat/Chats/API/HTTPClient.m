//
//  HTTPClient.m
//  ChatModule
//
//  Created by Виктория on 31.03.16.
//  Copyright © 2016 Виктория. All rights reserved.
//

#import "HTTPClient.h"

@implementation HTTPClient

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (HTTPClient *)sharedinstance {
    static HTTPClient *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[HTTPClient alloc] init];
    });
    return _sharedInstance;
}

- (void)getChatByOrder:(NSString *)order_id forUser:(NSInteger)user_id
             onSuccess:(void(^)(ChatData *response))success
             onFailure:(void(^)(NSError *error)) failure
{
     [[self getSessionManager] GET:[NSString stringWithFormat:@"/chat/%@/user/%li/", order_id, (long)user_id] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
         NSMutableDictionary *chatDict = [responseObject mutableCopy];
         [chatDict setObject:order_id forKey:@"chat_id"];
         
         ChatData *chatData = [[ChatData alloc] initWithJSON:chatDict];
         
         success(chatData);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure([self inputError:error]);
        
    }];
}

- (void)getCommonChatForUser:(NSInteger)user_id
             onSuccess:(void(^)(ChatData *response))success
             onFailure:(void(^)(NSError *error)) failure
{
    [[self getSessionManager] GET:[NSString stringWithFormat:@"/chat/common/user/%li/", (long)user_id] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSMutableDictionary *chatDict = [responseObject mutableCopy];
        [chatDict setObject:@"common" forKey:@"chat_id"];
        
        ChatData *chatData = [[ChatData alloc] initWithJSON:chatDict];
        
        success(chatData);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
        
    }];
}

- (void)sendMessage:(NSDictionary *)message forChat:(NSString *)chat_id fromUser:(NSInteger)user_id
          onSuccess:(void(^)(id response))success
          onFailure:(void(^)(NSError *error)) failure
{
    
    NSString *uri;
    if ([chat_id isEqualToString:@"common"]) {
        uri = [NSString stringWithFormat:@"/chat/common/user/%li", (long)user_id];
    } else {
        uri = [NSString stringWithFormat:@"/chat/%@/user/%li",chat_id, (long)user_id];
    }
    
    if ([message objectForKey:@"image"]) {
        // post to server
        [self uploadToServerUsingImage:[message objectForKey:@"image"]
                             andParams:message
                               withUri:uri
                             onSuccess:success
                             onFailure:failure];
    } else {
        [[self getSessionManager] POST:uri parameters:message progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

            failure(error);
        }];
    }
}

//MultyPart Data
- (void)uploadToServerUsingImage:(NSData *)imageData
                       andParams:(NSDictionary *)params
                         withUri:(NSString *)uri
                       onSuccess:(void(^)(id response))success
                       onFailure:(void(^)(NSError *error)) failure {
    // set this to your server's address
    NSString *urlString = [NSString stringWithFormat:@"%@%@", SERVER_URL, uri];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    // define the boundary and newline values
    NSString *boundary = @"uwhQ9Ho7y873Ha";
    NSString *kNewLine = @"\r\n";
    
    // Set the URLRequest value property for the HTTP Header
    // Set Content-Type as a multi-part form with boundary identifier
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // prepare a mutable data object used to build message body
    NSMutableData *body = [NSMutableData data];
    for (id keyObject in [params allKeys]) {
        if ([keyObject isEqualToString:@"image"]) {
            [body appendData:[[NSString stringWithFormat:@"--%@%@", boundary, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image-name.jpg\"%@", keyObject, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg"] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@%@", kNewLine, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:imageData];
            [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
        } else if ([keyObject isEqualToString:@"message"] && [[params objectForKey:@"message"] length] > 0) {
            
                [body appendData:[[NSString stringWithFormat:@"--%@%@", boundary, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", keyObject] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"%@%@", kNewLine, kNewLine] dataUsingEncoding:NSUTF8StringEncoding]];
                NSString *stringOfKeyobject = [params objectForKey:keyObject];
                [body appendData:[stringOfKeyobject dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[kNewLine dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    

    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *error = nil;
    if (returnData) {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:returnData
                                                             options:kNilOptions
                                                               error:&error];
        if (!error) {
            success(json);
        } else {
            failure(error);
        }
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"==> sendSyncReq returnString: %@", returnString);
    } else {
        error = [[NSError alloc] initWithDomain:@"AFNetworkingErrorDomain" code:403 userInfo:@{@"error":@"Sorry. Server temporary unavailable."}];
        failure(error);
        NSLog(@"Return parameters is nil!!!!");
    }
    
    
}


#pragma mark - SessionManager
     
 - (AFHTTPSessionManager *)getSessionManager {
     
     NSURL *baseURL = [NSURL URLWithString:SERVER_URL];
     
     AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
     manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];//[NSSet setWithObject:@"application/json"];
     return manager;
 }
     
#pragma mark - WorkWithError
     
 - (id)inputError:(id)error {
     id object;
     if (error) {
         if ([error isKindOfClass:[NSError class]] && [[error userInfo] objectForKey:@"JSONResponseSerializerWithDataKey"]) {
             NSError *deserializationError = nil;
             object = [NSJSONSerialization
                       JSONObjectWithData:[[error userInfo] objectForKey:@"JSONResponseSerializerWithDataKey"]
                       options:0
                       error:&deserializationError];
             if (!object) {
                 object = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
             }
         } else if ([[error userInfo] objectForKey:@"NSLocalizedDescription"]) {
             object = [[error userInfo] objectForKey:@"NSLocalizedDescription"];
         } else if ([[error userInfo] objectForKey:@"NSDebugDescription"]) {
             object = [[error userInfo] objectForKey:@"NSDebugDescription"];
         } else {
             object = error;
         }
     }
     return object;
 }

@end
