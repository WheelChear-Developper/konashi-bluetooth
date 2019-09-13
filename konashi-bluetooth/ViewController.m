//
//  ViewController.m
//  konashi-bluetooth
//
//  Created by mi.amatani on 2019/06/19.
//  Copyright © 2019 mi.amatani. All rights reserved.
//

#import "ViewController.h"
#import "Konashi.h"
#import "SRClientHelper.h"
#import "SRClientDataClasses.h"
#import "XMLReader.h"
#import <AVFoundation/AVFoundation.h>

static NSString* api_key = @"33635744542f4f523372794372396551435373394c317737512e7930547347374c47724a664d636b2f7243";

@interface ViewController ()
<SRClientHelperDelegate>
{
    NSUserDefaults_Setting *UdSetting; // インスタンス化して初期化
    
    NSTimer *bluetooth_connection_timer;
    Boolean blnFirstStart;
    
    NSString* total_serial_key;
    bool bln_SpeachMode;
    bool bln_Insearch;
    
    UIColor* sw_off_color;
    UIColor* sw_on_color;
    
    BOOL serchStartVoice_Flg;
    
    int sw1_Flg;
    int sw2_Flg;
    int sw3_Flg;
    int sw4_Flg;
    
    //効果音
    SystemSoundID sound_1;
    
    NSDate* timerStartNow;
    
    //緯度経度　前回のデータ
//    NSTimer *gps_check_timer;
//    BOOL gpsIdoChenge_Flg;
//    BOOL gpsIdoChenge_First_Flg;
//    BOOL gpsIdoKaijyo_Flg;
    double dbl_latitude;
    double dbl_longitude;
    double dbl_zenkai_latitude;
    double dbl_zenkai_longitude;
    double dbl_gpsHani;
    BOOL gpsChenge_Flg;
    
    __weak IBOutlet UILabel *sw_label_speachMode;
    __weak IBOutlet UILabel *sw1_label_button;
    __weak IBOutlet UILabel *sw2_label_button;
    __weak IBOutlet UILabel *sw3_label_button;
    __weak IBOutlet UILabel *sw4_label_button;
    
    __weak IBOutlet UIButton *sw_speachMode;
    __weak IBOutlet UIButton *sw1_button;
    __weak IBOutlet UIButton *sw2_button;
    __weak IBOutlet UIButton *sw3_button;
    __weak IBOutlet UIButton *sw4_button;
    __weak IBOutlet UILabel *battery_text;
    __weak IBOutlet UITextView *speachLog_text;
    __weak IBOutlet UIImageView *speach_lock;
    
    __weak IBOutlet UIImageView *batteryImage;
    
}
@property (nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation ViewController
{
    SRClientHelper* _srcHelper;
    NSMutableDictionary* _settings;
    int _mode;
    SPEECHREC_BUTTON_MODE _latestLevel;
}

- (void)viewDidLoad {
    
//    dbl_gpsHani = 0.000005;
//    gpsChenge_Flg = false;
//    gpsIdoChenge_Flg = false;
    
    [super viewDidLoad];
    
    /*
    if (nil == self.locationManager){
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    
        //    取得精度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
        //    更新頻度（メートル）
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
        //    サービスの開始
        [self.locationManager requestAlwaysAuthorization];
    }
     */

    UdSetting = [[NSUserDefaults_Setting alloc] init]; // インスタンス化して初期化
    
    //konashi初期化
    [Konashi initialize];
    
    sw1_Flg = 0;
    sw2_Flg = 0;
    sw3_Flg = 0;
    sw4_Flg = 0;
    
//    gpsIdoKaijyo_Flg = false;
    
    sw_off_color = [UIColor colorWithRed:175/255.0 green:201/255.0 blue:216/255.0 alpha:1.0]; ;//AFC9D8
    sw_on_color = [UIColor colorWithRed:211/255.0 green:0/255.0 blue:28/255.0 alpha:1.0]; ;//D3001C
    
    [[_buttonMic imageView] setClipsToBounds:NO];
    [[_buttonMic imageView] setContentMode:UIViewContentModeCenter];
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_NONE];
    _mode = SPEECHREC_RECOG_MODE_NONE;
    _latestLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
    
    blnFirstStart = true;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    //位置情報取得用
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    sw_chenge_Flg = false;
    konashi_onLine_Count = 0;
    
    timerStartNow = 0;
    
    serchStartVoice_Flg = false;
    
    //スイッチの初期化
    NSArray* flg = [UdSetting getUserArrayDefault:@"sw_paturn"];
    if(flg == nil){
        
        //スイッチ初期化
        sw1_OnOff_Flg = false;
        sw2_OnOff_Flg = false;
        sw3_OnOff_Flg = false;
        sw4_OnOff_Flg = false;
        
        bln_Insearch = false;
        bln_SpeachMode = false;
        
        [self setSw1OFF];
        [self setSw2OFF];
        [self setSw3OFF];
        [self setSw4OFF];
    }
    
    //アクティブ直前のメソッド設定
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(active_time_check)
//                                                 name:UIApplicationDidBecomeActiveNotification
//                                               object:nil];
    
    //アプリが終了する直前
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endMethod)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    //アプリがバックグラウンドに移行した時によばれる
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backGroundIn)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //konashiに接続完了した時(この時からkonashiにアクセスできるようになります)
    [[NSNotificationCenter defaultCenter] addObserverForName:KonashiEventReadyToUseNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        self->sw_chenge_Flg = true;
        self->konashi_onLine_Count += 1;
    }];
    
    [self active_time_check];
}

/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation* location = [locations lastObject];
    double la = location.coordinate.latitude;
    double lo = location.coordinate.longitude;
    dbl_latitude = la;
    dbl_longitude = lo;
    gpsIdoChenge_First_Flg = true;

    NSLog(@"\n %+.6f　＞　緯度 %+.6f ＜ %+.6f\n %+.6f　＞　経度 %+.6f ＜ %+.6f",dbl_zenkai_latitude - dbl_gpsHani, dbl_latitude, dbl_zenkai_latitude + dbl_gpsHani,dbl_zenkai_longitude - dbl_gpsHani, dbl_longitude, dbl_zenkai_longitude + dbl_gpsHani);
    
    if(dbl_zenkai_latitude - dbl_gpsHani < dbl_latitude && dbl_latitude < dbl_zenkai_latitude + dbl_gpsHani){
        if(dbl_zenkai_longitude - dbl_gpsHani < dbl_longitude && dbl_longitude < dbl_zenkai_longitude + dbl_gpsHani){
            gpsIdoKaijyo_Flg = true;
            gpsIdoChenge_Flg = false;
        }else{
            gpsIdoKaijyo_Flg = false;
            gpsIdoChenge_Flg = true;
        }
    }else{
        gpsIdoKaijyo_Flg = false;
        gpsIdoChenge_Flg = true;
    }
    
    dbl_zenkai_latitude = dbl_latitude;
    dbl_zenkai_longitude = dbl_longitude;
}
*/

