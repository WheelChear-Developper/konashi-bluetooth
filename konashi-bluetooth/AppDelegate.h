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
- (BOOL)sw1_inputResetOnOff;

- (NSString *)sw2_callFlaze;
- (BOOL)sw2_callFlazeOnOff;
- (BOOL)sw2_callFlazeOnOffTurn;
- (BOOL)sw2_inputResetOnOff;

- (NSString *)sw3_callFlaze;
- (BOOL)sw3_callFlazeOnOff;
- (BOOL)sw3_callFlazeOnOffTurn;
- (BOOL)sw3_inputResetOnOff;

- (NSString *)sw4_callFlaze;
- (BOOL)sw4_callFlazeOnOff;
- (BOOL)sw4_callFlazeOnOffTurn;
- (BOOL)sw4_inputResetOnOff;

@property (strong, nonatomic) UIWindow *window;

@end
