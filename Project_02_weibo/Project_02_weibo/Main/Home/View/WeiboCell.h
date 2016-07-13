//
//  WeiboCell.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/27.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weibo.h"
#import "WXLabel.h"

@interface WeiboCell : UITableViewCell <WXLabelDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView; //头像
@property (weak, nonatomic) IBOutlet ThemeLabel *userNameLabel;  //昵称
@property (weak, nonatomic) IBOutlet ThemeLabel *timeLabel;      //时间
@property (weak, nonatomic) IBOutlet ThemeLabel *sourceLabel;    //来源

@property (strong, nonatomic) WXLabel *weiboTextLabel;     //微博正文
@property (strong, nonatomic) WXLabel *reWeiboTextLabel;   //转发微博的正文
@property (nonatomic, strong) NSArray *imagesArray;        //微博中的图片
@property (strong ,nonatomic) ThemeImageView *reWeiboBGImageView;  //转发微博的背景图片视图

@property (strong, nonatomic) Weibo *weiboModel;

@end