- (void)active_time_check {
    
    if(_settings){
        _settings = nil;
    }
    _settings = [NSMutableDictionary dictionary];
    // get setting from settings.bundle
    [self loadSetting:@"konashi_serial_key" type:SPEECHREC_SETTING_TYPE_STRING];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *serial_key = [ud stringForKey: @"konashi_serial_key"];
    
    if([serial_key isEqualToString:@""]){
        
        total_serial_key = @"";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"Bluetoothのシリアルキーが設定されていません。\n設定画面から設定してください" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"設定画面" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            //設定画面へ
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }else
    if(serial_key == nil){
        
        total_serial_key = @"";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"Bluetoothのシリアルキーが設定されていません。\n設定画面から設定してください" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"設定画面" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

            //設定画面へ
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }else{
        
        total_serial_key = [@"konashi3-f0" stringByAppendingString:serial_key];
        
        [Konashi findWithName:total_serial_key];
    }
    
//    NSLog(@"findWithName[0:接続成功 -1:接続失敗] _ %d", [Konashi findWithName:total_serial_key]);
//    NSLog(@"isConnected[YES:接続中 NO:未接続] _ %@", ([Konashi isConnected] ? @"YES":@"NO"));
    
    //タイマーにてこkonashiの状態チェック
    if([Konashi isConnected] == NO){
        
        if([Konashi findWithName:total_serial_key] == KonashiResultFailure){
            
            //スイッチ初期化
            bln_SpeachMode = false;
            
            sw_speachMode.enabled = false;
            sw1_button.enabled = false;
            sw2_button.enabled = false;
            sw3_button.enabled = false;
            sw4_button.enabled = false;

            sw_label_speachMode.text = @"Speach Mode\nOFFLINE";\
            [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"%@\nOFFLINE",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
            [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"%@\nOFFLINE",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
            [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"%@\nOFFLINE",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
            [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"%@\nOFFLINE",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
            
            sw_label_speachMode.textColor = UIColor.darkGrayColor;
            sw1_label_button.textColor = UIColor.darkGrayColor;
            sw2_label_button.textColor = UIColor.darkGrayColor;
            sw3_label_button.textColor = UIColor.darkGrayColor;
            sw4_label_button.textColor = UIColor.darkGrayColor;
            
            UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
            [sw_speachMode setBackgroundImage:img forState:UIControlStateNormal];
            [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
            [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
            [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
            [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
        }
        
        //Bluetoothチェック
        bluetooth_connection_timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                      target:self
                                                                    selector:@selector(active_action)
                                                                    userInfo:nil
                                                                     repeats:YES];
       
    }else{
  
        //Bluetoothチェック
        bluetooth_connection_timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                      target:self
                                                                    selector:@selector(active_action)
                                                                    userInfo:nil
                                                                     repeats:YES];
    }
}

- (void)backGroundIn {
    
    total_serial_key = @"";
    
    konashi_onLine_Count = 0;
}

- (void)endMethod {
    
    [self setSwicheFlg];
    
    [Konashi disconnect];
}

- (void)active_action {
//    NSLog(@"UIApplicationWillTerminateNotification selector");
    
//    NSLog(@"findWithName[0:接続成功 -1:接続失敗] _ %d", [Konashi findWithName:total_serial_key]);
//    NSLog(@"isConnected[YES:接続中 NO:未接続] _ %@", ([Konashi isConnected] ? @"YES":@"NO"));
    
    //バッテリーの残量表示更新
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    [UIDevice currentDevice].batteryMonitoringEnabled = true;
    float battery = [UIDevice currentDevice].batteryLevel*100;
    battery_text.text = [NSString stringWithFormat:@"%.0f％",battery];
    if(batteryState == UIDeviceBatteryStateCharging){
        
        [batteryImage setImage:[UIImage imageNamed:@"BatteryInput.png"]];
    }else
    if(battery <= 20){
        
        [batteryImage setImage:[UIImage imageNamed:@"Battery20.png"]];
    }else
    if(battery <= 40){
        
        [batteryImage setImage:[UIImage imageNamed:@"Battery40.png"]];
    }else
    if(battery <= 60){
        
        [batteryImage setImage:[UIImage imageNamed:@"Battery60.png"]];
    }else
    if(battery <= 80){
        
        [batteryImage setImage:[UIImage imageNamed:@"Battery80.png"]];
    }else
    if(battery <= 100){
        
        [batteryImage setImage:[UIImage imageNamed:@"Battery100.png"]];
    }
    
    // 音声認識の継続
    if(bln_SpeachMode == true && bln_Insearch == false){
        
        [self start];
        bln_Insearch = true;
    }
     
    if([Konashi isConnected] == NO){
        
        NSLog(@"=- konashi off line -=");
        
        sw_speachMode.enabled = false;
        sw1_button.enabled = false;
        sw2_button.enabled = false;
        sw3_button.enabled = false;
        sw4_button.enabled = false;

        sw_label_speachMode.text = @"Speach Mode\nOFFLINE";
        [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFFLINE",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
        [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFFLINE",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
        [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFFLINE",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
        [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFFLINE",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
        
        sw_label_speachMode.textColor = UIColor.darkGrayColor;
        sw1_label_button.textColor = UIColor.darkGrayColor;
        sw2_label_button.textColor = UIColor.darkGrayColor;
        sw3_label_button.textColor = UIColor.darkGrayColor;
        sw4_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw_speachMode setBackgroundImage:img forState:UIControlStateNormal];
        [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
        [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
        [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
        [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
    
        [self stop];
        
        blnFirstStart = true;
    
        if(![total_serial_key isEqualToString:@""]){
            [Konashi findWithName:total_serial_key];
        }
        
    }else{
            
        NSLog(@"=- konashi on line -=");
        /*
        if(gpsIdoChenge_Flg){
            
            NSLog(@"=- Gps Chenge -=");
            if(gpsChenge_Flg == false){
//                [self setLog:[NSString stringWithFormat:@"＞ 現在移動中の為、機能を制限します。"]];
                gpsChenge_Flg = true;
            }
            
            sw_speachMode.enabled = false;
            sw1_button.enabled = false;
            sw2_button.enabled = false;
            sw3_button.enabled = false;
            sw4_button.enabled = false;
            
            sw_label_speachMode.text = @"Speach Mode\n移動中制限";
            [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"『%@』\n移動中制限",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
            [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"『%@』\n移動中制限",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
            [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"『%@』\n移動中制限",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
            [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"『%@』\n移動中制限",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
            
            sw_label_speachMode.textColor = UIColor.lightGrayColor;
            sw1_label_button.textColor = UIColor.lightGrayColor;
            sw2_label_button.textColor = UIColor.lightGrayColor;
            sw3_label_button.textColor = UIColor.lightGrayColor;
            sw4_label_button.textColor = UIColor.lightGrayColor;
            
            UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
            [sw_speachMode setBackgroundImage:img forState:UIControlStateNormal];
            [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
            [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
            [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
            [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
            
            sw_chenge_Flg = true;
            
            blnFirstStart = true;
            
            if(![total_serial_key isEqualToString:@""]){
                [Konashi findWithName:total_serial_key];
            }
            
        }else{
            */
            if(gpsChenge_Flg){
//                [self setLog:[NSString stringWithFormat:@"＞ 現在移動停止中、機能を制限解除します。"]];
                gpsChenge_Flg = false;
            }
            
            sw_speachMode.enabled = true;
            sw1_button.enabled = true;
            sw2_button.enabled = true;
            sw3_button.enabled = true;
            sw4_button.enabled = true;
            
            if(blnFirstStart){

                sw_label_speachMode.text = @"Speach Mode\nOFF";
                [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"%@\nOFF",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
                [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"%@\nOFF",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
                [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"%@\nOFF",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
                [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"%@\nOFF",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
                
                if([UdSetting getUserBoolDefault:@"autoSaveSwitch"] == true){
                    
                    NSArray* sw_paturn = [UdSetting getUserArrayDefault:@"sw_paturn"];
                    if([[sw_paturn objectAtIndex:0] boolValue] == true){
                        
                        [self setSw1ON];
                    }else{
                        
                        [self setSw1OFF];
                    }
                    
                    if([[sw_paturn objectAtIndex:1] boolValue] == true){
                        
                        [self setSw2ON];
                    }else{
                        
                        [self setSw2OFF];
                    }
                    
                    if([[sw_paturn objectAtIndex:2] boolValue] == true){
                        
                        [self setSw3ON];
                    }else{
                        
                        [self setSw3OFF];
                    }
                    
                    if([[sw_paturn objectAtIndex:3] boolValue] == true){
                        
                        [self setSw4ON];
                    }else{
                        
                        [self setSw4OFF];
                    }
                    
                    if(bln_SpeachMode == false){
                        if([[sw_paturn objectAtIndex:4] boolValue] == true){
                            
                            [self setSpeachON];
                        }else{
                            
                            [self setSpeachOFF];
                        }
                    }else{
                        
                        [self setSpeachON];
                    }
                }else{
                    
                    [self setSw1OFF];
                    [self setSw2OFF];
                    [self setSw3OFF];
                    [self setSw4OFF];
                    [self setSpeachOFF];
                }
                
                sw_chenge_Flg = false;
                blnFirstStart = false;
            }
            
            //前回のスイッチ状態の回復
            if(sw_chenge_Flg){
                if(konashi_onLine_Count <= 1){
                    
                    NSArray* sw_paturn = [UdSetting getUserArrayDefault:@"sw_paturn"];
                    if([[sw_paturn objectAtIndex:0] boolValue] == true){
                        
                        [self setSw1ON];
                    }else{
                        
                        [self setSw1OFF];
                    }
                    
                    if([[sw_paturn objectAtIndex:1] boolValue] == true){
                        
                        [self setSw2ON];
                    }else{
                        
                        [self setSw2OFF];
                    }
                    
                    if([[sw_paturn objectAtIndex:2] boolValue] == true){
                        
                        [self setSw3ON];
                    }else{
                        
                        [self setSw3OFF];
                    }
                    
                    if([[sw_paturn objectAtIndex:3] boolValue] == true){
                        
                        [self setSw4ON];
                    }else{
                        
                        [self setSw4OFF];
                    }
                    
                    if(bln_SpeachMode == false){
                        if([[sw_paturn objectAtIndex:4] boolValue] == true){
                            
                            [self setSpeachON];
                        }else{
                                
                            [self setSpeachOFF];
                        }
                    }else{
                        [self setSpeachON];
                    }
                    sw_chenge_Flg = false;
                }
            }
//        }
    }
    
    if(timerStartNow != nil){
        double timeOut = [NSDate timeIntervalSinceReferenceDate] - [timerStartNow timeIntervalSinceReferenceDate];
        if(timeOut >= 10){
            serchStartVoice_Flg = false;
            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
            [self serchOffSound];
            timerStartNow = nil;
        }
    }
}

- (IBAction)screenchenge:(id)sender {
    
    //タイマー停止
    if(bluetooth_connection_timer.isValid){
        [bluetooth_connection_timer invalidate];
    }
    
    //スピーチボタンのOFF
    sw_label_speachMode.text = @"Speach Mode\nOFF";
    sw_label_speachMode.textColor = UIColor.darkGrayColor;
    
    UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
    [sw_speachMode setBackgroundImage:img forState:UIControlStateNormal];
    
    [self setSpeachOFF];
    
    SettingTopViewController *settingTopVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"SettingTopViewController"];
    settingTopVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.navigationController pushViewController:settingTopVC animated:YES];
}

- (IBAction)speachOnOff:(id)sender {
    
    if([Konashi isConnected] == YES){
        
        if(bln_SpeachMode == false){
            
            [self setSpeachON];
        }else{
            
            [self setSpeachOFF];
        }
    }
}

- (IBAction)onButtonMic:(id)sender {
    
    sw_chenge_Flg = true;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->_mode==SPEECHREC_RECOG_MODE_NONE){
            [self start];
        }else{
            [self stop];
        }
    });
}

- (IBAction)sw1_action:(id)sender {
    
    sw_chenge_Flg = true;

    [self sw1_action_set];
}

- (void)sw1_action_set {
    
    if (sw1_OnOff_Flg == false) {
        
        [self setSw1ON];
        
    }else{
        
        [self setSw1OFF];
    }
}

- (void)sw1_action_set_on {
    
    [self setSw1ON];
}

- (void)sw1_action_set_off {
    
    [self setSw1OFF];
}

- (IBAction)sw2_action:(id)sender {
    
    sw_chenge_Flg = true;
    
    [self sw2_action_set];
}

- (void)sw2_action_set {
    
    if (sw2_OnOff_Flg == false) {
        
        [self setSw2ON];
        
    }else{
        
        [self setSw2OFF];
    }
}

- (void)sw2_action_set_on {
    
    [self setSw2ON];
}

- (void)sw2_action_set_off {
    
    [self setSw2OFF];
}

- (IBAction)sw3_action:(id)sender {
    
    sw_chenge_Flg = true;
    
    [self sw3_action_set];
}

- (void)sw3_action_set {
    
    if (sw3_OnOff_Flg == false) {
        
        [self setSw3ON];
        
    }else{
        
        [self setSw3OFF];
    }
}

- (void)sw3_action_set_on {
    
    [self setSw3ON];
}

- (void)sw3_action_set_off {
    
    [self setSw3OFF];
}

- (IBAction)sw4_action:(id)sender {
    
    sw_chenge_Flg = true;
    
    [self sw4_action_set];
}

- (void)sw4_action_set {
    
    if (sw4_OnOff_Flg == false) {
        
        [self setSw4ON];
        
    }else{
        
        [self setSw4OFF];
    }
}

- (void)sw4_action_set_on {
    
    [self setSw4ON];
}

- (void)sw4_action_set_off {
    
    [self setSw4OFF];
}

- (void)sw_allON_action_set {
    
    [self setSw1ON];
    [self setSw2ON];
    [self setSw3ON];
    [self setSw4ON];
}

- (void)sw_allOFF_action_set {
    
    [self setSw1OFF];
    [self setSw2OFF];
    [self setSw3OFF];
    [self setSw4OFF];
}

#pragma mark Delegate method from SRClientHelper

- (void)srcDidRecognize:(NSData*)data {
    
    @try {
        
        id decodedObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableString* serializedString = nil;
        if([decodedObj isMemberOfClass:[SRNbest class]]){
            SRNbest* nbestObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if([self isResultXml]){
                NSString* str = [nbestObj serialize];
                if(str == nil){
                    return;
                }
                if([NSMutableString stringWithString:[nbestObj serialize]]){
                    serializedString = [NSMutableString stringWithString:[nbestObj serialize]];
                }else{
                    serializedString = [NSMutableString stringWithString:@"(結果なし)"];
                }
            }else{
                serializedString = [[NSMutableString alloc]init];
                if(![nbestObj sentenceArray]||[[nbestObj sentenceArray]count]<1){
                    [serializedString appendString:@"(結果なし)"];
                }else{
                    for(NSString* sentenceString in [nbestObj getNbestStringArray:YES]){
                        if([serializedString length]>0){
                            [serializedString appendString:@"\r"];
                        }
                        [serializedString appendString:sentenceString];
                    }
                }
            }
        }
        [self showAlert:serializedString title:@"認識結果"];
    }
    @catch(NSException *exception) {

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"srcDidRecognize にて例外エラー" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];

        
        return;
    }
}

- (void)srcDidReady
{
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_READY];
}

- (void)srcDidSentenceEnd
{
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_RECOGNIZE];
}

- (void)srcDidComplete:(NSError*)error
{
    if(error){
        NSString* description = [error localizedDescription];
        NSString* reason = [error localizedFailureReason];
        [self showAlert:reason title:description];
    }
    [self swapButtonImage:SPEECHREC_BUTTON_MODE_NONE];
    if(_srcHelper){
        [_srcHelper setDelegate:nil];
        _srcHelper = nil;
    }
}

- (void)srcDidRecord:(NSData*)pcmData
{
    double level = [self decibelFromData:pcmData];
    [self performSelectorOnMainThread:@selector(updatePressureLevel:) withObject:[NSNumber numberWithDouble:level] waitUntilDone:NO];
}

#pragma mark Private method

- (void)start {
    
    if(_settings){
        _settings = nil;
    }
    _settings = [NSMutableDictionary dictionary];
    // get setting from settings.bundle
    //DocomoAPI Setting
    [_settings setObject:[APP_DELEGATE api_key] forKey:@"api_key"];
    [_settings setObject:[NSNumber numberWithBool:YES]
                  forKey:@"result_xml"];
    
    if(!_srcHelper){
        _srcHelper = [[SRClientHelper alloc] initWithDevice:_settings];
        if(!_srcHelper){
            [self showAlert:@"初期化失敗" title:@"エラー"];
            [self swapButtonImage:SPEECHREC_BUTTON_MODE_NONE];
            return;
        }else{
            _srcHelper.delegate = (id)self;
        }
    }
    [_srcHelper start];
}

- (void)stop {
    
    if(_srcHelper){
        [_srcHelper stop];
    }
}

//設定画面のパラメータ取得用
- (void)loadSetting:(NSString*)key type:(SPEECHREC_SETTING_TYPE)settingType {
    
    @try {
        id preferenceValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        id defaultValue = [self getUserDefault:key];
        NSString* prefString;
        switch(settingType){
            case SPEECHREC_SETTING_TYPE_BOOL:
                if(preferenceValue){
                    prefString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
                    if(prefString&&[prefString length]>0){
                        [_settings setObject:[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:key]]
                                      forKey:key];
                        break;
                    }
                }
                if(defaultValue){
                    [_settings setObject:[NSNumber numberWithBool:[defaultValue boolValue]]
                                  forKey:key];
                }
                break;
            case SPEECHREC_SETTING_TYPE_INTEGER:
                if(preferenceValue){
                    prefString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
                    if(prefString&&[prefString length]>0){
                        [_settings setObject:[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:key]]
                                      forKey:key];
                        break;
                    }
                }
                if(defaultValue){
                    [_settings setObject:[NSNumber numberWithInteger:[defaultValue integerValue]]
                                  forKey:key];
                }
                break;
            case SPEECHREC_SETTING_TYPE_REAL:
                if(preferenceValue){
                    prefString = [[NSUserDefaults standardUserDefaults] stringForKey:key];
                    if(prefString&&[prefString length]>0){
                        [_settings setObject:[NSNumber numberWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:key]]
                                      forKey:key];
                        break;
                    }
                }
                if(defaultValue){
                    [_settings setObject:[NSNumber numberWithDouble:[defaultValue doubleValue]]
                                  forKey:key];
                }
                break;
            case SPEECHREC_SETTING_TYPE_STRING:
            {
                if(preferenceValue){
                    [_settings setObject:[[NSUserDefaults standardUserDefaults] stringForKey:key]
                                  forKey:key];
                }else{
                    if(defaultValue&&[defaultValue length]>0){
                        [_settings setObject:defaultValue
                                      forKey:key];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    @catch(NSException *exception) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"loadSetting にて例外エラー" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
}

- (id)getUserDefault:(NSString*)key {
    
    id defaultValueId = nil;
    NSString* rootPlistFile = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"] stringByAppendingPathComponent:@"Root.plist"];
    NSDictionary* settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:rootPlistFile];
    NSArray* preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary* item in preferencesArray){
        NSString* keyValue = [item objectForKey:@"Key"];
        id defaultValue = [item objectForKey:@"DefaultValue"];
        if(keyValue&&defaultValue) {
            if ([keyValue compare:key] == NSOrderedSame) {
                defaultValueId = defaultValue;
            }
        }
    }
    return defaultValueId;
}

- (BOOL)isResultXml
{
    BOOL ret = NO;
    if([_settings objectForKey:@"result_xml"]&&[[_settings objectForKey:@"result_xml"] boolValue]){
        ret = YES;
    }
    return ret;
}

- (double)decibelFromData:(NSData*)data
{
    double decibel = 0;
    if(data&&[data length]>0){
        short* noiseReductData = (short*)malloc([data length]);
        [data getBytes:noiseReductData length:[data length]];
        for(int i=0; i<[data length]/sizeof(short); i++){
            short sample = noiseReductData[i];
            if(sample==0){
                sample = 1;
            }
            double db = log10(pow(sample, 2) / pow(SHRT_MAX, 2)) * 10;
            decibel += db;
        }
        decibel /= ([data length]/sizeof(short));
        free(noiseReductData);
        noiseReductData = NULL;
    }
    return decibel;
}

- (void)updatePressureLevel:(NSNumber*)levelObj{
    
    double level = [levelObj doubleValue];
    SPEECHREC_BUTTON_MODE newLevel = _latestLevel;
    if(-10<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_15;
    }else if(-15<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_14;
    }else if(-20<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_13;
    }else if(-25<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_12;
    }else if(-30<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_11;
    }else if(-35<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_10;
    }else if(-40<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_9;
    }else if(-45<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_8;
    }else if(-50<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_7;
    }else if(-55<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_6;
    }else if(-60<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_5;
    }else if(-65<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_4;
    }else if(-70<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_3;
    }else if(-75<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_2;
    }else if(-80<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_1;
    }else if(-90<level){
        newLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
    }
    if(abs(_latestLevel-newLevel)>2){
        if(_latestLevel>newLevel){
            newLevel -= _latestLevel;
        }else{
            newLevel += _latestLevel;
        }
        if(newLevel>SPEECHREC_BUTTON_MODE_LEVEL_15){
            newLevel = SPEECHREC_BUTTON_MODE_LEVEL_15;
        }
        if(newLevel<SPEECHREC_BUTTON_MODE_LEVEL_0){
            newLevel = SPEECHREC_BUTTON_MODE_LEVEL_0;
        }
        _latestLevel = newLevel;
    }
    [self swapButtonImage:newLevel];
}

- (void)swapButtonImage:(SPEECHREC_BUTTON_MODE)mode{
    
    @try {
        UIImage* buttonImage = [UIImage imageNamed:@"speaking.png"];
        float alpha = 0.6;
        float zoom = 0.8;
        if(serchStartVoice_Flg){

            alpha = 0.9;
            zoom = 0.8;
            
            switch(mode){
                case SPEECHREC_BUTTON_MODE_NONE:
                    _mode = SPEECHREC_RECOG_MODE_NONE;
                    buttonImage = [UIImage imageNamed:@"speaking.png"];
                    alpha = 0.6;
                    zoom = 0.8;
                    break;
                case SPEECHREC_BUTTON_MODE_READY:
                    _mode = SPEECHREC_RECOG_MODE_PUSH;
                    buttonImage = [UIImage imageNamed:@"speaking.png"];
                    alpha = 0.6;
                    zoom = 0.8;
                    break;
                case SPEECHREC_BUTTON_MODE_LEVEL_0:
                case SPEECHREC_BUTTON_MODE_LEVEL_1:
                case SPEECHREC_BUTTON_MODE_LEVEL_2:
                case SPEECHREC_BUTTON_MODE_LEVEL_3:
                case SPEECHREC_BUTTON_MODE_LEVEL_4:
                case SPEECHREC_BUTTON_MODE_LEVEL_5:
                case SPEECHREC_BUTTON_MODE_LEVEL_6:
                case SPEECHREC_BUTTON_MODE_LEVEL_7:
                case SPEECHREC_BUTTON_MODE_LEVEL_8:
                case SPEECHREC_BUTTON_MODE_LEVEL_9:
                case SPEECHREC_BUTTON_MODE_LEVEL_10:
                case SPEECHREC_BUTTON_MODE_LEVEL_11:
                case SPEECHREC_BUTTON_MODE_LEVEL_12:
                case SPEECHREC_BUTTON_MODE_LEVEL_13:
                    if(_mode!=SPEECHREC_RECOG_MODE_RECOG){
                        _mode = SPEECHREC_RECOG_MODE_PUSH;
                        buttonImage = [UIImage imageNamed:@"speaking_red.png"];
                        alpha = 0.9;
                        zoom = 0.7;
                    }
                    break;
                case SPEECHREC_BUTTON_MODE_LEVEL_14:
                    if(_mode!=SPEECHREC_RECOG_MODE_RECOG){
                        _mode = SPEECHREC_RECOG_MODE_PUSH;
                        buttonImage = [UIImage imageNamed:@"speaking_red.png"];
                        alpha = 0.9;
                        zoom = 0.8;
                    }
                    break;
                case SPEECHREC_BUTTON_MODE_LEVEL_15:
                    if(_mode!=SPEECHREC_RECOG_MODE_RECOG){
                        _mode = SPEECHREC_RECOG_MODE_PUSH;
                        buttonImage = [UIImage imageNamed:@"speaking_red.png"];
                        alpha = 0.9;
                        zoom = 0.9;
                    }
                    break;
                case SPEECHREC_BUTTON_MODE_RECOGNIZE:
                    _mode = SPEECHREC_RECOG_MODE_RECOG;
                    buttonImage = [UIImage imageNamed:@"speaking_red.png"];
                    alpha = 0.9;
                    zoom = 1.0;
                    break;
                default:
                    break;
            }
        }else{
            
            alpha = 0.6;
            zoom = 0.8;
        }
        
        [UIView beginAnimations:@"micAnim" context:NULL];
        [UIView setAnimationDuration:0.05f];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationRepeatAutoreverses:FALSE];
        [speach_lock setAlpha:alpha];
        [speach_lock setImage:buttonImage];
        [speach_lock setTransform:CGAffineTransformMakeScale(zoom, zoom)];
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"swapButtonImage にて例外エラー" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
}

- (void) showAlert:(NSString*)message title:(NSString*)title {
    
    @try {
        if ([UIAlertController class]) {
            
            NSError *parseError = nil;
            //辞書（XML原本データ）
            NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:message error:&parseError];
//            NSLog(@" %@", xmlDictionary);
            
            //辞書（Nbest）
            NSMutableDictionary *Nbest = [xmlDictionary objectForKey:@"Nbest"];
//            NSLog(@"Nbest  _count %ld _ %@", Nbest.count, Nbest);
            
            //辞書（Sentence）
            NSMutableArray *Sentence = [Nbest objectForKey:@"Sentence"];
//            NSLog(@"Sentence _count %ld _ %@", Sentence.count, Sentence);
            
            NSMutableArray* list_voiceTextData = [NSMutableArray array];
            
            for(int Sentence_idx=0;Sentence_idx<Sentence.count;Sentence_idx++){
                //辞書（Sentence）
                NSDictionary *Sentence_list = [Sentence objectAtIndex:Sentence_idx];
                NSLog(@"Sentence_list _count %ld/%ld _ %@", Sentence_idx, Sentence.count, Sentence_list);
                
                NSMutableArray *Word_array = [Sentence_list objectForKey:@"Word"];
                NSMutableDictionary *Word_dic = [Sentence_list objectForKey:@"Word"];
//                BOOL is_exists = [Word_dic.allKeys containsObject:@"Label"];
                
                BOOL isWordNotSingleData = false;
                @try {
                    BOOL is_dt = ([Word_dic objectForKey:@"Label"] != nil);
                    isWordNotSingleData = true;
                }
                //
                @catch (NSException *exception) {
                    isWordNotSingleData = false;
                }
                
                //Wordのデータがシングルなのかによる分岐
                if(isWordNotSingleData){
                    
                    //辞書Wordのシングルデータ
                    NSMutableDictionary *Label = [Word_dic objectForKey:@"Label"];
                    //        NSLog(@"%@", Label);
                    NSString *search_text = [Label objectForKey:@"text"];
                    //        NSLog(@" %@", search_text);
                    NSArray* speach_text = [search_text componentsSeparatedByString:@";"];
                    //        NSLog(@" %@", speach_text);

                    NSLog(@"speach_text[0] = [%@]", [speach_text objectAtIndex:0]);
                    NSLog(@"speach_text[1] = [%@]", [speach_text objectAtIndex:1]);
                    NSLog(@"speach_text[2] = [%@]", [speach_text objectAtIndex:2]);
                    NSLog(@"speach_text[3] = [%@]", [speach_text objectAtIndex:3]);
                    NSLog(@"speach_text[4] = [%@]", [speach_text objectAtIndex:4]);
                        
                    //音声認識にてカタカナのみ取得して確認
                    NSString* str_serchText = [speach_text objectAtIndex:1];
                    
                    //連用詞接続ワード
//                    NSLog(@"連用詞検索ワード [%@]", str_wordConnect);
                    
                    NSArray* ruiji_text = [str_serchText componentsSeparatedByString:@","];

                    for(int l=0;l<ruiji_text.count;l++){
                        [list_voiceTextData addObject:[ruiji_text objectAtIndex:l]];
                    }
                    
                }else{
                    
                    //辞書Wordの複数データ
                    NSString* str_mojiRenketsu = @"";
                    int word_idx = 0;
                    BOOL remketsu_flg = false;
                    while (word_idx<Word_array.count){
                        
                        NSMutableDictionary *Label = [[Word_array objectAtIndex:word_idx] objectForKey:@"Label"];
                        //        NSLog(@"%@", Label);
                        NSString *search_text = [Label objectForKey:@"text"];
                        //        NSLog(@" %@", search_text);
                        NSArray* speach_text = [search_text componentsSeparatedByString:@";"];
                        //        NSLog(@" %@", speach_text);
                        
                        NSLog(@"speach_text[0] = [%@]", [speach_text objectAtIndex:0]);
                        NSLog(@"speach_text[1] = [%@]", [speach_text objectAtIndex:1]);
                        NSLog(@"speach_text[2] = [%@]", [speach_text objectAtIndex:2]);
                        NSLog(@"speach_text[3] = [%@]", [speach_text objectAtIndex:3]);
                        NSLog(@"speach_text[4] = [%@]", [speach_text objectAtIndex:4]);
                        
                        //音声認識にてカタカナのみ取得して確認
                        NSString* str_serchText = [speach_text objectAtIndex:1];
                        
                        str_mojiRenketsu = [str_mojiRenketsu stringByAppendingString:str_serchText];
                        
                        word_idx = word_idx + 1;
                    }
                    
                    str_mojiRenketsu = [str_mojiRenketsu stringByReplacingOccurrencesOfString:@"、" withString:@""];
                    
                    [list_voiceTextData addObject:str_mojiRenketsu];
                }
            }
            
            //検索単語データ
            NSLog(@"list_voiceTextData _count %ld _ %@", list_voiceTextData.count, list_voiceTextData);
            int l = 0;
            while (l<list_voiceTextData.count) {
                NSLog(@"count %d _ %@", l, [list_voiceTextData objectAtIndex:l]);
                
                l = l + 1;
            }
            
            BOOL bln_sw_chenge = false;
            int list_voiceTextData_idx = 0;
            while (list_voiceTextData_idx<list_voiceTextData.count){
                
                NSString *str_SearchName = [list_voiceTextData objectAtIndex:list_voiceTextData_idx];
                
                if ([str_SearchName rangeOfString:[UdSetting getUserStringDefault:@"startFlaze"]].location != NSNotFound) {
                    serchStartVoice_Flg = true;
                    [self setLog:[NSString stringWithFormat:@"ーーーーー　検索開始　ーーーーー\n＞音声入力開始"]];
                    
                    NSURL *soundurl = [[NSBundle mainBundle] URLForResource: @"speachOn" withExtension: @"mp3"];
                    AVAudioPlayer *mySoundPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:soundurl error:nil];
                    mySoundPlayer.volume = 100.0f;
                    [mySoundPlayer prepareToPlay];
                    mySoundPlayer.numberOfLoops = 0;
                    
                    [mySoundPlayer play];
                    [NSThread sleepForTimeInterval:0.5];
                    
                    //検索開始時間設定
                    timerStartNow = [NSDate date];
                    
                    break;
                }else
                
                if(serchStartVoice_Flg == true){
                    
                    NSLog(@"検索名：  %@", str_SearchName);
#ifdef DEBUG
//                    [self setLog:[NSString stringWithFormat:@"=>検索名:%@",str_SearchName]];
#endif /* if DEBUG */
                    
                    NSString* swOn_pattern = @"オン";
                    NSString* swOff_pattern = @"オフ";
                    BOOL onCheck = [str_SearchName rangeOfString:swOn_pattern].location != NSNotFound;
                    BOOL offCheck = [str_SearchName rangeOfString:swOff_pattern].location != NSNotFound;
                    
                    NSString* sw1_pattern = [UdSetting getUserStringDefault:@"sw1_callFlaze"];
                    NSArray* check_array = [sw1_pattern componentsSeparatedByString:@","];
                    int array_count = 0;
                    NSArray* speach_array = [str_SearchName componentsSeparatedByString:@","];
                    if(bln_sw_chenge == false){
                        while(array_count < check_array.count){
                            
                            int speach_count = 0;
                            while(speach_count < speach_array.count){
                                
                                if([UdSetting getUserBoolDefault:@"sw1_callFlazeOnOff"]){
                                    if([UdSetting getUserBoolDefault:@"sw1_callFlazeOnOffTurn"] == false){
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw1_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw1_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }else{
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw1_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw1_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }
                                }else{
                                    
                                    if ([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) {
                                        [self sw1_action_set];
                                        bln_sw_chenge = true;
                                        [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                        serchStartVoice_Flg = false;
                                        [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                        [self serchOffSound];
                                        timerStartNow = 0;
                                        break;
                                    }
                                }
                                speach_count +=1;
                            }
                            if(bln_sw_chenge){
                                break;
                            }
                            array_count +=1;
                        }
                    }
                    
                    NSString* sw2_pattern =  [UdSetting getUserStringDefault:@"sw2_callFlaze"];
                    check_array = [sw2_pattern componentsSeparatedByString:@","];
                    array_count = 0;
                    speach_array = [str_SearchName componentsSeparatedByString:@","];
                    if(bln_sw_chenge == false){
                        while(array_count < check_array.count){
                            
                            int speach_count = 0;
                            while(speach_count < speach_array.count){
                                
                                if([UdSetting getUserBoolDefault:@"sw2_callFlazeOnOff"]){
                                    if([UdSetting getUserBoolDefault:@"sw2_callFlazeOnOffTurn"] == false){
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw2_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw2_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }else{
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw2_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw2_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }
                                }else{
                                    
                                    if ([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) {
                                        [self sw2_action_set];
                                        bln_sw_chenge = true;
                                        [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                        serchStartVoice_Flg = false;
                                        [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                        [self serchOffSound];
                                        timerStartNow = 0;
                                        break;
                                    }
                                }
                                speach_count +=1;
                            }
                            if(bln_sw_chenge){
                                break;
                            }
                            array_count +=1;
                        }
                    }

                    NSString* sw3_pattern = [UdSetting getUserStringDefault:@"sw3_callFlaze"];
                    check_array = [sw3_pattern componentsSeparatedByString:@","];
                    array_count = 0;
                    speach_array = [str_SearchName componentsSeparatedByString:@","];
                    if(bln_sw_chenge == false){
                        while(array_count < check_array.count){
                            
                            int speach_count = 0;
                            while(speach_count < speach_array.count){
                                
                                if([UdSetting getUserBoolDefault:@"sw3_callFlazeOnOff"]){
                                    if([UdSetting getUserBoolDefault:@"sw3_callFlazeOnOffTurn"] == false){
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw3_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw3_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }else{
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw3_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw3_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }
                                }else{
                                    
                                    if ([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) {
                                        [self sw3_action_set];
                                        bln_sw_chenge = true;
                                        [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                        serchStartVoice_Flg = false;
                                        [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                        [self serchOffSound];
                                        timerStartNow = 0;
                                        break;
                                    }
                                }
                                speach_count +=1;
                            }
                            if(bln_sw_chenge){
                                break;
                            }
                            array_count +=1;
                        }
                    }
                    
                    NSString* sw4_pattern = [UdSetting getUserStringDefault:@"sw4_callFlaze"];
                    check_array = [sw4_pattern componentsSeparatedByString:@","];
                    array_count = 0;
                    speach_array = [str_SearchName componentsSeparatedByString:@","];
                    if(bln_sw_chenge == false){
                        while(array_count < check_array.count){
                            
                            int speach_count = 0;
                            while(speach_count < speach_array.count){
                                
                                if([UdSetting getUserBoolDefault:@"sw3_callFlazeOnOff"]){
                                    if([UdSetting getUserBoolDefault:@"sw3_callFlazeOnOffTurn"] == false){
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw4_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw4_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }else{
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == YES) && (offCheck == NO)) {
                                            [self sw4_action_set_off];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                        
                                        if (([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) && (onCheck == NO) && (offCheck == YES)) {
                                            [self sw4_action_set_on];
                                            bln_sw_chenge = true;
                                            [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                            serchStartVoice_Flg = false;
                                            [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                            [self serchOffSound];
                                            timerStartNow = 0;
                                            break;
                                        }
                                    }
                                }else{
                                    
                                    if ([speach_array[speach_count] rangeOfString:check_array[array_count]].location != NSNotFound) {
                                        [self sw4_action_set];
                                        bln_sw_chenge = true;
                                        [self setLog:[NSString stringWithFormat:@"認識名:%@",str_SearchName]];
                                        
                                        serchStartVoice_Flg = false;
                                        [self setLog:@"ーーーーー　検索終了　ーーーーー"];
                                        [self serchOffSound];
                                        timerStartNow = 0;
                                        break;
                                    }
                                }
                                speach_count +=1;
                            }
                            if(bln_sw_chenge){
                                break;
                            }
                            array_count +=1;
                        }
                    }
                }
                list_voiceTextData_idx = list_voiceTextData_idx + 1;
            }
        }
        bln_Insearch = false;
    }
    /* 例外が起きると実行される */
    @catch (NSException *exception) {
        bln_Insearch = false;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"エラー" message:@"showAlert にて例外エラー" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
}

-(void)serchOffSound {
    
    NSURL *soundurl = [[NSBundle mainBundle] URLForResource: @"speachOff" withExtension: @"mp3"];
    AVAudioPlayer *mySoundPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:soundurl error:nil];
    mySoundPlayer.volume = 1.0f;
    [mySoundPlayer prepareToPlay];
    mySoundPlayer.numberOfLoops = 0;
    
    [mySoundPlayer play];
    [NSThread sleepForTimeInterval:0.5];
}

-(void)setLog:(NSString*)comment {
    
    if([speachLog_text.text isEqualToString:@""]){
        
        speachLog_text.text = [NSString stringWithFormat:@"%@",comment];
    }else{
        
        speachLog_text.text = [NSString stringWithFormat:@"%@\n%@",speachLog_text.text,comment];
    }
    
    //テキストビューを文末に移動
    dispatch_async(dispatch_get_main_queue(), ^{
        // 一番下を表示する
        if(self->speachLog_text.text.length > 0 ) {
            NSRange bottom = NSMakeRange(self->speachLog_text.text.length -1, 1);
            [self->speachLog_text scrollRangeToVisible:bottom];
        }
    });
}

- (void)setSw1ON {
    
    sw1_OnOff_Flg = true;
    
    if([UdSetting getUserBoolDefault:@"sw1_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
        sw1_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
        sw1_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmMode:KonashiDigitalIO1 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO1 period:0];
    [Konashi pwmDuty:KonashiDigitalIO1 duty:1];
    [Konashi pwmMode:KonashiDigitalIO0 mode:KonashiPWMModeDisable];
    [Konashi pwmPeriod:KonashiDigitalIO0 period:0];
    [Konashi pwmDuty:KonashiDigitalIO0 duty:1];
}

- (void)setSw1OFF {
    
    sw1_OnOff_Flg = false;
    
    if([UdSetting getUserBoolDefault:@"sw1_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
        sw1_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw1_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw1_callFlaze"]]];
        sw1_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw1_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmMode:KonashiDigitalIO0 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO0 period:0];
    [Konashi pwmDuty:KonashiDigitalIO0 duty:1];
    [Konashi pwmMode:KonashiDigitalIO1 mode:KonashiPWMModeDisable];
    [Konashi pwmPeriod:KonashiDigitalIO1 period:0];
    [Konashi pwmDuty:KonashiDigitalIO1 duty:1];
}

- (void)setSw2ON {
    
    sw2_OnOff_Flg = true;
    
    if([UdSetting getUserBoolDefault:@"sw2_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
        sw2_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
        sw2_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmPeriod:KonashiDigitalIO3 period:0];
    [Konashi pwmDuty:KonashiDigitalIO3 duty:1];
    [Konashi pwmMode:KonashiDigitalIO3 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO2 period:0];
    [Konashi pwmDuty:KonashiDigitalIO2 duty:1];
    [Konashi pwmMode:KonashiDigitalIO2 mode:KonashiPWMModeDisable];
}

- (void)setSw2OFF {
    
    sw2_OnOff_Flg = false;
    
    if([UdSetting getUserBoolDefault:@"sw2_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
        sw2_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw2_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw2_callFlaze"]]];
        sw2_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw2_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmPeriod:KonashiDigitalIO2 period:0];
    [Konashi pwmDuty:KonashiDigitalIO2 duty:1];
    [Konashi pwmMode:KonashiDigitalIO2 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO3 period:0];
    [Konashi pwmDuty:KonashiDigitalIO3 duty:1];
    [Konashi pwmMode:KonashiDigitalIO3 mode:KonashiPWMModeDisable];
}

- (void)setSw3ON {
    
    sw3_OnOff_Flg = true;
    
    if([UdSetting getUserBoolDefault:@"sw3_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
        sw3_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
        sw3_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmMode:KonashiDigitalIO5 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO5 period:0];
    [Konashi pwmDuty:KonashiDigitalIO5 duty:1];
    [Konashi pwmMode:KonashiDigitalIO4 mode:KonashiPWMModeDisable];
    [Konashi pwmPeriod:KonashiDigitalIO4 period:0];
    [Konashi pwmDuty:KonashiDigitalIO4 duty:1];
}

- (void)setSw3OFF {
    
    sw3_OnOff_Flg = false;
    
    if([UdSetting getUserBoolDefault:@"sw3_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
        sw3_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw3_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw3_callFlaze"]]];
        sw3_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw3_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmMode:KonashiDigitalIO4 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO4 period:0];
    [Konashi pwmDuty:KonashiDigitalIO4 duty:1];
    [Konashi pwmMode:KonashiDigitalIO5 mode:KonashiPWMModeDisable];
    [Konashi pwmPeriod:KonashiDigitalIO5 period:0];
    [Konashi pwmDuty:KonashiDigitalIO5 duty:1];
}

- (void)setSw4ON {
    
    sw4_OnOff_Flg = true;
    
    if([UdSetting getUserBoolDefault:@"sw4_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
        sw4_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
        sw4_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmMode:KonashiDigitalIO7 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO7 period:0];
    [Konashi pwmDuty:KonashiDigitalIO7 duty:1];
    [Konashi pwmMode:KonashiDigitalIO6 mode:KonashiPWMModeDisable];
    [Konashi pwmPeriod:KonashiDigitalIO6 period:0];
    [Konashi pwmDuty:KonashiDigitalIO6 duty:1];
}

- (void)setSw4OFF {
    
    sw4_OnOff_Flg = false;
    
    if([UdSetting getUserBoolDefault:@"sw4_callFlazeOnOffTurn"] == false){
        
        [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"『%@』\nOFF",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
        sw4_label_button.textColor = UIColor.darkGrayColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
        [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
    }else{
        
        [self LabelTextSet:sw4_label_button labelText:[NSString stringWithFormat:@"『%@』\nON",[UdSetting getUserStringDefault:@"sw4_callFlaze"]]];
        sw4_label_button.textColor = UIColor.redColor;
        
        UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
        [sw4_button setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    [self setSwicheFlg];
    
    [Konashi pwmMode:KonashiDigitalIO6 mode:KonashiPWMModeEnable];
    [Konashi pwmPeriod:KonashiDigitalIO6 period:0];
    [Konashi pwmDuty:KonashiDigitalIO6 duty:1];
    [Konashi pwmMode:KonashiDigitalIO7 mode:KonashiPWMModeDisable];
    [Konashi pwmPeriod:KonashiDigitalIO7 period:0];
    [Konashi pwmDuty:KonashiDigitalIO7 duty:1];
}

- (void)setSpeachON {
    
    bln_SpeachMode = true;
    
    sw_label_speachMode.text = @"Speach Mode\nON";
    sw_label_speachMode.textColor = UIColor.redColor;
    
    UIImage *img = [UIImage imageNamed:@"Big_ON.png"];
    [sw_speachMode setBackgroundImage:img forState:UIControlStateNormal];
    
    [self setLog:[NSString stringWithFormat:@"＞「開始呼び出しフレーズ」にて\n呼び出し後に指示をしてください。"]];
    [self start];
    
    [self setSwicheFlg];
}

- (void)setSpeachOFF {
    
    bln_SpeachMode = false;
    
    sw_label_speachMode.text = @"Speach Mode\nOFF";
    sw_label_speachMode.textColor = UIColor.darkGrayColor;
    
    UIImage *img = [UIImage imageNamed:@"Big_OFF.png"];
    [sw_speachMode setBackgroundImage:img forState:UIControlStateNormal];
    
    [self stop];
    
    [self setSwicheFlg];
}

- (void)setSwicheFlg {
    
     [UdSetting setUserArrayDefault:@"sw_paturn" data:@[@(sw1_OnOff_Flg),@(sw2_OnOff_Flg),@(sw3_OnOff_Flg),@(sw4_OnOff_Flg),@(bln_SpeachMode)]];
}

- (void)LabelTextSet:(UILabel*)label labelText:(NSString*)labelText {
    
    NSString *text = labelText;
    
    // カスタムLineHeightを指定
    CGFloat customLineHeight = 25.0f;
    
    // パラグラフスタイルにlineHeightをセット
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    paragrahStyle.minimumLineHeight = customLineHeight;
    paragrahStyle.maximumLineHeight = customLineHeight;
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    // NSAttributedStringを生成してパラグラフスタイルをセット
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSParagraphStyleAttributeName
                           value:paragrahStyle
                           range:NSMakeRange(0, attributedText.length)];
    label.attributedText = attributedText;
}

@end
