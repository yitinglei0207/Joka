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
@property BOOL isNew;
@property (nonatomic,strong) NSString *getObjectID;
@end

@implementation JKEnterUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEnteringInfo:(id)sender {
    if (_isNew) {
        [self createUserInfo];
    }
    else{
        [self updateUserInfo];
    }
    
    [self performSegueWithIdentifier:@"doneEnteringSegue" sender:self];
    
}
- (void)getUserInfo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    //[params setObject:@"4.0" forKey:@"level"];
    
    [[JKLightspeedManager manager] sendRequest:@"objects/User/search.json" method:AnSocialManagerGET params:params success:^
     (NSDictionary *response) {
         if (![[response objectForKey:@"response"]objectForKey:@"Users"]) {
             NSLog(@"no object");
             dispatch_async(dispatch_get_main_queue(), ^{
                 _isNew = YES;
             });
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSDictionary *responseObject = [[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0];
                 
                 _getObjectID = [responseObject objectForKey:@"id"];
                 _experienceText.text = [responseObject objectForKey:@"experience"]? [responseObject objectForKey:@"experience"]:@"";
                 _awardText.text = [responseObject objectForKey:@"award"]? [responseObject objectForKey:@"award"]:@"";
                 _levelText.text = [responseObject objectForKey:@"level"]? [responseObject objectForKey:@"level"]:@"";
                 _locationText.text = [responseObject objectForKey:@"location"]? [responseObject objectForKey:@"location"]:@"";
             });
         }
         //NSLog(@"key: %@ ,value: %@",@"response",[response objectForKey:@"response"]);
         
         
         
     } failure:^(NSDictionary *response) {
         NSLog(@"failed or is new");
         dispatch_async(dispatch_get_main_queue(), ^{
             _isNew = YES;
         });
     }];
}

- (void)createUserInfo {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    if (_experienceText.text) {
        [params setObject:_experienceText.text forKey:@"experience"];
    }else{
        [params setObject:@"" forKey:@"experience"];
    }
    if (_levelText.text) {
        [params setObject:_levelText.text forKey:@"level"];
    }else{
        [params setObject:@"" forKey:@"level"];
    }
    if (_awardText.text) {
        [params setObject:_awardText.text forKey:@"award"];
    }else{
        [params setObject:@"" forKey:@"award"];
    }
    if (_locationText.text) {
        [params setObject:_locationText.text forKey:@"location"];
    }else{
        [params setObject:@"" forKey:@"location"];
    }

    
    [[JKLightspeedManager manager] sendRequest:@"objects/User/create.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
             NSLog(@"UserInfo created");
     } failure:^(NSDictionary *response) {
             NSLog(@"UserInfo creating failed");
     }];
}


- (void)updateUserInfo {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_getObjectID forKey:@"object_id"];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    if (_experienceText.text) {
        [params setObject:_experienceText.text forKey:@"experience"];
    }else{
        [params setObject:@"" forKey:@"experience"];
    }
    if (_levelText.text) {
        [params setObject:_levelText.text forKey:@"level"];
    }else{
        [params setObject:@"" forKey:@"level"];
    }
    if (_awardText.text) {
        [params setObject:_awardText.text forKey:@"award"];
    }else{
        [params setObject:@"" forKey:@"award"];
    }
    if (_locationText.text) {
        [params setObject:_locationText.text forKey:@"location"];
    }else{
        [params setObject:@"" forKey:@"location"];
    }

    
    [[JKLightspeedManager manager] sendRequest:@"objects/User/update.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         NSLog(@"UserInfo updated");
     } failure:^(NSDictionary *response) {
         NSLog(@"UserInfo updating failed");
         for (id key in response) {
             NSLog(@"%@",response);
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
