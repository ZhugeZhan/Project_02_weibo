//
//  ThemeImageView.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/23.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "ThemeImageView.h"

@implementation ThemeImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        //监听通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme) name:kThemeDidChangedNotifacationName object:nil];
        
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme) name:kThemeDidChangedNotifacationName object:nil];
}

//移除监听对象
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//当主题改变时需要重新获取对应的图片
- (void)changeTheme {
    
    //获取主题图片
    UIImage *image = [[ThemeManager shareManager] themeImageWithImageName:self.imageName];
    //图片拉伸
    if (_leftCapWidth != 0 || _topCapHeight != 0) {
        image = [image stretchableImageWithLeftCapWidth:_leftCapWidth topCapHeight:_topCapHeight];
    }
    //设置图片
    self.image = image;
}

//重写imageName的setter方法，当设置新的图片名时，需要刷新图片
- (void)setImageName:(NSString *)imageName {
    
    if ([_imageName isEqualToString:imageName]) {
        return;
    }
    
    _imageName = [imageName copy];
    
    [self changeTheme];
}

//设置拉伸点时，需要重新加载图片
- (void)setLeftCapWidth:(CGFloat)leftCapWidth {
    _leftCapWidth = leftCapWidth;
    [self changeTheme];
}

- (void)setTopCapHeight:(CGFloat)topCapHeight {
    _topCapHeight = topCapHeight;
    [self changeTheme];
}

@end
