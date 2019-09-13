//
//  AppDelegate.h
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/06/19.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

- (NSString *)api_key;
- (NSString *)startFlaze;

- (NSString *)sw1_callFlaze;
- (BOOL)sw1_callFlazeOnOff;
- (BOOL)sw1_callFlazeOnOffTurn;

- (NSString *)sw2_callFlaze;
- (BOOL)sw2_callFlazeOnOff;
- (BOOL)sw2_callFlazeOnOffTurn;

- (NSString *)sw3_callFlaze;
- (BOOL)sw3_callFlazeOnOff;
- (BOOL)sw3_callFlazeOnOffTurn;

- (NSString *)sw4_callFlaze;
- (BOOL)sw4_callFlazeOnOff;
- (BOOL)sw4_callFlazeOnOffTurn;

@property (strong, nonatomic) UIWindow *window;

@end
