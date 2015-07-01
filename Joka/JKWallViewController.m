//
//  JKWallViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/24.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKWallViewController.h"
#import "JKLightspeedManager.h"
#import "JokaCredentials.h"
#import "SWRevealViewController.h"
#import "JKWallTableViewCell.h"
#import "JKCreatePostViewController.h"
#import "JKCommentViewController.h"

@interface JKWallViewController ()
@property (nonatomic,strong) NSMutableArray *postArray;
@property (weak, nonatomic) IBOutlet UITableView *wallTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
//@property (nonatomic,strong) NSMutableDictionary *likedDic;
@property (nonatomic,strong) NSString *sendCommentId;
@property (nonatomic,strong) NSMutableArray *likeArray;
@property (nonatomic,strong) NSMutableArray *likeCountArray;
@end

@implementation JKWallViewController

- (void)viewDidLoad {
     [super viewDidLoad];
     // Do any additional setup after loading the view.
     self.postArray = [[NSMutableArray alloc]initWithCapacity:0];
     
     self.likeArray = [[NSMutableArray alloc]initWithCapacity:0];
     self.likeCountArray = [[NSMutableArray alloc]initWithCapacity:0];
     //self.likedDic = [[NSMutableDictionary alloc]initWithCapacity:0];
     
     SWRevealViewController *revealViewController = self.revealViewController;
     if ( revealViewController )
     {
          [self.sideBarButton setTarget: self.revealViewController];
          [self.sideBarButton setAction: @selector(revealToggle:)];
          [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
     }
     
}

- (void)viewWillAppear:(BOOL)animated{
     [self queryWallPosts];
     
     
     //[self queryLiked];
}

- (void)didReceiveMemoryWarning {
     [super didReceiveMemoryWarning];
     // Dispose of any resources that can be recreated.
}





#pragma mark - TableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return 180;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return self.postArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *cellIdentifier = @"postCell";
     
     JKWallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
     if (cell == nil) {
          cell = [[JKWallTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
     }
     NSDictionary *tempDic = [[NSDictionary alloc]initWithDictionary:[_postArray objectAtIndex:indexPath.row] ];
     NSLog(@"This cell is for Data:%@",tempDic);
     
     if (_likeArray.count) {
          for (id likedpost in _likeArray) {
               if ([[likedpost objectForKey:@"parentId"]isEqualToString:[tempDic objectForKey:@"id"]]) {
                    if ([[likedpost objectForKey:@"positive"] integerValue] == 1) {
                         //cell.likeButton.selected = YES;
                         [[_likeCountArray objectAtIndex:indexPath.row] setObject:[NSNumber numberWithBool:YES] forKey:@"liked"];
                         cell.likeButton.customData = [likedpost objectForKey:@"id"];
                         break;
                    }else{
                         //cell.likeButton.selected = NO;
                         cell.likeButton.customData = @"";
                    }
               }else{
                    //cell.likeButton.selected = NO;
               }
          }
     }else{
          //cell.likeButton.selected = NO;
     }
     NSNumber *liked = [[_likeCountArray objectAtIndex:indexPath.row]objectForKey:@"liked"];
     if (liked.boolValue == YES) {
          cell.likeButton.selected = YES;
          //cell.likeButton.customData = [likedpost objectForKey:@"id"];
     }else{
          cell.likeButton.selected = NO;
          //cell.likeButton.customData = @"";
     }
     
     NSNumber *likes = [[_likeCountArray objectAtIndex:indexPath.row]objectForKey:@"likeCount"];
     //NSNumber *unlikes = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"dislikeCount"];
     //cell.likeButton.likeIndexSaver = indexPath.row;
     cell.postId = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"id"];
     
     cell.postTextView.text = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"content"];
     
     cell.postCreatorName.text = [[[_postArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"username"];
     cell.likes.text = [NSString stringWithFormat:@"%d likes",likes.intValue];
     cell.comments.text = [NSString stringWithFormat:@"%@",[[_postArray objectAtIndex:indexPath.row] objectForKey:@"commentCount"]];
     cell.createAt.text = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"created_at"];
     cell.likeButton.tag = indexPath.row;
     cell.commentButton.cellId = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"id"];
     //[cell.likeButton addTarget:self action:@selector(yourButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
     [cell.commentButton addTarget:self action:@selector(commentsPressed:) forControlEvents:UIControlEventTouchUpInside];
     return cell;
}

