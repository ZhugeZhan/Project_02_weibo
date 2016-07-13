//
//  HomeViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/21.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "YYModel.h"
#import "WeiboCell.h"
#import "WXRefresh.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController () <SinaWeiboRequestDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_weiboList;     //微博表视图
    NSMutableArray *_weiboArray; //微博数据
    SystemSoundID soundID;  //系统声音
}

@property (nonatomic, strong) ThemeImageView *weiboCountView;
@property (nonatomic, strong) ThemeLabel *weiboCountLabel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"主页";
    
    //获取微博首页的数据
    [self requestWeiboData];
    
    //创建微博列表
    [self creatWeiboTableView];
    
    //显示新微博数量
    [self weiboCountView];
    [self weiboCountLabel];
    
    //添加系统声音
    [self registerSystemSound];
}

#pragma mark - 懒加载
- (ThemeImageView *)weiboCountView {
    if (_weiboCountView == nil) {
        _weiboCountView = [[ThemeImageView alloc] initWithFrame:CGRectMake(5, -45, kScreenWidth - 10, 40)];
        _weiboCountView.imageName = @"timeline_notify.png";
        _weiboCountView.hidden = YES; //默认隐藏
        [self.view addSubview: _weiboCountView];
    }
    
    return _weiboCountView;
}

- (ThemeLabel *)weiboCountLabel {
    if (_weiboCountLabel == nil) {
        _weiboCountLabel = [[ThemeLabel alloc] initWithFrame:self.weiboCountView.bounds];
        _weiboCountLabel.colorName = @"Mask_Noitce_color";
        _weiboCountLabel.textAlignment = NSTextAlignmentCenter;
        [_weiboCountView addSubview:_weiboCountLabel];
        
    }
    
    return _weiboCountLabel;
}

#pragma mark - 刷新微博的系统声音
- (void)registerSystemSound {
    //获取音频文件的URL路径
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"msgcome" withExtension:@"wav"];
    //创建系统声音
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(soundURL), &soundID);
}
- (void)dealloc {
    AudioServicesRemoveSystemSoundCompletion(soundID);
}

#pragma mark - 显示刷新出来的微博条数
- (void)showNewWeiboCount:(NSInteger)count {
    
    self.weiboCountView.hidden = NO;
    self.weiboCountLabel.text = [NSString stringWithFormat:@"%li条新微博", (long)count];
    if (count <= 0) {
        self.weiboCountLabel.text = @"没有新微博";
    }
    
    //动画效果
    [UIView animateWithDuration:0.5 animations:^{
        
        self.weiboCountView.top = 5;
        
        //播放系统声音
        AudioServicesPlaySystemSound(soundID);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:2 options:UIViewAnimationOptionLayoutSubviews animations:^{
            
            self.weiboCountView.top = -45;
            
        } completion:^(BOOL finished) {
        }];
        
    }];
}


