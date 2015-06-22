//
//  JKProfileViewController.h
//  Joka
//
//  Created by 雷翊廷 on 2015/6/18.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKProfileViewController : UIViewController
@property (strong, nonatomic) NSDictionary *friendInfo;
@property (strong, nonatomic) NSMutableDictionary *topicInfo;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addToFriendButton;
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *awardLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property BOOL isTopicMode;
@end
