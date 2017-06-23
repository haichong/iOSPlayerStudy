//
//  AppDelegate.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/11/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "FHHomePageTableViewController.h"
#import "FHAudioViewController.h"
#import "FHAVPlayerViewController.h"
#import "FHMusicPlayerViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    // 设置根控制器
    FHHomePageTableViewController *homePageVC = [[FHHomePageTableViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homePageVC];
    self.window.rootViewController = nav;
    // 设置后台播放
    [self setBackGroudPlay];
    [self.window makeKeyAndVisible];
    
    return YES;

}
// 设置后台播放
- (void)setBackGroudPlay {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
}
// 程序进入后台，执行这个方法
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    UIBackgroundTaskIdentifier taskID = [application beginBackgroundTaskWithExpirationHandler:^{
       // 如果过期了，就停止任务
        [application endBackgroundTask:taskID];
    }];
}

@end
