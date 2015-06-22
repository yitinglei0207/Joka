//
//  JKProfileViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/18.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKProfileViewController.h"
#import "AnSocial.h"
#import "JokaCredentials.h"
#import "JKChatViewController.h"
#import "JKLightspeedManager.h"

@interface JKProfileViewController ()
//@property (nonatomic, strong) AnSocial *anSocial;
@end

@implementation JKProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //_anSocial = [[AnSocial alloc]initWithAppKey:LIGHTSPEED_APP_KEY];
    _nameLabel.text = [_friendInfo objectForKey:@"username"];
    
    

    [self checkIfAlreadyIsFriend];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    JKChatViewController *chatView = [segue destinationViewController];
    //chatView.hidesBottomBarWhenPushed = YES;
    chatView.friendInfo = self.friendInfo;
    //self.friendChatting = [self.friendsArray[self.tableView.indexPathForSelectedRow.row] objectForKey:@"clientId"];
}



- (IBAction)addToFriendButtonTapped:(id)sender {
    [self addToFriend];
}



- (void)addToFriend {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[JKLightspeedManager manager].userId forKey:@"user_id"];
    [params setObject:[_friendInfo objectForKey:@"id"]  forKey:@"target_user_id"];
    
    [[JKLightspeedManager manager] sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
         _addToFriendButton.titleLabel.text = @"Already a Friend";
         _addToFriendButton.enabled = NO;
     } failure:^(NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
     }];
}

- (void)checkIfAlreadyIsFriend {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].userId forKey:@"user_id"];
    
    [[JKLightspeedManager manager] sendRequest:@"friends/list.json" method:AnSocialManagerGET params:params success:^
     (NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             for (id friend in [[response objectForKey:@"response"]objectForKey:@"friends"]) {
                 if ([[friend objectForKey:@"id"] isEqualToString:[_friendInfo objectForKey:@"id"]]) {
                     _addToFriendButton.enabled = NO;
                     //_addToFriendButton.titleLabel.text = @"Already a Friend";
                 }
             }
         });
         
         
     } failure:^(NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
     }];
}

@end
