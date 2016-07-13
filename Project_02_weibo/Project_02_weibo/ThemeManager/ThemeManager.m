//
//  ThemeManager.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/23.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "ThemeManager.h"



@interface ThemeManager()

@property (nonatomic, strong) NSDictionary *themeDic; //主题信息字典

@property (nonatomic, strong) NSDictionary *textColorConfigDic;//存储当前主题下的颜色config.plist文件

@end

@implementation ThemeManager


#pragma mark - ThemeManager单例创建
+ (instancetype)shareManager {
    
    static ThemeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            
            manager = [[super allocWithZone:NULL] init];
            
            //初始化主题信息字典
            manager.themeDic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"]];
            
            //初始化当前主题的字体颜色信息字典
            [manager loadTextColorConfigPlist];
        }
    });
    
    return manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareManager];
}

- (id)copy {
    return self;
}

#pragma mark - 发送通知
//当主题名发生改变的时候，发送通知
- (void)setThemeName:(NSString *)themeName {
    
    //只有主题名发生改变的时候才执行
    if (![themeName isEqualToString:self.themeName]) {
        
        _themeName = [themeName copy];
        
        //更换主题名，保存到本地
        [[NSUserDefaults standardUserDefaults] setObject:_themeName forKey:kThemeNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //重新加载更换后的主题的字体颜色信息
        [self loadTextColorConfigPlist];
        
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangedNotifacationName object:nil];
    }
}

//主题名的getter方法
- (NSString *)themeName {
    
    //从本地读取主题名
    NSString *preThemeName = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeNameKey];
    
    if (preThemeName == nil) {
        preThemeName = @"猫爷";
        [[NSUserDefaults standardUserDefaults] setObject:preThemeName forKey:kThemeNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _themeName = preThemeName;
    
    return _themeName;
}


#pragma mark - 获取主题图片
//根据传入的图片名，获取当前主题的图片
- (UIImage *)themeImageWithImageName:(NSString *)imageName {
    //Skins/主题名对应的文件夹/图片名
    //1.根据当前的主题名，从theme.plist文件中找到对应的路径
    NSString *filePath = _themeDic[self.themeName];   //这里调用了主题名的getter方法
    //2.拼接图片路径
    NSString *imageFilePath = [NSString stringWithFormat:@"%@/%@", filePath, imageName];
    
    return [UIImage imageNamed:imageFilePath];
}

#pragma mark - 获取字体颜色
//根据传入的颜色名，获取当前主题对应的颜色
- (UIColor *)themeColorWithColorName:(NSString *)colorName {
     //从字典中，获取颜色对应的数据
    NSDictionary *colorDic = _textColorConfigDic[colorName];
    if (colorDic == nil) {
        return nil;
    }
    
    //解析数据，获取对应的color
    CGFloat red = [colorDic[@"R"] floatValue] / 255.0;
    CGFloat green = [colorDic[@"G"] floatValue] / 255.0;
    CGFloat blue = [colorDic[@"B"] floatValue] / 255.0;
    CGFloat alpha = [colorDic[@"alpha"] floatValue];
    if (alpha == 0) {
        alpha = 1;
    }
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - 当前主题的字体颜色初始化
- (void)loadTextColorConfigPlist {
    //Skins/主题名对应的文件夹/config.plist
    //1.根据当前的主题名，从theme.plist文件中找到对应的路径
    NSString *filePath = _themeDic[self.themeName];
    //2.拼接路径
    NSString *configFilePath = [NSString stringWithFormat:@"%@/%@", filePath, @"config"];
    configFilePath = [[NSBundle mainBundle] pathForResource:configFilePath ofType:@"plist"];
    //3.加载文件到字典
    _textColorConfigDic = [[NSDictionary alloc] initWithContentsOfFile:configFilePath];
}

@end
