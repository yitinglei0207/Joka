//
//  JKCreatePostViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/24.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKCreatePostViewController.h"
#import "JKLightspeedManager.h"
#import "JokaCredentials.h"
//#import "SWRevealViewController.h"

@interface JKCreatePostViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end

@implementation JKCreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendPost:(id)sender {
    [self finishButtonTapped];
}


#pragma mark - Listener

- (void)messageTextViewTapped
{
//    [self.collectionView removeGestureRecognizer:self.messageTextViewTap];
    [self.messageTextView resignFirstResponder];
}

- (void)finishButtonTapped
{
    [self.messageTextView resignFirstResponder];
    [self createPost];

}


- (void)createPost
{
    
    NSMutableDictionary *params = [@{@"title":@"_EMPTY_",
                                     @"type":@"normal",
                                     @"user_id":[JKLightspeedManager manager].userId,
                                     @"wall_id":LIGHTSPEED_WALL_ID,
                                     @"content":self.messageTextView.text}mutableCopy];
    
    [[JKLightspeedManager manager]sendRequest:@"posts/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary *response){
        NSLog(@"post data :%@",[response description]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self successPost];
        });
        
    } failure:^(NSDictionary *response){
        //[self.load removeFromSuperview];
        NSLog(@"fail to post data :%@",[response description]);
    }];
}

- (void)successPost
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"RefreshWall" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
-(void) textViewDidChange:(UITextView *)textView
{
//    if (self.messageTextView.text.length)
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    else if(self.photosArray.count <= 1)
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    [self.collectionView addGestureRecognizer:self.messageTextViewTap];
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
