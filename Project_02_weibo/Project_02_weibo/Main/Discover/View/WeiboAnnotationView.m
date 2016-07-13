//
//  WeiboAnnotationView.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/11.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "WeiboAnnotationView.h"
#import "WeiboAnnotation.h"
#import "UIImageView+WebCache.h"

@implementation WeiboAnnotationView

//复写初始化方法
- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        //自定义创建标注视图
        [self createSubviews];
    }
    
    return self;
}

- (void)createSubviews {
    
    //背景图片
    UIImage *image = [UIImage imageNamed:@"nearby_map_people_bg.png"];
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:image];
    //自动调整大小
    [bgImageView sizeToFit];
    
    [self addSubview:bgImageView];
    
    //调整背景视图位置，是底边中心点对准(0,0)
    bgImageView.center = CGPointZero;
    bgImageView.bottom = 0;
    
    //显示用户头像的视图
    UIImageView *userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 50, 50)];
    //设置圆角
    userImageView.layer.cornerRadius = 5;
    userImageView.layer.masksToBounds = YES;
    userImageView.backgroundColor = [UIColor clearColor];
    [bgImageView addSubview:userImageView];
    
    //填充数据
    //获取标注对象  ---> weiboModel ---> 用户头像URL地址
    WeiboAnnotation *annotation = self.annotation;
    Weibo *weibo = annotation.weibo;
    NSURL *url = [NSURL URLWithString:weibo.user.profile_image_url];
    [userImageView sd_setImageWithURL:url];
    
}



@end
