//
//  FHAVPlayerViewController.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/11/25.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHAVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface FHAVPlayerViewController (){
    
    UIProgressView *_progressView; // 缓冲进度条
    UISlider *_pregressSlider; // 播放控制条
    UILabel *_pregressLabel; // 进度
    UISlider *_volumeSlider;   // 声音控制
}

@property (nonatomic, strong)AVPlayer *avPlayer;
@property (nonatomic, strong)AVPlayerItem * songItem;
@property (nonatomic, strong)id timePlayProgerssObserver;// 播放进度观察者

@end

@implementation FHAVPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.初识化UI
    // (1)初始化二个Button;
    NSArray *titleArr = @[@"播放",@"暂停"];
    for (int i = 0; i < titleArr.count; i++ ) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.view addSubview:button];
        [button setFrame:CGRectMake(20 + i * 50, 200 , 60, 40)];
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        button.tag = i+100;
        [button addTarget:self action:@selector(controlAVPlayerAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // (2)初始化缓冲进度条
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, 130, ScreenWidth - 130 - 20, 5)];
    // 设置缓冲进度条的颜色
    _progressView.progressTintColor = [UIColor yellowColor];
    [self.view addSubview:_progressView];
    
    // (3)初始化播放进度
    _pregressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 120, ScreenWidth - 130 - 20, 20)];
    _pregressSlider.minimumValue = 0.0f;
    _pregressSlider.maximumValue = 1.0f;
    // 把_pregressSlider小于滑块的部分设置成蓝色以显示播放进度
    _pregressSlider.minimumTrackTintColor = [UIColor blueColor];
    // 把_pregressSlider大于滑块的部分设置成透明以显示缓冲进度条
    _pregressSlider.maximumTrackTintColor = [UIColor clearColor];
    [_pregressSlider addTarget:self action:@selector(pregressChange) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview: _pregressSlider];
    // (4)时间
    _pregressLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 120, 130, 100, 20)];
    _pregressLabel.text = @"00:00/00:00";
    [self.view addSubview:_pregressLabel];
    
    // (5)初始化音量
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 170, ScreenWidth - 130 - 20, 20)];
    [_volumeSlider addTarget:self action:@selector(volumeChange) forControlEvents:UIControlEventValueChanged];
    _volumeSlider.minimumValue = 0.0f;
    _volumeSlider.maximumValue = 10.0f;
    _volumeSlider.value = 1.0f;
    [self.view addSubview:_volumeSlider];
    UILabel *volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 120, 170, 40, 20)];
    volumeLabel.text = @"音量";
    [self.view addSubview:volumeLabel];
    
    // 2.播放在线音频文件
    // (1)取得音频播放路径
#warning 请换成可用的网址
    NSString *strURL = @"http://yinyueshiting.baidu.com/data2/music/42783748/42783748.mp3?xcode=b31ae4e046eac3470c486914f0acd7b6";
    // (2)把音频文件转化成url格式
    NSURL *url = [NSURL URLWithString:strURL];
    // (3)使用playerItem获取视频的信息，当前播放时间，总时间等
    _songItem = [[AVPlayerItem alloc]initWithURL:url];
    // (3)初始化音频类 并且添加播放文件
    self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:_songItem];
    // (4) 设置初始音量大小 默认1，取值范围 0~1
    self.avPlayer.volume = 1.0;
    // (5)监听播放器状态 NSKeyValueObservingOptionNew 把更改之前的值提供给处理方法
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // (6)监听缓存状态
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"isPlaybackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    // (7)监听音乐播放的进度
    // 防止循环引用
    __weak typeof(self) weakSelf = self;
    __weak UISlider *weakPregressSlider = _pregressSlider;
    __weak UILabel *weakPregressLabel = _pregressLabel;
    self.timePlayProgerssObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前播放的时间
        float current = CMTimeGetSeconds(time);
        // 总时间
        float total = CMTimeGetSeconds(weakSelf.avPlayer.currentItem.duration);
        // 更改当前播放时间
        NSString *currentMStr = [weakSelf FormatTime: current / 60];
        NSString *currentSStr = [weakSelf FormatTime: (int)current % 60];
        NSString *durationMStr = [weakSelf FormatTime:total / 60];
        NSString *durationSStr = [weakSelf FormatTime: (int)total % 60];
        weakPregressLabel.text = [NSString stringWithFormat:@"%@:%@/%@:%@",currentMStr,currentSStr,durationMStr,durationSStr];
        // 更新播放进度条
        weakPregressSlider.value = current / total;
    }];
    // (8)监听音乐播放是否完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.avPlayer play];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        switch (_avPlayer.status) {
            case AVPlayerStatusUnknown:
                NSLog(@"KVO：未知状态，此时不能播放");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"KVO：准备完毕，可以播放");
                [self.avPlayer play];
                break;
            case AVPlayerStatusFailed:
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                break;
            default:
                break;
        }
    }
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray * timeRanges = self.avPlayer.currentItem.loadedTimeRanges;
        //本次缓冲的时间范围
        CMTimeRange timeRange = [timeRanges.firstObject CMTimeRangeValue];
        //缓冲总长度
        NSTimeInterval totalLoadTime = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
        //音乐的总时间
        NSTimeInterval duration = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
        //计算缓冲百分比例
        NSTimeInterval scale = totalLoadTime/duration;
        //更新缓冲进度条
        _progressView.progress = scale;
    }
    
     if ([keyPath isEqualToString:@"isPlaybackBufferEmpty"])
     {
         NSLog(@"isPlaybackBufferEmpty = %d",self.avPlayer.currentItem.isPlaybackBufferEmpty);
     }
    
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        NSLog(@"playbackLikelyToKeepUp = %d",self.avPlayer.currentItem.playbackLikelyToKeepUp);
    }
}
- (void)playFinished:(NSNotification *)notification {
    // 时间跳转到零 重新播放
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer play];
}
// 音频控制
- (void)controlAVPlayerAction : (UIButton *)button {
    
    NSInteger tag = button.tag;
    
    // 播放
    if (tag == 100) {
        [self.avPlayer play];
    }
    
    // 暂停
    if (tag == 101) {
        
        [self.avPlayer pause];
    }
}
// 播放进度控制
- (void)pregressChange{
    
    float total = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    float current = total *_pregressSlider.value;
    [self.avPlayer seekToTime:CMTimeMake(current, 1)];
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
    self.avPlayer.volume = _volumeSlider.value;
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.avPlayer removeTimeObserver:self.timePlayProgerssObserver];
    self.timePlayProgerssObserver = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
