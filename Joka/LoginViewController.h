//
//  LoginViewController.h
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnSocial.h"
#import "AnSocial.h"
#import "AnSocialFile.h"//用來上傳文件或照片

@interface LoginViewController : UIViewController

@property (nonatomic,strong) AnSocial *anSocial;
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end
