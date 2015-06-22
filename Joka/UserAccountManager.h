//
//  UserAccountManager.h
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccountManager : NSObject
@property (strong, nonatomic) NSString *userName;
//@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *clientId;

@end
