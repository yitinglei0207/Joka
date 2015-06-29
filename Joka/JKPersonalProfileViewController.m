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
#import "LoginViewController.h"
#import "SWRevealViewController.h"
#import "JKActivityControlView.h"

@interface JKPersonalProfileViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property (nonatomic,strong) JKActivityControlView *indicator;
@end

@implementation JKPersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[JKLightspeedManager manager] checkIMConnection];
    // Do any additional setup after loading the view.
    self.usernameLabel.text = [JKLightspeedManager manager].username;
    self.primaryHandLabel.text = [JKLightspeedManager manager].userId;
    _indicator = [[JKActivityControlView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 50, 50)];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideBarButton setTarget: self.revealViewController];
        [self.sideBarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:@"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod" forKey:@"key"];
//    [params setObject:[JKLightspeedManager manager].clientId forKey:@"client"];
//    
//    [[JKLightspeedManager manager] sendRequest:@"http://api.lightspeedmbs.com/v1/im/remove_clients.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
//        NSLog(@"success log: %@",[response description]);
//    }
//              failure:^(NSDictionary *response) {
//                  NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
//              }];
//    
//    
//   
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getUserInfo{
    [self.view addSubview:_indicator];
    [_indicator activityStart];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    //[params setObject:@"4.0" forKey:@"level"];
    
    [[JKLightspeedManager manager] sendRequest:@"objects/MemberInfo/search.json" method:AnSocialManagerGET params:params success:^
     (NSDictionary *response) {
         //NSLog(@"key: %@ ",response);
         NSUInteger i = [[[response objectForKey:@"response"]objectForKey:@"MemberInfos"] count];
         if (!i) {
             NSLog(@"no object");
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_indicator activityStop];
                 [_indicator removeFromSuperview];
             });
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

- (IBAction)editProfileInfo:(id)sender {
    [self performSegueWithIdentifier:@"editSegue" sender:self];
}
- (IBAction)deleteUser:(id)sender {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].userId forKey:@"user_ids"];
    
    [[JKLightspeedManager manager] sendRequest:@"users/delete.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
         LoginViewController *loginView = [[LoginViewController alloc]init];
         [self showViewController:loginView sender:self];
         
     } failure:^(NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
     }];
    
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
