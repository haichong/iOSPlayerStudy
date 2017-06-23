//
//  CustomButton.h
//  iOSPlyaerStudy
//
//  Created by FuHang on 2016/12/2.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FHCustomButton : UIView

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong)  UIImageView *imageView;

- (instancetype) initWithFrame:(CGRect)frame withImage: (UIImage *)image;
@end
