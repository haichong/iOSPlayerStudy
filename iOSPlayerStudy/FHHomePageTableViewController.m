//
//  HomePageTableViewController.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/7.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHHomePageTableViewController.h"
#import "AppDelegate.h"
#import "FHAudioViewController.h"
#import "FHAVPlayerViewController.h"
#import "FHMusicPlayerViewController.h"

@interface FHHomePageTableViewController (){
    
    NSArray *_itemArr;
}

@end

@implementation FHHomePageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"功能列表";
    _itemArr = @[@"播放本地音频",@"播放在线音频",@"音乐播放器：实现了歌曲切换和歌词"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _itemArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = _itemArr[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case 0:
            [self setUpAudioVC];
            break;
        case 1:
            [self setupAVPlayerVC];
            break;
        default:
            [self setupMusicPlayerVC];
            break;
    }
}
// 这个类主要讲播放本地音频
- (void)setUpAudioVC {
    FHAudioViewController *audioVC = [FHAudioViewController new];
    [self.navigationController pushViewController:audioVC animated:YES];
}
// 这个类主要讲播放在线音频
- (void)setupAVPlayerVC {
    FHAVPlayerViewController *avPlayerVC = [FHAVPlayerViewController new];
    [self.navigationController pushViewController:avPlayerVC animated:YES];
}
// 完整的音乐播放器
- (void)setupMusicPlayerVC {
    FHMusicPlayerViewController *musicPalyerVC = [FHMusicPlayerViewController new];
    [self.navigationController pushViewController:musicPalyerVC animated:YES];
}

@end
