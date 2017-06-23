//
//  SongModel.h
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/2.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHAlbumModel : NSObject

@property (nonatomic, copy) NSString *lrclink; // 歌词
@property (nonatomic, copy) NSString *pic_big; // 背景图
@property (nonatomic, copy) NSString *artist_name; // 歌手
@property (nonatomic, copy) NSString *title; // 歌名
@property (nonatomic, copy) NSString *song_id; // 歌曲地址


- (instancetype)initWithInfo: (NSDictionary *)InfoDic;
@end
