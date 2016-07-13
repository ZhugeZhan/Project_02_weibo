//
//  ThemeButton.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/24.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "ThemeButton.h"

@implementation ThemeButton


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

//移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changeTheme {
    //获取主题对应的图片
    ThemeManager *manager = [ThemeManager shareManager];
    UIImage *image = [manager themeImageWithImageName:self.imageName];
    UIImage *bgImage = [manager themeImageWithImageName:self.backgroundImageName];
    //设置按钮图片
    [self setImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
}

- (void)setImageName:(NSString *)imageName {
    
    if ([_imageName isEqualToString:imageName]) {
        return;
    }
    
    _imageName = [imageName copy];
    [self changeTheme];
}

- (void)setBackgroundImageName:(NSString *)backgroundImageName {
    
    if ([_backgroundImageName isEqualToString:backgroundImageName]) {
        return;
    }
    
    _backgroundImageName = [backgroundImageName copy];
    [self changeTheme];
}

@end
