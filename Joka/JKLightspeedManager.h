//
//  JKLightspeedManager.h
//  Joka
//
//  Created by 雷翊廷 on 2015/6/18.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnIM.h"
#import "AnSocial.h"


typedef enum {
    AnSocialManagerGET,
    AnSocialManagerPOST
} AnSocialManagerMethod;

@protocol JKLightspeedManagerChatDelegate
@optional
- (void)messageSent:(NSString *)messageId;
- (void)didGetClientStatus:(NSDictionary *)clientStatus;
@end

@interface JKLightspeedManager : NSObject
@property (strong,nonatomic) NSString *userId;
@property (strong,nonatomic) NSString *clientId;
@property (strong,nonatomic) NSString *username;
@property BOOL clientStatus;
@property (weak, nonatomic) id<JKLightspeedManagerChatDelegate> chatDelegate;


+ (JKLightspeedManager *)manager;
- (AnIM *)anIM;
- (void)logOut;
- (void)checkIMConnection;
- (void)sendRequest:(NSString *)path
             method:(AnSocialManagerMethod)method
             params:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
            failure:(void (^)(NSDictionary *response))failure;

@end
