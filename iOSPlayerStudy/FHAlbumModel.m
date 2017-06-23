//
//  SongModel.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/2.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHAlbumModel.h"

@implementation FHAlbumModel

- (instancetype)initWithInfo: (NSDictionary *)InfoDic {
    
    FHAlbumModel *model = [[FHAlbumModel alloc] init];
    // 通过kvo为属性赋值
    [model setValuesForKeysWithDictionary:InfoDic];
    return model;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
