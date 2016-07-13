//
//  MoreViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/21.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "MoreViewController.h"
#import "AppDelegate.h"
#import "UIViewController+MMDrawerController.h"
#import "SDImageCache.h"


@interface MoreViewController ()

@property (weak, nonatomic) IBOutlet ThemeImageView *icon1;
@property (weak, nonatomic) IBOutlet ThemeImageView *icon2;
@property (weak, nonatomic) IBOutlet ThemeImageView *icon3;
@property (weak, nonatomic) IBOutlet ThemeImageView *icon4;
@property (weak, nonatomic) IBOutlet ThemeLabel *label1;
@property (weak, nonatomic) IBOutlet ThemeLabel *label2;
@property (weak, nonatomic) IBOutlet ThemeLabel *label3;
@property (weak, nonatomic) IBOutlet ThemeLabel *label4;
@property (weak, nonatomic) IBOutlet ThemeLabel *themeNameLabel;
@property (weak, nonatomic) IBOutlet ThemeLabel *cacheSizeLabel;


@end


@implementation MoreViewController

#pragma mark - MoreViewController单例创建
+ (instancetype)shareMoreVC {
    
    static MoreViewController *moreVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (moreVC == nil) {
            moreVC = [[super allocWithZone:NULL] init];
        }
    });
    
    return moreVC;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareMoreVC];
}

- (id)copy {
    return self;
}


//界面将要显示的时候 显示主题名
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.themeNameLabel.text = [ThemeManager shareManager].themeName;
    
    [self readCatchSize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"更多";
    
    //不是继承自BaseViewController，需要单独设置背景图片
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"bg_home.jpg";
    [self.view insertSubview:bgImageView atIndex:0];

    self.icon1.imageName = @"more_icon_theme.png";
    self.icon2.imageName = @"more_icon_account.png";
    self.icon3.imageName = @"more_icon_draft.png";
    self.icon4.imageName = @"more_icon_feedback.png";
    
    self.label1.colorName = @"More_Item_Text_color";
    self.label2.colorName = @"More_Item_Text_color";
    self.label3.colorName = @"More_Item_Text_color";
    self.label4.colorName = @"More_Item_Text_color";
    self.themeNameLabel.colorName = @"More_Item_Text_color";
    self.cacheSizeLabel.colorName = @"More_Item_Text_color";
    
    SinaWeibo *weibo = ((AppDelegate *)([UIApplication sharedApplication].delegate)).sinaWeibo;
    if (weibo.accessToken == nil) {
        [_logButton setTitle:@"登陆" forState:UIControlStateNormal];
        _logButton.tag = 0;
    } else {
        [_logButton setTitle:@"取消登陆" forState:UIControlStateNormal];
        _logButton.tag = 1;
    }
    
    [self creatNavigationBarButton];
}

//添加单元格的点击事件，主题选择
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        //PUSH
        UIViewController *theme = [self.storyboard instantiateViewControllerWithIdentifier:@"ThemeSelectController"];
        //PUSH过去之后隐藏标签栏
        theme.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:theme animated:YES];
        
    } else if(indexPath.row == 0 && indexPath.section ==1) {
            
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"清除缓存" message:[NSString stringWithFormat:@"确定清除缓存%@", self.cacheSizeLabel.text] preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            self.cacheSizeLabel.text = @"0.0 MB";
            
            [self clearCatch];
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
        
        [self presentViewController:alert animated:YES completion:NULL];
        
    }
    
}



#pragma mark - 登陆按钮操作
- (IBAction)weiboLogButton:(UIButton *)sender {
    //从AppDelegate代理对象中获取微博对象
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    SinaWeibo *weibo = appDelegate.sinaWeibo;
    
    if (sender.tag == 0) {
        [weibo logIn]; //登陆微博
        
    } else if (sender.tag == 1) {
        //删除本地保存的用户登陆信息
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"SinaWeiboAuthData"];
        [userDefaults synchronize];
        
        [weibo logOut]; //注销微博

    }
}

#pragma mark - 打开侧边栏按钮
- (void)creatNavigationBarButton {
    ThemeButton *button = [ThemeButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 44);
    [button setTitle:@"设置" forState:UIControlStateNormal];
    button.backgroundImageName = @"titlebar_button_9.png";
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)buttonAction:(ThemeButton *)button {
    //获取到MMDrawerController
    /*
     方法1
     在APPDelegate中，将MMDrawer设置为其中一个属性。然后通过APP->Delegate->MMDrawer
     
     方法2
     获取Window，然后通过RootViewController就能够来获取MMDrawer
     self.view.window.rootViewController
     
     方法3
     使用UIViewController+MMDrawerController类目，来快速的获取MMDrawer
     */

    MMDrawerController *mmDrawer = self.mm_drawerController;
    
    //通过设置按钮，打开和关闭左边侧边栏
    if (mmDrawer.openSide == 0) {
        [mmDrawer openDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        
    } else if (mmDrawer.openSide == 1) {
        [mmDrawer closeDrawerAnimated:MMDrawerSideRight completion:nil];
        
    }
}

#pragma mark - 缓存
- (void)readCatchSize {
    
    NSInteger fileSize = [self getCatchSize];
    
    self.cacheSizeLabel.text = [NSString stringWithFormat:@"%.2f MB", fileSize / 1024.0 / 1024.0];
    
}

- (NSInteger)getCatchSize
{
    NSInteger fileSize = 0;
    
    //拿到缓存文件夹  (PathComponent追加路径的方法，前面不需要加'/')
    NSString *catchPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    //拿到缓存文件夹下的所有文件的属性
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:catchPath];
    //拿到属性中的文件名，确定文件的路径，计算文件的大小
    for (NSString *fileName in fileEnumerator) {
        //确定文件的路径
        NSString *filePath = [catchPath stringByAppendingPathComponent:fileName];
        //获取文件的属性
        NSDictionary *attDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        //累加文件大小（文件属性中的getter方法得到文件的大小）
        fileSize += attDic.fileSize;
    }

    return fileSize;
}

- (void)clearCatch
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];  //拿到缓存文件夹
        
       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];

       for (NSString *p in files) {
           NSError *error;
           NSString *path = [cachPath stringByAppendingPathComponent:p];
           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
           }
       }
        
       [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
    });
}

-(void)clearCacheSuccess
{

    UIAlertController *cacheAlert = [UIAlertController alertControllerWithTitle:@"缓存清理成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [cacheAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:NULL]];
    
    [self presentViewController:cacheAlert animated:YES completion:NULL];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
