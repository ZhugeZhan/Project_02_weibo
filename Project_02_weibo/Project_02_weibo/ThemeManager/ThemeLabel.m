//
//  ThemeLabel.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/24.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "ThemeLabel.h"

@implementation ThemeLabel

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
    
    //从ThemeManager获取字体颜色
    UIColor *color = [[ThemeManager shareManager] themeColorWithColorName:self.colorName];
    self.textColor = color;
}

- (void)setColorName:(NSString *)colorName {
    
    if ([_colorName isEqualToString:colorName]) {
        return;
    }
    
    _colorName = [colorName copy];
    
    [self changeTheme];
}

@end
