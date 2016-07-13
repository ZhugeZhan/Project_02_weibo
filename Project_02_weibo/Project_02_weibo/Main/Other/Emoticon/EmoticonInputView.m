//
//  EmoticonInputView.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/10.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "EmoticonInputView.h"
#import "YYModel.h"
#import "Emoticon.h"


@interface EmoticonInputView() <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    NSMutableArray *_emoticons;  //所有的表情
}
@end

@implementation EmoticonInputView

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        //设定frame
        self.frame = CGRectMake(0, 0, kScreenWidth, kEmoticonInputViewHeight);
        
        self.backgroundColor = [UIColor blackColor];
        
        [self loadEmoticonData];
        [self createScrollView];
        [self createPageControl];
    }
    
    return self;
}



- (void)loadEmoticonData {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"];
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    _emoticons = [NSMutableArray array];
    
    //遍历数据 创建表情对象
    for (NSDictionary *dic in array) {
        
        Emoticon *em = [Emoticon yy_modelWithDictionary:dic];
        [_emoticons addObject:em];
    }
}

- (void)createScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kEmoticonScrollViewHeight)];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsVerticalScrollIndicator = NO;  //竖直方向滑动条
    _scrollView.showsHorizontalScrollIndicator = NO;//水平反向滑动条
    _scrollView.pagingEnabled = YES;  //分页滑动
    _scrollView.bounces = NO;         //反弹效果
    _scrollView.delegate = self;  //设置代理
    [self addSubview:_scrollView];
    
    _emViewArray = [NSMutableArray array]; //创建数组
    
    //创建滑动视图的内容视图   表情显示视图
    //每32个表情分为一页
    
    //1.计算总页数
    _pageCount = _emoticons.count / 32 + 1;
    
    for (int i = 0; i < _pageCount; i++) {
        //2.分割表情数组
        NSRange range = NSMakeRange(i * 32, 32);
        //如果是最后一页 则lenght需要重新计算
        if (i == _pageCount - 1) {
            range.length = _emoticons.count - 32 * i;
        }
        NSArray *array = [_emoticons subarrayWithRange:range];
        
        //3.创建表情视图，添加到滑动视图上
        CGRect frame = CGRectMake(i * kScreenWidth, 0, kScreenWidth, kEmoticonScrollViewHeight);
        _emoticonView = [[EmoticonView alloc] initWithFrame:frame emoticons:array]; //绘制表情界面
        [_emViewArray addObject:_emoticonView];  //保存当前绘制的界面到数组
        
        [_scrollView addSubview:_emoticonView];
    }
    
    //设置滑动视图的滑动范围
    _scrollView.contentSize = CGSizeMake(kScreenWidth * _pageCount, 0);

}

- (void)createPageControl {
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, kEmoticonScrollViewHeight, kScreenWidth, kPageControlHeight)];
    [self addSubview:_pageControl];
    
    _pageControl.numberOfPages = _pageCount;
    _pageControl.currentPage = 0;
    
    //监听通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePageNumber) name:kScrollPageNumber object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)changePageNumber {
    
    if (_pageControl.currentPage == _pageNumber) {
        return;
    }
    
    _pageControl.currentPage = _pageNumber;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    // 获取当前的x偏移量
    int offsetX = targetContentOffset->x;
    
    _pageNumber = offsetX / kScreenWidth;
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kScrollPageNumber object:nil];
}

@end
