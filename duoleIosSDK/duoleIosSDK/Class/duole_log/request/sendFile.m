//
//  sendFile.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/5.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "sendFile.h"
#import "logFileRW.h"

#define userinfo_url @"http://120.132.95.238/ios/up_players.json"//用户信息地址
#define sendout_url @"http://123.59.110.147/cgi-bin/fate/up_log.py"//日志发送地址


@implementation sendFile{
//    NSDictionary* _userInfo;
}


/**
 *  获取网络上的用户信息，用来比对是否发送
 *
 *  @param block 成功回调（请求失败时返回nil）
 */
-(void)getWedUserInfo:(void(^)(NSDictionary* dic))block{
    NSURL* userInfo_url = [NSURL URLWithString:userinfo_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:userInfo_url];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;//忽略本地缓存数据，直接请求服务端.
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary* userInfo = nil;
        if (error == nil) {
            userInfo =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        }
        block(userInfo);
    }] resume];
}

/**
 *  发送日志文件
 *
 *  @param userInfo 用户信息
 */
-(void)SendOutLog:(NSDictionary*)userInfo{

    //查看是否有购买列表里的掉单
//    [duole_ios_iap resumedPay];

    // 创建请求
    
    NSURL *url = [NSURL URLWithString:sendout_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval=5.0;//设置请求超时为5秒
    
    NSString* str = [NSString stringWithFormat:@"server_id=%@&player_id=%@&log=",[userInfo objectForKey:@"server_id"],[userInfo objectForKey:@"player_id"]];
    NSMutableArray* arr = [[logFileRW share] ReadLog];
    for (int i = 0 ; i < arr.count;i++) {
        str = [str stringByAppendingString:arr[i]];
        str = [str stringByAppendingString:@"\n"];
    }
//    NSLog(@"%@",str);
    //把拼接后的字符串转换为data，设置请求体
    //                    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    request.HTTPBody=[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if(error){
            NSLog(@"日志发送失败:%@",[error localizedDescription]);
        }
        else{
            NSLog(@"日志发送成功");
            
        }
        
    }] resume];
}



@end
