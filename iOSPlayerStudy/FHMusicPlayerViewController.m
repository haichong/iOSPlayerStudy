//
//  FHMusicPlayerViewController.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/2.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHMusicPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+RGBHelper.h"
#import "FHCustomButton.h"
#import "Masonry.h"
#import "FHAlbumModel.h"
#import "FHLrcModel.h"

/*
百度音乐API:http://tingapi.ting.baidu.com/v1/restserver/ting?format=json&calback=&from=webapp_music&method=baidu.ting.song.play&songid=877578
 **/

@interface FHMusicPlayerViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    UIImageView *_backImageView; // 背景图
    UILabel *_album_titleLabel; // 标题
    UILabel *_artist_nameLabel; // 副标题
    UILabel *_currentLabel;  // 当前时间
    UILabel *_durationLabel; // 总时间
    UIProgressView *_progressView; // 进度条
    UISlider *_playerSlider;   // 播放控制器
    FHCustomButton *_playButton;  // 播放暂停
    FHCustomButton *_prevButton;  // 上一首
    FHCustomButton *_nextButton;  // 下一首
    BOOL _isPlay; // 记录播放暂停状态
    NSInteger _index; // 记录播放到了第几首歌
    FHAlbumModel *_currentModel;
    UITableView *_lrcTableView;  // 用于显示歌词
    int _row;  //记录歌词第几行
}
@property (nonatomic, strong)NSMutableArray *albumArr; //歌曲
@property (nonatomic, strong)NSMutableArray *lrcArr;  // 歌词
@property (nonatomic, strong)AVPlayer *avPlayer;
@property (nonatomic, strong)id timePlayProgerssObserver;// 播放器进度观察者

@end

@implementation FHMusicPlayerViewController

