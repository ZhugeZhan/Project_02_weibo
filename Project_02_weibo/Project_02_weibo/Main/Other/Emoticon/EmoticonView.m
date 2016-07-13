//
//  EmoticonView.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/10.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "EmoticonView.h"
#import "Emoticon.h"

#define kEmoticonWidth (kScreenWidth / 8)  //每一个表情的高度

@interface EmoticonView ()
{
    NSArray *_emoticons;    //储存表情 1-32个
}
@end


@implementation EmoticonView


- (instancetype)initWithFrame:(CGRect)frame emoticons:(NSArray *)emoticons {
    self = [super initWithFrame:frame];
    if (self) {
        _emoticons = [emoticons copy];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
    //i 第几行   j 第几列
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 8; j++) {
            
            //通过行列 来计算每一个表情图片的位置
            CGRect rect = CGRectMake(j * kEmoticonWidth, i * kEmoticonWidth, kEmoticonWidth, kEmoticonWidth);
            //绘制图片
            if (i * 8 + j >= _emoticons.count) {
                //超出了表情总数
                return;
            }
            Emoticon *emoticon = _emoticons[i * 8 + j];
            //获取图片
            UIImage *image = [UIImage imageNamed:emoticon.png];
            //绘制
            [image drawInRect:rect];
        }
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //获取手指触摸的位置
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    //计算x,y的索引值
    NSInteger xIndex = point.x / kEmoticonWidth;
    NSInteger yindex = point.y / kEmoticonWidth;
    NSInteger index = yindex * 8 + xIndex;
    
    if (index >= _emoticons.count) {
        return;
    }
    //根据计算出的索引值获取表情字典
    Emoticon *emoticon = _emoticons[index];
    
    if (_block) {
        _block(emoticon.chs);
    }
}

- (void)addFaceBlcok:(FaceBlock)block {
    if (_block != block) {
        _block = [block copy];
    }
}

@end
