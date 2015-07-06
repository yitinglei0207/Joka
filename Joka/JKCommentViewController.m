//
//  JKCommentViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/30.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKCommentViewController.h"
#import "JKLightspeedManager.h"
@interface JKCommentViewController ()
@property (weak, nonatomic) IBOutlet UITextField *commentText;
@property (weak, nonatomic) IBOutlet UITableView *commentTable;
@property (strong, nonatomic) NSMutableArray *commentsArray;

@end

@implementation JKCommentViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _commentsArray = [[NSMutableArray alloc]initWithCapacity:0];
    [_commentText setDelegate:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [self queryComments];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendComment:(id)sender {
    
        
        NSMutableDictionary *params = [@{@"object_type":@"Post",
                                         @"user_id":[JKLightspeedManager manager].userId,
                                         @"object_id":self.commentPostId,
                                         @"content":self.commentText.text
                                         }mutableCopy];
    
        [[JKLightspeedManager manager] sendRequest:@"comments/create.json" method:AnSocialManagerPOST params:params success:^
         (NSDictionary *response) {
             for (id key in response)
             {
                 NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self queryComments];
                 _commentText.text = @"";
             });
         } failure:^(NSDictionary *response) {
             for (id key in response)
             {
                 NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
             }
         }];
    
}


#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"commentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *commentLabel = (UILabel *)[cell viewWithTag:101];
    
    nameLabel.text = [[self.commentsArray[indexPath.row] objectForKey:@"user"]objectForKey:@"username"];
    commentLabel.text = [self.commentsArray[indexPath.row] objectForKey:@"content"];
//    if ([self.commentsArray[indexPath.row] customData]) {
//        if ([[[self.commentsArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"link"]) {
//            messageLabel.text = [NSString stringWithFormat:@"[Link]"];
//            messageLabel.textColor = UIColorFromRGB(0xea9c29);
//        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"video"]) {
//            messageLabel.text = [NSString stringWithFormat:@"[Video]"];
//            messageLabel.textColor = UIColorFromRGB(0xec4f54);
//        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"location"]) {
//            messageLabel.text = [NSString stringWithFormat:@"[Location]"];
//            messageLabel.textColor = UIColorFromRGB(0x27abb9);
//        }
//    } else if ([self.commentsArray[indexPath.row] message]) {
//        messageLabel.text = [self.commentsArray[indexPath.row] message];
//        messageLabel.textColor = [UIColor blackColor];
//    } else {
//        messageLabel.text = [self stringForCustomFileType:[self.messagesArray[indexPath.row] fileType]];
//        messageLabel.textColor = UIColorFromRGB(0x7ca941);
//    }
//    
//    if ([[self.messagesArray[indexPath.row] from] isEqualToString:[JKLightspeedManager manager].clientId]) {
//        nameLabel.text = @"Me";
//        
//        nameLabel.textAlignment = NSTextAlignmentRight;
//        messageLabel.textAlignment = NSTextAlignmentRight;
//    } else {
//        if (!_isTopicMode) {
//            nameLabel.text = [self.friendInfo objectForKey:@"username"];
//        } else {
//            //nameLabel.text = [[HXLightspeedManager manager] getCircleFriendForClientId:[self.messagesArray[indexPath.row] from]][@"username"];
//        }
//        nameLabel.textAlignment = NSTextAlignmentLeft;
//        messageLabel.textAlignment = NSTextAlignmentLeft;
//    }
    return cell;
}

-(void)queryComments{
    NSMutableDictionary  * params  =  [[ NSMutableDictionary alloc ] init ];
    [ params setObject :@ "Post" forKey :@ "object_type" ];
    [ params setObject :self.commentPostId forKey :@ "object_id" ];
    //[ params setObject :@ " 1425372027683" forKey :@ "begin_time" ];
    [_commentsArray removeAllObjects];
    [[JKLightspeedManager manager] sendRequest :@ "comments/query.json" method : AnSocialManagerGET  params : params success :^
     ( NSDictionary  * response )  {
         NSLog(@"=========================\n comments response:%@",response);
         //NSLog(@"_commentsArray = %@\n============================================",_commentsArray);
         dispatch_async(dispatch_get_main_queue(), ^{
             //NSLog(@"_commentsArray = %@\n============================================",_commentsArray);
             _commentsArray = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"comments"]] mutableCopy];
             NSLog(@"_commentsArray = %lu\n============================================",(unsigned long)_commentsArray.count);
             [self.commentTable reloadData];
         });
     } failure :^( NSDictionary  * response )  {
         for  ( id key in response )
         {
             NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
         } 
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
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
