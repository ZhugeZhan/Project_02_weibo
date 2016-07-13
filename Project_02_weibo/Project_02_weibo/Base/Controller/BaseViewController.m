//
//  BaseViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/22.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置背景图片
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"bg_home.jpg";
    //将背景图片插入到最底层
    [self.view insertSubview:bgImageView atIndex:0];
    
    //添加返回按钮
    [self creakBackButton];
}

//设置返回按钮，所有不是最外层视图的界面都需要加载返回按钮
- (void)creakBackButton {
    //判断当前界面是不是第一层界面，如果是则返回
    UINavigationController *navi = self.navigationController;
    if (navi == nil || navi.viewControllers.count == 1) {
        return;
    }
    
    //创建返回按钮
    ThemeButton *backButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 60, 44);
    backButton.backgroundImageName = @"titlebar_button_back_9.png";
    [backButton setTitle:@" 返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}
//返回按钮点击事件
- (void)backAction:(UIButton *)button {
    
    [self.navigationController popViewControllerAnimated:YES];
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
