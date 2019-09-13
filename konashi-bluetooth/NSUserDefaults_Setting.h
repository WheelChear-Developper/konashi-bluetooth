//
//  NSUserDefaults_Setting.h
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/08/07.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

@interface NSUserDefaults_Setting : NSObject

- (void)setUserArrayDefault:(NSString*)key
                       data:(NSArray*)data;
- (NSArray*)getUserArrayDefault:(NSString*)key;

- (void)setUserStringDefault:(NSString*)key
                        data:(NSString*)data;
- (NSString*)getUserStringDefault:(NSString*)key;

- (void)setUserIntegerDefault:(NSString*)key
                         data:(NSInteger)data;
- (NSInteger)getUserIntegerDefault:(NSString*)key;

- (void)setUserBoolDefault:(NSString*)key
                      data:(BOOL)data;
- (BOOL)getUserBoolDefault:(NSString*)key;

@end
