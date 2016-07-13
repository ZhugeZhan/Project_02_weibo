//
//  WeiboAnnotation.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/11.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WeiboAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; //协议中必须实现
@property (nonatomic, strong) Weibo *weibo; //通过微博对象，来设置标注点在地图中的经纬度位置

@end
