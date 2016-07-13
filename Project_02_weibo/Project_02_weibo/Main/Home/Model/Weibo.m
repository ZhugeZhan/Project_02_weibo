//
//  Weibo.m
//  Project_02_weibo
//
//  Created by ZhugeZhan on 16/6/27.
//  Copyright © 2016年 ZGZ. All rights reserved.
//

#import "Weibo.h"
#import "RegexKitLite.h"

@implementation Weibo

//采用YYModel框架 在Json -> Model 转化完成后 可调用方法，处理自动转换无法完成的数据
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    //微博正文内容的检索和替换  [兔子] ---> <image url = '001.png'>
    
    //1.读取plist文件
    NSArray *emoticons = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"emoticons" ofType:@"plist"]];
    
    //2.检索正文中的表情
    NSString *regex = @"\\[\\w+\\]";  //[]中括号在正则表达式中表示字符集，需要写成\\[  \\]
    NSString *weiboText = _text;      //微博正文
    NSArray *array = [weiboText componentsMatchedByRegex:regex];  //检索字符串
    
    //3.替换正文中的表情
    for (NSString *subString in array) {
        
        //使用谓词删选对象
        NSString *string = [NSString stringWithFormat:@"chs = '%@'", subString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
        NSDictionary *dicEmo = [[emoticons filteredArrayUsingPredicate:predicate] firstObject];
        
        //判断当前表情 在表情库中是否存在
        if (dicEmo == nil) {
            continue;
        }
        
        //获取表情的图片文件名
        NSString *fileName = dicEmo[@"png"];
        NSString *imageString = [NSString stringWithFormat:@"<image url = '%@'>", fileName];
        
        //将表情的字符串  替换为  <image url = '001.png'>
        weiboText = [weiboText stringByReplacingOccurrencesOfString:subString withString:imageString];
        
    }
    
    _text = weiboText;

    return YES;
}

@end
