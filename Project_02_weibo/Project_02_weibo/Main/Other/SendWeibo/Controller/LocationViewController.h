//
//  LocationViewController.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/7.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^LocationResultBlock)(NSDictionary *location);


@interface LocationViewController : BaseViewController

@property (nonatomic, copy) LocationResultBlock locationBlock;


@end
