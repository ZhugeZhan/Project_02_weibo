//
//  WeiboCellLayout.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/28.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

/**
 *  布局对象通过Weibo对象进行创建，并且能够自动的计算出每一个需要布局的UI控件的位置和大小。
 *  方便ViewController来获取整个单元格的大小
 */

#import <UIKit/UIKit.h>

//布局条件设置
#define kWeiboTextLabelFont     [UIFont systemFontOfSize:18]    //微博正文字体大小
#define kReWeiboTextLabelFont   [UIFont systemFontOfSize:16]    //转发微博的正文字体大小
#define kTopViewHeight          70  //顶部视图高度
#define kSpaceWidth             10  //上下左右默认的空隙宽度
#define kReWeiboSpaceWdith      10  //转发微博背景和正文之间的空隙宽度
#define kImageSpeace            5   //图片之间间隙
#define kImageViewWidth         100 //默认图片大小宽度
#define kImagesCountPerLine     3   //多图排列，每行图片个数
#define kWeiboTextLinspace      5   //微博正文的行间距
#define kReWeiboTextLinspace    2   //转发微博正文的行间距

@interface WeiboCellLayout : NSObject

@property (nonatomic, strong) Weibo *weiboModel;

//类方法创建对象 在创建对象的方法中初始化
+ (instancetype)weiboCellLayoutWithWeiboModel:(Weibo *)weiboModel;


//布局结果
@property (nonatomic, assign, readonly) CGRect weiboTextFrame;            //正文Frame
@property (nonatomic, assign, readonly) CGRect reWeiboTextFrame;          //转发微博正文Frame
@property (nonatomic, strong) NSMutableArray *imagesFrameArray;           //多图排列
@property (nonatomic, assign, readonly) CGRect reWeiboBGImageViewFrame;   //转发微博背景图片Frame


@property (nonatomic, assign, readonly) CGFloat cellHeight;   //单元格总高度 


@end





