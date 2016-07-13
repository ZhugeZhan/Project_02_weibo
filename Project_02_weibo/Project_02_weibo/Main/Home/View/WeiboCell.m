//
//  WeiboCell.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/27.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "WeiboCell.h"
#import "UIImageView+WebCache.h"
#import "NSDate+TimeAgo.h"
#import "WeiboWebViewController.h"
#import "WXPhotoBrowser.h"

@interface WeiboCell() <PhotoBrowerDelegate>

@end


@implementation WeiboCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    //设置头像的圆角
    _userImageView.layer.cornerRadius = 5;
    _userImageView.layer.masksToBounds = YES;
    
    //设置字体颜色
    _userNameLabel.colorName = @"More_Item_Text_color";
    _timeLabel.colorName = @"Timeline_Time_color";
    _sourceLabel.colorName = @"Timeline_Time_color";
    
    //添加监听，用于主题改变时切换字体颜色
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged) name:kThemeDidChangedNotifacationName object:nil];
    //文本颜色初始化
    [self themeChanged];
}

- (void)themeChanged {
    //改变微博中的文本颜色
    self.weiboTextLabel.textColor = [[ThemeManager shareManager] themeColorWithColorName:@"Timeline_Content_color"];
    self.reWeiboTextLabel.textColor = [[ThemeManager shareManager] themeColorWithColorName:@"Detail_Content_color"];
}

#pragma mark - 创建子视图 懒加载
//只有在需要使用到属性对象时才加载
- (UILabel *)weiboTextLabel {
    if (_weiboTextLabel == nil) {
        
        _weiboTextLabel = [[WXLabel alloc] init];
        _weiboTextLabel.font = kWeiboTextLabelFont;
        _weiboTextLabel.numberOfLines = 0;
        //修改行间距
        _weiboTextLabel.linespace = kWeiboTextLinspace;
        //设定代理 用于设置正则表达式字符串，字体颜色
        _weiboTextLabel.wxLabelDelegate = self;
        
        [self.contentView addSubview:_weiboTextLabel];
    }
    
    return _weiboTextLabel;
}

- (UILabel *)reWeiboTextLabel {
    if (_reWeiboTextLabel == nil) {
        _reWeiboTextLabel = [[WXLabel alloc] init];
        _reWeiboTextLabel.font = kReWeiboTextLabelFont;
        _reWeiboTextLabel.numberOfLines = 0;
        //修改行间距
        _reWeiboTextLabel.linespace = kReWeiboTextLinspace;
        //设定代理 用于设置正则表达式字符串，字体颜色
        _reWeiboTextLabel.wxLabelDelegate = self;
        
        [self.contentView addSubview:_reWeiboTextLabel];
    }
    
    return _reWeiboTextLabel;
}

- (NSArray *)imagesArray {
    if (_imagesArray == nil && _imagesArray.count != 9) {
        
        NSMutableArray *mArray = [NSMutableArray array];
        for (int i = 0; i < 9; i++) {
            UIImageView *imageView = [[UIImageView alloc] init];
            
            [self.contentView addSubview:imageView];
            [mArray addObject:imageView];
            
            //添加点击手势，在点击时，显示图片浏览模块
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tap];
            
            //用于区别ImageView
            imageView.tag = i;
        }
        
        _imagesArray = [mArray copy];
    }
    
    return _imagesArray;
}

- (ThemeImageView *)reWeiboBGImageView {
    if (_reWeiboBGImageView == nil) {
        _reWeiboBGImageView = [[ThemeImageView alloc] init];
        _reWeiboBGImageView.imageName = @"timeline_rt_border_9.png";
        _reWeiboBGImageView.leftCapWidth = 20;
        _reWeiboBGImageView.topCapHeight = 20;
        [self.contentView insertSubview:_reWeiboBGImageView atIndex:0];
    }
    
    return _reWeiboBGImageView;
}


#pragma mark - cell数据填充
- (void)setWeiboModel:(Weibo *)weiboModel {
    if (_weiboModel != weiboModel) {
        _weiboModel = weiboModel;
        
        //1、处理-------------微博头像、昵称
        NSURL *userImageURL = [NSURL URLWithString:_weiboModel.user.profile_image_url];
        [_userImageView sd_setImageWithURL:userImageURL];
        _userNameLabel.text = _weiboModel.user.screen_name;
        
        
        //2、处理-------------发微博时间
        //NSDateFormatter 时间格式化对象 用于将NSDate对象和相对应的时间字符串之间进行互相转化
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        //设定格式
        [dateFormatter setDateFormat:@"E M d HH:mm:ss Z yyyy"];
        
        //当前手机系统语言为中文时，新浪提供的为英文，因此在时间转换时将转换的本地化环境设置为英文
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        //通过格式化对象  字符串->NSDate
        NSDate *date = [dateFormatter dateFromString:_weiboModel.created_at];
        
        //设置当前时间字符串
        _timeLabel.text = [date timeAgo];
        
        //3、处理-------------微博来源
        NSString *source = _weiboModel.source;
        
        if (source.length <= 0) {
            _sourceLabel.text = nil;
            
        } else {
            
            NSInteger start = [source rangeOfString:@">"].location;
            NSInteger end = [source rangeOfString:@"<" options:NSBackwardsSearch].location;
            
            //提取字符串
            NSString *str = [source substringWithRange:NSMakeRange(start + 1, end - start - 1)];
            _sourceLabel.text = [NSString stringWithFormat:@"来自%@", str];
        }
        
        
        
        //当设置新的weibo对象时，需要来计算布局
        WeiboCellLayout *layout = [WeiboCellLayout weiboCellLayoutWithWeiboModel:_weiboModel];
 
        //4、处理-------------微博内容
        self.weiboTextLabel.text = _weiboModel.text;
        self.reWeiboTextLabel.text = _weiboModel.retweeted_status.text;

        //填充图片数据
        NSArray *imageUrlArray;
        if (_weiboModel.bmiddle_pic) {
            //填充当前微博中的图片
            imageUrlArray = [_weiboModel.pic_urls copy];
        } else if (_weiboModel.retweeted_status.bmiddle_pic) {
            //填充转发微博中的图片
            imageUrlArray = [_weiboModel.retweeted_status.pic_urls copy];
        } else {
            //没有图片
            imageUrlArray = nil;
        }
        
        //5、处理-------------微博布局
        self.weiboTextLabel.frame = layout.weiboTextFrame;
        self.reWeiboTextLabel.frame = layout.reWeiboTextFrame;
        self.reWeiboBGImageView.frame = layout.reWeiboBGImageViewFrame;

        //九个视图的布局设置
        for (int i = 0; i < 9; i++) {
            //取出frmae
            CGRect frame = [layout.imagesFrameArray[i] CGRectValue];
            //取出imageView
            UIImageView *imageView = self.imagesArray[i];
            
            //只有在图片数量大于当前编号时才来填充数据
            if (i < imageUrlArray.count) {
                //获取图片的网络地址
                NSDictionary *dic = imageUrlArray[i];
                NSString *urlStrng = dic[@"thumbnail_pic"];
                
                [imageView sd_setImageWithURL:[NSURL URLWithString:urlStrng]];
            }
            
            imageView.frame = frame;
        }
        
    }
}

