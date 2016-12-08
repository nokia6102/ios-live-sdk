//
//  UPLivePlayerVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/20/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLivePlayerVC.h"
#import <UPLiveSDK/UPAVPlayer.h>
#import "AppDelegate.h"
#import "UPAVCapturer.h"

//在播放界面接入连麦功能
#import "UPAVCapturer.h"


@interface UPLivePlayerVC () <UPAVPlayerDelegate, UPAVCapturerDelegate>
{
    UPAVPlayer *_player;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_bufferingProgressLabel;
    BOOL _sliding;
    BOOL _rtcConnected;//是否已连麦
}

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UISlider *playProgressSlider;
@property (weak, nonatomic) IBOutlet UIButton *rtcBtn;



@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *bufferingProgressLabel;
@property (weak, nonatomic) IBOutlet UITextView *dashboardView;
@property (nonatomic, strong) UIView *videoPreview;//连麦大视图

@end

@implementation UPLivePlayerVC

- (void)viewDidLoad {
    [UPLiveSDKConfig setLogLevel:UP_Level_error];
    self.view.backgroundColor = [UIColor blackColor];
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    _activityIndicatorView.hidesWhenStopped = YES;
    
    [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playBtn setTitle:@"play" forState:UIControlStateNormal];
    [_stopBtn addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pauseBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [_pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    [_stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [_infoBtn addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    [_infoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_infoBtn setTitle:@"streamInfo" forState:UIControlStateNormal];
    
    [_rtcBtn addTarget:self action:@selector(rtcStart:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _bufferingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _bufferingProgressLabel.backgroundColor = [UIColor clearColor];
    _bufferingProgressLabel.textColor = [UIColor lightTextColor];
    
    _playProgressSlider.minimumValue = 0;
    _playProgressSlider.maximumValue = 0;
    _playProgressSlider.value = 0;
    _playProgressSlider.continuous = NO;
    [_playProgressSlider addTarget:self action:@selector(valueChange:) forControlEvents:(UIControlEventTouchUpInside)];
    [_playProgressSlider addTarget:self action:@selector(valueChange:) forControlEvents:(UIControlEventTouchUpOutside)];
    [_playProgressSlider addTarget:self action:@selector(touchDown:) forControlEvents:(UIControlEventTouchDown)];

    [self.view addSubview:_activityIndicatorView];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_stopBtn];
    [self.view addSubview:_infoBtn];
    [self.view addSubview:_bufferingProgressLabel];
    [self.view insertSubview:_rtcBtn atIndex:101];
    
    
    
    _player = [[UPAVPlayer alloc] initWithURL:self.url];
    _player.bufferingTime = self.bufferingTime;
    _player.delegate = self;
    _player.lipSynchOn = NO;
    self.dashboardView.hidden = YES;
    [self updateDashboard];
}

- (void)viewWillAppear:(BOOL)animated {

    self.view.frame = [UIScreen mainScreen].bounds;
    [_player setFrame:[UIScreen mainScreen].bounds];

    [self.view insertSubview:_player.playView atIndex:0];
    _activityIndicatorView.center = CGPointMake(_player.playView.center.x - 30, _player.playView.center.y);
    _bufferingProgressLabel.center = CGPointMake(_player.playView.center.x + 30, _player.playView.center.y);
    [self.view addSubview:_activityIndicatorView];
    [_player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stop:nil];
}

- (void)play:(id)sender {
    [_player play];
}

- (void)stop:(id)sender {
    [_player stop];
}
- (void)pause:(id)sender {
    [_player pause];
}




- (void)info:(id)sender {
    self.dashboardView.hidden =  !self.dashboardView.hidden;
}

- (void)updateDashboard{
    
    NSMutableString *string = [NSMutableString new];
    [string appendString:[NSString stringWithFormat:@"url: %@ \n", _player.dashboard.url]];
    [string appendString:[NSString stringWithFormat:@"serverName: %@ \n", _player.dashboard.serverName]];
    [string appendString:[NSString stringWithFormat:@"serverIp: %@ \n", _player.dashboard.serverIp]];
    [string appendString:[NSString stringWithFormat:@"cid: %d \n", _player.dashboard.cid]];
    [string appendString:[NSString stringWithFormat:@"pid: %d \n", _player.dashboard.pid]];
    [string appendString:[NSString stringWithFormat:@"fps: %.0f \n", _player.dashboard.fps]];
    [string appendString:[NSString stringWithFormat:@"bps: %.0f \n", _player.dashboard.bps]];
    [string appendString:[NSString stringWithFormat:@"vCachedFrames: %d \n", _player.dashboard.vCachedFrames]];
    [string appendString:[NSString stringWithFormat:@"aCachedFrames: %d \n", _player.dashboard.aCachedFrames]];
    [string appendString:[NSString stringWithFormat:@"vDecodedFrames: %d  key:%d\n", _player.dashboard.decodedVFrameNum,  _player.dashboard.decodedVKeyFrameNum]];
    [string appendString:[NSString stringWithFormat:@"aDecodedFrames: %d \n", _player.dashboard.decodedAFrameNum]];

    
    for (NSString *key in _player.streamInfo.descriptionInfo.allKeys) {
        [string appendString:[NSString stringWithFormat:@"%@: %@ \n", key, _player.streamInfo.descriptionInfo[key]]];
    }

    self.dashboardView.text = string;
    self.dashboardView.textColor = [UIColor whiteColor];
    
    double delayInSeconds = 1.0;
    
    __weak UPLivePlayerVC *weakself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakself updateDashboard];
    });
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if(_rtcConnected){
        [[UPAVCapturer sharedInstance] stop];
    }
}

-(void)touchDown:(UISlider *)slider{
    _sliding = YES;
}

-(void)valueChange:(UISlider *)slider_{
    NSLog(@"slider value : %.2f", slider_.value);
    if (_player) {
        [_player seekToTime:slider_.value];
        _sliding = NO;
    }
}

#pragma mark UPAVPlayerDelegate

- (void)player:(UPAVPlayer *)player streamStatusDidChange:(UPAVStreamStatus)streamStatus {
    switch (streamStatus) {
        case UPAVStreamStatusIdle:
            NSLog(@"连接断开－－－－－");
            break;
        case UPAVStreamStatusConnecting:{
            NSLog(@"建立连接－－－－－");
        }
            break;
        case UPAVStreamStatusReady:{
            NSLog(@"连接成功－－－－－");
        }
            break;
        default:
            break;
    }
}

- (void)player:(id)player playerStatusDidChange:(UPAVPlayerStatus)playerStatus {
    
    switch (playerStatus) {
        case UPAVPlayerStatusIdle:{
            NSLog(@"播放停止－－－－－");
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.playBtn.enabled = YES;
            [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = NO;
            [self.stopBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            [self.pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case UPAVPlayerStatusPause:{
            NSLog(@"播放暂停－－－－－");
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.playBtn.enabled = YES;
            [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = YES;
            [self.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            [self.pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case UPAVPlayerStatusPlaying_buffering:{
            NSLog(@"播放缓冲－－－－－");
            [self.activityIndicatorView startAnimating];
            self.bufferingProgressLabel.hidden = NO;
            self.playBtn.enabled = NO;
            [self.playBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = YES;
            [self.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = YES;
            [self.pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
        }
            break;
        case UPAVPlayerStatusPlaying:{
            NSLog(@"播放中－－－－－");
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.pauseBtn.enabled = YES;
            [self.pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
            break;
        case UPAVPlayerStatusFailed:{
            NSLog(@"播放失败－－－－－");

        }
            break;
        default:
            break;
    }
}

- (void)player:(id)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo {
    if (streamInfo.canPause && streamInfo.canSeek) {
        _playProgressSlider.enabled = YES;
        _playProgressSlider.maximumValue = streamInfo.duration;
        NSLog(@"streamInfo.duration %f", streamInfo.duration);
    } else {
        _playProgressSlider.enabled = NO;
    }
}

- (void)player:(id)player displayPositionDidChange:(float)position {
    if (_sliding) {
        return;
    }
    _playProgressSlider.value = position;
    self.timelabel.text = [NSString stringWithFormat:@"%.0f / %.0f", position, _player.streamInfo.duration];
}

- (void)player:(id)player playerError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
    self.bufferingProgressLabel.hidden = YES;
    NSString *msg = @"请重新尝试播放.";
    if (error) {
        NSLog(@"%@", error.description);
    }
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"播放失败!"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)player:(id)player bufferingProgressDidChange:(float)progress {
    self.bufferingProgressLabel.text = [NSString stringWithFormat:@"%.0f %%", (progress * 100)];
}

- (void)rtcStart:(UIButton *)sender {
    // 按钮切换
    if (sender.tag != 0) {
        sender.tag = 0;
        [sender setTitle:@"连麦" forState:UIControlStateNormal];
        //关闭当前连麦
        [[UPAVCapturer sharedInstance] stop];
        
        //观众端连麦结束之后 UPAVCapturer streamingOn 属性最好恢复默认值。避免主播端调用时候 UPAVCapturer 引起无法推流。
        [UPAVCapturer sharedInstance].streamingOn = YES;

        [self.videoPreview removeFromSuperview];
        return;
        
    } else {
        sender.tag = 1;
        [sender setTitle:@"关闭连麦" forState:UIControlStateNormal];
    }
    //连麦需要先关掉播放器
    [_player stop];
    //_player stop 是异步的在 main_queue 执行，无法立即结束。所以需要在 main_queue 下一个 block 中来启动连麦过程。
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSLog(@"开启采集 － 进行连麦");
        //设置代理，采集状态信息回调
        [UPAVCapturer sharedInstance].delegate = self;
        self.videoPreview = [[UPAVCapturer sharedInstance] previewWithFrame:[UIScreen mainScreen].bounds
                                                                contentMode:UIViewContentModeScaleAspectFill];
        self.videoPreview.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:self.videoPreview belowSubview:_rtcBtn];
        [[UPAVCapturer sharedInstance] stop];
        [UPAVCapturer sharedInstance].openDynamicBitrate = YES;
        [UPAVCapturer sharedInstance].capturerPresetLevel = UPAVCapturerPreset_640x480;
        [UPAVCapturer sharedInstance].camaraPosition = AVCaptureDevicePositionFront;
        [UPAVCapturer sharedInstance].videoOrientation = AVCaptureVideoOrientationPortrait;
        [UPAVCapturer sharedInstance].fps = 20;
        //观众端连麦不需要 rtmp 推流，所以不要设置 outStreamPath。同时关闭 UPAVCapturer 推流开关。
        [UPAVCapturer sharedInstance].streamingOn = NO;
        [UPAVCapturer sharedInstance].capturerPresetLevelFrameCropSize= CGSizeMake(360, 640);//剪裁为 16 : 9
        [UPAVCapturer sharedInstance].filterOn = YES;
        [[UPAVCapturer sharedInstance] start];
        
        //需要设置 rtc appId
        [[UPAVCapturer sharedInstance] rtcInitWithAppId:@"be0c14467694a1194adab41370cbed5b2fb6"];
        //设置连麦的 channelID，UPLiveSDKDemo 中使用推拉流 id 当作 channelID，方便和主播端连麦的配合。
        NSString *rtcChannelId = [NSURL URLWithString:self.url].pathComponents.lastObject;
        [[UPAVCapturer sharedInstance] rtcConnect:rtcChannelId];
        _rtcConnected = YES;
    });
}

//采集状态
- (void)capturer:(UPAVCapturer *)capturer capturerStatusDidChange:(UPAVCapturerStatus)capturerStatus {
    switch (capturerStatus) {
        case UPAVCapturerStatusStopped: {
            NSLog(@"===UPAVCapturerStatusStopped");
        }
            break;
        case UPAVCapturerStatusLiving: {
            NSLog(@"===UPAVCapturerStatusLiving");
            
        }
            break;
        case UPAVCapturerStatusError: {
            NSLog(@"===UPAVCapturerStatusError");
        }
            break;
        default:
            break;
    }
}

- (void)capturer:(UPAVCapturer *)capturer capturerError:(NSError *)error {
    NSLog(@"视频采集错误！%@",  error);
}


@end
