//
//  ThemeImageView.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/23.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeImageView : UIImageView

//增加一个图片名，用来决定所显示的内容
@property (nonatomic, copy) NSString *imageName;

//用于图片拉伸处理  如果图片不需要拉伸  设定0
@property (nonatomic, assign) CGFloat leftCapWidth;
@property (nonatomic, assign) CGFloat topCapHeight;


@end
