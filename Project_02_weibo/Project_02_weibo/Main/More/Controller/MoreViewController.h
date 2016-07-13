//
//  MoreViewController.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/21.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *logButton;

//获取Manager单例对象
+ (instancetype)shareMoreVC;

@end
