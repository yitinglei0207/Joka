//
//  JKLightspeedManager.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/18.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKLightspeedManager.h"
#import "JokaCredentials.h"
#import "AnSocial.h"
#import "AnIM.h"
#import "MessageUtil.h"



@interface JKLightspeedManager () <AnIMDelegate,JKLightspeedManagerChatDelegate>
@property (strong, nonatomic) AnIM *anIM;
@property (strong, nonatomic) AnSocial *anSocial;
@property BOOL imConnecting;
@end

@implementation JKLightspeedManager


- (id)init
{
    self = [super init];
    if (self) {
        self.anIM = [[AnIM alloc]initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
        self.anSocial = [[AnSocial alloc]initWithAppKey:LIGHTSPEED_APP_KEY];
        self.remoteNotificationInfo = [[NSMutableDictionary alloc]initWithCapacity:0];
        [self.anSocial setSecureConnection:YES];
        [self.anSocial setTimeout:20.0f];
    }
    return self;
}

- (AnIM *)anIM {
    return _anIM;
}

- (void)logOut{
    [_anIM disconnect];
    self.userId = nil;
    self.clientId = nil;
    self.username = nil;
}


#pragma mark - Lightspeed Delegate

- (void)anIM:(AnIM *)anIM didGetClientsStatus:(NSDictionary *)clientsStatus exception:(ArrownockException *)exception
{

    if (!exception) {
        NSLog(@"%@",clientsStatus);
        
        if ([(NSObject *)self.chatDelegate respondsToSelector:@selector(didGetClientStatus:)]) {
            [self.chatDelegate didGetClientStatus:clientsStatus];
        }
    }
    else{
        NSLog(@"%@",exception);
        
    }
}




// it is for receiving message
//- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
//{
//    NSLog(@"the message is: %@", message);
//    NSLog(@"the messageId is: %@", messageId);
//    NSLog(@"the sender is: %@", from);
//    //NSLog(@"all recipients, including the sender: %@", [parties componentsJoinedByString:@","]);
//    
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Joka.didReceiveMessage"
//                                                        object:@{@"message": message,
//                                                                 @"customData": customData ? customData : @"",
//                                                                 @"from": from,
//                                                                 @"parties": parties,
//                                                                 @"messageId": messageId,
//                                                                 @"timestamp": timestamp}];
//}

+ (JKLightspeedManager *)manager
{
    static JKLightspeedManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[JKLightspeedManager alloc] init];
    });
    return _manager;
}


#pragma mark - AnIM Chat Delgate

- (void)anIM:(AnIM *)anIM didAddClientsWithException:(ArrownockException *)exception
{
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidAddClientsWithException:)])
    {
        [self.chatDelegate anIMDidAddClientsWithException:exception.message];
    }
}

- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId
{
    if ([self.chatDelegate respondsToSelector:@selector(anIMMessageSent:)])
    {
        [self.chatDelegate anIMMessageSent:messageId];
    }
}

- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId
{
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMSendReturnedException:messageId:)])
    {
        [self.chatDelegate anIMSendReturnedException:exception.message messageId:messageId];
    }
}

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    /* configure location or text */
    NSString *fileType = [MessageUtil configureTextMessageType:customData];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                            msgId:messageId
                                                          topicId:@""
                                                          message:message
                                                          content:nil
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    HXMessage *hxCustomMessage = [MessageUtil anIMMessageToHXMessage:customMessage];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveMessage:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveMessage:message
                                      customData:customData
                                            from:from
                                         topicId:@""
                                       messageId:messageId
                                              at:timestamp
                                   customMessage:hxCustomMessage];
    }
    [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:hxCustomMessage.from];
}

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    /* configure location or text */
    NSString *fileType = [MessageUtil configureTextMessageType:customData];
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMTextMessage
                                                            msgId:messageId
                                                          topicId:topicId
                                                          message:message
                                                          content:nil
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveMessage:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveMessage:message
                                      customData:customData
                                            from:from
                                         topicId:topicId
                                       messageId:messageId
                                              at:timestamp
                                   customMessage:[MessageUtil anIMMessageToHXMessage:customMessage]];
    }
    [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
}

- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    if ([fileType isEqualToString:@"send"]) {
        if ([customData[@"type"] isEqualToString:@"approve"]) {
            
//            NSLog(@"received approve message");
//            HXUser *friend = [UserUtil getHXUserByClientId:from];
//            [UserUtil updatedUserFriendsWithCurrentUser:[HXUserAccountManager manager].userInfo targetUser:friend];
//            
//            /* show toast*/
//            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [displayWindow makeImppToast:NSLocalizedString(@"好友邀請同意", nil) navigationBarHeight:0];
//            });
//            
//            
//            [[NSNotificationCenter defaultCenter]postNotificationName:RefreshFriendList object:nil];
            
        }else if ([customData[@"type"] isEqualToString:@"send"]){
            
//            NSLog(@"received friend request ");
//            /* show toast*/
//            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [displayWindow makeImppToast:NSLocalizedString(@"收到好友邀請", nil) navigationBarHeight:0];
//            });
//            NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadFriendRequestCount"];
//            [[NSUserDefaults standardUserDefaults] setObject:@([unreadCount intValue]+1) forKey:@"unreadFriendRequestCount"];
//            [[NSNotificationCenter defaultCenter]postNotificationName:RefreshFriendList object:nil];
        }else{
            
//            NSNumber *unreadCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"unreadSocialNoticeCount"];
//            [[NSUserDefaults standardUserDefaults] setObject:@([unreadCount intValue]+1) forKey:@"unreadSocialNoticeCount"];
//            [[NSNotificationCenter defaultCenter]postNotificationName:UpdateFriendCircleBadge object:nil];
//            
//            UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [displayWindow makeImppToast:customData[@"notification_alert"] navigationBarHeight:0];
//            });
        }
        
        return;
    }
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:messageId
                                                          topicId:@""
                                                          message:@""
                                                          content:data
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    HXMessage *hxCustomMessage = [MessageUtil anIMMessageToHXMessage:customMessage];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveBinaryData:fileType:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveBinaryData:data
                                           fileType:fileType
                                         customData:customData
                                               from:from
                                            topicId:@""
                                          messageId:messageId
                                                 at:timestamp
                                      customMessage:[MessageUtil anIMMessageToHXMessage:customMessage]];
    }
    [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:hxCustomMessage.from];
}

- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:messageId
                                                          topicId:topicId
                                                          message:@""
                                                          content:data
                                                         fileType:fileType
                                                             from:from
                                                       customData:customData
                                                        timestamp:timestamp];
    
    if ([self.chatDelegate respondsToSelector:@selector(anIMDidReceiveBinaryData:fileType:customData:from:topicId:messageId:at:customMessage:)])
    {
        [self.chatDelegate anIMDidReceiveBinaryData:data
                                           fileType:fileType
                                         customData:customData
                                               from:from
                                            topicId:topicId
                                          messageId:messageId
                                                 at:timestamp
                                      customMessage:[MessageUtil anIMMessageToHXMessage:customMessage]];
    }
    [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
    
}

- (void)anIM:(AnIM *)anIM didReceiveNotice:(NSString *)notice customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    
//    if (self.noticeDelegate) {
//        [self.noticeDelegate anIMDidReceiveNotice:notice customData:customData from:from topicId:topicId messageId:messageId at:timestamp];
//    }
}

- (void)anIM:(AnIM *)anIM messageRead:(NSString *)messageId from:(NSString *)from
{
    [MessageUtil updateRemoteMessageReadAckByMessageId:messageId];
    //add notificaiton update badge
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ReceiveRemoteReadAck" object:messageId];
}



// it is for receiving message receive acknowledgment
- (void)anIM:(AnIM *)anIM messageReceived:(NSString *)messageId
{
    NSLog(@"it means the message with this messageId is already delivered to the recipient");
}



- (void)sendRequest:(NSString *)path
             method:(AnSocialManagerMethod)method
             params:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
            failure:(void (^)(NSDictionary *response))failure
{
    int methodInt = method;
    [self.anSocial sendRequest:path
                        method:methodInt
                        params:params
                       success:^(NSDictionary *response) {
                           success(response);
                       } failure:^(NSDictionary *response) {
                           failure(response);
                       }];
}



#pragma mark - Message
- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId at:(NSNumber *)timestamp {
    NSLog(@"message %@ is sent at %@",messageId,timestamp);
    [self.chatDelegate messageSent:messageId];
}


- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception{
    NSLog(@"%@",status? @"yes":@"no");
    NSLog(@"AnIM status changed: %i", status);
    _imConnecting = NO;
    _clientStatus = status;
    //if (self.isAppEnterBackground)return;
    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:@"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod" forKey:@"key"];
//    [params setObject:[JKLightspeedManager manager].clientId forKey:@"client"];
//    
//    [self sendRequest:@"http://api.lightspeedmbs.com/v1/im/client_status.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
//        NSLog(@"success log: %@",[response description]);
//    }
//    failure:^(NSDictionary *response) {
//        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
//    }];
    
    
    if (!status)
    {
//        UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [displayWindow makeImppToast:@"IM Disconnect" navigationBarHeight:0];
//            [self performSelector:@selector(checkIMConnection) withObject:nil afterDelay:5.0];
//        });
        
    }else{
        
//        UIWindow *displayWindow = [[[UIApplication sharedApplication] delegate] window];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [displayWindow makeImppToast:@"IM Connect" navigationBarHeight:0];
//        });
        /* just get topic once */
//        if (!self.isGetTopicList) {
//            [self.anIM getMyTopics];
//            self.isGetTopicList = YES;
//        }
//        
        //[MessageUtil getOfflineChatHistory];
        //[MessageUtil getOfflineTopicHistory];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"connect" object:nil];
    }
    

}

- (void)checkIMConnection
{
    if (!self.clientId.length) return;
    
    if (!_clientStatus )
    {
        NSLog(@"IM Connecting ...");
        //_imConnecting = YES;
        
        [self.anIM connect:self.clientId];
    }

    else
    {
        NSLog(@"IM is connected");
    }
    
}

@end
