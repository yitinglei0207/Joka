//
//  JKRearTableViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/23.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKRearTableViewController.h"
#import "SWRevealViewController.h"
#import "JKLightspeedManager.h"

@interface JKRearTableViewController ()
{
    NSInteger _presentedRow;
}

@end

@implementation JKRearTableViewController


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillDisappear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"mapEnable" object:nil];
}
#pragma mark - Table view data source


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SWRevealViewController *revealController = self.revealViewController;
    
    // selecting row
    NSInteger row = indexPath.row;
    
    // if we are trying to push the same row or perform an operation that does not imply frontViewController replacement
    // we'll just set position and return
    
    if ( row == _presentedRow )
    {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
    else if (row == 6)//user logout
    {
        [revealController setFrontViewPosition:FrontViewPositionRight animated:YES];
        //[PFUser logOut];
        [[JKLightspeedManager manager] logOut];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"logged out");
        return;
    }
    _presentedRow = row;  // <- store the presented row
}

@end
