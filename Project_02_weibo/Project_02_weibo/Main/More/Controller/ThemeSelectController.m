//
//  ThemeSelectController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/22.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "ThemeSelectController.h"
#import "UIViewController+MMDrawerController.h"

@interface ThemeSelectController () <UITableViewDelegate, UITableViewDataSource>
{
    NSDictionary *_themeDic; //保存主题的信息
    NSInteger _selectRow; //选中的行数
    UIColor *_textColor;  //文本颜色
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation ThemeSelectController

//界面将要显示的时候 显示主题名 关闭MMDrawer手势
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
}

//界面消失的时候执行 打开MMDrawer手势
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.mm_drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"主题选择";
    
    //初始化文本颜色
    _textColor = [[ThemeManager shareManager] themeColorWithColorName:@"More_Item_Text_color"];
    
    //读取本地保存的主题对应的selectRow,打勾
    NSString *row = [[NSUserDefaults standardUserDefaults] objectForKey:kThemeSelectRow];
    
    if (row == nil) {
        _selectRow = 10; //默认主题为 猫爷
    } else {
        _selectRow = [row integerValue];
    }

    //注册单元格
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    //读取主题字典文件
    _themeDic = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"theme" ofType:@"plist"]];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _themeDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    //key：主题名
    //value：主题包路径
    
    //获取主题名
    NSArray *themeNames = _themeDic.allKeys;
    NSString *themeKey = themeNames[indexPath.row];
    //获取主题包路径
    NSString *themePath = _themeDic[themeKey];
    //拼接主题包路径和里面的图片名，获取主题图片
    NSString *iconPath = [NSString stringWithFormat:@"%@/%@", themePath, @"more_icon_theme.png"];
    UIImage *iconImage = [UIImage imageNamed:iconPath];
    
    cell.textLabel.text = themeKey;
    cell.textLabel.textColor = _textColor;
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = iconImage;
    
    //判断当前行是否已经选中,选中打勾
    if (_selectRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _selectRow = indexPath.row;
    
    //主题对应的selectRow保存到本地,打勾
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%li", _selectRow] forKey:kThemeSelectRow];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //改变当前主题
    NSString *themeName = _themeDic.allKeys[indexPath.row];
    ThemeManager *manager = [ThemeManager shareManager];
    manager.themeName = themeName; //传递主题名
    
    _textColor = [[ThemeManager shareManager] themeColorWithColorName:@"More_Item_Text_color"];
    
    //刷新表视图
    [tableView reloadData];
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
