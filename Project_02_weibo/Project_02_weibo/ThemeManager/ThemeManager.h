//
//  ThemeManager.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/23.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kThemeNameKey @"kThemeNameKey"
#define kThemeDidChangedNotifacationName @"kThemeDidChangedNotifacationName"

@interface ThemeManager : NSObject
{
    NSString *_themeName;
}
//选中的当前主题名
@property (nonatomic, copy) NSString *themeName;

//获取Manager单例对象
+ (instancetype)shareManager;

//获取某个图片 将图片名作为参数传入，自动拼接出完整的图片路径并查找图片
- (UIImage *)themeImageWithImageName:(NSString *)imageName;

//获取字体颜色 将字体名作为参数传入，从字典中查找对应的颜色
- (UIColor *)themeColorWithColorName:(NSString *)colorName;

@end
