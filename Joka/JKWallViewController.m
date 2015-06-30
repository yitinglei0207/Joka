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

@interface JKWallViewController ()
@property (nonatomic,strong) NSMutableArray *postArray;
@property (weak, nonatomic) IBOutlet UITableView *wallTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
//@property (nonatomic,strong) NSMutableDictionary *likedDic;

@property (nonatomic,strong) NSMutableArray *likeArray;
@end

@implementation JKWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postArray = [[NSMutableArray alloc]initWithCapacity:0];
     
     self.likeArray = [[NSMutableArray alloc]initWithCapacity:0];
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
     
     if (_likeArray.count) {
          for (id likedpost in _likeArray) {
               if ([[likedpost objectForKey:@"parentId"]isEqualToString:[tempDic objectForKey:@"id"]]) {
                    if ([[likedpost objectForKey:@"positive"] integerValue] == 1) {
                         cell.likeButton.selected = YES;
                         cell.likeButton.customData = [likedpost objectForKey:@"id"];
                         break;
                    }else{
                         cell.likeButton.selected = NO;
                         cell.likeButton.customData = @"";
                    }
               }else{
                    cell.likeButton.selected = NO;
               }
          }
     }else{
          cell.likeButton.selected = NO;
     }
     
     
     NSNumber *likes = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"likeCount"];
     NSNumber *unlikes = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"dislikeCount"];

    
    cell.postTextView.text = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"content"];
    
    cell.postCreatorName.text = [[[_postArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"username"];
    cell.likes.text = [NSString stringWithFormat:@"%d likes",(likes.intValue - unlikes.intValue)];
    cell.comments.text = [NSString stringWithFormat:@"%@ comments",[[_postArray objectAtIndex:indexPath.row] objectForKey:@"commentCount"]];
    cell.createAt.text = [[_postArray objectAtIndex:indexPath.row] objectForKey:@"created_at"];
    cell.likeButton.tag = indexPath.row;
   
     [cell.likeButton addTarget:self action:@selector(yourButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)yourButtonClicked:(JKCustomButton*)sender{
    if (sender.selected == YES) {
//         NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//         [params setObject:@"Post" forKey:@"object_type"];
//         [params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
//         [params setObject:@"false" forKey:@"like"];
         sender.selected = NO;
         NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
         [params setObject:sender.customData forKey:@"like_id"];
         
         [[JKLightspeedManager manager] sendRequest:@"likes/delete.json" method:AnSocialManagerPOST params:params success:^
          (NSDictionary *response) {
               for (id key in response)
               {
                    NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
               }
               dispatch_async(dispatch_get_main_queue(), ^{
                    //sender.userInteractionEnabled = NO;
                    
                    [self queryWallPosts];
               });
          } failure:^(NSDictionary *response) {
               for (id key in response)
               {
                    NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
               }
          }];
         

//         for (id liked in _likeArray) {
//              if ([liked objectForKey:@"parentId"] == [[_likeArray objectAtIndex:sender.tag] objectForKey:@"id"]) {
//                   NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//                   [params setObject:@"Post" forKey:@"object_type"];
//                   [params setObject:[liked objectForKey:@"parentId"] forKey:@"object_id"];
//                   [params setObject:@"true" forKey:@"like"];
//                   
//                   
//                   [[JKLightspeedManager manager] sendRequest:@"likes/delete.json" method:AnSocialManagerPOST params:params success:^
//                    (NSDictionary *response) {
//                         for (id key in response)
//                         {
//                              NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//                         }
//                         NSLog(@"unliked");
//                         
//                         
//                    } failure:^(NSDictionary *response) {
//                         for (id key in response)
//                         {
//                              NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//                         }
//                    }];
//                   
//              }
//         }
         
         
         
    }else{
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:@"Post" forKey:@"object_type"];
        [params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
        [params setObject:@"true" forKey:@"like"];
         [params setObject:[JKLightspeedManager manager].userId forKey:@"user_id"];
        sender.selected = YES;
        [[JKLightspeedManager manager] sendRequest:@"likes/create.json" method:AnSocialManagerPOST params:params success:^
         (NSDictionary *response) {
             for (id key in response)
             {
                 NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
             }
             NSLog(@"post: %@ liked",[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] );
             dispatch_async(dispatch_get_main_queue(), ^{
                 //sender.userInteractionEnabled = NO;
                 
                 [self queryWallPosts];
             });
         } failure:^(NSDictionary *response) {
             for (id key in response)
             {
                 NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
             }
         }];
    }
    
    
    
}


- (void)queryWallPosts{
     
     NSDictionary *params = @{@"wall_id":LIGHTSPEED_WALL_ID,
                              @"limit":@99,
                              @"sort": @"-created_at"};
     [[JKLightspeedManager manager] sendRequest:@ "posts/query.json" method:AnSocialManagerGET params:params success:^
      ( NSDictionary  * response )  {
           //NSLog(@"Post data:%@",response);
           [self.postArray removeAllObjects];
           self.postArray = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"posts"]] mutableCopy];
           NSLog(@"postArray:\n %@ ",self.postArray);
           dispatch_async(dispatch_get_main_queue(), ^{
                 [self queryLiked];
           });
           
           
      } failure :^( NSDictionary  * response )  {
           for  ( id key in response )
           {
                NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
           }
      }];
     
}



//-(void)queryLikes{
//     
//     for (id posts in _postArray) {
//          NSMutableDictionary  * params  =  [[ NSMutableDictionary alloc ] init ];
//          [ params setObject :@"Wall" forKey:@"object_type" ];
//          //[ params setObject :[posts objectForKey:@"id"] forKey:@"object_id"];
//          [ params setObject :[JKLightspeedManager manager].userId forKey :@ "user_id" ];
//          
//          [[JKLightspeedManager manager] sendRequest :@ "likes/query.json" method : AnSocialManagerGET  params : params success :^
//           ( NSDictionary  * response )  {
//                NSLog(@"================Query for user likes!=============");
//                for  ( id key in response )
//                {
//                     NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
//                     if ([key objectForKey:@"positive"]) {
//                          [_likedDic setObject:@"YES" forKey:[key objectForKey:@"id"]];
//                     }
//                }
//                
//                NSLog(@"================Query for user likes!=============");
//                dispatch_async(dispatch_get_main_queue(), ^{
//                     [self.wallTableView reloadData];
//                     
//                });
//           } failure :^( NSDictionary  * response )  {
//                for  ( id key in response )
//                {
//                     NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
//                }
//           }];
//     }
//    
//}

-(void)queryLiked{
     NSMutableDictionary  * params  =  [[ NSMutableDictionary alloc ] init ];
     [params setObject :@ "Post" forKey :@ "object_type" ];
     //[params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
     [params setObject :[JKLightspeedManager manager].userId forKey :@ "user_id" ];
     [_likeArray removeAllObjects];
     [[JKLightspeedManager manager] sendRequest :@ "likes/query.json" method : AnSocialManagerGET  params : params success :^
      ( NSDictionary  * response )  {
           for  ( id key in response )
           {
                NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
           }
           _likeArray = [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"likes"]] mutableCopy];
          
           NSLog(@"likeArray:%@",_likeArray);
           
           dispatch_async(dispatch_get_main_queue(), ^{
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
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
