//
//  SendWeiboViewController.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/6.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "SendWeiboViewController.h"
#import "AppDelegate.h"
#import "LocationViewController.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "EmoticonInputView.h"


#define kToolViewHeight (40+20+5+100)
#define kLocationViewHeight 20
#define kSendImageViewHeight 100

@interface SendWeiboViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UITextView *_inputTextView;
    UIView *_toolView;
    
    //定位相关视图
    UIImageView *_locationIcon;
    ThemeLabel *_locationTitle;
    ThemeButton *_locationCancelButton;
    
    //选取图片发送
    UIImageView *_sendImageView;
    ThemeButton *_imageCancelButton;
}

@property (nonatomic, copy) EmoticonInputView *emoticonInputView;   //表情输入界面

@property (nonatomic, copy) NSDictionary *locationDic; //接收block回传过来的地理位置信息

@end



@implementation SendWeiboViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createNaviBarButton];
    [self createInputTextView];
    [self createToolView];
    [self createLocationViews];
    [self creatSendImageView];
    
    self.locationDic = nil;
    
    //监听键盘改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 懒加载
- (EmoticonInputView *)emoticonInputView {
    
    if (_emoticonInputView == nil) {
        _emoticonInputView = [[EmoticonInputView alloc] init];
    }
    return _emoticonInputView;
}

#pragma mark - 创建导航栏上的按钮
- (void)createNaviBarButton {
    //返回
    ThemeButton *cancel = [ThemeButton buttonWithType:UIButtonTypeCustom];
    cancel.frame = CGRectMake(0, 0, 60, 44);
    cancel.backgroundImageName = @"titlebar_button_9.png";
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    self.navigationItem.leftBarButtonItem = backItem;
    [cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    //发送
    ThemeButton *send = [ThemeButton buttonWithType:UIButtonTypeCustom];
    send.frame = CGRectMake(0, 0, 60, 44);
    send.backgroundImageName = @"titlebar_button_9.png";
    [send setTitle:@"发送" forState:UIControlStateNormal];
    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:send];
    self.navigationItem.rightBarButtonItem = sendItem;
    [send addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - 创建输入的界面
//创建文本输入
- (void)createInputTextView {
    _inputTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64 - kToolViewHeight)];
    _inputTextView.backgroundColor = [UIColor clearColor];
    [self.view addSubview: _inputTextView];
    
    //输入表情符号
    [self changePageNumber];
    
    //接收通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePageNumber) name:kScrollPageNumber object:nil];
    
    
}


- (void)changePageNumber{
    
    //全局变量在block中使用，相当于block持有了self，有可能造成循环引用
    //需要创建一个weak类型的指针来传递变量
    __weak UITextView *weakText = _inputTextView;
    
    //构建执行代码block 传递给消息的发送者
    [self.emoticonInputView.emViewArray[self.emoticonInputView.pageNumber] addFaceBlcok:^(NSString *faceName) {
        
        //在block中 引用了一个weak类型的变量 所以不会造成循环应用
        //因为weak类型指针变量的特殊性，所以在使用时，最好将weak类型再次转化为strong类型
        __strong UITextView *strongText = weakText;
        
        strongText.text = [NSString stringWithFormat:@"%@%@", strongText.text, faceName];
    }];
}


//创建工具栏
- (void)createToolView {
    _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kToolViewHeight)];
    _toolView.top = _inputTextView.bottom; //位置
    [self.view addSubview: _toolView];
    
    //五个按钮
    NSArray *imageNames = @[@"compose_toolbar_1.png",
                            @"compose_toolbar_3.png",
                            @"compose_toolbar_4.png",
                            @"compose_toolbar_5.png",
                            @"compose_toolbar_6.png",
                            ];
    
    CGFloat buttonWidth = kScreenWidth / imageNames.count;
    for (int i = 0; i < imageNames.count; i++) {
        ThemeButton *button = [ThemeButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i * buttonWidth, kLocationViewHeight + kSendImageViewHeight + 5, buttonWidth, kToolViewHeight - kLocationViewHeight - kSendImageViewHeight);
        button.imageName = imageNames[i];
        
        [button addTarget:self action:@selector(toolBottonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [_toolView addSubview:button];
    }
}

//创建位置信息显示模块，添加到toolView
- (void)createLocationViews {
    
    _locationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, kSendImageViewHeight + 5, kLocationViewHeight, kLocationViewHeight)];
    [_toolView addSubview:_locationIcon];
    
    
    _locationTitle = [[ThemeLabel alloc] initWithFrame:CGRectMake(0, kSendImageViewHeight + 5, 100, kLocationViewHeight)];
    _locationTitle.left = _locationIcon.right + 5;
    _locationTitle.colorName = @"More_Item_Text_color";
    [_toolView addSubview:_locationTitle];
    
    
    _locationCancelButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    _locationCancelButton.frame = CGRectMake(0, kSendImageViewHeight, kLocationViewHeight + 5, kLocationViewHeight);
    _locationCancelButton.left = _locationTitle.right + 5;
    _locationCancelButton.imageName = @"compose_toolbar_clear.png";
    [_locationCancelButton addTarget:self action:@selector(locationCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [_toolView addSubview:_locationCancelButton];
    
}

//创建发送图片的模块，添加到toolView
- (void)creatSendImageView {
    
    _sendImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, kSendImageViewHeight, kSendImageViewHeight)];
    _sendImageView.hidden = YES;
    _sendImageView.userInteractionEnabled = YES;
    [_toolView addSubview:_sendImageView];
    
    _imageCancelButton = [ThemeButton buttonWithType:UIButtonTypeCustom];
    _imageCancelButton.frame = CGRectMake(kSendImageViewHeight - 35, 0, 35, 35);
    _imageCancelButton.imageName = @"compose_toolbar_clear.png";
    [_imageCancelButton addTarget:self action:@selector(imageCancelAction) forControlEvents:UIControlEventTouchUpInside];
    _imageCancelButton.hidden = YES;
    [_sendImageView addSubview:_imageCancelButton];
    
}


