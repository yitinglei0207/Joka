//
//  AppDelegate.m
//  Joka
//
//  Created by 雷翊廷 on 2015/6/17.
//  Copyright (c) 2015年 雷翊廷. All rights reserved.
//

#import "AppDelegate.h"
#import "AnPush.h"
#import "JKPushDelegate.h"
#import "JokaCredentials.h"
#import "JKLightspeedManager.h"
@interface AppDelegate ()<AnPushDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    NSData *tokenData = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"];
//    
//    if (tokenData)
//        [AnPush setup:LIGHTSPEED_APP_KEY deviceToken:tokenData delegate:self secure:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerPushNotification)
                                                 name:@"connect"
                                               object:nil];
    
    return YES;
}

- (void) registerPushNotification
{
    [AnPush registerForPushNotification:(UIUserNotificationTypeAlert|
                                         UIUserNotificationTypeBadge|
                                         UIUserNotificationTypeSound)];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"error: %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [AnPush setup:LIGHTSPEED_APP_KEY deviceToken:deviceToken delegate:self secure:YES];
    [[AnPush shared] register:@[ @"Joka_Push" ] overwrite:YES];
    //    NSArray *channels = [NSArray arrayWithObjects:@"BroadcastMessage", @"Payroll", @"ImportantNews"];
    //    [[AnPush shared] register:channels overwrite:YES];
    //    
}


#pragma mark - AnPushDelegate functions
- (void)didRegistered:(NSString *)anid withError:(NSString *)error
{
    NSLog(@"Arrownock didRegistered\nError: %@", error);
    if (error && ![error isEqualToString:@""])
    {
        NSLog(@"LSIM AppDelegate, AnPush failed to register, error: %@", error);
    }
    else if (!anid || [anid isEqualToString:@""])
    {
        NSLog(@"LSIM AppDelegate, AnPush failed to register, invalid Lightspeed ID");
    }
    else
    {
        /* use the anId to bind AnIM & AnPush */
        [[[JKLightspeedManager manager]anIM] bindAnPushService:anid appKey:LIGHTSPEED_APP_KEY deviceType:AnPushTypeiOS];
    }
}

- (void)didUnregistered:(BOOL)success withError:(NSString *)error
{
    NSLog(@"Unregistration success: %@\nError: %@", success? @"YES" : @"NO", error);
    if (!success)
    {
        /* do nothing */
    }
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    // only perform the action associated with this noitification if we're being brought to the foreground
//    // by the user swiping the notification or otherwise triggering it's action.
//    
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    
//    if (application.applicationState == UIApplicationStateActive)
//    {
//        
//    }else if (application.applicationState == UIApplicationStateInactive)
//    {
//        NSLog(@"Notification revieced!!! ================\n%@", userInfo);
//        HXTabBarViewController *vc = (HXTabBarViewController*) self.window.rootViewController;
//        [HXIMManager manager].remoteNotificationInfo = [userInfo mutableCopy];
//        
//        [self resetTabBarViews];
//        if (vc.selectedIndex != 0) {
//            vc.selectedIndex = 0;
//        }
//    }
//}
//
//- (void)resetTabBarViews {
//    HXTabBarViewController *tabBarController = (HXTabBarViewController *)self.window.rootViewController;
//    for(UIViewController *foo in tabBarController.viewControllers) {
//        if([foo isKindOfClass:[UINavigationController class]]) {
//            UINavigationController *bar = (UINavigationController*)foo;
//            [bar popToRootViewControllerAnimated:NO];
//        }
//    }
//}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if ([[JKLightspeedManager manager].clientId length]) {
        [JKLightspeedManager manager].isAppEnterBackground = YES;
        [[JKLightspeedManager manager].anIM disconnect];
        //[[AnPush shared]setBadge:(int)[MessageUtil getAllUnreadCount]];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([[JKLightspeedManager manager].clientId length]) {
        [JKLightspeedManager manager].isAppEnterBackground = YES;
        [[JKLightspeedManager manager].anIM disconnect];
        //[[AnPush shared]setBadge:(int)[MessageUtil getAllUnreadCount]];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[JKLightspeedManager manager].clientId length]) {
        [JKLightspeedManager manager].isAppEnterBackground = NO;
        [[JKLightspeedManager manager].anIM connect:[JKLightspeedManager manager].clientId];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addDidBecomeActive" object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if ([[JKLightspeedManager manager].clientId length]) {
        [JKLightspeedManager manager].isAppEnterBackground = YES;
        [[JKLightspeedManager manager].anIM disconnect];
    }
}





@end
