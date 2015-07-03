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
#import "JKActivityControlView.h"
#import "KLCPopup.h"
#import "HXAnSocialManager.h"
#import <CoreData/CoreData.h>
#import "HXMessage.h"
#import "MessageUtil.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "HXMessageTableViewCell.h"
//#import "HXMapViewController.h"

typedef NS_ENUM(NSInteger, FieldTag) {
    FieldTagHorizontalLayout = 1001,
    FieldTagVerticalLayout,
    FieldTagMaskType,
    FieldTagShowType,
    FieldTagDismissType,
    FieldTagBackgroundDismiss,
    FieldTagContentDismiss,
    FieldTagTimedDismiss,
};


@interface JKChatViewController () <AnIMDelegate,JKLightspeedManagerChatDelegate,UIImagePickerControllerDelegate>
//@property (nonatomic, strong)AnIM *anIM;

{
    
    NSArray* _fields;
    NSDictionary* _namesForFields;
    
    NSArray* _horizontalLayouts;
    NSArray* _verticalLayouts;
    NSArray* _maskTypes;
    NSArray* _showTypes;
    NSArray* _dismissTypes;
    
    NSDictionary* _namesForHorizontalLayouts;
    NSDictionary* _namesForVerticalLayouts;
    NSDictionary* _namesForMaskTypes;
    NSDictionary* _namesForShowTypes;
    NSDictionary* _namesForDismissTypes;
    
    NSInteger _selectedRowInHorizontalField;
    NSInteger _selectedRowInVerticalField;
    NSInteger _selectedRowInMaskField;
    NSInteger _selectedRowInShowField;
    NSInteger _selectedRowInDismissField;
    BOOL _shouldDismissOnBackgroundTouch;
    BOOL _shouldDismissOnContentTouch;
    BOOL _shouldDismissAfterDelay;
}
@property (nonatomic, strong)NSMutableArray *messagesArray;
//@property (nonatomic, strong)NSString *clientID1;
//@property (nonatomic, strong)NSString *clientID2;
@property (nonatomic,strong) JKActivityControlView *indicator;
@property (strong, nonatomic) NSMutableSet *sendingMsgSet;
//@property (strong, nonatomic) CLLocationManager* locationManager;

- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag;

@end

@implementation JKChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _indicator = [[JKActivityControlView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 50, 50)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification)
                                                 name:@"co.herxun.Joka.didReceiveMessage"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getChatHistory) name:@"addDidBecomeActive" object:nil];
    
    
    
    self.sendingMsgSet = [[NSMutableSet alloc] initWithCapacity:0];
    self.messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
    //[[[JKLightspeedManager manager]anIM] connect:[JKLightspeedManager manager].clientId];
    
    [[JKLightspeedManager manager] checkIMConnection];
    //_anIM = [[AnIM alloc] initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
    //[[JKLightspeedManager manager].anIM getClientId:[JKLightspeedManager manager].userId];
    //_anIM = [[JKLightspeedManager manager] anIM];
    //_anIM = [[AnIM alloc] initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
    //NSLog(@"%@",[[JKLightspeedManager manager] anIM]);
    //_clientID1 = [JKLightspeedManager manager].clientId;
    //_clientID2 = [_friendInfo objectForKey:@"clientId"];
    //NSString *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"lastLoggedInUser"];
    
    [_messageTextField setDelegate:self];
    [self initInstance];
    
    
    self.navigationItem.title = [self.friendInfo objectForKey:@"username"];
    [JKLightspeedManager manager].chatDelegate = self;
    
    [self getChatHistory];
    // developers will get the clientId in
    // - (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId error:(NSString *)error;
}

