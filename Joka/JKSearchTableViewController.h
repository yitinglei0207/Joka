//
//  JKSearchTableViewController.h
//  Joka
//
//  Created by 雷翊廷 on 2015/7/7.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKSearchTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *gender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ageGroup;

@property (weak, nonatomic) IBOutlet UISegmentedControl *playerType;
@property (weak, nonatomic) IBOutlet UITextField *preferedLocations;
@property (weak, nonatomic) IBOutlet UISegmentedControl *preferToPlay;
@property (weak, nonatomic) IBOutlet UISegmentedControl *ratingNTRP;

@property (weak, nonatomic) IBOutlet UISegmentedControl *toPlayWithGender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *toPlayWithAge;
@end
