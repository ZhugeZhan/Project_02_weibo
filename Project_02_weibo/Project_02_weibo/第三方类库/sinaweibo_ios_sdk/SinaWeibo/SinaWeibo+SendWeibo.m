//
//  SinaWeibo+SendWeibo.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/7/9.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "SinaWeibo+SendWeibo.h"
#import "AFNetworking.h"

#define UpdateURL @"https://api.weibo.com/2/statuses/update.json"       //发送纯文本
#define UploadURL @"https://api.weibo.com/2/statuses/upload.json"       //带图片微博


@implementation SinaWeibo (SendWeibo)

- (void)sendWeiboText:(NSString *)text image:(UIImage *)image params:(NSDictionary *)params success:(SendWeiboSuccessBlock)sBlock fail:(SendWeiboFailBlock)fBlock {
    
    //对传入的请求参数，再进行拼接
    NSMutableDictionary *mDic = [params mutableCopy];
    [mDic setObject:self.accessToken forKey:@"access_token"];  //accessToken
    [mDic setObject:text forKey:@"status"];  //正文
    

    if (image) {  //带有图片微博发送
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        [manager POST:UploadURL
           parameters:mDic
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
    //将图片转换为NSData
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    //拼接图片数据
    [formData appendPartWithFileData:imageData name:@"pic" fileName:@"image.jpg" mimeType:@"image/jpeg"];
    
}
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if (sBlock) {
                      sBlock(responseObject);
                  }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (fBlock) {
                      fBlock(error);
                  }
              }];
        
    } else {  //不带图片的微博发送
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        //发送POST请求
        [manager POST:UpdateURL
           parameters:mDic
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if (sBlock) {
                      sBlock(responseObject);
                  }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (fBlock) {
                      fBlock(error);
                  }
              }];
    }
 
    
}

@end
