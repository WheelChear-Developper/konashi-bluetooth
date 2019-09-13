//
//  SettingTopViewController.m
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/07/18.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

#import "SettingTopViewController.h"

@interface SettingTopViewController ()
{
    NSUserDefaults_Setting *UdSetting; // インスタンス化して初期化
    
    __weak IBOutlet UITextField *startFlazeText;
    __weak IBOutlet UISwitch *autoSaveSwitch;
}
@end

@implementation SettingTopViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UdSetting = [[NSUserDefaults_Setting alloc] init]; // インスタンス化して初期化
    
    startFlazeText.placeholder = [APP_DELEGATE startFlaze];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if([[UdSetting getUserStringDefault:@"startFlaze"] isEqualToString:[APP_DELEGATE startFlaze]]){
        startFlazeText.text = @"";
    }else{
        startFlazeText.text = [UdSetting getUserStringDefault:@"startFlaze"];
    }
    
    autoSaveSwitch.on = [UdSetting getUserBoolDefault:@"autoSaveSwitch"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([startFlazeText.text isEqualToString:@""]){
        
        [UdSetting setUserStringDefault:@"startFlaze" data:[APP_DELEGATE startFlaze]];
    }else{
        
        [UdSetting setUserStringDefault:@"startFlaze" data:startFlazeText.text];
    }
    
    [UdSetting setUserBoolDefault:@"autoSaveSwitch" data:autoSaveSwitch.on];
}

- (IBAction)handlePan:(id)sender {
    
    //遷移先より元のページへ戻る
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)channel1Setting:(id)sender {
    
    SettingChannelViewController *settingChannelVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"SettingChannelViewController"];
    settingChannelVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingChannelVC.channelNo = 1;
    [self.navigationController pushViewController:settingChannelVC animated:YES];
}

- (IBAction)channel2Setting:(id)sender {
    
    SettingChannelViewController *settingChannelVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"SettingChannelViewController"];
    settingChannelVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingChannelVC.channelNo = 2;
    [self.navigationController pushViewController:settingChannelVC animated:YES];
}

- (IBAction)channel3Setting:(id)sender {
    
    SettingChannelViewController *settingChannelVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"SettingChannelViewController"];
    settingChannelVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingChannelVC.channelNo = 3;
    [self.navigationController pushViewController:settingChannelVC animated:YES];
}

- (IBAction)channel4Setting:(id)sender {
    
    SettingChannelViewController *settingChannelVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"SettingChannelViewController"];
    settingChannelVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    settingChannelVC.channelNo = 4;
    [self.navigationController pushViewController:settingChannelVC animated:YES];
}

- (IBAction)onReturn:(UITextField *)sender {
    
    [sender resignFirstResponder];
}

@end
