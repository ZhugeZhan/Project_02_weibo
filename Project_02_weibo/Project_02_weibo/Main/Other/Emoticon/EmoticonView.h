//
//  EmoticonView.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/10.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FaceBlock)(NSString *);



@interface EmoticonView : UIView

@property (nonatomic, copy) FaceBlock block;

- (void)addFaceBlcok:(FaceBlock)block;

- (instancetype)initWithFrame:(CGRect)frame emoticons:(NSArray *)emoticons;

@end
