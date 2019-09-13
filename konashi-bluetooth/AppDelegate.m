//
//  AppDelegate.m
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/06/19.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

#import "AppDelegate.h"
#import "Konashi.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (NSString *)api_key
{
    return @"43694b6b67647a792f357350314a664e467032417941527648506d386c4f4e554b4c5259652e4e66333036";
}

- (NSString *)startFlaze
{
    return @"スイッチ";
}

- (NSString *)sw1_callFlaze
{
    return @"アカ";
}
- (BOOL)sw1_callFlazeOnOff
{
    return false;
}
- (BOOL)sw1_callFlazeOnOffTurn
{
    return false;
}


- (NSString *)sw2_callFlaze
{
    return @"アオ";
}
- (BOOL)sw2_callFlazeOnOff
{
    return false;
}
- (BOOL)sw2_callFlazeOnOffTurn
{
    return false;
}

- (NSString *)sw3_callFlaze
{
    return @"キイロ";
}
- (BOOL)sw3_callFlazeOnOff
{
    return false;
}
- (BOOL)sw3_callFlazeOnOffTurn
{
    return false;
}

- (NSString *)sw4_callFlaze
{
    return @"ミドリ";
}
- (BOOL)sw4_callFlazeOnOff
{
    return false;
}
- (BOOL)sw4_callFlazeOnOffTurn
{
    return false;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // デバイスのスリープタイマーを無効化します。
//    UIApplication* application = [UIApplication sharedApplication];
    application.idleTimerDisabled = YES;
    
    //初回フレーズ設定（開始呼び出し用）
    if([self getUserStringDefault:@"startFlaze"] == nil){
        [self setUserStringDefault:@"startFlaze" data:self.startFlaze];
    }
    if([self getUserStringDefault:@"sw1_callFlaze"] == nil){
        [self setUserStringDefault:@"sw1_callFlaze" data:self.sw1_callFlaze];
    }
    if([self getUserStringDefault:@"sw2_callFlaze"] == nil){
        [self setUserStringDefault:@"sw2_callFlaze" data:self.sw2_callFlaze];
    }
    if([self getUserStringDefault:@"sw3_callFlaze"] == nil){
        [self setUserStringDefault:@"sw3_callFlaze" data:self.sw3_callFlaze];
    }
    if([self getUserStringDefault:@"sw4_callFlaze"] == nil){
        [self setUserStringDefault:@"sw4_callFlaze" data:self.sw4_callFlaze];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [Konashi disconnect];
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

- (void)setUserStringDefault:(NSString*)key
                        data:(NSString*)data {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:data forKey:key];
    [ud synchronize];
}
- (NSString*)getUserStringDefault:(NSString*)key {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString* str = [ud objectForKey:key];
    return str;
}

@end
