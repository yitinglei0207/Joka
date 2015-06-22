//
//  JKEnterUserInfoViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/22.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKEnterUserInfoViewController.h"
#import "JKLightspeedManager.h"

@interface JKEnterUserInfoViewController ()

@end

@implementation JKEnterUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEnteringInfo:(id)sender {
    [self updateUserInfo];
    [self performSegueWithIdentifier:@"doneEnteringSegue" sender:self];
    
}

- (void)updateUserInfo {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    [params setObject:_experienceText.text forKey:@"experience"];
    [params setObject:_levelText.text forKey:@"level"];
    [params setObject:_awardText.text forKey:@"award"];
    [params setObject:_locationText.text forKey:@"location"];
    
    [[JKLightspeedManager manager] sendRequest:@"objects/User/create.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         for (id key in response)
         {
             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
         }
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
