//
//  LoginViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "LoginViewController.h"
#import "JKLightspeedManager.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //_anSocial = [[AnSocial alloc]initWithAppKey:@"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod"];
    [self.usernameText becomeFirstResponder];
    
    
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
    
    if (!(self.usernameText.text.length && self.passwordText.text.length)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
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
         [[NSUserDefaults standardUserDefaults] setObject:@{@"userId": userId ? userId : @"",
                                                            @"userName": userName ? userName : @"",
                                                            @"clientId": clientId ? clientId : @""}
                                                   forKey:@"lastLoggedInUser"];
         [self performSegueWithIdentifier:@"SigninSegue" sender:self];
         
         
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
             });
         }
     }];
}

- (void)userLogin {
    if (!(self.usernameText.text.length && self.passwordText.text.length)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
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
        
        UIViewController *profileView = [self.storyboard instantiateViewControllerWithIdentifier:@"SWView"];
        [self presentViewController:profileView animated:YES completion:nil];
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
