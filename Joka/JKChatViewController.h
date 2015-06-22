//
//  JKChatViewController.h
//  Joka
//
//  Created by 雷翊廷 on 2015/6/18.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *chatTable;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) NSDictionary *friendInfo;
@property (strong, nonatomic) NSMutableDictionary *topicInfo;
@property BOOL isTopicMode;

@end
