//
//  JKFriendsViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKUserListViewController.h"
#import "AnIM.h"
#import "AnSocial.h"
#import "JokaCredentials.h"
#import "JKProfileViewController.h"
#import "JKLightspeedManager.h"
#import "SWRevealViewController.h"
#import "JKActivityControlView.h"

@interface JKUserListViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property (strong, nonatomic) NSMutableArray *userArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableSet *unreadMessagesSet;
@property (strong, nonatomic) NSString *friendChatting;
@property (strong, nonatomic) NSMutableDictionary *clientStatus;
@property (strong, nonatomic) NSMutableSet *clientIDset;
//@property (strong, nonatomic) AnSocial *anSocial;

@property (nonatomic,strong) JKActivityControlView *indicator;
@end

@implementation JKUserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.unreadMessagesSet = [[NSMutableSet alloc] initWithCapacity:0];
    self.clientIDset = [[NSMutableSet alloc] initWithCapacity:0];
    
    _indicator = [[JKActivityControlView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 50, 50)];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@"ZG4Nr4VrZM1sW8gWvUA64c7jd3XigTod" forKey:@"key"];
    [params setObject:[JKLightspeedManager manager].clientId forKey:@"client"];
    
    [[JKLightspeedManager manager] sendRequest:@"http://api.lightspeedmbs.com/v1/im/client_status.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
        NSLog(@"success log: %@",[response description]);
    }
              failure:^(NSDictionary *response) {
                  NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
              }];
    
    
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
    [JKLightspeedManager manager].chatDelegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUser {
    
    [self.view addSubview:_indicator];
    [_indicator activityStart];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@99 forKey:@"limit"];
    //[params setObject:[JKLightspeedManager manager].userId forKey:@"user_ids"];
    [[JKLightspeedManager manager] sendRequest:@"users/search.json" method:AnSocialManagerGET params:params success:^(NSDictionary *response) {
        NSLog(@"success log: %@",[response description]);
        NSLog(@"Recieved a list of users");
        self.userArray =  [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"users"]] mutableCopy];
        NSLog(@"%@",_userArray);
        
        
        //delete myself from list
        NSMutableArray *toDelete = [NSMutableArray array];
        for (id user in _userArray) {
            [_clientIDset addObject:[user objectForKey:@"clientId"]];
            
            if([[user objectForKey:@"username"]isEqualToString:[JKLightspeedManager manager].username]){
                [toDelete addObject:user];
            }
        }
        [_userArray removeObjectsInArray: toDelete];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [self getUserStatus];
            
            [self.tableView reloadData];
            [_indicator activityStop];
            [_indicator removeFromSuperview];
        });
        
    } failure:^(NSDictionary *response) {
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    }];
    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    JKProfileViewController *profileView = [segue destinationViewController];
    //profileView.hidesBottomBarWhenPushed = YES;
    profileView.friendInfo = self.userArray[self.tableView.indexPathForSelectedRow.row];
    self.friendChatting = [self.userArray[self.tableView.indexPathForSelectedRow.row] objectForKey:@"clientId"];
}




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
    return self.userArray.count;
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
    
    nameLabel.text = [self.userArray[indexPath.row] objectForKey:@"username"];
    newMessageLabel.text = @"";
    if ([self.unreadMessagesSet containsObject:[self.userArray[indexPath.row] objectForKey:@"clientId"]])
        newMessageLabel.text = @"New!";
    NSString *status = [self.clientStatus objectForKey:[self.userArray[indexPath.row] objectForKey:@"clientId"]];
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
        NSString *selectedId = [self.userArray[indexPath.row] objectForKey:@"clientId"];
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


-(void)getUserStatus{
    //NSSet  * clientIds =  [[ NSSet alloc ] initWithObjects :@ "thisisclientId_1" ,  @ "thisisclientId_2" ,  nil ];
    [[JKLightspeedManager manager].anIM getClientsStatus: _clientIDset];
    


}

- (void)didGetClientStatus:(NSDictionary *)clientStatus
{
    self.clientStatus = [NSMutableDictionary dictionaryWithDictionary:clientStatus];
    [self.tableView reloadData];
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