- (void)yourButtonClicked:(JKCustomButton*)sender{
     if (sender.selected) {
          [sender setSelected:NO];
          sender.userInteractionEnabled = NO;
          
          
          NSMutableDictionary *changeLike = [[NSMutableDictionary alloc]initWithDictionary:[_postArray objectAtIndex:sender.tag]];
          if (_likeArray.count) {
               for (int i=0;i<_likeArray.count;i++) {
                    if ([[[_likeArray objectAtIndex:i] objectForKey:@"parentId"]isEqualToString:[changeLike objectForKey:@"id"]]) {
                         [_likeArray removeObjectAtIndex:i];
                    }
               }
          }
          
          NSNumber *likecount = [[NSNumber alloc]initWithInt:[[[_likeCountArray objectAtIndex:sender.tag] objectForKey:@"likeCount"] intValue] - 1];
          [[_likeCountArray objectAtIndex:sender.tag] setObject:[NSNumber numberWithBool:NO] forKey:@"liked"];
          [[_likeCountArray objectAtIndex:sender.tag] setObject:likecount forKey:@"likeCount"];

          NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
          [params setObject:sender.customData forKey:@"like_id"];
          
          [[JKLightspeedManager manager] sendRequest:@"likes/delete.json" method:AnSocialManagerPOST params:params success:^
           (NSDictionary *response) {
                for (id key in response)
                {
                     NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                     
//                     
//                     [self queryWallPosts];
//                });
                sender.userInteractionEnabled = YES;
           } failure:^(NSDictionary *response) {
                for (id key in response)
                {
                     NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
                }
           }];
          [self.wallTableView reloadData];

          
     }else{
          
          [sender setSelected:YES];
          sender.userInteractionEnabled = NO;
          

         
          NSNumber *likecount = [[NSNumber alloc]initWithInt:[[[_likeCountArray objectAtIndex:sender.tag] objectForKey:@"likeCount"] intValue] + 1];
          [[_likeCountArray objectAtIndex:sender.tag] setObject:[NSNumber numberWithBool:YES] forKey:@"liked"];
          [[_likeCountArray objectAtIndex:sender.tag] setObject:likecount forKey:@"likeCount"];
          
//          NSMutableDictionary *changeLike = [[NSMutableDictionary alloc]initWithDictionary:[_postArray objectAtIndex:sender.tag]];
//          [changeLike setObject:likecount forKey:@"likeCount"];
//          if (_likeArray.count) {
//               for (int i=0;i<_likeArray.count;i++) {
//                    if ([[[_likeArray objectAtIndex:i] objectForKey:@"parentId"]isEqualToString:[changeLike objectForKey:@"id"]]) {
//                         NSMutableDictionary *changePositive = [[NSMutableDictionary alloc]initWithDictionary:[_likeArray objectAtIndex:i]];
//                         [changePositive setObject:[NSNumber numberWithInt:1] forKey:@"positive"];
//                         [_likeArray setObject:changePositive atIndexedSubscript:i];
//                    }
//               }
//          }
          //[_postArray setObject:changeLike atIndexedSubscript:sender.tag] ;
          NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
          [params setObject:@"Post" forKey:@"object_type"];
          [params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
          [params setObject:@"true" forKey:@"like"];
          [params setObject:[JKLightspeedManager manager].userId forKey:@"user_id"];

          
          [[JKLightspeedManager manager] sendRequest:@"likes/create.json" method:AnSocialManagerPOST params:params success:^
           (NSDictionary *response) {
//                for (id key in response)
//                {
//                     NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//                }
                NSLog(@"post: %@ liked",[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] );
                dispatch_async(dispatch_get_main_queue(), ^{
                     //sender.userInteractionEnabled = NO;
                     [self queryLiked];
                });
                sender.userInteractionEnabled = YES;
           } failure:^(NSDictionary *response) {
                for (id key in response)
                {
                     NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
                }
           }];
          [self.wallTableView reloadData];
     }
     
     
     
}


- (void)queryWallPosts{
     
     NSDictionary *params = @{@"wall_id":LIGHTSPEED_WALL_ID,
                              @"limit":@99,
                              @"sort": @"-created_at"};
     [[JKLightspeedManager manager] sendRequest:@ "posts/query.json" method:AnSocialManagerGET params:params success:^
      ( NSDictionary  * response )  {
           //NSLog(@"Post data:%@",response);
           
           //NSLog(@"postArray:\n %@ ",self.postArray);
           dispatch_async(dispatch_get_main_queue(), ^{
                [self.postArray removeAllObjects];
                self.postArray = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"posts"]] mutableCopy];
                
                for (id post in _postArray) {
                     NSMutableDictionary *likedRecordingDic = [[NSMutableDictionary alloc]initWithCapacity:0];
                     [likedRecordingDic setObject:[post objectForKey:@"likeCount"] forKey:@"likeCount"];
                     [likedRecordingDic setObject:[NSNumber numberWithBool:NO] forKey:@"liked"];
                     [_likeCountArray addObject:likedRecordingDic];
                }
                [self queryLiked];
           });
           
           
      } failure :^( NSDictionary  * response )  {
           for  ( id key in response )
           {
                NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
           }
      }];
     
}


-(void)queryLiked{
     NSMutableDictionary  * params  =  [[ NSMutableDictionary alloc ] init ];
     [params setObject :@ "Post" forKey :@ "object_type" ];
     //[params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
     [params setObject :[JKLightspeedManager manager].userId forKey :@ "user_id" ];
     [_likeArray removeAllObjects];
     [[JKLightspeedManager manager] sendRequest :@ "likes/query.json" method : AnSocialManagerGET  params : params success :^
      ( NSDictionary  * response )  {
           dispatch_async(dispatch_get_main_queue(), ^{
                _likeArray = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"likes"]] mutableCopy];
                [self.wallTableView reloadData];
                //[self deleteAllLikes];
           });
           
      } failure :^( NSDictionary  * response )  {
           for  ( id key in response )
           {
                NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
           }
      }];
     
}

-(void)deleteAllLikes{
     for (id likes in _likeArray) {
          NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
          [params setObject:[likes objectForKey:@"id"] forKey:@"like_id"];
          
          [[JKLightspeedManager manager] sendRequest:@"likes/delete.json" method:AnSocialManagerPOST params:params success:^
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
     
     
}
- (void)commentsPressed:(JKCustomButton*)sender {
     
     self.sendCommentId = [[NSString alloc]initWithString:sender.cellId];
     [self performSegueWithIdentifier:@"Comment" sender:self];
}
- (IBAction)addPostPressed:(id)sender {
     [self performSegueWithIdentifier:@"AddPost" sender:self];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
     if ([segue.identifier isEqualToString:@"Comment"]) {
          JKCommentViewController *commentView = [segue destinationViewController];
          //commentView.commentOrPost = @"Comment";
          commentView.commentPostId = self.sendCommentId;
     }else{
          JKCreatePostViewController *postView = [segue destinationViewController];
          postView.commentOrPost = @"Post";
     }
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
