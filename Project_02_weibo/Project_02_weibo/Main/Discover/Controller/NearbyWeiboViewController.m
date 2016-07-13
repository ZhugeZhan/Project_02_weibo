//
//  NearbyWeiboViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/11.
//  Copyright © 2016年 ZGZ. All rights reserved.
//


/*
 1.创建地图显示视图
 2.GPS定位，获取用户当前位置，并且显示在地图中
 3.获取用户经纬度信息，向新浪服务器请求位置附近的微博消信息
 4.添加地图标注点，使用系统标注点的样式
 5.标注点视图的自定义
 */


#import "NearbyWeiboViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "YYModel.h"
#import "WeiboAnnotation.h"
#import "WeiboAnnotationView.h"


@interface NearbyWeiboViewController() <MKMapViewDelegate, SinaWeiboRequestDelegate>
{
    MKMapView *_mapView;
    
    BOOL _isLocation; //避免多次请求
}

@end



@implementation NearbyWeiboViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"附近微博";
    
    _isLocation = NO;
    [self creatMapView];
}


- (void)creatMapView {
    
    //需要请求用户授权访问位置信息
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
    if (systemVersion >= 8.0) {
        //请求授权在使用时获取位置信息
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        [manager requestWhenInUseAuthorization];
    }
    
    //创建地图视图
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_mapView];
    
    //显示当前用户位置
    _mapView.showsUserLocation = YES;
    
    //通过代理对象 来获取用户定位的结果
    _mapView.delegate = self;
    
}

#pragma mark - MKMapViewDelegate 1
//当地图更新用户位置完成后调用的代理方法
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    //获取用户位置
    //用户位置在2维坐标系中的经纬度坐标
    CLLocationCoordinate2D coordinate = userLocation.coordinate;
    //经纬度
    double lat = coordinate.latitude;       //纬度
    double lon = coordinate.longitude;      //经度
    
    //设定显示范围 以经纬度的范围来计算
    //在经纬度坐标系中的范围，单位为度
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    
    //设定地图的显示区域
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [_mapView setRegion:region animated:YES];
    
    if (_isLocation == NO) {
        _isLocation = YES;
        
        //发送请求，获取附近的微博信息
        UIApplication *app = [UIApplication sharedApplication];
        AppDelegate *appDelegate = app.delegate;
        SinaWeibo *weibo = appDelegate.sinaWeibo;
        
        //拼接经纬度参数
        NSDictionary *dic = @{@"long" : [NSString stringWithFormat:@"%f", lon], @"lat" : [NSString stringWithFormat:@"%f", lat]};
        
        //发起请求
        [weibo requestWithURL:@"place/nearby_timeline.json" params:[dic mutableCopy] httpMethod:@"GET" delegate:self];
    }
}


#pragma mark - SinaWeiboRequestDelegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    
    //获取微博数组
    NSArray *statuses = result[@"statuses"];
    
    //遍历数组 创建微博对象
    for (NSDictionary *dic in statuses) {
        Weibo *wb = [Weibo yy_modelWithDictionary:dic];
        
        //标注对象
        WeiboAnnotation *annotation = [[WeiboAnnotation alloc] init];
        annotation.weibo = wb;
        
        //在地图中 添加一个标注
        [_mapView addAnnotation:annotation];
    }
    
}


#pragma mark - MKMapViewDelegate 2
//显示自定义的MKAnnotationView
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    //用户自身位置标注点
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    WeiboAnnotationView *annotationView = (WeiboAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"WeiboAnnotationView"];
    
    if (annotationView == nil) {
        annotationView = [[WeiboAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"WeiboAnnotationView"];
    }
    
    return annotationView;
}

@end
