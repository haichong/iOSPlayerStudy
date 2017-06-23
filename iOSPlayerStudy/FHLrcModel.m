//
//  LrcModel.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/5.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHLrcModel.h"

@implementation FHLrcModel

+ (instancetype)allocLrcModelWithLrc: (NSString *)lrc {
    
    FHLrcModel *model =[FHLrcModel new];
    // 把歌词和时间分割开
    NSArray *array = [lrc componentsSeparatedByString:@"]"];
    // 处理时间 [00:01.70] =》 1.70
    NSString *timeStr;
    if ([array[0] length] >8) {
        timeStr = [array[0] substringWithRange:NSMakeRange(1, 8)];
    }
    NSArray *timeArr = [timeStr componentsSeparatedByString:@":"];
    if (timeArr.count > 1) {
        model.presenTime = (int)[timeArr[0] floatValue] * 60 + [timeArr[1] intValue];
    }
    // 如果没有歌词 就换行
    if (array.count > 1) {
        model.lrc = array[1];
    }else {
        model.lrc = @"\n";
    }
    return model;
}

@end