#pragma - mark 懒加载歌曲
- (NSMutableArray *)albumArr {
    
    if (!_albumArr) {
        
        _albumArr = [NSMutableArray new];
        // 从本地获取json数据
        NSData *jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"songList" ofType:@"json"]];
        // 把json数据转换成字典
        NSDictionary *rootDic  = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
        NSArray *albumArr = [NSArray arrayWithArray:rootDic[@"song_list"]];
        for (NSDictionary *dic in albumArr) {
            FHAlbumModel *albumModel = [[FHAlbumModel alloc] initWithInfo:dic];
            [_albumArr addObject:albumModel];
        }
    }
    return _albumArr;
    
}
#pragma - mark 懒加载歌词
- (NSMutableArray *)lrcArr{
    
    if (!_lrcArr) {
        _lrcArr = [NSMutableArray new];
    }
    return _lrcArr;
    
}
#pragma - mark 懒加载AVPlayer 
- (AVPlayer *)avPlayer {
    
    if (!_avPlayer) {
        _avPlayer = [[AVPlayer alloc] initWithPlayerItem:nil];
    }
    return _avPlayer;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // 添加UI
    [self loadContenView];
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextButtonClick:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)loadContenView {
    
    // 把statusbar 字体变白
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //背景图
    _backImageView = [[UIImageView alloc] init];
    _backImageView.image = [UIImage imageNamed:@"back"];
    [self.view addSubview:_backImageView];
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(0);
        make.right.mas_equalTo(self.view).offset(0);
        make.left.mas_equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view).offset(0);
    }];
    
    // 标题
    _album_titleLabel = [UILabel new];
    [self.view addSubview:_album_titleLabel];
    [_album_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(24);
        make.right.mas_equalTo(self.view).offset(0);
        make.left.mas_equalTo(self.view).offset(0);
        make.height.equalTo(@20);
    }];
    _album_titleLabel.text = @"歌名";
    _album_titleLabel.font = [UIFont systemFontOfSize:17.f];
    _album_titleLabel.textAlignment = NSTextAlignmentCenter;
    _album_titleLabel.textColor = [UIColor whiteColor];
    
    // 副标题
    _artist_nameLabel = [UILabel new];
    _artist_nameLabel.font = [UIFont systemFontOfSize:13.f];
    [self.view addSubview:_artist_nameLabel];
    [_artist_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_album_titleLabel.mas_bottom).offset(0);
        make.right.mas_equalTo(self.view).offset(0);
        make.left.mas_equalTo(self.view).offset(0);
        make.height.equalTo(@20);
    }];
    _artist_nameLabel.text = @"歌手 - 经典老歌榜";
    _artist_nameLabel.textAlignment = NSTextAlignmentCenter;
    _artist_nameLabel.textColor = [UIColor RGBColorFromHexString:@"#eeeeee" alpha:1.0];
    
    // 默认第一首歌
    _playButton.imageView.image = [UIImage imageNamed:@"play"];
    FHAlbumModel *albumModel = self.albumArr[_index];
    _album_titleLabel.text = albumModel.title;
    _artist_nameLabel.text = [NSString stringWithFormat:@"%@ - 经典老歌榜",albumModel.artist_name];
    
    // 当前时间
    _currentLabel = [UILabel new];
    [self.view addSubview:_currentLabel];
    _currentLabel.text = @"0:00";
    _currentLabel.textAlignment = NSTextAlignmentCenter;
    _currentLabel.textColor = [UIColor whiteColor];
    [_currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(10);
        make.bottom.mas_equalTo(self.view).offset(-70);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    // 总时间
    _durationLabel = [UILabel new];
    [self.view addSubview:_durationLabel];
    _durationLabel.text = @"0:00";
    _durationLabel.textAlignment = NSTextAlignmentCenter;
    _durationLabel.textColor = [UIColor whiteColor];
    [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view).offset(-10);
        make.bottom.mas_equalTo(self.view).offset(-70);
        make.width.equalTo(@40);
        make.height.equalTo(@20);
    }];
    
    // 进度条
    _progressView = [UIProgressView new];
    [self.view addSubview:_progressView];
    _progressView.progress = 0.f;
    _progressView.tintColor = [UIColor RGBColorFromHexString:@"#AAAAAA" alpha:1.0];
    _progressView.trackTintColor = [UIColor whiteColor];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(_currentLabel.mas_right).offset(10);
        make.right.mas_equalTo(_durationLabel.mas_left).offset(-10);
        make.bottom.mas_equalTo(self.view).offset(-78);
        make.height.equalTo(@2);
    }];
    
    // 播放控制器
    _playerSlider = [UISlider new];
    [self.view addSubview:_playerSlider];
    _playerSlider.value = 0.0f;
    _playerSlider.minimumTrackTintColor = [UIColor colorWithRed:95/255.0 green:171/255.0 blue:128/255.0 alpha:1.0f];
    _playerSlider.maximumTrackTintColor = [UIColor clearColor];
    [_playerSlider addTarget:self action:@selector(pregressChange) forControlEvents:UIControlEventValueChanged];

    [_playerSlider mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.mas_equalTo(_currentLabel.mas_right).offset(10);
        make.right.mas_equalTo(_durationLabel.mas_left).offset(-10);
        make.bottom.mas_equalTo(self.view).offset(-70);
        make.height.equalTo(@20);
    }];
    
    // 播放/暂停
    _playButton = [[FHCustomButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50) withImage:[UIImage imageNamed:@"stop"]];
    [_playButton.button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-10);
        make.width.equalTo(@50);
        make.height.equalTo(@50);

    }];
    
    // 上一首
    _prevButton = [[FHCustomButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withImage:[UIImage imageNamed:@"pre"]];
    [_prevButton.button addTarget:self action:@selector(prevButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_prevButton];
    [_prevButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playButton);
        make.right.mas_equalTo(_playButton.mas_left).offset(-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        
    }];
    
    // 下一首
    _nextButton = [[FHCustomButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withImage:[UIImage imageNamed:@"next"]];
    [_nextButton.button addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nextButton];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_playButton);
        make.left.mas_equalTo(_playButton.mas_right).offset(20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
    }];
    
    // 显示歌词的tableview
    _lrcTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _lrcTableView.dataSource = self;
    _lrcTableView.delegate = self;
    _lrcTableView.backgroundColor = [UIColor clearColor];
    _lrcTableView.separatorStyle = UITableViewCellEditingStyleNone;
    [_lrcTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LrcCell"];
    [self.view addSubview:_lrcTableView];
    [_lrcTableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.mas_equalTo (_artist_nameLabel.mas_bottom).offset(10);
        make.left.mas_equalTo (self.view).offset(10);
        make.right.mas_equalTo (self.view).offset(-10);
        make.bottom.mas_equalTo (_progressView.mas_top).offset(-20);
    }];
    
    _artist_nameLabel.text = [NSString stringWithFormat:@"%@ - 经典老歌榜",albumModel.artist_name];
}
#pragma mark - 播放暂停
- (void)playAction:(UIButton *)button {
    
    _isPlay = !_isPlay;
    if (_isPlay) {
        _playButton.imageView.image = [UIImage imageNamed:@"play"];
        if (_currentModel) {
            [self.avPlayer play];
        }else {
            [self playMusic];
        }
      }else {
        _playButton.imageView.image = [UIImage imageNamed:@"stop"];
        [self.avPlayer pause];
    }
    
}
#pragma mark - 播放歌曲
- (void)playMusic {
    
    // 1.移除观察者
    [self removeObserver];
    // 2.修改播放按钮的图片
    _playButton.imageView.image = [UIImage imageNamed:@"play"];
    // 3.获取歌曲
    FHAlbumModel *albumModel = self.albumArr[_index];
    // 4.修改标题
    _album_titleLabel.text = albumModel.title;
    // 5.修改副标题标题
    _artist_nameLabel.text = [NSString stringWithFormat:@"%@ - 经典老歌榜",albumModel.artist_name];
    // 6. 实例化新的playerItem
    // b31ae4e046eac3470c486914f0acd7b6 是访问凭证，经常换
    NSString *fileURL = [NSString stringWithFormat:@"%@xcode=%@",albumModel.song_id,@"e406469c3efcb7e46b73a0f684021956"];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:fileURL]];
    // 7.取代旧的playerItem
    [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
    // 8.开始播放
    [self.avPlayer play];
    // 9.添加缓存状态的观察者
    [self addObserverOfLoadedTimeRanges];
    // 10.添加播放进度的观察者
    [self addTimePlayProgerssObserver];
    // 11.记录当前播放的歌曲
    _currentModel = self.albumArr[_index];
    // 12.获取歌词
    [self getAlbumLrc];
}
#pragma mark - 获取歌词
- (void)getAlbumLrc {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 异步并发下载歌曲
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_currentModel.lrclink]];
        // 二进制转为字符串
        NSString *allLrcStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        // 分割字符串
        NSArray *lrcArray = [allLrcStr componentsSeparatedByString:@"\n"];
        // 添加到数组中
        [self.lrcArr removeAllObjects];
        for (NSString *lrc in lrcArray) {
            FHLrcModel *lrcModel = [FHLrcModel  allocLrcModelWithLrc:lrc];
            [self.lrcArr addObject:lrcModel];
        }
        // 主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [_lrcTableView reloadData];
        });
    });
}
#pragma mark - 移除观察者
- (void)removeObserver {
    // 没添加之前不能移除否则会崩溃
    if (!_currentModel) {
        return;
    }else {
         [self.avPlayer.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.avPlayer removeTimeObserver:self.timePlayProgerssObserver];
    }
}
#pragma mark - 添加监听缓存状态的观察者
- (void)addObserverOfLoadedTimeRanges {
    
    [self.avPlayer.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
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
        
        _durationLabel.text = [NSString stringWithFormat:@"%d:%@",(int)duration/60,[self FormatTime:(int)duration%60]];
    }
}
#pragma mark - 添加监听播放进度的观察者
- (void)addTimePlayProgerssObserver {
    
    __block UISlider *weakPregressSlider = _playerSlider;
    __weak UILabel *waekCurrentLabel = _currentLabel;
    __block int weakRow = _row;  // 来记录当前歌词显示到第几行
    __weak typeof(self) weakSelf = self;
    self.timePlayProgerssObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        // 当前播放的时间
        float current = CMTimeGetSeconds(time);
        // 更新歌词
        if (weakRow < weakSelf.lrcArr.count) {
            FHLrcModel *model = weakSelf.lrcArr[weakRow];
            // 比较时间 比较成功了刷新TabelView
            if (model.presenTime <= (int)current) {
                [weakSelf reloadTabelViewWithRow:weakRow];
                weakRow++;
            }
        }
        // 总时间
        float total = CMTimeGetSeconds(weakSelf.avPlayer.currentItem.duration);
        // 更改当前播放时间
        NSString *currentSStr = [weakSelf FormatTime: (int)current % 60];
        waekCurrentLabel.text = [NSString stringWithFormat:@"%d:%@",(int)current / 60,currentSStr];
        // 更新播放进度条
        weakPregressSlider.value = current / total;
            
    }];
}
#pragma mark - 更新歌词
- (void)reloadTabelViewWithRow:(int)row {
    
    // 找到cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [_lrcTableView cellForRowAtIndexPath:indexPath];
    // 字体变色
    cell.textLabel.textColor = [UIColor yellowColor];
    // 当前歌词滑动到TableView中间
    [_lrcTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    // 上一句变为白色 如果是第一句就没有上一句，所以不操作
    if (row > 0) {
        UITableViewCell *preCell = [_lrcTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row - 1 inSection:0]];
        preCell.textLabel.textColor = [UIColor whiteColor];
    }
}
- (NSString *)FormatTime: (int)time {
    
    if (time < 10) {
        return  [NSString stringWithFormat:@"0%d",time];
    }else {
        return  [NSString stringWithFormat:@"%d",time];
    }
}
#pragma mark - 播放进度控制
- (void)pregressChange{
    
    float total = CMTimeGetSeconds(self.avPlayer.currentItem.duration);
    float current = total *_playerSlider.value;
    [self.avPlayer seekToTime:CMTimeMake(current, 1)];
}
#pragma mark - 上一首
- (void)prevButtonClick :(UIButton *)button {
    
    _index--;
    if (_index < 0) {
        
        _index = self.albumArr.count - 1;
    }
    [self playMusic];
}
#pragma mark - 下一首
- (void)nextButtonClick :(UIButton *)button {
    _index++;
        if (_index >= self.albumArr.count) {
        
        _index = 0;
    }
    [self playMusic];
}
#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.lrcArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [_lrcTableView dequeueReusableCellWithIdentifier:@"LrcCell" forIndexPath:indexPath];
    // 去掉点击效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    FHLrcModel *lrcmodel = self.lrcArr[indexPath.row];
    cell.textLabel.text = lrcmodel.lrc;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    if (lrcmodel.isPresent) {
        // 当前歌词显示黄色
        cell.textLabel.textColor = [UIColor yellowColor];
    }else {
        cell.textLabel.textColor = [UIColor whiteColor];

    }
    return cell;
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
