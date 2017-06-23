//
//  UIColor+RGBHelper.h
//  LicaiApp
//
//  Created by cora1n on 14-8-21.
//  Copyright (c) 2014年 devwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RGBHelper)

+(UIColor *)RGBColorFromHexString:(NSString *)color alpha:(float)alpha;
@end