#pragma mark - 按钮点击事件
//返回
- (void)cancelAction {
    
    //隐藏键盘----放弃第一响应者
    [_inputTextView resignFirstResponder];
    
    //隐藏模态视图 返回前一页面
    [self dismissViewControllerAnimated:YES completion:nil];
}

//发送
- (void)sendAction {
    
    //获取微博对象
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    SinaWeibo *weibo = appDelegate.sinaWeibo;
    
    if (weibo.accessToken == nil) {
        UIAlertController *alertViewOne = [UIAlertController alertControllerWithTitle:@"发送失败" message:@"未登陆微博" preferredStyle:UIAlertControllerStyleAlert];
        [alertViewOne addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:NULL]];
        [self presentViewController:alertViewOne animated:YES completion:NULL];
        
        return;
    }
    
    //去除字符串中头部的空白字符，再判断是否有正文
    NSString *text = [_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //判断是否输入了正文
    if (text.length == 0)  {
        UIAlertController *alertViewTwo = [UIAlertController alertControllerWithTitle:@"发送失败" message:@"微博内容不能为空" preferredStyle:UIAlertControllerStyleAlert];
        [alertViewTwo addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:NULL]];
        [self presentViewController:alertViewTwo animated:YES completion:NULL];
  
        return;
    }
    
    //显示HUD
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
    [self.view.window addSubview:hud];
    //显示的文本信息
    hud.labelText = @"正在发送";
    //设置背景颜色变暗
    hud.dimBackground = YES;
    //将HUD显示出来
    [hud show:YES];
    
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    //发送请求，发送微博信息
    [weibo sendWeiboText:text
                   image:_sendImageView.image
                  params:params
                 success:^(id result) {
                     
                     //隐藏HUD
                     hud.labelText = @"发送成功";
                     hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                     hud.mode = MBProgressHUDModeCustomView;
                     [hud hide:YES afterDelay:2];
                 }
                    fail:^(NSError *error) {
                        
                     //隐藏HUD
                     hud.labelText = @"发送失败";
                     hud.mode = MBProgressHUDModeCustomView;
                     [hud hide:YES afterDelay:2];
                    }];
    
    //页面返回
    [self cancelAction];
}

//工具栏按钮点击事件
- (void)toolBottonAction:(UIButton *)button {
    
    if (button.tag == 0) { //选取图片

        //图片来源
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = sourceType;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:NULL];
    
    } else if (button.tag == 3) { //设置定位
        //打开定位
        LocationViewController *location = [[LocationViewController alloc] init];
        //设定位置信息回传Blcok
        location.locationBlock = ^(NSDictionary *locationResult){
            self.locationDic = locationResult;
        };
        [self.navigationController pushViewController:location animated:YES];
        
    } else if (button.tag == 4) {  //创建表情输入界面
        
        //将文本输入框的输入视图 切换为表情输入视图
        _inputTextView.inputView = _inputTextView.inputView ? nil : self.emoticonInputView;
        //重新加载输入视图
        [_inputTextView reloadInputViews];
        //强制显示键盘
        [_inputTextView becomeFirstResponder];

    }
}

//位置信息按钮取消
- (void)locationCancelAction {
    self.locationDic = nil;
}

//图片删除
- (void)imageCancelAction {
    _sendImageView.image = nil;
    _imageCancelButton.hidden = YES;
}


#pragma mark - 键盘改变的通知事件
- (void)keyboardDidShow:(NSNotification *)notification {
    
    //获取键盘在屏幕中的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //改变工具栏的位置
    _toolView.bottom = kScreenHeight - 64 - keyboardFrame.size.height;
    //输入框 根据键盘的显示，而改变高度
    _inputTextView.height = kScreenHeight - 64 - keyboardFrame.size.height - kToolViewHeight;
}
- (void)keyboardDidHide:(NSNotification *)notification { 
    _toolView.bottom = kScreenHeight - 64;
    _inputTextView.height = kScreenHeight - 64 - kToolViewHeight;
}


#pragma mark - 位置信息数据的设定
- (void)setLocationDic:(NSDictionary *)locationDic {
    
    if ((locationDic == _locationDic) && (locationDic != nil)) {
        return;
    }
    
    _locationDic = locationDic;
    
    if (_locationDic) {
        //1 传入了一个新的位置信息  更新界面显示的内容
        //显示定位信息界面
        _locationCancelButton.hidden = NO;
        _locationTitle.hidden = NO;
        _locationIcon.hidden = NO;
        
        //加载内容
        _locationTitle.text = _locationDic[@"title"];
        [_locationIcon sd_setImageWithURL:[NSURL URLWithString:_locationDic[@"icon"]]];
        
        //计算字体宽度
        CGRect rect = [_locationTitle.text boundingRectWithSize:CGSizeMake(kScreenWidth - 40 - 40, kLocationViewHeight) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : _locationTitle.font} context:nil];
        _locationTitle.width = rect.size.width;
        _locationCancelButton.left = _locationTitle.right + 5;
        
    } else {
        //2 传入了一个空的位置信息
        //隐藏定位信息界面
        _locationCancelButton.hidden = YES;
        _locationTitle.hidden = YES;
        _locationIcon.hidden = YES;
    }
}

#pragma mark - 获取图片的delegate 在相册中选择图片时调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    _sendImageView.image = image;
    
    _sendImageView.hidden = NO;
    _imageCancelButton.hidden = NO;
}

@end
