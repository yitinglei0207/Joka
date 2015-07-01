//
//  JKWallTableViewCell.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/24.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKWallTableViewCell.h"

@implementation JKWallTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)likebuttonPressed:(JKCustomButton*)sender {
    if (sender.selected) {
        [sender setSelected:NO];
        NSNumber *likecount = [NSNumber numberWithInteger:[self.likes.text intValue]-1] ;
        
        self.likes.text = [NSString stringWithFormat:@"%d likes",likecount.intValue];
    }else{
        [sender setSelected:YES];
        NSNumber *likecount = [NSNumber numberWithInteger:[self.likes.text intValue]+1] ;
        
        self.likes.text = [NSString stringWithFormat:@"%d likes",likecount.intValue];
    }
    
}

@end
