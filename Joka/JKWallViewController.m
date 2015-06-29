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


@property (nonatomic,strong) NSMutableArray *likeArray;
@end

@implementation JKWallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postArray = [[NSMutableArray alloc]initWithCapacity:0];
     
     self.likeArray = [[NSMutableArray alloc]initWithCapacity:0];
     
     
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideBarButton setTarget: self.revealViewController];
        [self.sideBarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    //[self queryWallPosts];
}

- (void)viewWillAppear:(BOOL)animated{
    [self queryWallPosts];
    [self queryLikes];
     
     [self queryLiked];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
             [self.wallTableView reloadData];
         });
     } failure :^( NSDictionary  * response )  {
         for  ( id key in response )
         {
             NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
         }
     }];
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
    
    //    [cell.postCreatorName setFrame:CGRectMake(cell.frame.origin.x+8, cell.frame.origin.y+8, 100, 21)];
    //    [cell.postTextView setFrame:CGRectMake(cell.frame.origin.x+8, cell.frame.origin.y+37, cell.frame.size.width - 16, 100)];
    //    [cell.likeButton setFrame:CGRectMake(cell.frame.origin.x+8, cell.frame.origin.y+147, 46, 30)];
    //    [cell.likes setFrame:CGRectMake(cell.frame.origin.x+64, cell.frame.origin.y+147, 100, 28)];
    //    [cell.comments setFrame:CGRectMake(cell.frame.origin.x+164, cell.frame.origin.y+147, 100, 28)];
    //    [cell.createAt setFrame:CGRectMake(cell.frame.origin.x+264, cell.frame.origin.y+147, 100, 28)];
    //
     
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

- (void)yourButtonClicked:(UIButton*)sender{
    if (sender.selected == YES) {
//         NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//         [params setObject:@"Post" forKey:@"object_type"];
//         [params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
//         [params setObject:@"false" forKey:@"like"];
//         sender.selected = NO;
//         [[JKLightspeedManager manager] sendRequest:@"likes/create.json" method:AnSocialManagerPOST params:params success:^
//          (NSDictionary *response) {
//               for (id key in response)
//               {
//                    NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//               }
//               NSLog(@"post: %@ liked",[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] );
//               dispatch_async(dispatch_get_main_queue(), ^{
//                    //sender.userInteractionEnabled = NO;
//                    
//                    [self queryWallPosts];
//               });
//          } failure:^(NSDictionary *response) {
//               for (id key in response)
//               {
//                    NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
//               }
//          }];
         
         for (id liked in _likeArray) {
              if ([liked objectForKey:@"parentId"] == [[_likeArray objectAtIndex:sender.tag] objectForKey:@"id"]) {
                   NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                   [params setObject:@"Post" forKey:@"object_type"];
                   [params setObject:[liked objectForKey:@"parentId"] forKey:@"object_id"];
                   [params setObject:@"true" forKey:@"like"];
                   
                   
                   [[JKLightspeedManager manager] sendRequest:@"likes/delete.json" method:AnSocialManagerPOST params:params success:^
                    (NSDictionary *response) {
                         for (id key in response)
                         {
                              NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
                         }
                         NSLog(@"unliked");
                         
                         
                    } failure:^(NSDictionary *response) {
                         for (id key in response)
                         {
                              NSLog(@"key: %@ ,value: %@",key,[response objectForKey:key]);
                         }
                    }];
                   
              }
         }
         dispatch_async(dispatch_get_main_queue(), ^{
              //sender.userInteractionEnabled = NO;
              
              [self queryWallPosts];
         });
         
         
         
         
         
         
         
         
    }else{
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:@"Post" forKey:@"object_type"];
        [params setObject:[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] forKey:@"object_id"];
        [params setObject:@"true" forKey:@"like"];
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



-(void)queryLikes{
    NSMutableDictionary  * params  =  [[ NSMutableDictionary alloc ] init ];
    [ params setObject :@"Wall" forKey:@"object_type" ];
    [ params setObject :@"558a60d356a7c98a9b000001"  forKey:@"object_id"];
    [ params setObject :[JKLightspeedManager manager].userId forKey :@ "user_id" ];
    
    [[JKLightspeedManager manager] sendRequest :@ "likes/query.json" method : AnSocialManagerGET  params : params success :^
     ( NSDictionary  * response )  {
         NSLog(@"================Query for user likes!=============");
         for  ( id key in response )
         {
             NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
         }
         NSLog(@"================Query for user likes!=============");
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
     [params setObject :[JKLightspeedManager manager].userId forKey :@ "target_user_id" ];
     
     [[JKLightspeedManager manager] sendRequest :@ "likes/query.json" method : AnSocialManagerGET  params : params success :^
      ( NSDictionary  * response )  {
           for  ( id key in response )
           {
                NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
           }
           _likeArray = [response objectForKey:@"likes"];
           NSLog(@"likeArray:%@",_likeArray);
           
           
           //               NSLog(@"post: %@ unliked",[[_postArray objectAtIndex:sender.tag] objectForKey:@"id"] );
           //               dispatch_async(dispatch_get_main_queue(), ^{
           //                    //sender.userInteractionEnabled = NO;
           //
           //                    [self queryWallPosts];
           //               });
           
      } failure :^( NSDictionary  * response )  {
           for  ( id key in response )
           {
                NSLog (@ "key: %@ ,value: %@" , key ,[ response objectForKey : key ]);
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
