//
//  JKPushDelegate.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "JKPushDelegate.h"

@implementation JKPushDelegate

- (void)didRegistered:(NSString *)anid withError:(NSString *)error
{
    NSString *result = [NSString stringWithFormat:@"ANID: %@\nerror: %@", anid, error];
    NSLog(@"%@",result);
}

- (void) didUnregistered:(Boolean)success withError:(NSString *)error
{
    NSString *result = [NSString stringWithFormat:@"success: %@\nerror: %@", success?@"YES":@"NO", error];
    NSLog(@"%@",result);
}

@end
