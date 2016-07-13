//
//  BaseNavigationController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/22.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏的背景图片
    [self navigationBarBackgroundImage];
    
    //去除导航栏的黑色阴影线
    self.navigationBar.shadowImage = [UIImage new];
    
    //设置标题颜色和字体
    NSDictionary *attri = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
                            NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationBar.titleTextAttributes = attri;
    
    //设置导航栏不透明，会从导航栏下方开始计算坐标
    self.navigationBar.translucent = NO;
    
    //添加监听通知，用于主题切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationBarBackgroundImage) name:kThemeDidChangedNotifacationName object:nil];
}

//移除监听通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//设备导航栏的背景图片
- (void)navigationBarBackgroundImage {
    
    //判断当前systemVersion系统版本
    //UIDevice程序所运行的设备 当前的手机
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    UIImage *image;
    if (systemVersion >= 7.0) {
        image = [[ThemeManager shareManager] themeImageWithImageName:@"mask_titlebar64.png"];
    } else {
        image = [[ThemeManager shareManager] themeImageWithImageName:@"mask_titlebar.png"];
    }
    //设置背景图片
    //image = [image stretchableImageWithLeftCapWidth:0.5 topCapHeight:0.5];
    [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
