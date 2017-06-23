//
//  CustomButton.m
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/2.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "FHCustomButton.h"

@implementation FHCustomButton

- (instancetype) initWithFrame:(CGRect)frame withImage: (UIImage *)image {
    
    self = [super initWithFrame:frame];
    
    [self createUIWith: (UIImage *)image];
    
    return self;
}
- (void)createUIWith: (UIImage *)image {
    
    self.backgroundColor = [UIColor colorWithRed:95/255.0 green:171/255.0 blue:128/255.0 alpha:1.0f];
    // 加圆角
    float selfWidth = self.frame.size.width;
    self.clipsToBounds = YES;
    self.layer.cornerRadius = selfWidth / 2;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    // 加图片
    float imageWidth = selfWidth * 0.6;
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageWidth)];
    self.imageView.image = image;
    self.imageView.center = self.center;
    [self addSubview:self.imageView];
    
    // 加按钮
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.button.frame = CGRectMake(0, 0, selfWidth, selfWidth);
    [self addSubview:self.button];
}
@end
