 //
//  JKChatViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/18.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "JKChatViewController.h"
#import "AnIMMessage.h"
#import "JokaCredentials.h"
#import "JKLightspeedManager.h"

@interface JKChatViewController () <AnIMDelegate,JKLightspeedManagerChatDelegate>
//@property (nonatomic, strong)AnIM *anIM;
@property (nonatomic, strong)NSMutableArray *messagesArray;
//@property (nonatomic, strong)NSString *clientID1;
//@property (nonatomic, strong)NSString *clientID2;
@end

@implementation JKChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification)
                                                 name:@"co.herxun.Joka.didReceiveMessage"
                                               object:nil];
    //[[[JKLightspeedManager manager]anIM] connect:[JKLightspeedManager manager].clientId];
    
    [[JKLightspeedManager manager] checkIMConnection];
    //_anIM = [[AnIM alloc] initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
    //[[JKLightspeedManager manager].anIM getClientId:[JKLightspeedManager manager].userId];
    //_anIM = [[JKLightspeedManager manager] anIM];
    //_anIM = [[AnIM alloc] initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
    NSLog(@"%@",[[JKLightspeedManager manager] anIM]);
    //_clientID1 = [JKLightspeedManager manager].clientId;
    //_clientID2 = [_friendInfo objectForKey:@"clientId"];
    //NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastLoggedInUser"];
    
    [_messageTextField setDelegate:self];
    
    
    self.navigationItem.title = [self.friendInfo objectForKey:@"username"];
    [JKLightspeedManager manager].chatDelegate = self;
    
    [self getChatHistory];
    // developers will get the clientId in
    // - (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId error:(NSString *)error;
}

- (void)viewWillAppear:(BOOL)animated {
    //[_anIM connect:_clientID1];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButton:(id)sender {
    [self sendMessage];
}

- (void)sendMessage {
    
    NSSet *clientIds = [NSSet setWithObjects:[_friendInfo objectForKey:@"clientId"], nil];
    [[[JKLightspeedManager manager] anIM] sendMessage:_messageTextField.text toClients:clientIds needReceiveACK:NO];
    self.messageTextField.text = @"";
}




- (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId error:(NSString *)error{
    
    
}



#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"messageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *messageLabel = (UILabel *)[cell viewWithTag:101];
    
    if ([self.messagesArray[indexPath.row] customData]) {
        if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"link"]) {
            messageLabel.text = [NSString stringWithFormat:@"[Link]"];
            messageLabel.textColor = UIColorFromRGB(0xea9c29);
        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"video"]) {
            messageLabel.text = [NSString stringWithFormat:@"[Video]"];
            messageLabel.textColor = UIColorFromRGB(0xec4f54);
        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"location"]) {
            messageLabel.text = [NSString stringWithFormat:@"[Location]"];
            messageLabel.textColor = UIColorFromRGB(0x27abb9);
        }
    } else if ([self.messagesArray[indexPath.row] message]) {
        messageLabel.text = [self.messagesArray[indexPath.row] message];
        messageLabel.textColor = [UIColor blackColor];
    } else {
        messageLabel.text = [self stringForCustomFileType:[self.messagesArray[indexPath.row] fileType]];
        messageLabel.textColor = UIColorFromRGB(0x7ca941);
    }
    
    if ([[self.messagesArray[indexPath.row] from] isEqualToString:[JKLightspeedManager manager].clientId]) {
        nameLabel.text = @"Me";
        nameLabel.textAlignment = NSTextAlignmentRight;
        messageLabel.textAlignment = NSTextAlignmentRight;
    } else {
        if (!_isTopicMode) {
            nameLabel.text = [self.friendInfo objectForKey:@"username"];
        } else {
            //nameLabel.text = [[HXLightspeedManager manager] getCircleFriendForClientId:[self.messagesArray[indexPath.row] from]][@"username"];
        }
        nameLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}


- (NSString *)stringForCustomFileType:(NSString *)fileType
{
    if ([fileType isEqualToString:@"image"])
        return @"[Image]";
    else
        return fileType;
    
}

#pragma mark - HXLightspeedManager Delegate & Notification

- (void)messageSent:(NSString *)messageId
{
    [self getChatHistory];
//    if (!_isTopicMode) {
//        [self getChatHistory];
//    } else {
//        [self getTopicHistory];
//        [[[HXLightspeedManager manager] anIM] getTopicInfo:self.topicInfo[@"id"]];
//    }
}



- (void)didReceiveMessageNotification
{
    [self getChatHistory];
//    if (!_isTopicMode) {
//        [self getChatHistory];
//    } else {
//        [self getTopicHistory];
//        [[[HXLightspeedManager manager] anIM] getTopicInfo:self.topicInfo[@"id"]];
//    }
}

- (void)talkDisconnected
{
//    if (_isTopicMode) {
//        [[[HXLightspeedManager manager] anIM] removeClients:[NSSet setWithObject:[HXLightspeedManager manager].clientId] fromTopicId:self.topicInfo[@"id"]];
//    }
}

- (void)didGetTopicInfo:(NSNotification *)notificaiton
{
//    self.topicInfo[@"name"] = notificaiton.object[@"topicName"];
//    self.topicInfo[@"parties"] = [notificaiton.object[@"parties"] allObjects];
//    self.topicInfo[@"parties_count"] = [NSNumber numberWithInt:[notificaiton.object[@"parties"] count]];
}



- (void)getChatHistory
{

        [[JKLightspeedManager manager].anIM getHistory:[NSSet setWithObject:[_friendInfo objectForKey:@"clientId"]]
                                                clientId:[JKLightspeedManager manager].clientId
                                                   limit:30
                                               timestamp:0
                                                 success:^(NSArray *messages) {
                                                     if (messages.count) {
                                                         self.messagesArray = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
                                                         [self.chatTable reloadData];
                                                     }
                                                 }
                                                 failure:^(ArrownockException *exception) {
                                                     NSLog(@"%@",exception);
                                                 }];

    }


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)getOfflineChatHistory{
    [[JKLightspeedManager manager].anIM getOfflineHistory:[NSSet setWithObject:[_friendInfo objectForKey:@"clientId"]] clientId:[JKLightspeedManager manager].clientId limit:30 success:^(NSArray *messages, int count) {
        if (messages.count) {
            self.messagesArray = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
            [self.chatTable reloadData];
        }
    } failure:^(ArrownockException *exception) {
        NSLog(@"%@",exception);
        
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
