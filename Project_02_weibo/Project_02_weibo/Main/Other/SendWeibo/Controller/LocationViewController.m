//
//  LocationViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/7.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "LocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"

@interface LocationViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, SinaWeiboRequestDelegate>
{
    UITableView *_locationTableView;
    CLLocationManager *_locationManager;  //定位服务管理器，用于开启定位
    NSArray *_locationArray;  //存储反编码后的位置信息
    UIColor *_textColor;
}
@end


@implementation LocationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //初始化文本颜色
    _textColor = [[ThemeManager shareManager] themeColorWithColorName:@"More_Item_Text_color"];
    
    //创建表视图
    [self creatLocationTableView];
    
    //开启定位
    [self openLocation];
    
}

//创建表视图
- (void)creatLocationTableView {
    
    _locationTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
    _locationTableView.backgroundColor = [UIColor clearColor];
    _locationTableView.delegate = self;
    _locationTableView.dataSource = self;
    [self.view addSubview:_locationTableView];
}


#pragma mark - 开启定位
- (void)openLocation {
    
    _locationManager = [[CLLocationManager alloc] init];
    
    //在iOS8后，进行定位服务需要设置定位服务的类型
    //NSLocationAlwaysUsageDescription 始终使用定位服务
    //NSLocationWhenInUseUsageDescription 仅在使用程序时获取位置信息
    //将配置信息字段，添加到info.plist文件中，并且在字段后，输入一段提示文字
    
    //需要请求用户授权访问位置信息
    CGFloat systemVersion = [[UIDevice currentDevice].systemVersion floatValue];
    
    if (systemVersion >= 8.0) {
        //请求授权在使用时获取位置信息
        [_locationManager requestWhenInUseAuthorization];
    }
    
    //设定定位的精准度
    /*
     kCLLocationAccuracyBest;                //最高精准度
     kCLLocationAccuracyNearestTenMeters;    //10米
     kCLLocationAccuracyHundredMeters;       //100米
     kCLLocationAccuracyKilometer;           //1000米
     kCLLocationAccuracyThreeKilometers;     //3000米
     */
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //设置代理 用于获取定位结果
    _locationManager.delegate = self;
    
    //开启定位
    [_locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    //关闭定位
    [manager stopUpdatingLocation];
    
    //获取当前位置的经纬度信息
    CLLocation *location = [locations firstObject];
    //经度
    CGFloat lon = location.coordinate.longitude;
    //纬度
    CGFloat lat = location.coordinate.latitude;
    
    //进行位置的反编码  经纬度值-->地点名称.XX省XX市XX区
    //使用新浪微博的接口，进行位置信息反编码
    
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    SinaWeibo *weibo = appDelegate.sinaWeibo;
    
    NSMutableDictionary *params = [@{@"lat" :[NSString stringWithFormat:@"%f", lat],
                                     @"long" : [NSString stringWithFormat:@"%f", lon],
                                     @"count" : @"20",
                                     } mutableCopy];
    //发起请求 获取附近的地点信息
    [weibo requestWithURL:@"place/nearby/pois.json" params:params httpMethod:@"GET" delegate:self];
}


#pragma mark - SinaWeiboRequestDelegate

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    
    _locationArray = result[@"pois"];
    
    //刷新表视图
    [_locationTableView reloadData];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _locationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        //两个标题的style---subtitle
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    //填充地理信息数据
    //获取到一个地点的信息
    NSDictionary *dic = _locationArray[indexPath.row];
    
    //加载地标图片
    NSString *imageUrl = dic[@"icon"];
    UIImage *imageData =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    cell.imageView.image = imageData;
    
    cell.textLabel.text = dic[@"title"];
    cell.textLabel.textColor = _textColor;
    
    //保证address不为空
    id address = dic[@"address"];
    if (![address isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = dic[@"address"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //获取选中的位置
    NSDictionary *location = _locationArray[indexPath.row];
    
    //执行Block 回传数据
    if (_locationBlock) {
        _locationBlock(location);
    }
    
    //隐藏定位界面
    [self.navigationController popViewControllerAnimated:YES];
}






@end













