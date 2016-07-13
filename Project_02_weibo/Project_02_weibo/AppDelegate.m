//
//  AppDelegate.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/21.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "AppDelegate.h"
#import "BaseTabBarController.h"
#import "BaseNavigationController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "MoreViewController.h"

@interface AppDelegate () <SinaWeiboDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //创建左中右三个控制器
    LeftViewController *leftVC = [[LeftViewController alloc] init];
    RightViewController *rightVC = [[RightViewController alloc] init];
    BaseTabBarController *centerVC = [[BaseTabBarController alloc] init];
    
    //给左右视图添加导航控制器
    BaseNavigationController *leftNVC = [[BaseNavigationController alloc] initWithRootViewController:leftVC];
    BaseNavigationController *rightNVC = [[BaseNavigationController alloc] initWithRootViewController:rightVC];
    
    //创建MMDrawerController
    MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:centerVC leftDrawerViewController:leftNVC rightDrawerViewController:rightNVC];
    
    //设置左右滑动的距离
    drawerController.maximumLeftDrawerWidth = kScreenWidth / 2;
    drawerController.maximumRightDrawerWidth = 80;
    
    //设置打开和关闭的手势
    drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    
    //设置左右滑动开关动画的Block
    [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        
        //创建管理器
        MMExampleDrawerVisualStateManager *manager = [MMExampleDrawerVisualStateManager sharedManager];
        //获取相对应的滑动方向的Block
        MMDrawerControllerDrawerVisualStateBlock block = [manager drawerVisualStateBlockForDrawerSide:drawerSide];
        //执行对应的Block 执行动画
        if (block) {
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    
    
    //创建window
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = drawerController;
    
    [self.window makeKeyAndVisible];
    
    
    
    //在AppDelegate中实现微博对象的初始化
    _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI andDelegate:self];
    
    //读取本地信息，判断是否已经登陆过
    BOOL isLogin = [self readUserData];
    
    if (isLogin == NO) {
        //之前没有登陆过，登陆
        [_sinaWeibo logIn];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - SinaWeibo Delegate
//登陆完成
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    NSLog(@"登陆成功");
    [self saveAuthData]; //保存账号信息
    MoreViewController *moreVC = [MoreViewController shareMoreVC];
    [moreVC.logButton setTitle:@"注销" forState:UIControlStateNormal];
    moreVC.logButton.tag = 1;
}
//注销完成
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo {
    NSLog(@"注销成功");
    MoreViewController *moreVC = [MoreViewController shareMoreVC];
    [moreVC.logButton setTitle:@"登陆" forState:UIControlStateNormal];
    moreVC.logButton.tag = 0;
}
//登陆认证时间过期
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {
    //删除本地保存的用户登陆信息
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"SinaWeiboAuthData"];
    [userDefaults synchronize];
    //注销微博
    [_sinaWeibo logOut];
    //重新登陆
    [_sinaWeibo logIn];
}

#pragma mark - 保存和读取用户认证信息
//保存账号认证信息
- (void)saveAuthData {
    
    NSString *accessToken = _sinaWeibo.accessToken;
    NSDate *expiresDate = _sinaWeibo.expirationDate;  //认证的有效期限
    NSString *uid = _sinaWeibo.userID;  //用户id
    
    //将登陆的认证信息保存到本地
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //创建一个认证信息字典
    NSDictionary *authDic = @{@"accessToken" : accessToken,
                              @"expiresDate" : expiresDate,
                              @"uid" : uid};
    //保存数据
    [userDefaults setObject:authDic forKey:@"SinaWeiboAuthData"];
    //同步数据
    [userDefaults synchronize];
}

//读取之前登陆过的本地用户信息
- (BOOL)readUserData {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *authDic = [userDefaults objectForKey:@"SinaWeiboAuthData"];
    
    if (authDic == nil) {
        //之前没有登陆过
        return NO;
    }
    
    //从字典中读取信息
    NSString *accessToken = authDic[@"accessToken"];
    NSDate *expiresDate = authDic[@"expiresDate"];
    NSString *uid = authDic[@"uid"];
    
    //再次判断登入过的信息是否存在
    if (accessToken == nil || expiresDate == nil ||uid == nil) {
        return NO;
    }
    
    //设置用户登陆信息，从本地
    self.sinaWeibo.accessToken = accessToken;
    self.sinaWeibo.expirationDate = expiresDate;
    self.sinaWeibo.userID = uid;
    NSLog(@"之前已经登陆过了微博，accessToken:%@",accessToken);
    
    return YES;
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.zgz.Project_02_weibo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Project_02_weibo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Project_02_weibo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
