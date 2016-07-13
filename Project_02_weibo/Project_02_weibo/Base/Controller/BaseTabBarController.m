//
//  BaseTabBarController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/21.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "BaseTabBarController.h"

@interface BaseTabBarController ()
{
    ThemeImageView *_arrowView;
}
@end

@implementation BaseTabBarController


//重写init方法，用于加载五个子控制器
- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        //读取五个Storyboard 来加载子控制器
        NSArray *storyBoardNames = @[@"Home",
                                     @"Message",
                                     @"Discover",
                                     @"Profile",
                                     @"More"];
        
        NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
        
        for (NSString *name in storyBoardNames) {
            //根据文件名读取storyBoard
            UIStoryboard *sb = [UIStoryboard storyboardWithName:name bundle:[NSBundle mainBundle]];
            //从storyBoard中获取视图控制器
            UIViewController *vc = [sb instantiateInitialViewController];
            
            [viewControllers addObject:vc];
        }
        
        self.viewControllers = viewControllers;
        
        //自定义标签栏
        [self customTabBar];
        
        //添加监听通知，用于主题切换
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabBarBackgroundImage) name:kThemeDidChangedNotifacationName object:nil];
    }
    
    return self;
}

//移除通知监听
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//自定义标签栏
- (void)customTabBar {
    
    //1.把原来按钮移除
    for (UIView *view in self.tabBar.subviews) {
        
        Class buttonClass = NSClassFromString(@"UITabBarButton");
        
        if ([view isKindOfClass:buttonClass]) {
            
            [view removeFromSuperview];
        }
    }
    
    //2.添加自定义按钮
    
    //设置标签栏背景
    [self tabBarBackgroundImage];
    
    
    NSArray *imageNames = @[@"home_tab_icon_1.png",
                            @"home_tab_icon_2.png",
                            @"home_tab_icon_3.png",
                            @"home_tab_icon_4.png",
                            @"home_tab_icon_5.png"];
    //计算按钮的宽度
    CGFloat buttonWidth = kScreenWidth / imageNames.count;
    //创建按钮
    for (int i = 0; i < imageNames.count; i++) {
        ThemeButton *button = [ThemeButton buttonWithType:UIButtonTypeCustom];
        //计算按钮frame
        button.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, 49);
        //设置按钮图片
        button.imageName = imageNames[i];
        
        [self.tabBar addSubview:button];
        
        //3.添加点击逻辑，改变当前显示的页面
        button.tag = i;
        [button addTarget:self action:@selector(tabBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //选中视图
    _arrowView = [[ThemeImageView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, 49)];
    _arrowView.imageName = @"home_bottom_tab_arrow.png";
    [self.tabBar insertSubview:_arrowView atIndex:0];
    
    //去除标签栏的黑色阴影线
    self.tabBar.shadowImage = [UIImage new];
}

//标签栏按钮点击事件
- (void)tabBarButtonAction:(UIButton *)button{
    
    //根据按钮点击 切换页面
    self.selectedIndex = button.tag;
    
    [UIView animateWithDuration:0.3 animations:^{
        _arrowView.center = button.center;
    }];
}

//监听事件 标签栏的背景随主题改变
- (void)tabBarBackgroundImage {
    //背景图片拉伸
    UIImage *backgroundImage = [[ThemeManager shareManager] themeImageWithImageName:@"mask_navbar.png"];
    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:0.5 topCapHeight:0.5];
    self.tabBar.backgroundImage = backgroundImage;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
