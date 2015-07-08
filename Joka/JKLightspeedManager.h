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
#import "HXMessage.h"

//typedef enum {
//    AnSocialManagerGET,
//    AnSocialManagerPOST
//} AnSocialManagerMethod;

@protocol JKLightspeedManagerChatDelegate <NSObject>
@optional
- (void)messageSent:(NSString *)messageId;
- (void)didGetClientStatus:(NSDictionary *)clientStatus;
- (void)anIMDidAddClientsWithException:(NSString *)exception;
- (void)anIMMessageSent:(NSString *)messageId;
- (void)anIMSendReturnedException:(NSString *)exception messageId:(NSString *)messageId;
- (void)anIMDidReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp customMessage:(HXMessage *)customMessage;
- (void)anIMDidReceiveBinaryData:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp customMessage:(HXMessage *)customMessage;
@optional
- (void)anIMDidUpdateStatus:(BOOL)status exception:(NSString *)exception;
- (void)anIMDidGetClientsStatus:(NSDictionary *)clientsStatus exception:(NSString *)exception;

@end



@interface JKLightspeedManager : NSObject
@property (strong,nonatomic) NSString *userId;
@property (strong,nonatomic) NSString *clientId;
@property (strong,nonatomic) NSString *username;
@property (strong, nonatomic) NSMutableDictionary *remoteNotificationInfo;
@property BOOL isAppEnterBackground;
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