#pragma mark - Creat Weibo Table View
- (void)creatWeiboTableView {
    
    _weiboList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - 49) style:UITableViewStylePlain];
    _weiboList.backgroundColor = [UIColor clearColor];
    _weiboList.delegate = self;
    _weiboList.dataSource = self;
    [self.view addSubview:_weiboList];
    
    //注册单元格
    UINib *nib = [UINib nibWithNibName:@"WeiboCell" bundle:[NSBundle mainBundle]];
    [_weiboList registerNib:nib forCellReuseIdentifier:@"WeiboCell"];
    
    
    
    //添加下拉刷新 上拉加载
    //解决ARC环境下 block的循环引用
    __weak HomeViewController *weakSelf = self;
    
    [_weiboList addPullDownRefreshBlock:^{
        
        __strong HomeViewController *strongSelf = weakSelf;
        [strongSelf loadNewWeibo];
        
    }];
    
    [_weiboList addInfiniteScrollingWithActionHandler:^{
        
        __strong HomeViewController *strongSelf = weakSelf;
        [strongSelf loadMoreWeibo];
        
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _weiboArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeiboCell" forIndexPath:indexPath];
    cell.weiboModel = _weiboArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Weibo *weiboModel = _weiboArray[indexPath.row];
    
    //每次设置新的weibo对象时，重新计算布局
    WeiboCellLayout *layout = [WeiboCellLayout weiboCellLayoutWithWeiboModel:weiboModel];
    
    return layout.cellHeight;
}


#pragma mark - 获取微博数据
- (void)requestWeiboData {
    
    //获取微博对象
    SinaWeibo *weibo = ((AppDelegate *)([UIApplication sharedApplication].delegate)).sinaWeibo;
    
    if (weibo.accessToken == nil) {
        return;
    }
    
    //请求参数字典 AccessToken不需要手动设置，在系统内部自动添加
    NSMutableDictionary *params = [@{@"count" : @"20"} mutableCopy];
    
    //发起请求
    SinaWeiboRequest *request = [weibo requestWithURL:@"statuses/friends_timeline.json"
                                             params:params
                                         httpMethod:@"GET"
                                           delegate:self];
    request.tag = 1;
}

#pragma mark - 下拉刷新和上拉加载
- (void)loadNewWeibo {
    //获取微博对象
    SinaWeibo *weibo = ((AppDelegate *)([UIApplication sharedApplication].delegate)).sinaWeibo;
    
    if (weibo.accessToken == nil) {
        [_weiboList.pullToRefreshView stopAnimating];
        return;
    }
    
    //已经获取的第一条微博数据
    Weibo *firstWeibo = [_weiboArray firstObject];
    
    //如果之前还没有获取到微博数据，重新获取
    if (firstWeibo == nil) {
        [self requestWeiboData];
        return;
    }
    
    //请求参数字典 AccessToken不需要手动设置，在系统内部自动添加
    NSDictionary *params = @{@"count" : @"20",
                             @"since_id" : firstWeibo.idstr
                            };
    //发起请求
    SinaWeiboRequest *request = [weibo requestWithURL:@"statuses/friends_timeline.json"
                                              params:[params mutableCopy]
                                          httpMethod:@"GET"
                                            delegate:self];
    request.tag = 2;
}

- (void)loadMoreWeibo {
    //获取微博对象
    SinaWeibo *weibo = ((AppDelegate *)([UIApplication sharedApplication].delegate)).sinaWeibo;
    
    if (weibo.accessToken == nil) {
        [_weiboList.infiniteScrollingView stopAnimating];
        return;
    }

    //已经获取的第一条微博数据
    Weibo *lastWeibo = [_weiboArray lastObject];
    
    //如果之前还没有获取到微博数据，重新获取
    if (lastWeibo == nil) {
        [self requestWeiboData];
        return;
    }
    

    long long num = [lastWeibo.idstr longLongValue] - 1;
    NSString *max_id = [NSString stringWithFormat:@"%lld", num];
    
    //请求参数字典 AccessToken不需要手动设置，在系统内部自动添加
    NSDictionary *params = @{@"count" : @"20",
                             @"max_id" : max_id
                             };
    //发起请求
    SinaWeiboRequest *request = [weibo requestWithURL:@"statuses/friends_timeline.json"
                                               params:[params mutableCopy]
                                           httpMethod:@"GET"
                                             delegate:self];
    request.tag = 3;
}


#pragma mark - SinaWeiboRequestDelegate
- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result {
    
    //读取和接收数据
    NSArray *statuses = result[@"statuses"];
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    //遍历数组，获取每一条微博
    for (NSDictionary *dic in statuses) {
        
        //采用YYModel框架 在Json -> Model 转化完成后 可调用方法，处理自动转换无法完成的数据
        Weibo *weibo = [Weibo yy_modelWithJSON:dic];
        
        [mArray addObject:weibo];
    }
    
    if (request.tag == 1) {
        
        _weiboArray = [mArray mutableCopy];
        
    } else if (request.tag == 2) {
        
        [_weiboArray insertObjects:mArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, mArray.count)]];
        //显示刷新出来的微博条数
        [self showNewWeiboCount:mArray.count];
        
    } else if (request.tag == 3) {
        
        [_weiboArray addObjectsFromArray:mArray];
    }

    //刷新表视图
    [_weiboList reloadData];
    
    //停止刷新动画
    [_weiboList.pullToRefreshView stopAnimating];
    [_weiboList.infiniteScrollingView stopAnimating];
}


@end
