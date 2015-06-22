//
//  JKPersonalProfileViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKPersonalProfileViewController.h"
#import "JKLightspeedManager.h"
@interface JKPersonalProfileViewController ()

@end

@implementation JKPersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameLabel.text = [JKLightspeedManager manager].username;
    self.userIDLabel.text = [JKLightspeedManager manager].userId;
    
    
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

@end
