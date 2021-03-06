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
#import "JKActivityControlView.h"

@interface JKProfileViewController ()
//@property (nonatomic, strong) AnSocial *anSocial;
@property (nonatomic,strong) JKActivityControlView *indicator;
@end

@implementation JKProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //_anSocial = [[AnSocial alloc]initWithAppKey:LIGHTSPEED_APP_KEY];
    _nameLabel.text = [_friendInfo objectForKey:@"username"];
    _indicator = [[JKActivityControlView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 50, 50)];
    
    
    [self getUserInfo];

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
    [self.view addSubview:_indicator];
    [_indicator activityStart];
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:[JKLightspeedManager manager].userId forKey:@"user_id"];
    [params setObject:[_friendInfo objectForKey:@"id"]  forKey:@"target_user_id"];
    
    [[JKLightspeedManager manager] sendRequest:@"friends/add.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
         dispatch_async(dispatch_get_main_queue(), ^{
             //_addToFriendButton.titleLabel.text = @"Already a Friend";
             _addToFriendButton.enabled = NO;
             [_indicator activityStop];
             [_indicator removeFromSuperview];
         });

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
         
         
         for (id friend in [[response objectForKey:@"response"]objectForKey:@"friends"]) {
             if ([[friend objectForKey:@"id"] isEqualToString:[_friendInfo objectForKey:@"id"]]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     _addToFriendButton.enabled = NO;
                     //_addToFriendButton.titleLabel.text = @"Already a Friend";
                 });
             }
         }
         
         
     } failure:^(NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
     }];
}

//- (void)getUserInfo{
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:[_friendInfo objectForKey:@"username"] forKey:@"username"];
//    
//    [[JKLightspeedManager manager] sendRequest:@"objects/User/query.json" method:AnSocialManagerGET params:params success:^
//     (NSDictionary *response) {
//         
//         NSLog(@"key: %@ ,value: %@",@"response",[response objectForKey:@"response"]);
//         dispatch_async(dispatch_get_main_queue(), ^{
//             _experienceLabel.text = [[[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0]objectForKey:@"experience"];
//             _ageGroupLabel.text = [[[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0] objectForKey:@"award"];
//             _levelLabel.text = [[[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0] objectForKey:@"level"];
//             _locationLabel.text = [[[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0] objectForKey:@"location"];
//         });
//         
//         
//     } failure:^(NSDictionary *response) {
//         for (id key in response)
//         {
//             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//         }
//     }];
//}

- (void)getUserInfo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[_friendInfo objectForKey:@"username"] forKey:@"username"];
    //[params setObject:@"4.0" forKey:@"level"];
    
    [[JKLightspeedManager manager] sendRequest:@"objects/MemberInfo/search.json" method:AnSocialManagerGET params:params success:^
     (NSDictionary *response) {
         NSLog(@"key: %@ ",response);
         NSUInteger i = [[[response objectForKey:@"response"]objectForKey:@"MemberInfos"] count];
         if (!i) {
             NSLog(@"no object");
         }
         else{
             //NSLog(@"key: %@ ,value: %@",@"response",[response objectForKey:@"response"]);
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSDictionary *responseObject = [[[response objectForKey:@"response"]objectForKey:@"MemberInfos"]objectAtIndex:0];
                 _experienceLabel.text = [responseObject objectForKey:@"experience"]? [responseObject objectForKey:@"experience"]:@"";
                 _ageGroupLabel.text = [responseObject objectForKey:@"ageGroup"]? [responseObject objectForKey:@"ageGroup"]:@"";
                 _levelLabel.text = [responseObject objectForKey:@"ratingNTRP"]? [responseObject objectForKey:@"ratingNTRP"]:@"";
                 _locationLabel.text = [responseObject objectForKey:@"preferedLocations"]? [responseObject objectForKey:@"preferedLocations"]:@"";
                 [_indicator activityStop];
                 [_indicator removeFromSuperview];
             });
         }
         
         
         
     } failure:^(NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
     }];
}


@end
