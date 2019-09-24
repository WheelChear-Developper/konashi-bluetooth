//
//  SettingChannelViewController.m
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/07/27.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

#import "SettingChannelViewController.h"

@interface SettingChannelViewController ()
{
    NSUserDefaults_Setting *UdSetting; // インスタンス化して初期化
    
    __weak IBOutlet UILabel *channelLabel;
    __weak IBOutlet UITextField *callFlaze;
    __weak IBOutlet UISwitch *callFlazeOnOff;
    __weak IBOutlet UISwitch *callFlazeOnOffTurn;
    __weak IBOutlet UISwitch *inputResetOnOff;
}
@end

@implementation SettingChannelViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UdSetting = [[NSUserDefaults_Setting alloc] init]; // インスタンス化して初期化
    
    channelLabel.text =  [NSString stringWithFormat:@"チャンネルNo.%lu", self.channelNo];
    
    switch (self.channelNo) {
        case 1:
            callFlaze.placeholder = [APP_DELEGATE sw1_callFlaze];
            callFlazeOnOff.on = [APP_DELEGATE sw1_callFlazeOnOff];
            callFlazeOnOffTurn.on = [APP_DELEGATE sw1_callFlazeOnOffTurn];
            inputResetOnOff.on = [APP_DELEGATE sw1_inputResetOnOff];
            break;
        case 2:
            callFlaze.placeholder = [APP_DELEGATE sw2_callFlaze];
            callFlazeOnOff.on = [APP_DELEGATE sw2_callFlazeOnOff];
            callFlazeOnOffTurn.on = [APP_DELEGATE sw2_callFlazeOnOffTurn];
            inputResetOnOff.on = [APP_DELEGATE sw2_inputResetOnOff];
            break;
        case 3:
            callFlaze.placeholder = [APP_DELEGATE sw3_callFlaze];
            callFlazeOnOff.on = [APP_DELEGATE sw3_callFlazeOnOff];
            callFlazeOnOffTurn.on = [APP_DELEGATE sw3_callFlazeOnOffTurn];
            inputResetOnOff.on = [APP_DELEGATE sw3_inputResetOnOff];
            break;
        case 4:
            callFlaze.placeholder = [APP_DELEGATE sw4_callFlaze];
            callFlazeOnOff.on = [APP_DELEGATE sw4_callFlazeOnOff];
            callFlazeOnOffTurn.on = [APP_DELEGATE sw4_callFlazeOnOffTurn];
            inputResetOnOff.on = [APP_DELEGATE sw4_inputResetOnOff];
            break;
            
        default:
            break;
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    switch (self.channelNo) {
        case 1:
            
            if([[UdSetting getUserStringDefault:@"sw1_callFlaze"] isEqualToString:[APP_DELEGATE sw1_callFlaze]]){
                callFlaze.text = @"";
            }else{
                callFlaze.text = [UdSetting getUserStringDefault:@"sw1_callFlaze"];
            }
            callFlazeOnOff.on = [UdSetting getUserBoolDefault:@"sw1_callFlazeOnOff"];
            callFlazeOnOffTurn.on = [UdSetting getUserBoolDefault:@"sw1_callFlazeOnOffTurn"];
            inputResetOnOff.on = [UdSetting getUserBoolDefault:@"sw1_inputResetOnOff"];
            break;
        case 2:
            
            if([[UdSetting getUserStringDefault:@"sw2_callFlaze"] isEqualToString:[APP_DELEGATE sw2_callFlaze]]){
                callFlaze.text = @"";
            }else{
                callFlaze.text = [UdSetting getUserStringDefault:@"sw2_callFlaze"];
            }
            callFlazeOnOff.on = [UdSetting getUserBoolDefault:@"sw2_callFlazeOnOff"];
            callFlazeOnOffTurn.on = [UdSetting getUserBoolDefault:@"sw2_callFlazeOnOffTurn"];
            inputResetOnOff.on = [UdSetting getUserBoolDefault:@"sw2_inputResetOnOff"];
            break;
        case 3:
            
            if([[UdSetting getUserStringDefault:@"sw3_callFlaze"] isEqualToString:[APP_DELEGATE sw3_callFlaze]]){
                callFlaze.text = @"";
            }else{
                callFlaze.text = [UdSetting getUserStringDefault:@"sw3_callFlaze"];
            }
            callFlazeOnOff.on = [UdSetting getUserBoolDefault:@"sw3_callFlazeOnOff"];
            callFlazeOnOffTurn.on = [UdSetting getUserBoolDefault:@"sw3_callFlazeOnOffTurn"];
            inputResetOnOff.on = [UdSetting getUserBoolDefault:@"sw3_inputResetOnOff"];
            break;
        case 4:
            
            if([[UdSetting getUserStringDefault:@"sw4_callFlaze"] isEqualToString:[APP_DELEGATE sw4_callFlaze]]){
                callFlaze.text = @"";
            }else{
                callFlaze.text = [UdSetting getUserStringDefault:@"sw4_callFlaze"];
            }
            callFlazeOnOff.on = [UdSetting getUserBoolDefault:@"sw4_callFlazeOnOff"];
            callFlazeOnOffTurn.on = [UdSetting getUserBoolDefault:@"sw4_callFlazeOnOffTurn"];
            inputResetOnOff.on = [UdSetting getUserBoolDefault:@"sw4_inputResetOnOff"];
            break;
            
        default:
            break;
    }
/*
    if(callFlazeOnOff.on){
        callFlazeOnOffTurn.enabled = true;
    }else{
        
        callFlazeOnOffTurn.on = false;
        callFlazeOnOffTurn.enabled = false;
    }
*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    switch (self.channelNo) {
        case 1:
            if([callFlaze.text isEqualToString:@""]){
                
                [UdSetting setUserStringDefault:@"sw1_callFlaze" data:[APP_DELEGATE sw1_callFlaze]];
                [UdSetting setUserBoolDefault:@"sw1_callFlazeOnOff" data:callFlazeOnOff.on];
                [UdSetting setUserBoolDefault:@"sw1_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                [UdSetting setUserBoolDefault:@"sw1_inputResetOnOff" data:inputResetOnOff.on];
            }else{
                BOOL bln_jyufukuSet = false;
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"startFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw2_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw3_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw4_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                
                if(bln_jyufukuSet == false){
                    [UdSetting setUserStringDefault:@"sw1_callFlaze" data:callFlaze.text];
                    [UdSetting setUserBoolDefault:@"sw1_callFlazeOnOff" data:callFlazeOnOff.on];
                    [UdSetting setUserBoolDefault:@"sw1_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                    [UdSetting setUserBoolDefault:@"sw1_inputResetOnOff" data:inputResetOnOff.on];
                }else{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"他のフレーズと重複している為、登録はされません。" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
            break;
        case 2:
            if([callFlaze.text isEqualToString:@""]){
                
                [UdSetting setUserStringDefault:@"sw2_callFlaze" data:[APP_DELEGATE sw2_callFlaze]];
                [UdSetting setUserBoolDefault:@"sw2_callFlazeOnOff" data:callFlazeOnOff.on];
                [UdSetting setUserBoolDefault:@"sw2_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                [UdSetting setUserBoolDefault:@"sw2_inputResetOnOff" data:inputResetOnOff.on];
            }else{
                BOOL bln_jyufukuSet = false;
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"startFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw1_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw3_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw4_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                
                if(bln_jyufukuSet == false){
                    [UdSetting setUserStringDefault:@"sw2_callFlaze" data:callFlaze.text];
                    [UdSetting setUserBoolDefault:@"sw2_callFlazeOnOff" data:callFlazeOnOff.on];
                    [UdSetting setUserBoolDefault:@"sw2_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                    [UdSetting setUserBoolDefault:@"sw2_inputResetOnOff" data:inputResetOnOff.on];
                }else{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"他のフレーズと重複している為、登録はされません。" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
            break;
        case 3:
            if([callFlaze.text isEqualToString:@""]){
                
                [UdSetting setUserStringDefault:@"sw3_callFlaze" data:[APP_DELEGATE sw3_callFlaze]];
                [UdSetting setUserBoolDefault:@"sw3_callFlazeOnOff" data:callFlazeOnOff.on];
                [UdSetting setUserBoolDefault:@"sw3_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                [UdSetting setUserBoolDefault:@"sw3_inputResetOnOff" data:inputResetOnOff.on];
            }else{
                BOOL bln_jyufukuSet = false;
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"startFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw1_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw2_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw4_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                
                if(bln_jyufukuSet == false){
                    [UdSetting setUserStringDefault:@"sw3_callFlaze" data:callFlaze.text];
                    [UdSetting setUserBoolDefault:@"sw3_callFlazeOnOff" data:callFlazeOnOff.on];
                    [UdSetting setUserBoolDefault:@"sw3_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                    [UdSetting setUserBoolDefault:@"sw3_inputResetOnOff" data:inputResetOnOff.on];
                }else{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"他のフレーズと重複している為、登録はされません。" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
            break;
        case 4:
            if([callFlaze.text isEqualToString:@""]){
                
                [UdSetting setUserStringDefault:@"sw4_callFlaze" data:[APP_DELEGATE sw4_callFlaze]];
                [UdSetting setUserBoolDefault:@"sw4_callFlazeOnOff" data:callFlazeOnOff.on];
                [UdSetting setUserBoolDefault:@"sw4_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                [UdSetting setUserBoolDefault:@"sw4_inputResetOnOff" data:inputResetOnOff.on];
            }else{
                BOOL bln_jyufukuSet = false;
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"startFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw1_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw2_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                if([callFlaze.text isEqualToString: [UdSetting getUserStringDefault:@"sw3_callFlaze"]]){
                    bln_jyufukuSet = true;
                }
                
                if(bln_jyufukuSet == false){
                    [UdSetting setUserStringDefault:@"sw4_callFlaze" data:callFlaze.text];
                    [UdSetting setUserBoolDefault:@"sw4_callFlazeOnOff" data:callFlazeOnOff.on];
                    [UdSetting setUserBoolDefault:@"sw4_callFlazeOnOffTurn" data:callFlazeOnOffTurn.on];
                    [UdSetting setUserBoolDefault:@"sw4_inputResetOnOff" data:inputResetOnOff.on];
                }else{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"他のフレーズと重複している為、登録はされません。" preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            }
            break;
            
        default:
            break;
    }
    
}

- (IBAction)onReturn:(UITextField *)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)handlePan:(id)sender {
    
    //遷移先より元のページへ戻る
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)callFlazeOnOff:(id)sender {
/*
    if(callFlazeOnOff.on){
        callFlazeOnOffTurn.enabled = true;
    }else{
        
        callFlazeOnOffTurn.on = false;
        callFlazeOnOffTurn.enabled = false;
    }
*/
}

@end
