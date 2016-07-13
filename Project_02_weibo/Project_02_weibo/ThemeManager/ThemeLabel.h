//
//  ThemeLabel.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/24.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeLabel : UILabel

//根据颜色名，到字典中找到当前主题对应的文本颜色数据
@property (nonatomic, copy) NSString *colorName;

@end
