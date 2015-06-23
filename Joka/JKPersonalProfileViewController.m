//
//  JKPersonalProfileViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKPersonalProfileViewController.h"
#import "JKLightspeedManager.h"
#import "JKEnterUserInfoViewController.h"
@interface JKPersonalProfileViewController ()

@end

@implementation JKPersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameLabel.text = [JKLightspeedManager manager].username;
    self.userIDLabel.text = [JKLightspeedManager manager].userId;
    [self getUserInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getUserInfo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    //[params setObject:@"4.0" forKey:@"level"];
    
    [[JKLightspeedManager manager] sendRequest:@"objects/User/search.json" method:AnSocialManagerGET params:params success:^
     (NSDictionary *response) {
         
         NSLog(@"key: %@ ,value: %@",@"response",[response objectForKey:@"response"]);
         dispatch_async(dispatch_get_main_queue(), ^{
             NSDictionary *responseObject = [[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0];
             _experienceLabel.text = [responseObject objectForKey:@"experience"]? [responseObject objectForKey:@"experience"]:@"";
             _awardLabel.text = [responseObject objectForKey:@"award"]? [responseObject objectForKey:@"award"]:@"";
             _levelLabel.text = [responseObject objectForKey:@"level"]? [responseObject objectForKey:@"level"]:@"";
             _locationLabel.text = [responseObject objectForKey:@"location"]? [responseObject objectForKey:@"location"]:@"";
         });
         
         
     } failure:^(NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
     }];
}

- (IBAction)editProfileInfo:(id)sender {
    [self performSegueWithIdentifier:@"editSegue" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
