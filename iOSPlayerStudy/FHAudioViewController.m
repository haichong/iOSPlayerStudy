//
//  ViewController.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/11/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHAudioViewController.h"
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface FHAudioViewController ()<AVAudioPlayerDelegate>{
    
    AVAudioPlayer *_avAudioPlayer; // 播放器palyer
    UISlider *_pregressSlider; // 播放控制
    UILabel *_pregressLabel; // 进度
    UISlider *_volumeSlider;   // 声音控制
    NSTimer *_timer; // 监控音频播放进度
}
@end

@implementation FHAudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // 1.初识化UI
    // (1)初始化三个Button;
    NSArray *titleArr = @[@"播放",@"暂停",@"停止"];
    for (int i = 0; i < titleArr.count; i++ ) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:button];
        [button setFrame:CGRectMake(20 + i * 50, 200 , 60, 40)];
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        button.tag = i+100;
        [button addTarget:self action:@selector(controlAVAudioAction:) forControlEvents:UIControlEventTouchUpInside];
    }
  
    // (2)初始化播放控制
    _pregressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 100, ScreenWidth - 130 - 20, 20)];
    [self.view addSubview: _pregressSlider];
    _pregressSlider.minimumValue = 0.0f;
    _pregressSlider.maximumValue = 1.0f;
    [_pregressSlider addTarget:self action:@selector(pregressChange) forControlEvents:UIControlEventValueChanged];
    _pregressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 120, 100, 100, 20)];
    _pregressLabel.text = @"00:00/00:00";
    [self.view addSubview:_pregressLabel];
    
    // (3)用NSTimer来监控音频播放进度
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(playProgress) userInfo:nil repeats:YES];
   
    // (4)初始化音量控制
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 140, ScreenWidth - 130 - 20, 20)];
    [_volumeSlider addTarget:self action:@selector(volumeChange) forControlEvents:UIControlEventValueChanged];
    _volumeSlider.minimumValue = 0.0f;
    _volumeSlider.maximumValue = 10.0f;
    _volumeSlider.value = 1.0f;
    [self.view addSubview:_volumeSlider];
    UILabel *volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 120, 140, 40, 20)];
    volumeLabel.text = @"音量";
    [self.view addSubview:volumeLabel];
    
    // 2.播放本地音频文件
    // (1)从boudle路径下读取音频文件 陈小春 - 独家记忆文件名，mp3文件格式
    NSString *path = [[NSBundle mainBundle] pathForResource:@"陈小春 - 独家记忆" ofType:@"mp3"];
    // (2)把音频文件转化成url格式
    NSURL *url = [NSURL fileURLWithPath:path];
    // (3)初始化音频类 并且添加播放文件
    _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    // (4) 设置代理
    _avAudioPlayer.delegate = self;
    // (5) 设置初始音量大小 默认1，取值范围 0~1
    _avAudioPlayer.volume = 1;
    // (6)设置音乐播放次数 负数为一直循环，直到stop，0为一次，1为2次，以此类推
    _avAudioPlayer.numberOfLoops = 0;
    // (7)准备播放
    [_avAudioPlayer prepareToPlay];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
}

// 音频控制
- (void)controlAVAudioAction : (UIButton *)button {
    
    NSInteger tag = button.tag;
    
    // 播放
    if (tag == 100) {
        
        [_avAudioPlayer play];
    }
    
    // 暂停
    if (tag == 101) {
        
        [_avAudioPlayer pause];
    }
    
    // 停止
    if (tag == 102) {
        
        _avAudioPlayer.currentTime = 0;
        [_avAudioPlayer stop];
    }
}

// 播放进度控制
- (void)pregressChange{
    
    _avAudioPlayer.currentTime = _pregressSlider.value * _avAudioPlayer.duration;
}

// 播放进度条
- (void)playProgress {
    // 更改当前播放时间
    NSString *currentMStr = [self FormatTime:_avAudioPlayer.currentTime / 60];
    NSString *currentSStr = [self FormatTime:(int)_avAudioPlayer.currentTime % 60];
    NSString *durationMStr = [self FormatTime:_avAudioPlayer.duration / 60];
    NSString *durationSStr = [self FormatTime:(int)_avAudioPlayer.duration % 60];
    _pregressLabel.text = [NSString stringWithFormat:@"%@:%@/%@:%@",currentMStr,currentSStr,durationMStr,durationSStr];
    // 播放进度条
    _pregressSlider.value = _avAudioPlayer.currentTime / _avAudioPlayer.duration;
}
- (NSString *)FormatTime: (int)time {
    
    if (time < 10) {
        return  [NSString stringWithFormat:@"0%d",time];
    }else {
        return  [NSString stringWithFormat:@"%d",time];
    }
}

// 音量控制
- (void)volumeChange {
    _avAudioPlayer.volume = _volumeSlider.value;
}

#pragma mark - AVAudioPlayerDelegate
// 当播放完成时执行的代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    NSLog(@"audioPlayerDidFinishPlaying");
    _timer = nil;
    [_timer invalidate];
}
// 当播放发生错误时调用
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"播放发生错误%@",error);
}
// 当播放器发生中断时调用 如来电
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    
    NSLog(@"audioPlayerBeginInterruption");
    // 暂停播放 用户不暂停，系统也会帮你暂停。但是如果你暂停了，等来电结束，需要再开启
    [_avAudioPlayer pause];
}
// 当中断停止时调用 如来电结束
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    
    NSLog(@"audioPlayerEndInterruption");
    // 你可以帮用户开启 也可以什么都不执行，让用户自己决定
    [_avAudioPlayer play];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
