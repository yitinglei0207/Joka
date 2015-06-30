//
//  JKWallTableViewCell.h
//  Joka
//
//  Created by 雷翊廷 on 2015/6/24.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKCustomButton.h"
@interface JKWallTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *postTextView;

@property (weak, nonatomic) IBOutlet UILabel *postCreatorName;
@property (weak, nonatomic) IBOutlet UILabel *likes;
@property (weak, nonatomic) IBOutlet UILabel *comments;
@property (weak, nonatomic) IBOutlet UILabel *createAt;
@property (weak, nonatomic) IBOutlet JKCustomButton *likeButton;
@property (weak, nonatomic) IBOutlet JKCustomButton *commentButton;
@property (nonatomic,strong) NSString *postId;
@end
