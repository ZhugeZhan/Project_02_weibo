//
//  SinaWeibo+SendWeibo.h
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/9.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "SinaWeibo.h"

typedef void(^SendWeiboSuccessBlock)(id result);
typedef void(^SendWeiboFailBlock)(NSError *error);

@interface SinaWeibo (SendWeibo)

/**
 *  发送一条微博，文字/图片/地理位置信息
 *
 *  @param text   微博正文
 *  @param image  图片，如果不发送图片，则为nil
 *  @param params 参数
 *  @param sBlock 成功
 *  @param fBlock 失败
 */
- (void)sendWeiboText:(NSString *)text
                image:(UIImage *)image
               params:(NSDictionary *)params
              success:(SendWeiboSuccessBlock)sBlock
                 fail:(SendWeiboFailBlock)fBlock;

@end
