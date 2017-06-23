//
//  LrcModel.h
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/5.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHLrcModel : NSObject

@property (nonatomic, copy) NSString *lrc; // 歌词
@property (nonatomic, assign) int presenTime; //显示这句歌词的时间
@property (nonatomic, assign) bool isPresent; // 当前显示的是否是这句歌词

// 实例化方法
+ (instancetype)allocLrcModelWithLrc: (NSString *)lrc;

@end