#pragma mark - WXLabelDelegate
//检索文本的正则表达式的字符串
- (NSString *)contentsOfRegexStringWithWXLabel:(WXLabel *)wxLabel {
    
    return @"(@[\\w-]{2,30}[\\s:])|(#[^#]+#)|(http(s)?://([A-Za-z0-9._-]+(/)?)*)";
}
//设置当前链接文本的颜色
- (UIColor *)linkColorWithWXLabel:(WXLabel *)wxLabel {
    
    return [[ThemeManager shareManager] themeColorWithColorName:@"Link_color"];
}
//设置当前文本手指经过的颜色
- (UIColor *)passColorWithWXLabel:(WXLabel *)wxLabel {
    
    return [UIColor redColor];
}
//手指离开当前超链接文本响应的协议方法
- (void)toucheEndWXLabel:(WXLabel *)wxLabel withContext:(NSString *)context {
    
    //使用正则表达式来判断所点击的是不是链接
    NSString *regex = @"http(s)?://([a-zA-Z0-9._-]+(/)?)*";
    
    //判断所点击的context 是否符合超链接的正则表达式
    if ([context isMatchedByRegex:regex]) {
        //创建网页界面
        WeiboWebViewController *webVC = [[WeiboWebViewController alloc] initWithURL:[NSURL URLWithString:context]];
        [[self navigationController] pushViewController:webVC animated:YES];
        
    } else if ([context isMatchedByRegex:@"@[\\w-]{2,30}[\\s:]"]) {
        NSLog(@"用户");
    } else if ([context isMatchedByRegex:@"#[^#]+#"]) {
        NSLog(@"话题");
    }
    
}

#pragma mark - 使用响应者链获取导航控制器
- (UINavigationController *)navigationController {
    
    UIResponder *nextResponder = self.nextResponder;
    
    while (nextResponder) {
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)nextResponder;
        }
        nextResponder = nextResponder.nextResponder;
    }
    
    return nil;
}


#pragma mark - 大图浏览功能
- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    //显示大图浏览
    [WXPhotoBrowser showImageInView:self.window    //浏览器所显示的视图
                   selectImageIndex:tap.view.tag   //所选中的图片是第几张图
                           delegate:self];
}

#pragma mark - PhotoBrowerDelegate
//需要显示的图片个数
- (NSUInteger)numberOfPhotosInPhotoBrowser:(WXPhotoBrowser *)photoBrowser {
    //有转发微博，并且转发微博带有图片
    if (_weiboModel.retweeted_status && _weiboModel.retweeted_status.pic_urls) {
        return _weiboModel.retweeted_status.pic_urls.count;
        
    } else if (_weiboModel.pic_urls) {
        //在当前微博中有图片 没有转发微博
        return _weiboModel.pic_urls.count;
    }
    
    return 0;
}

//返回需要显示的图片对应的Photo实例,通过Photo类指定大图的URL,以及原始的图片视图
- (WXPhoto *)photoBrowser:(WXPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    WXPhoto *photo = [[WXPhoto alloc] init];
    
    //获取URL
    NSString *imageURLString;
    
    //有转发微博，并且转发微博带有图片
    if (_weiboModel.retweeted_status && _weiboModel.retweeted_status.pic_urls) {
        imageURLString = _weiboModel.retweeted_status.pic_urls[index][@"thumbnail_pic"];
        
    } else if (_weiboModel.pic_urls) {
        //在当前微博中有图片 没有转发微博
        imageURLString = _weiboModel.pic_urls[index][@"thumbnail_pic"];
    }
    
    //将缩略图的URL地址 转化为大图地址 http://ww3.sinaimg.cn/thumbnail/6a89fe23jw1f56d7x1byuj20f30gln0q.jpg
    imageURLString = [imageURLString stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
    
    //设定大图的URL
    photo.url = [NSURL URLWithString:imageURLString];
    
    //原始的图片视图
    photo.srcImageView = self.imagesArray[index];
    
    return photo;
}


@end
