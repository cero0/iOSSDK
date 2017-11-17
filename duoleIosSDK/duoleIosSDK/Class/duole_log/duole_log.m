//
//  duole_log.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/3.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "duole_log.h"
#import "logFileRW.h"
#import "sendFile.h"


@implementation duole_log
/**
 *  写日志
 *
 *  @param log 日志内容
 */
+(void)WriteLog:(NSString*)log{
    [[logFileRW share] WriteLog:log];
}


/**
 *  设置玩家信息用来判断是否发送文件
 *
 *  @param userInfo 玩家信息
 */
+(void)setUserInfo:(NSDictionary*)userInfo{
    //写日志
    NSString* str= @"";
    for (NSString* key in userInfo) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@:%@ ",key,[userInfo objectForKey:key]]];
    }
    [duole_log WriteLog:str];
    
    
    sendFile* sf = [[sendFile alloc] init];
    //请求网络上的用户信息判断条件
    [sf getWedUserInfo:^(NSDictionary *dic) {
        //判断是否上传
        BOOL bl = YES;
        for (NSString* key in dic)
        if ([[userInfo objectForKey:key] intValue] != [[dic objectForKey:key] intValue])  bl = NO;
        
        if (bl)
        [sf SendOutLog:userInfo];
    }];
}


@end