//
//  AppDelegate.m
//  BloothDemo
//
//  Created by ayong on 2018/10/15.
//  Copyright © 2018年 ayong. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()
@property (nonatomic) dispatch_source_t badgeTimer;
@property (nonatomic , assign) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //注册推送
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    if (@available(iOS 10.0, *)) {
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
    } else {
        // Fallback on earlier versions
    }
    
    return YES;
}

#pragma mark -
- (void)stratBadgeNumberCount{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.badgeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.badgeTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.badgeTimer, ^{
        
        [UIApplication sharedApplication].applicationIconBadgeNumber++;
//        NSLog(@"我在执行%d",[UIApplication sharedApplication].applicationIconBadgeNumber);
    });
    dispatch_resume(self.badgeTimer);
}

- (void)beginBackgroundUpdateTask{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackGroundUpdateTask];
    }];
}

- (void)endBackGroundUpdateTask{
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}



- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
   [self beginBackgroundUpdateTask];
   [self stratBadgeNumberCount];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
