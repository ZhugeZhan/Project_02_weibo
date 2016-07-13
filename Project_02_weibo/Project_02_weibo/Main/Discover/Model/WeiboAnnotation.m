//
//  WeiboAnnotation.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/11.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "WeiboAnnotation.h"

@implementation WeiboAnnotation

- (void)setWeibo:(Weibo *)weibo {
    _weibo = weibo;
    
    //从微博对象中 获取地理位置信息字段
    NSDictionary *geo = _weibo.geo;
    
    //获取经纬度信息
    NSArray *array = geo[@"coordinates"];
    
    if (array.count == 2) {
        NSString *lat = [array firstObject];
        NSString *lon = [array lastObject];
        
        //创建位置信息对象
        _coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
    }
    
}

@end
