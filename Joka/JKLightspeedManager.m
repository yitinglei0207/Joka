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

@interface JKLightspeedManager () <AnIMDelegate>
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
        if ([(NSObject *)self.chatDelegate respondsToSelector:@selector(didGetClientStatus:)]) {
            [self.chatDelegate didGetClientStatus:clientsStatus];
        }
    }
}

// it is for receiving message
- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    NSLog(@"the message is: %@", message);
    NSLog(@"the messageId is: %@", messageId);
    NSLog(@"the sender is: %@", from);
    //NSLog(@"all recipients, including the sender: %@", [parties componentsJoinedByString:@","]);
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Joka.didReceiveMessage"
                                                        object:@{@"message": message,
                                                                 @"customData": customData ? customData : @"",
                                                                 @"from": from,
                                                                 @"parties": parties,
                                                                 @"messageId": messageId,
                                                                 @"timestamp": timestamp}];
}

+ (JKLightspeedManager *)manager
{
    static JKLightspeedManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[JKLightspeedManager alloc] init];
    });
    return _manager;
}


- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId
{
    NSLog(@"Message sent");
    [self.chatDelegate messageSent:messageId];
}
// it is for receiving message receive acknowledgment
- (void)anIM:(AnIM *)anIM messageReceived:(NSString *)messageId
{
    NSLog(@"it means the message with this messageId is already delivered to the recipient");
}

// it is for receiving message read acknowledgment
- (void)anIM:(AnIM *)anIM messageRead:(NSString *)messageId from:(NSString *)from
{
    NSLog(@"it means the message with this messageId is already read by the recipient(from)");
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
- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId {
    NSLog(@"message %@ failed",messageId);
}


- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception{
    NSLog(@"%@",status? @"yes":@"no");
    NSLog(@"AnIM status changed: %i", status);
    _imConnecting = NO;
    _clientStatus = status;
    //if (self.isAppEnterBackground)return;
    
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
