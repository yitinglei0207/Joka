//
//  JKFriendListViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/24.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKFriendListViewController.h"
#import "SWRevealViewController.h"
#import "JKLightspeedManager.h"

@interface JKFriendListViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableSet *unreadMessagesSet;
@property (strong, nonatomic) NSString *friendChatting;
@property (strong, nonatomic) NSMutableDictionary *clientStatus;
@end

@implementation JKFriendListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.friendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.unreadMessagesSet = [[NSMutableSet alloc] initWithCapacity:0];
    
    //_anSocial = [[AnSocial alloc]initWithAppKey:LIGHTSPEED_APP_KEY];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideBarButton setTarget: self.revealViewController];
        [self.sideBarButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    [JKLightspeedManager manager].chatDelegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveMessageNotification:) name:@"didReceivedMessage" object:nil];
    
    
    [self loadUser];
    /*
     NSString *appKey = @"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod";
     AnIM *anIM = [[AnIM alloc] initWithAppKey:appKey delegate:self secure:YES];
     
     NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userId"];
     [anIM getClientId:userId];
     
     [anIM connect:clientId];
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUser {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].userId forKey:@"user_id"];
    
    [[JKLightspeedManager manager] sendRequest:@"friends/list.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
        NSLog(@"success log: %@",[response description]);
        NSLog(@"Recieved friend list");
        self.friendsArray =  [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"friends"]] mutableCopy];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(NSDictionary *response) {
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
}

#pragma mark - Segue

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    JKProfileViewController *profileView = [segue destinationViewController];
//    //profileView.hidesBottomBarWhenPushed = YES;
//    profileView.friendInfo = self.friendsArray[self.tableView.indexPathForSelectedRow.row];
//    self.friendChatting = [self.friendsArray[self.tableView.indexPathForSelectedRow.row] objectForKey:@"clientId"];
//}




#pragma mark - TableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *newMessageLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *statusMessageLabel = (UILabel *)[cell viewWithTag:102];
    
    nameLabel.text = [self.friendsArray[indexPath.row] objectForKey:@"username"];
    newMessageLabel.text = @"";
    if ([self.unreadMessagesSet containsObject:[self.friendsArray[indexPath.row] objectForKey:@"clientId"]])
        newMessageLabel.text = @"New!";
    NSString *status = [self.clientStatus objectForKey:[self.friendsArray[indexPath.row] objectForKey:@"clientId"]];
    if (status) {
        if ([status isEqualToString:@"NO"]) {
            statusMessageLabel.text = @"Offline";
            statusMessageLabel.textColor = [UIColor lightGrayColor];
        } else {
            statusMessageLabel.text = @"Online";
            statusMessageLabel.textColor = [UIColor blackColor];
        }
    }
    else
        statusMessageLabel.text = @"";
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *newMessageLabel = (UILabel *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:101];
    if (newMessageLabel.text.length) {
        newMessageLabel.text = @"";
        NSString *selectedId = [self.friendsArray[indexPath.row] objectForKey:@"clientId"];
        [self.unreadMessagesSet removeObject:selectedId];
    }
}

- (void)didReceiveMessageNotification:(NSNotification*)notification
{
    NSDictionary *notificaitonObject = (NSDictionary *)(notification.object);
    if (![[notificaitonObject objectForKey:@"from"] isEqualToString:self.friendChatting]) {
        [self.unreadMessagesSet addObject:[notificaitonObject objectForKey:@"from"]];
        NSLog(@"From: %@", [notificaitonObject objectForKey:@"from"]);
        [self.tableView reloadData];
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
