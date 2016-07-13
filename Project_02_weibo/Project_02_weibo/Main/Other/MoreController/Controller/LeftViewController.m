//
//  LeftViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/25.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "LeftViewController.h"
#import "MMExampleDrawerVisualStateManager.h"

@interface LeftViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *_types;
    
    NSInteger _selectIndex;
}

@end

@implementation LeftViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    //背景视图
    ThemeImageView *bgImageView = [[ThemeImageView alloc] initWithFrame:self.view.bounds];
    bgImageView.imageName = @"mask_bg.jpg";
    [self.view insertSubview:bgImageView atIndex:0];
    
    //初始化数据
    _types = @[@"无",
                 @"滑动",
                 @"滑动&缩放",
                 @"3D旋转",
                 @"视差滑动"];
    
    [self createTableView];
    
    //从本地读取滑动样式
    NSString * type = [[NSUserDefaults standardUserDefaults] objectForKey:kTypesSelectRow];
    
    if (type == nil) {
        _selectIndex = 0;
        
    } else {
        _selectIndex = [type integerValue];
    }
    
    //设置滑动样式
    [self typesSelectManager:_selectIndex];
    
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeDidChangedNotifacationName object:nil];

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)createTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth / 2, kScreenHeight - 64) style:UITableViewStylePlain];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _types.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    //设置内容
    cell.textLabel.text = _types[indexPath.row];
    cell.textLabel.textColor = [[ThemeManager shareManager] themeColorWithColorName:@"Timeline_Content_color"];
    cell.backgroundColor = [UIColor clearColor];
    
    //去掉选中效果
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //判断当前单元格是否被选中
    if (indexPath.row == _selectIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectIndex = indexPath.row;
    
    [tableView reloadData];
    
    //更改滑动样式
    [self typesSelectManager:_selectIndex];
    
    //更改后的滑动样式保存到本地
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%li", _selectIndex] forKey:kTypesSelectRow];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (void)themeChanged {
    
    [_tableView reloadData];
}


#pragma mark - 滑动样式的设定
- (void)typesSelectManager:(NSInteger)index {
    //获取滑动样式管理器
    MMExampleDrawerVisualStateManager *manager = [MMExampleDrawerVisualStateManager sharedManager];
    
    //设定向左滑动和向右滑动的动画样式
    manager.leftDrawerAnimationType = index;
    manager.rightDrawerAnimationType = index;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
