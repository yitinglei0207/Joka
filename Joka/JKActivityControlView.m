//
//  JKActivityControlView.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/26.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKActivityControlView.h"
#import <UIKit/UIKit.h>

@interface JKActivityControlView()
{
    UIImageView *indicatorBackground;
    
}
@property(nonatomic,strong) UIActivityIndicatorView *indicator;
@end



@implementation JKActivityControlView


- (void)activityStart{
    [self activityIndicatorSetup];
    [_indicator startAnimating];
}

- (void)activityStop{
    [_indicator stopAnimating];
    [indicatorBackground removeFromSuperview];
}


- (void)activityIndicatorSetup{
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _indicator.center = CGPointMake(25, 25) ;
    indicatorBackground = [[UIImageView alloc]init];
    indicatorBackground.backgroundColor = [UIColor darkGrayColor];
    indicatorBackground.alpha = 0.5;
    [indicatorBackground setFrame:CGRectMake([UIScreen mainScreen].applicationFrame.size.width/2-25, [UIScreen mainScreen].applicationFrame.size.height/2-25, 50, 50)];
    indicatorBackground.layer.cornerRadius = 5;
    indicatorBackground.layer.masksToBounds = YES;
    [indicatorBackground addSubview:_indicator];
    [self addSubview:indicatorBackground];
    
}

@end