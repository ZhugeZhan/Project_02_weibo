//
//  EmoticonInputView.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/10.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmoticonView.h"

#define kScrollPageNumber @"kScrollPageNumber"

#define kEmoticonWidth (kScreenWidth / 8)  //每一个表情的高度
#define kEmoticonScrollViewHeight (kEmoticonWidth * 4)  //滑动视图高度
#define kPageControlHeight 20       //页码控制器高度
#define kEmoticonInputViewHeight (kEmoticonScrollViewHeight + kPageControlHeight)   //总高度


@interface EmoticonInputView : UIView

@property (nonatomic, copy) EmoticonView *emoticonView;   //绘制出的表情界面
@property (nonatomic, copy) NSMutableArray *emViewArray;  //保存每一页的表情界面

@property (nonatomic, assign) NSInteger pageCount; //总页数
@property (nonatomic, assign) NSInteger pageNumber; //当前页码

@end
