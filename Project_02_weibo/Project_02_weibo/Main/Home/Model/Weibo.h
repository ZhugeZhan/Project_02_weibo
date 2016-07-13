//
//  Weibo.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/27.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Weibo : NSObject

@property(nonatomic,copy)NSString *created_at;       //微博创建时间
@property(nonatomic,copy)NSString  *idstr;           //微博ID
@property(nonatomic,copy)NSString  *text;              //微博的内容
@property(nonatomic,copy)NSString  *source;              //微博来源
@property(nonatomic,retain)NSNumber     *favorited;         //是否已收藏
@property(nonatomic,copy)NSString       *thumbnail_pic;     //缩略图片地址
@property(nonatomic,copy)NSString       *bmiddle_pic;     //中等尺寸图片地址
@property(nonatomic,copy)NSString       *original_pic;     //原始图片地址
@property(nonatomic,retain)NSDictionary *geo;               //地理信息字段
@property(nonatomic,retain)NSNumber     *reposts_count;      //转发数
@property(nonatomic,retain)NSNumber     *comments_count;      //评论数
@property(nonatomic,retain)NSNumber     *attitudes_count;   //点赞数
@property (nonatomic,strong)User *user; //用户  微博的发送者
@property (nonatomic,strong)Weibo *retweeted_status; //转发的微博

@property(nonatomic, strong) NSArray *pic_urls;     //多图URL数组

@end
