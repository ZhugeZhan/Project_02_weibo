//
//  RightViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/25.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "RightViewController.h"
#import "SendWeiboViewController.h"
#import "BaseNavigationController.h"
#import "UIViewController+MMDrawerController.h"

@interface RightViewController ()

@end

@implementation RightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"功能";
    
    //背景视图
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"mask_bg.jpg";
    [self.view insertSubview:bgImageView atIndex:0];
    
    [self createButtons];
}


- (void)createButtons {
    
    //上面五个
    for (int i = 0; i < 5; i++) {
        //计算按钮的frmae
        CGRect frame = CGRectMake(20, 10 + i * (40 + 10), 40, 40);
        
        ThemeButton *button = [ThemeButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        NSString *fileName = [NSString stringWithFormat:@"newbar_icon_%i.png", i+1];
        button.imageName = fileName;
        button.tag = i;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    //下面两个
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    locationButton.frame = CGRectMake(20, kScreenHeight - 60 - 64 - 40, 40, 40);
    [locationButton setImage:[UIImage imageNamed:@"btn_map_location"] forState:UIControlStateNormal];
    [self.view addSubview:locationButton];
    
    UIButton *towDCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    towDCodeButton.frame = CGRectMake(20, kScreenHeight - 10 - 64 - 40, 40, 40);
    [towDCodeButton setImage:[UIImage imageNamed:@"qr_btn"] forState:UIControlStateNormal];
    [self.view addSubview:towDCodeButton];
    
}

- (void)buttonAction:(UIButton *)button {
    
    if (button.tag == 0) {
        //发微博操作
        //模态视图的形式 弹出发微博的视图，带有导航栏
        SendWeiboViewController *send = [[SendWeiboViewController alloc] init];
        BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:send];
        
        [self presentViewController:navi animated:YES completion:^(){
            //关闭侧拉栏
            [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        }];
    }
    
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
