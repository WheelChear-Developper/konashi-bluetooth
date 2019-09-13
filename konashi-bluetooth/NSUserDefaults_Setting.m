//
//  NSUserDefaults_Setting.m
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/08/07.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

#import "NSUserDefaults_Setting.h"

@implementation NSUserDefaults_Setting

- (void)setUserArrayDefault:(NSString*)key
                       data:(NSArray*)data {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:data forKey:key];
    [ud synchronize];
}
- (NSArray*)getUserArrayDefault:(NSString*)key {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray* array = [ud arrayForKey:key];
    return array;
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

- (void)setUserIntegerDefault:(NSString*)key
                         data:(NSInteger)data {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:data forKey:key];
    [ud synchronize];
}
- (NSInteger)getUserIntegerDefault:(NSString*)key {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger no = [ud integerForKey:key];
    return no;
}

- (void)setUserBoolDefault:(NSString*)key
                      data:(BOOL)data {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:data forKey:key];
    [ud synchronize];
}
- (BOOL)getUserBoolDefault:(NSString*)key {
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL no = [ud boolForKey:key];
    return no;
}

@end
