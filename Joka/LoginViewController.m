//
//  LoginViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "LoginViewController.h"
#import "JKLightspeedManager.h"
#import "JKActivityControlView.h"

@interface LoginViewController ()
@property (nonatomic,strong) JKActivityControlView *indicator;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //_anSocial = [[AnSocial alloc]initWithAppKey:@"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod"];
    [self.usernameText becomeFirstResponder];
    _indicator = [[JKActivityControlView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 50, 50)];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.usernameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}

- (void)returnKeyBoardTapped
{
    [self.usernameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonPressed:(id)sender {
    [self.usernameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self createUser];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.usernameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
    [self userLogin];
}


- (void)createUser {
    [self.view addSubview:_indicator];
    [_indicator activityStart];
    
    
    
    if (!(self.usernameText.text.length && self.passwordText.text.length)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [_indicator activityStop];
        [_indicator removeFromSuperview];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_usernameText.text forKey:@"username"];
    [params setObject:_passwordText.text forKey:@"password"];
    [params setObject:_passwordText.text forKey:@"password_confirmation"];
    
    // get talk client ID
    [params setObject:@"true" forKey:@"enable_im"];
    
    //從相簿取出圖片
//    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
//    AnSocialFile* file = [AnSocialFile createWithFileName:@"test.jpg" data:imageData];
//    [params setObject:file forKey:@"photo"];
//    [params setObject:@"image/png" forKey:@"mime_type"];
    
    [[JKLightspeedManager manager] sendRequest:@"users/create.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         NSLog(@"success log: %@",[response description]);
         NSString *userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
         NSString *clientId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"clientId"];
         NSString *userName = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"username"];
         
         NSLog(@"User created, user id is: %@", userId);
         NSLog(@"User client id is: %@", clientId);
         
         [JKLightspeedManager manager].userId = userId;
         [JKLightspeedManager manager].username = userName;
         [JKLightspeedManager manager].clientId = clientId;
         
         //NSDictionary *user = [[response objectForKey:@"response"] objectForKey:@"user"];
//         [[NSUserDefaults standardUserDefaults] setObject:@{@"userId": userId ? userId : @"",
//                                                            @"userName": userName ? userName : @"",
//                                                            @"clientId": clientId ? clientId : @""}
//                                                   forKey:@"lastLoggedInUser"];
//         [self performSegueWithIdentifier:@"SigninSegue" sender:self];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [[JKLightspeedManager manager] checkIMConnection];
             [_indicator activityStop];
             [_indicator removeFromSuperview];
             
             
             
         });
         UIViewController *profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"SWView"];
         [self showViewController:profileView sender:self];
         
     } failure:^(NSDictionary *response) {
         NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
         
         if ([response objectForKey:@"meta"]) {
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                             message:[[response objectForKey:@"meta"] objectForKey:@"message"]
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil, nil];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [alert show];
                 [_indicator activityStop];
                 [_indicator removeFromSuperview];
             });
         }
     }];
}

- (void)userLogin {
//    [_indicator activityStart];
//    [self.view addSubview:_indicator];
//    
    if (!(self.usernameText.text.length && self.passwordText.text.length)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        [_indicator activityStop];
        [_indicator removeFromSuperview];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.usernameText.text forKey:@"username"];
    [params setObject:self.passwordText.text forKey:@"password"];
    

    
    [[JKLightspeedManager manager] sendRequest:@"users/auth.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSString *userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSString *clientId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"clientId"];
        NSString *userName = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"username"];
        NSLog(@"User created, user id is: %@", userId);
        NSLog(@"User client id is: %@", clientId);
        
        [JKLightspeedManager manager].userId = userId;
        [JKLightspeedManager manager].username = userName;
        [JKLightspeedManager manager].clientId = clientId;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [[JKLightspeedManager manager] checkIMConnection];
//        });
        //[[JKLightspeedManager manager].anIM connect:[JKLightspeedManager manager].clientId];
        //NSDictionary *user = [[response objectForKey:@"response"] objectForKey:@"user"];
        
//        [[NSUserDefaults standardUserDefaults] setObject:@{@"userId": userId ? userId : @"",
//                                                           @"userName": userName ? userName : @"",
//                                                           @"clientId": clientId ? clientId : @""}
//                                                  forKey:@"lastLoggedInUser"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[JKLightspeedManager manager] checkIMConnection];
            [_indicator activityStop];
            [_indicator removeFromSuperview];
//            UIViewController *profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"SWView"];
//            [self showViewController:profileView sender:self];
            dispatch_queue_t myBackgroundQ = dispatch_queue_create("backgroundDelayQueue", NULL);
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC);
            dispatch_after(delay, myBackgroundQ, ^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"showMainView" sender:self];
                });
            });
            
            
            
//
//            
//            [params setObject:@"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod" forKey:@"key"];
//            [params setObject:[JKLightspeedManager manager].clientId forKey:@"client"];
//            
//            [[JKLightspeedManager manager] sendRequest:@"http://api.lightspeedmbs.com/v1/im/client_status.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
//                NSLog(@"success log: %@",[response description]);
//                
//                
//            } failure:^(NSDictionary *response) {
//                NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
//            }];
        });
        
        //[self performSegueWithIdentifier:@"LoginSegue" sender:self];
        
    } failure:^(NSDictionary *response) {
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
        if ([response objectForKey:@"meta"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[[response objectForKey:@"meta"] objectForKey:@"message"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_indicator activityStop];
                [_indicator removeFromSuperview];
                [alert show];
                
            });
        }
    }];
}

//- (void)checkUserData {
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:@"51fc911692597a0000000001" forKey:@"user_ids"];
//    
//    [_anSocial sendRequest:@"users/get.json" method:AnSocialMethodGET params:params success:^
//     (NSDictionary *response) {
//         for (id key in response)
//         {
//             NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//         }
//         //[self handleSucc:response]; 處理成功的方法
//         
//     } failure:^(NSDictionary *response) {
//         //[self handleFailure:response]; 處理失敗的方法
//     }];
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
