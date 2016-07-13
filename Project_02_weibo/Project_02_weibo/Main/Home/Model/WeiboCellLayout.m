//
//  WeiboCellLayout.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/28.
//  Copyright © 2016年 ZGZ. All rights reserved.
//


#import "WeiboCellLayout.h"
#import "WXLabel.h"

@implementation WeiboCellLayout


+ (instancetype)weiboCellLayoutWithWeiboModel:(Weibo *)weiboModel {
    
    WeiboCellLayout *layout = [[WeiboCellLayout alloc] init];
    
    layout.weiboModel = weiboModel;

    return layout;
}


- (NSMutableArray *)imagesFrameArray {
    if (_imagesFrameArray == nil) {
        _imagesFrameArray = [NSMutableArray array];
    }
    
    return _imagesFrameArray;
}


//当设置新的weibo对象时，需要来计算布局
- (void)setWeiboModel:(Weibo *)weiboModel {
    
    if (_weiboModel == weiboModel) {
        
        return;
    }
    
    _weiboModel = weiboModel;
    
    //计算每一个视图的位置和大小
    _cellHeight = kTopViewHeight;
    
    //计算微博正文高度
//    CGSize size = CGSizeMake(kScreenWidth - 2 * kSpaceWidth, 10000);
//    NSDictionary *attributes = @{NSFontAttributeName : kWeiboTextLabelFont};
//    CGRect rect = [_weiboModel.text boundingRectWithSize:size
//                                                 options:NSStringDrawingUsesLineFragmentOrigin
//                                              attributes:attributes
//                                                 context:nil];
    
    //调用WXLabel的方法 计算文本的高度
    CGFloat weiboTextHeight = [WXLabel getTextHeight:kWeiboTextLabelFont.pointSize width:kScreenWidth - 2 * kSpaceWidth text:_weiboModel.text linespace:kWeiboTextLinspace];
    
    //计算正文frame
    _weiboTextFrame = CGRectMake(kSpaceWidth, kTopViewHeight, kScreenWidth - 2 * kSpaceWidth, weiboTextHeight);
    
    //将正文的高度 累加到总高度上
    _cellHeight = _cellHeight + _weiboTextFrame.size.height + kSpaceWidth;
    
    
    //判断是否有转发微博
    if (_weiboModel.retweeted_status) {
        
        
        //设置转发微博内容和背景的frame

        //调用WXLabel的方法 计算文本的高度
        CGFloat reWeiboTextHeight = [WXLabel getTextHeight:kReWeiboTextLabelFont.pointSize width:kScreenWidth - 2 * (kReWeiboSpaceWdith + kSpaceWidth) text:_weiboModel.retweeted_status.text linespace:kReWeiboTextLinspace];
        
        //内容
        _reWeiboTextFrame = CGRectMake(kSpaceWidth + kReWeiboSpaceWdith, CGRectGetMaxY(_weiboTextFrame) + kSpaceWidth + kReWeiboSpaceWdith, kScreenWidth - 2 * (kReWeiboSpaceWdith + kSpaceWidth), reWeiboTextHeight);
        
        //背景
        _reWeiboBGImageViewFrame = CGRectMake(kSpaceWidth, CGRectGetMaxY(_weiboTextFrame) + kSpaceWidth, kScreenWidth - 2 * kSpaceWidth, 2 * kReWeiboSpaceWdith + reWeiboTextHeight);
        
        _cellHeight = _cellHeight + _reWeiboBGImageViewFrame.size.height + kSpaceWidth;
        
        
        //如果转发微博中有图片
        if (_weiboModel.retweeted_status.bmiddle_pic) {
            
            CGFloat imgsHight = [self weiboMultiImagesFrame:_reWeiboTextFrame picUrls:_weiboModel.retweeted_status.pic_urls];
            
            _reWeiboBGImageViewFrame.size.height += imgsHight + kReWeiboSpaceWdith;
            _cellHeight += imgsHight + kReWeiboSpaceWdith;
            
            } else {
            for (NSInteger i = 0; i < 9; i++) {
                [self.imagesFrameArray addObject:[NSValue valueWithCGRect:CGRectZero]];
            }
        }
        

        
    } else if (_weiboModel.bmiddle_pic) { //判断正文是否有图片
        
        _reWeiboTextFrame = CGRectZero;
        _reWeiboBGImageViewFrame = CGRectZero;
        
        CGFloat imgsHight = [self weiboMultiImagesFrame:_weiboTextFrame picUrls:_weiboModel.pic_urls];
        
        _cellHeight += imgsHight;
        
    } else {
        
        _reWeiboTextFrame = CGRectZero;
        _reWeiboBGImageViewFrame = CGRectZero;
        for (NSInteger i = 0; i < 9; i++) {
            [self.imagesFrameArray addObject:[NSValue valueWithCGRect:CGRectZero]];
        }
    }
    
}


//确定多图的Frame 和 高度
//imgRefFrame:上面一个布局好的对象的Frame值
- (CGFloat)weiboMultiImagesFrame:(CGRect)imgRefFrame picUrls:(NSArray *)urls {
    
    //1.确定第一张图片的X,Y
    CGFloat imgX = CGRectGetMinX(imgRefFrame);
    CGFloat imgY = CGRectGetMaxY(imgRefFrame) + kSpaceWidth;
    
    //2.确定图片的宽高
    CGFloat imgSize = (CGRectGetWidth(imgRefFrame) - 2 * kImageSpeace) / kImagesCountPerLine;
    
    //3.计算多个图片的frame
    
    NSInteger row = 0;     //行数
    NSInteger column = 0;  //列数
    
    for (NSInteger i = 0; i < 9; i++) {
        
        
        if (i >= urls.count) {
            
            [self.imagesFrameArray addObject:[NSValue valueWithCGRect:CGRectZero]];
            
        } else {
            
            //当前图的X坐标：第一张图的x坐标 + 列数 *（图片宽度+空隙)
            //当前图的Y坐标：第一张图的Y坐标 + 行数 *（图片高度+空隙）
        
            row = i / kImagesCountPerLine;
            column = i % kImagesCountPerLine;
        
            CGRect imgFrame = CGRectMake(imgX + column * (imgSize + kImageSpeace), imgY + row *(imgSize + kImageSpeace), imgSize, imgSize);
        
            //4.加入到数组中
            [self.imagesFrameArray addObject:[NSValue valueWithCGRect:imgFrame]];
        }
    }
    
    
    
    //5.根据图片的个数来计算单元格的高度
    //和单元格高度有关的项：
    //（1）图片有几行：0-3
    NSInteger line = (urls.count + kImagesCountPerLine - 1) / kImagesCountPerLine;
    //（2）图片间有几个空隙：0-2
    NSInteger imgGap = MAX(line - 1, 0);
    //（3）图片与微博正文之间的空隙：0-1
    NSInteger imgTextGap = MIN(1, MAX(0, line));
    
    CGFloat imgsHeight = line * imgSize + imgGap * kImageSpeace + imgTextGap * kSpaceWidth;
    
    return imgsHeight;
}


@end