- (void)viewWillAppear:(BOOL)animated {
    //[_anIM connect:_clientID1];
    [self getChatHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButton:(id)sender {
    [self sendMessage];
}

-(void)initInstance{
    _fields = @[@(FieldTagHorizontalLayout),
                @(FieldTagVerticalLayout),
                @(FieldTagMaskType),
                @(FieldTagShowType),
                @(FieldTagDismissType),
                @(FieldTagBackgroundDismiss),
                @(FieldTagContentDismiss),
                @(FieldTagTimedDismiss)];
    
    _namesForFields = @{@(FieldTagHorizontalLayout) : @"Horizontal layout",
                        @(FieldTagVerticalLayout) : @"Vertical layout",
                        @(FieldTagMaskType) : @"Background mask",
                        @(FieldTagShowType) : @"Show type",
                        @(FieldTagDismissType) : @"Dismiss type",
                        @(FieldTagBackgroundDismiss) : @"Dismiss on background touch",
                        @(FieldTagContentDismiss) : @"Dismiss on content touch",
                        @(FieldTagTimedDismiss) : @"Dismiss after delay"};
    
    // FIELD SUB-LISTS
    _horizontalLayouts = @[@(KLCPopupHorizontalLayoutLeft),
                           @(KLCPopupHorizontalLayoutLeftOfCenter),
                           @(KLCPopupHorizontalLayoutCenter),
                           @(KLCPopupHorizontalLayoutRightOfCenter),
                           @(KLCPopupHorizontalLayoutRight)];
    
    _namesForHorizontalLayouts = @{@(KLCPopupHorizontalLayoutLeft) : @"Left",
                                   @(KLCPopupHorizontalLayoutLeftOfCenter) : @"Left of Center",
                                   @(KLCPopupHorizontalLayoutCenter) : @"Center",
                                   @(KLCPopupHorizontalLayoutRightOfCenter) : @"Right of Center",
                                   @(KLCPopupHorizontalLayoutRight) : @"Right"};
    
    _verticalLayouts = @[@(KLCPopupVerticalLayoutTop),
                         @(KLCPopupVerticalLayoutAboveCenter),
                         @(KLCPopupVerticalLayoutCenter),
                         @(KLCPopupVerticalLayoutBelowCenter),
                         @(KLCPopupVerticalLayoutBottom)];
    
    _namesForVerticalLayouts = @{@(KLCPopupVerticalLayoutTop) : @"Top",
                                 @(KLCPopupVerticalLayoutAboveCenter) : @"Above Center",
                                 @(KLCPopupVerticalLayoutCenter) : @"Center",
                                 @(KLCPopupVerticalLayoutBelowCenter) : @"Below Center",
                                 @(KLCPopupVerticalLayoutBottom) : @"Bottom"};
    
    _maskTypes = @[@(KLCPopupMaskTypeNone),
                   @(KLCPopupMaskTypeClear),
                   @(KLCPopupMaskTypeDimmed)];
    
    _namesForMaskTypes = @{@(KLCPopupMaskTypeNone) : @"None",
                           @(KLCPopupMaskTypeClear) : @"Clear",
                           @(KLCPopupMaskTypeDimmed) : @"Dimmed"};
    
    _showTypes = @[@(KLCPopupShowTypeNone),
                   @(KLCPopupShowTypeFadeIn),
                   @(KLCPopupShowTypeGrowIn),
                   @(KLCPopupShowTypeShrinkIn),
                   @(KLCPopupShowTypeSlideInFromTop),
                   @(KLCPopupShowTypeSlideInFromBottom),
                   @(KLCPopupShowTypeSlideInFromLeft),
                   @(KLCPopupShowTypeSlideInFromRight),
                   @(KLCPopupShowTypeBounceIn),
                   @(KLCPopupShowTypeBounceInFromTop),
                   @(KLCPopupShowTypeBounceInFromBottom),
                   @(KLCPopupShowTypeBounceInFromLeft),
                   @(KLCPopupShowTypeBounceInFromRight)];
    
    _namesForShowTypes = @{@(KLCPopupShowTypeNone) : @"None",
                           @(KLCPopupShowTypeFadeIn) : @"Fade in",
                           @(KLCPopupShowTypeGrowIn) : @"Grow in",
                           @(KLCPopupShowTypeShrinkIn) : @"Shrink in",
                           @(KLCPopupShowTypeSlideInFromTop) : @"Slide from Top",
                           @(KLCPopupShowTypeSlideInFromBottom) : @"Slide from Bottom",
                           @(KLCPopupShowTypeSlideInFromLeft) : @"Slide from Left",
                           @(KLCPopupShowTypeSlideInFromRight) : @"Slide from Right",
                           @(KLCPopupShowTypeBounceIn) : @"Bounce in",
                           @(KLCPopupShowTypeBounceInFromTop) : @"Bounce from Top",
                           @(KLCPopupShowTypeBounceInFromBottom) : @"Bounce from Bottom",
                           @(KLCPopupShowTypeBounceInFromLeft) : @"Bounce from Left",
                           @(KLCPopupShowTypeBounceInFromRight) : @"Bounce from Right"};
    
    _dismissTypes = @[@(KLCPopupDismissTypeNone),
                      @(KLCPopupDismissTypeFadeOut),
                      @(KLCPopupDismissTypeGrowOut),
                      @(KLCPopupDismissTypeShrinkOut),
                      @(KLCPopupDismissTypeSlideOutToTop),
                      @(KLCPopupDismissTypeSlideOutToBottom),
                      @(KLCPopupDismissTypeSlideOutToLeft),
                      @(KLCPopupDismissTypeSlideOutToRight),
                      @(KLCPopupDismissTypeBounceOut),
                      @(KLCPopupDismissTypeBounceOutToTop),
                      @(KLCPopupDismissTypeBounceOutToBottom),
                      @(KLCPopupDismissTypeBounceOutToLeft),
                      @(KLCPopupDismissTypeBounceOutToRight)];
    
    _namesForDismissTypes = @{@(KLCPopupDismissTypeNone) : @"None",
                              @(KLCPopupDismissTypeFadeOut) : @"Fade out",
                              @(KLCPopupDismissTypeGrowOut) : @"Grow out",
                              @(KLCPopupDismissTypeShrinkOut) : @"Shrink out",
                              @(KLCPopupDismissTypeSlideOutToTop) : @"Slide to Top",
                              @(KLCPopupDismissTypeSlideOutToBottom) : @"Slide to Bottom",
                              @(KLCPopupDismissTypeSlideOutToLeft) : @"Slide to Left",
                              @(KLCPopupDismissTypeSlideOutToRight) : @"Slide to Right",
                              @(KLCPopupDismissTypeBounceOut) : @"Bounce out",
                              @(KLCPopupDismissTypeBounceOutToTop) : @"Bounce to Top",
                              @(KLCPopupDismissTypeBounceOutToBottom) : @"Bounce to Bottom",
                              @(KLCPopupDismissTypeBounceOutToLeft) : @"Bounce to Left",
                              @(KLCPopupDismissTypeBounceOutToRight) : @"Bounce to Right"};
    
    // DEFAULTS
    _selectedRowInHorizontalField = [_horizontalLayouts indexOfObject:@(KLCPopupHorizontalLayoutCenter)];
    _selectedRowInVerticalField = [_verticalLayouts indexOfObject:@(KLCPopupVerticalLayoutCenter)];
    _selectedRowInMaskField = [_maskTypes indexOfObject:@(KLCPopupMaskTypeDimmed)];
    _selectedRowInShowField = [_showTypes indexOfObject:@(KLCPopupShowTypeBounceInFromBottom)];
    _selectedRowInDismissField = [_dismissTypes indexOfObject:@(KLCPopupDismissTypeBounceOutToBottom)];
    _shouldDismissOnBackgroundTouch = YES;
    _shouldDismissOnContentTouch = YES;
    _shouldDismissAfterDelay = NO;

}

- (void)sendMessage {
    
    //NSSet *clientIds = [NSSet setWithObjects:[_friendInfo objectForKey:@"clientId"], nil];
    //[[[JKLightspeedManager manager] anIM] sendMessage:_messageTextField.text toClients:clientIds needReceiveACK:NO];
    [[[JKLightspeedManager manager] anIM] sendMessage:_messageTextField.text
                                             toClient:[_friendInfo objectForKey:@"clientId"]
                                       needReceiveACK:NO];
    //[[JKLightspeedManager manager] anIM] send
    self.messageTextField.text = @"";
    

    if (self.messagesArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
        [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

}




- (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId error:(NSString *)error{
    
    
}



#pragma mark - TableView Datasource
- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if ([self.messagesArray[indexPath.row] isKindOfClass:[NSMutableDictionary class]]) {
        
        CGFloat timeLabelY = indexPath.row ? 0 : 20/2;
        return 24/2 + 20/2 + timeLabelY;
        
    }else{
        //HXMessage *message = self.messagesArray[indexPath.row];
        AnIMMessage *message = self.messagesArray[indexPath.row];
        
        NSString *ownerName = [ message.from isEqualToString:[JKLightspeedManager manager].clientId]
        ? nil : [_friendInfo objectForKey:@"username"];
        
        return [HXMessageTableViewCell cellHeightForOwnerName:ownerName
                                                      message:message.message
                                                  messageType:message.fileType
                                                        image:message.content] + 20/2;
        
    }
    return 70;
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if ([self.messagesArray[indexPath.row] isKindOfClass:[NSMutableDictionary class]])
    {
        UITableViewCell *dateCell = [tableView dequeueReusableCellWithIdentifier:@"dateCell"];
        if (!dateCell) {
            dateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dateCell"];
        }
        dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        dateCell.backgroundColor = [UIColor clearColor];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"%@.%@.%@", self.messagesArray[indexPath.row][@"year"], self.messagesArray[indexPath.row][@"month"], self.messagesArray[indexPath.row][@"date"]];
        timeLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:24.0f/2];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.numberOfLines = 1;
        [timeLabel sizeToFit];
        CGFloat timeLabelY = indexPath.row ? 0 : 20/2;
        timeLabel.frame = CGRectMake(self.view.frame.size.width/2 - timeLabel.frame.size.width/2 , timeLabelY, timeLabel.frame.size.width, timeLabel.frame.size.height);
        
        [[dateCell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [dateCell.contentView addSubview:timeLabel];
        return dateCell;
    }else
    {
        static NSString *cellIdentifier = @"chatCell";
        HXMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        //HXMessage *message = self.messagesArray[indexPath.row];
        
//        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"clientId == %@", message.from];
//        NSArray *users = [[[self.chatInfo.users allObjects] filteredArrayUsingPredicate:resultPredicate]mutableCopy];
//        HXUser *remoteUser = [users firstObject];
//        
        //NSString *photoUrl = remoteUser ? remoteUser.photoURL : nil;
        //NSString *ownerName = [[self.messagesArray[indexPath.row]objectForKey:@"from"] isEqualToString:[_friendInfo objectForKey:@"clientId"]] ? [_friendInfo objectForKey:@"username"] :[JKLightspeedManager manager].username;
        AnIMMessage *message = self.messagesArray[indexPath.row];
        
        NSString *ownerName = [ message.from isEqualToString:[JKLightspeedManager manager].clientId]
        ? nil : [_friendInfo objectForKey:@"username"];
//
//        // read ack
//        if (self.remoteReadMsgSet) {
//            if ([self.remoteReadMsgSet count]){
//                if ([self.remoteReadMsgSet containsObject:message.msgId]) {
//                    message.readACK = @(YES);
//                    self.messagesArray[indexPath.row] = message;
//                    [self.remoteReadMsgSet removeObject:message.msgId];
//                }
//            }
//        }
        
        
        if (cell == nil) {
            //NSLog(@"%@",[[HXImageStore imageStore] imageUrlForKey:message.from]);
            cell = [[HXMessageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:cellIdentifier
                                                      OwnerName:ownerName
                                          profileImageUrlString:nil
                                                        message:message.message
                                                           date:message.timestamp
                                                           type:message.fileType
                                                          image:message.content
                                                        readACK:YES];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.delegate = self;
            cell.tappedTag = indexPath.row;
            
        }else{
            //NSLog(@"%@",[[HXImageStore imageStore] imageUrlForKey:message.from]);
            [cell reuseCellWithOwnerName:ownerName
                            profileImage:[UIImage imageNamed:@"friend_default"]
                   profileImageUrlString:nil
                                 message:message.message
                                    date:message.timestamp
                                    type:message.fileType
                                   image:message.content
                                 readACK:YES];
            cell.tappedTag = indexPath.row;
        }
        
        
        return cell;
    }
    
}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *cellIdentifier = @"messageCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
//    
//    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
//    UILabel *messageLabel = (UILabel *)[cell viewWithTag:101];
//    
//    if ([self.messagesArray[indexPath.row] customData]) {
//        if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"link"]) {
//            messageLabel.text = [NSString stringWithFormat:@"[Link]"];
//            messageLabel.textColor = UIColorFromRGB(0xea9c29);
//        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"video"]) {
//            messageLabel.text = [NSString stringWithFormat:@"[Video]"];
//            messageLabel.textColor = UIColorFromRGB(0xec4f54);
//        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"location"]) {
//            messageLabel.text = [NSString stringWithFormat:@"[Location]"];
//            messageLabel.textColor = UIColorFromRGB(0x27abb9);
//        }
//    } else if ([self.messagesArray[indexPath.row] message]) {
//        messageLabel.text = [self.messagesArray[indexPath.row] message];
//        messageLabel.textColor = [UIColor blackColor];
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
//    return cell;
//}


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
    [self.view addSubview:_indicator];
    [_indicator activityStart];
    
    [[JKLightspeedManager manager].anIM getHistory:[NSSet setWithObject:[_friendInfo objectForKey:@"clientId"]]
                                                clientId:[JKLightspeedManager manager].clientId
                                                   limit:30
                                               timestamp:0
                                                 success:^(NSArray *messages) {
                                                     if (messages.count) {
                                                         self.messagesArray = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             [self.chatTable reloadData];
                                                             [_indicator activityStop];
                                                             [_indicator removeFromSuperview];
                                                             if (self.messagesArray.count) {
                                                                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
                                                                 [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                                             }
                                                         });
                                                         
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.chatTable reloadData];
                if (self.messagesArray.count) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
                    [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            });
        }
    } failure:^(ArrownockException *exception) {
        NSLog(@"%@",exception);
        
    }];
}



#pragma mark - Popup view
- (IBAction)showButtonPressed:(id)sender {
    // Generate content view to present
    UIView* contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.backgroundColor = [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
    contentView.layer.cornerRadius = 12.0;
    
    UILabel* dismissLabel = [[UILabel alloc] init];
    dismissLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dismissLabel.backgroundColor = [UIColor clearColor];
    dismissLabel.textColor = [UIColor lightGrayColor];
    dismissLabel.font = [UIFont boldSystemFontOfSize:20.0];
    dismissLabel.text = @"Send Media Files:";
    
    UIButton* dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
    dismissButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    dismissButton.backgroundColor = [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
    [dismissButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [dismissButton setTitleColor:[[dismissButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    dismissButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    dismissButton.layer.cornerRadius = 6.0;
    [dismissButton addTarget:self action:@selector(dismissButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton* takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    takePhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    takePhotoButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    takePhotoButton.backgroundColor = [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
    [takePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [takePhotoButton setTitleColor:[[takePhotoButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    takePhotoButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [takePhotoButton setTitle:@"Take a Photo" forState:UIControlStateNormal];
    takePhotoButton.layer.cornerRadius = 6.0;
    [takePhotoButton addTarget:self action:@selector(takePhotoTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton* choosePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    choosePhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    choosePhotoButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
    choosePhotoButton.backgroundColor = [UIColor colorWithRed:(184.0/255.0) green:(233.0/255.0) blue:(122.0/255.0) alpha:1.0];
    [choosePhotoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [choosePhotoButton setTitleColor:[[choosePhotoButton titleColorForState:UIControlStateNormal] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    choosePhotoButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [choosePhotoButton setTitle:@"Choose a Photo" forState:UIControlStateNormal];
    choosePhotoButton.layer.cornerRadius = 6.0;
    [choosePhotoButton addTarget:self action:@selector(selectPhotoTapped) forControlEvents:UIControlEventTouchUpInside];

    
    
    //[contentView addSubview:dismissLabel];
    [contentView addSubview:dismissButton];
    [contentView addSubview:takePhotoButton];
    [contentView addSubview:choosePhotoButton];
    
    NSDictionary* views = NSDictionaryOfVariableBindings(contentView, dismissButton, takePhotoButton,choosePhotoButton);
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(16)-[choosePhotoButton]-(10)-[takePhotoButton]-(10)-[dismissButton]-(24)-|"
                                             options:NSLayoutFormatAlignAllCenterX
                                             metrics:nil
                                               views:views]];
    
    [contentView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(36)-[choosePhotoButton]-(36)-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    // Show in popup
    KLCPopupLayout layout = KLCPopupLayoutMake((KLCPopupHorizontalLayout)[self valueForRow:_selectedRowInHorizontalField inFieldWithTag:FieldTagHorizontalLayout],
                                               (KLCPopupVerticalLayout)[self valueForRow:_selectedRowInVerticalField inFieldWithTag:FieldTagVerticalLayout]);
    
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:(KLCPopupShowType)[self valueForRow:_selectedRowInShowField inFieldWithTag:FieldTagShowType]
                                         dismissType:(KLCPopupDismissType)[self valueForRow:_selectedRowInDismissField inFieldWithTag:FieldTagDismissType]
                                            maskType:(KLCPopupMaskType)[self valueForRow:_selectedRowInMaskField inFieldWithTag:FieldTagMaskType]
                            dismissOnBackgroundTouch:_shouldDismissOnBackgroundTouch
                               dismissOnContentTouch:_shouldDismissOnContentTouch];
    
    if (_shouldDismissAfterDelay) {
        [popup showWithLayout:layout duration:2.0];
    } else {
        [popup showWithLayout:layout];
    }
}


- (void)dismissButtonPressed:(id)sender {
    if ([sender isKindOfClass:[UIView class]]) {
        [(UIView*)sender dismissPresentingPopup];
    }
}


- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag {
    
    NSArray* listForField = nil;
    if (tag == FieldTagHorizontalLayout) {
        listForField = _horizontalLayouts;
        
    } else if (tag == FieldTagVerticalLayout) {
        listForField = _verticalLayouts;
        
    } else if (tag == FieldTagMaskType) {
        listForField = _maskTypes;
        
    } else if (tag == FieldTagShowType) {
        listForField = _showTypes;
        
    } else if (tag == FieldTagDismissType) {
        listForField = _dismissTypes;
    }
    
    // If row is out of bounds, try using first row.
    if (row >= listForField.count) {
        row = 0;
    }
    
    if (row < listForField.count) {
        id obj = [listForField objectAtIndex:row];
        if ([obj isKindOfClass:[NSNumber class]]) {
            return [(NSNumber*)obj integerValue];
        }
    }
    
    return 0;
}


#pragma mark AnIM Send Binary Data Method

- (void)showSendingImage:(UIImage *)image
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    // NSData* originalImageData = UIImageJPEGRepresentation(image, 1);
    UIImage *thumbnail = [self thumbnailImage:image];
    NSData* thumbnailData = UIImageJPEGRepresentation(thumbnail, 1);
    
    NSString *notificationAlert = [NSString stringWithFormat:@"%@ 向您傳送了圖片",[self.friendInfo objectForKey:@"username"]];
    NSDictionary *customData = @{@"name":[self.friendInfo objectForKey:@"username"],
                                 @"notification_alert":notificationAlert};
    NSNumber *timestamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000];
    
    NSString *timestampStr = [timestamp stringValue];
    AnIMMessage *customMessage = [[AnIMMessage alloc]initWithType:AnIMBinaryMessage
                                                            msgId:timestampStr
                                                          topicId:@""
                                                          message:@""
                                                          content:thumbnailData
                                                         fileType:@"image"
                                                             from:[JKLightspeedManager manager].clientId
                                                       customData:customData
                                                        timestamp:timestamp];
    
    
    
    //[self wrapMessageToSend:[MessageUtil anIMMessageToHXMessage:customMessage]];
    
    //HXMessage *hxMessage = [HXMessage createTempObjectWithDict:[MessageUtil reformedMessageToDic:customMessage]]
    
    //[self addTimeMessageWithTimestamp:message.timestamp];
    [self.sendingMsgSet addObject:customMessage.msgId];
    [self.messagesArray addObject:customMessage];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.chatTable reloadData];
        if (self.messagesArray.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
            [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    });
    
    
    
    
    [self sendImageData:image thumbnailData:thumbnailData timestampStr:timestampStr];
    //[MessageUtil saveTopicMessageIntoDB:@[customMessage]];
//    if (!self.isTopicMode) {
//        [MessageUtil saveChatMessageIntoDB:@[customMessage] withTargetClientId:[_friendInfo objectForKey:@"clientId"] ];
//    }else{
//        [MessageUtil saveTopicMessageIntoDB:@[customMessage]];
//    }
    
}

- (void)sendImageData:(UIImage *)image thumbnailData:(NSData *)thumbnailData timestampStr:(NSString *)timestampStr
{
    /* resize the image */
    
    UIImage *resizedImage = [self resizedOriginalImage:image maxOffset:480];
    NSData* resizedImageData = UIImageJPEGRepresentation(resizedImage, 1);
    
    NSInteger photoDataIndex = self.messagesArray.count - 1;
    
//    HXLoadingView *load = [[HXLoadingView alloc]initLoadingView];
//    [self.view addSubview:load];
    
    [[HXAnSocialManager manager] uploadPhotoToServer:resizedImageData Success:^(NSDictionary *response){
        
        NSString *photoUrls = response[@"response"][@"photo"][@"url"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *msgId;
            NSString *notificationAlert = [NSString stringWithFormat:NSLocalizedString(@"%@ 向您傳送了圖片", nil),[self.friendInfo objectForKey:@"username"]];
            NSDictionary *customData = @{@"name":[self.friendInfo objectForKey:@"username"],
                                         @"type":@"image",
                                         @"url":photoUrls,
                                         @"notification_alert":notificationAlert};
            //if (!self.isTopicMode) {
//                NSSet *clientId = [NSSet setWithObject:[self.friendInfo objectForKey:@"clientId"]];
//                msgId = [[[JKLightspeedManager manager] anIM] sendBinary:thumbnailData
//                                                        fileType:@"image"
//                                                      customData:customData
//                                                       toClients:clientId
//                                                  needReceiveACK:YES];
            
            msgId = [[[JKLightspeedManager manager] anIM] sendBinary:thumbnailData fileType:@"image" customData:customData toClient:[self.friendInfo objectForKey:@"clientId"] needReceiveACK:NO];
//            }else{
//                msgId = [[[JKLightspeedManager manager] anIM] sendBinary:thumbnailData
//                                                        fileType:@"image"
//                                                      customData:customData
//                                                       toTopicId:self.targetTopicId
//                                                  needReceiveACK:YES];
//                
//            }
//            HXMessage *imageMessage = [MessageUtil getMessageByMessageId:timestampStr];
//            imageMessage.msgId = msgId;
//            imageMessage.fileURL = photoUrls;
//            
//            NSError *error;
//            [[CoreDataUtil sharedContext] save:&error];
//            if (error) {
//                NSLog(@"Whoops, couldn't save image: %@", [error localizedDescription]);
//            }
            //self.messagesArray[photoDataIndex] = imageMessage;
            
//            [self.chatTable beginUpdates];
//            [self.chatTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:photoDataIndex inSection:0]]
//                                  withRowAnimation:UITableViewRowAnimationAutomatic];
//            [self.chatTable endUpdates];
            [self.chatTable reloadData];
            if (self.messagesArray.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
                [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
            //[load loadCompleted];
            
        });
    } failure:^(NSDictionary *response){
        //[load removeFromSuperview];
        NSLog(@"photo sending failed");
    }];
    
}

- (void)selectPhotoTapped
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* cameraRollPicker = [[UIImagePickerController alloc] init];
        cameraRollPicker.navigationBar.barTintColor = [UIColor colorWithRed:(0.0/255.0) green:(204.0/255.0) blue:(134.0/255.0) alpha:1.0];
        cameraRollPicker.delegate = self;
        cameraRollPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraRollPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        cameraRollPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        cameraRollPicker.allowsEditing = NO;
        //cameraRollPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        [cameraRollPicker removeFromParentViewController];
        //[self.navigationController presentViewController:cameraRollPicker animated:YES completion:nil];
        [self presentViewController:cameraRollPicker animated:YES completion:nil];
//
//        [self addChildViewController:cameraRollPicker];
//        [self.view addSubview:cameraRollPicker.view];
//        [cameraRollPicker didMoveToParentViewController:self];
    }
}
- (void)takePhotoTapped
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        imagePicker.showsCameraControls = YES;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)shareLocationTapped
{
    [self performSelectorOnMainThread:@selector(initLocationManager) withObject:nil waitUntilDone:NO];
}


#pragma mark - Image setting

- (UIImage *)thumbnailImage:(UIImage *)image
{
    if (image.size.height > image.size.width) {
        if (image.size.width<200) {
            image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
        }else
            image = [self imageWithImage:image scaledToSize:CGSizeMake(image.size.width*200/image.size.height, 200)];
    }else if(image.size.height < image.size.width){
        if (image.size.height<200) {
            image = [self imageWithImage:image scaledToSize:CGSizeMake(200,200)];
        }else
            image = [self imageWithImage:image scaledToSize:CGSizeMake(200, image.size.height*200/image.size.width)];
    }else {
        image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
    }
    return image;
}

- (UIImage *)resizedOriginalImage:(UIImage *)image maxOffset:(CGFloat)maxOffset
{
    CGSize size;
    if (image.size.height > image.size.width && image.size.height > maxOffset)
    {
        size = CGSizeMake(image.size.width * maxOffset/image.size.height, maxOffset);
    }
    else if(image.size.width > image.size.height && image.size.width > maxOffset)
    {
        size = CGSizeMake(maxOffset, image.size.height * maxOffset/image.size.width);
    }
    else
    {
        return image;
    }
    
    return [self imageWithImage:image scaledToSize:size];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)setImage:(UIImage *)image withAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:@"public.image"]) {
        
        UIImage* image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
        NSLog(@"I got the photo!!!");
        
        [self showSendingImage:image];
        
    }
    
}


#pragma mark Helper

- (void)wrapMessageToSend:(HXMessage *)message
{
    
    //[self addTimeMessageWithTimestamp:message.timestamp];
    [self.sendingMsgSet addObject:message.msgId];
    [self.messagesArray addObject:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.chatTable reloadData];
        if (self.messagesArray.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
            [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    });
    
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
