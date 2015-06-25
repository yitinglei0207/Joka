//
//  JKEditProfileTableViewController.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/25.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKEditProfileTableViewController.h"
#import "JKLightspeedManager.h"

@interface JKEditProfileTableViewController ()
@property (nonatomic,strong) NSString *getObjectID;
@property BOOL isNew;
@end

@implementation JKEditProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self getUserInfo];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEnteringInfo:(id)sender {
    if (_isNew) {
        [self createUserInfo];
    }
    else{
        [self updateUserInfo];
    }
    
    
    
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/



- (void)updateUserInfo {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    [params setObject:_getObjectID forKey:@"object_id"];
    [params setObject:[_gender titleForSegmentAtIndex:_gender.selectedSegmentIndex] forKey:@"gender"];
    [params setObject:[_ageGroup titleForSegmentAtIndex:_ageGroup.selectedSegmentIndex] forKey:@"ageGroup"];
    [params setObject:[_primaryHand titleForSegmentAtIndex:_primaryHand.selectedSegmentIndex] forKey:@"primaryHand"];
    [params setObject:[_gender titleForSegmentAtIndex:_gender.selectedSegmentIndex] forKey:@"gender"];
    [params setObject:[_playerType titleForSegmentAtIndex:_playerType.selectedSegmentIndex] forKey:@"playerType"];
    [params setObject:[_preferToPlay titleForSegmentAtIndex:_preferToPlay.selectedSegmentIndex] forKey:@"preferToPlay"];
    [params setObject:[_ratingNTRP titleForSegmentAtIndex:_ratingNTRP.selectedSegmentIndex] forKey:@"ratingNTRP"];
    if (_experience.text) {
        [params setObject:_experience.text forKey:@"experience"];
    }else{
        [params setObject:@"" forKey:@"experience"];
    }
    if (_preferedLocations.text) {
        [params setObject:_preferedLocations.text forKey:@"preferedLocations"];
    }else{
        [params setObject:@"" forKey:@"preferedLocations"];
    }
    [params setObject:[_toPlayWithGender titleForSegmentAtIndex:_toPlayWithGender.selectedSegmentIndex] forKey:@"toPlayWithGender"];
    [params setObject:[_toPlayWithAge titleForSegmentAtIndex:_toPlayWithAge.selectedSegmentIndex] forKey:@"toPlayWithAge"];
    if (_webSite.text) {
        [params setObject:_webSite.text forKey:@"website"];
    }else{
        [params setObject:@"" forKey:@"website"];
    }
    
    
    [[JKLightspeedManager manager] sendRequest:@"objects/MemberInfo/update.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         NSLog(@"UserInfo updated");
         NSLog(@"%@",response);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self dismissViewControllerAnimated:YES completion:nil];
         });
     } failure:^(NSDictionary *response) {
         NSLog(@"UserInfo updating failed");
         for (id key in response) {
             NSLog(@"%@",response);
         }
         
     }];
}

- (void)createUserInfo {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    [params setObject:[_gender titleForSegmentAtIndex:_gender.selectedSegmentIndex] forKey:@"gender"];
    [params setObject:[_ageGroup titleForSegmentAtIndex:_ageGroup.selectedSegmentIndex] forKey:@"ageGroup"];
    [params setObject:[_primaryHand titleForSegmentAtIndex:_primaryHand.selectedSegmentIndex] forKey:@"primaryHand"];
    [params setObject:[_gender titleForSegmentAtIndex:_gender.selectedSegmentIndex] forKey:@"gender"];
    [params setObject:[_playerType titleForSegmentAtIndex:_playerType.selectedSegmentIndex] forKey:@"playerType"];
    [params setObject:[_preferToPlay titleForSegmentAtIndex:_preferToPlay.selectedSegmentIndex] forKey:@"preferToPlay"];
    [params setObject:[_ratingNTRP titleForSegmentAtIndex:_ratingNTRP.selectedSegmentIndex] forKey:@"ratingNTRP"];
    if (_experience.text) {
        [params setObject:_experience.text forKey:@"experience"];
    }else{
        [params setObject:@"" forKey:@"experience"];
    }
    [params setObject:[_toPlayWithGender titleForSegmentAtIndex:_toPlayWithGender.selectedSegmentIndex] forKey:@"toPlayWithGender"];
    [params setObject:[_toPlayWithAge titleForSegmentAtIndex:_toPlayWithAge.selectedSegmentIndex] forKey:@"toPlayWithAge"];
    if (_webSite.text) {
        [params setObject:_webSite.text forKey:@"website"];
    }else{
        [params setObject:@"" forKey:@"website"];
    }
    if (_preferedLocations.text) {
        [params setObject:_preferedLocations.text forKey:@"preferedLocations"];
    }else{
        [params setObject:@"" forKey:@"preferedLocations"];
    }
    [[JKLightspeedManager manager] sendRequest:@"objects/MemberInfo/create.json" method:AnSocialManagerPOST params:params success:^
     (NSDictionary *response) {
         NSLog(@"UserInfo created");
         NSLog(@"%@",response);
         dispatch_async(dispatch_get_main_queue(), ^{
             [self dismissViewControllerAnimated:YES completion:nil];
         });
         
     } failure:^(NSDictionary *response) {
         NSLog(@"UserInfo creating failed");
     }];
}

- (void)getUserInfo{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[JKLightspeedManager manager].username forKey:@"username"];
    //[params setObject:@"4.0" forKey:@"level"];
    
    [[JKLightspeedManager manager] sendRequest:@"objects/MemberInfo/search.json" method:AnSocialManagerGET params:params success:^
     (NSDictionary *response) {
         NSLog(@"key: %@ ",response);
         NSUInteger i = [[[response objectForKey:@"response"]objectForKey:@"MemberInfos"] count];
         if (!i) {
             NSLog(@"no object");
         
             dispatch_async(dispatch_get_main_queue(), ^{
                 _isNew = YES;
             });
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSDictionary *responseObject = [[[response objectForKey:@"response"]objectForKey:@"MemberInfos"]objectAtIndex:0];
                 _getObjectID = [responseObject objectForKey:@"id"];
                 _isNew = NO;
             });
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 NSDictionary *responseObject = [[[response objectForKey:@"response"]objectForKey:@"Users"]objectAtIndex:0];
//                 
//                 _getObjectID = [responseObject objectForKey:@"id"];
//                 _experienceText.text = [responseObject objectForKey:@"experience"]? [responseObject objectForKey:@"experience"]:@"";
//                 _awardText.text = [responseObject objectForKey:@"award"]? [responseObject objectForKey:@"award"]:@"";
//                 _levelText.text = [responseObject objectForKey:@"level"]? [responseObject objectForKey:@"level"]:@"";
//                 _locationText.text = [responseObject objectForKey:@"location"]? [responseObject objectForKey:@"location"]:@"";
//             });
         }
         //NSLog(@"key: %@ ,value: %@",@"response",[response objectForKey:@"response"]);
         
         
         
     } failure:^(NSDictionary *response) {
         NSLog(@"failed or is new");
         dispatch_async(dispatch_get_main_queue(), ^{
             _isNew = YES;
         });
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
