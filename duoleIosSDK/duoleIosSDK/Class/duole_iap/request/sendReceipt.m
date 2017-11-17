//
//  sendReceipt.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/5.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "sendReceipt.h"
#import "iapFileRW.h"
#import <CommonCrypto/CommonDigest.h>
#import "duole_log.h"
#import "duole_iap.h"




@implementation sendReceipt
//开始发送订单
+(void)start:(void(^)(NSDictionary* dic))successBlock{
    iapFileRW* fileRw = [[iapFileRW alloc] init];
    NSMutableArray* Receipts = [fileRw getReceipts];
    if (Receipts.count == 0) return;
    
    //开始发送收据
    NSLog(@"开始发送收据");
    //拆分数据
    NSDictionary* Dic = Receipts[0];
    NSString* receipt = [Dic objectForKey:@"receipt"];
    NSDictionary* protocolInfo = [sendReceipt dictionaryWithJsonString:[Dic objectForKey:@"protocolInfo"]];
    //NSLog(@"%@",protocolInfo);
    
    //组合参数
    NSString* urlStr = [protocolInfo objectForKey:@"URL"];
    NSString* argsStr = @"";
    
    NSDictionary* Parameters = [fileRw getProtocolParameters];
    for (NSString* key in Parameters) {
        argsStr = [argsStr stringByAppendingString:key];
        argsStr = [argsStr stringByAppendingString:@"="];
        
        NSDictionary* dic = [Parameters objectForKey:key];
        switch ([[dic objectForKey:@"type"] intValue]) {
            case 1:
                //普通参数
                argsStr = [argsStr stringByAppendingString:[protocolInfo objectForKey:key]];
                break;
            case 2:
                //收据
                argsStr = [argsStr stringByAppendingString:receipt];
                break;
            case 3:
                //验证需要合成的key
                argsStr = [argsStr stringByAppendingString:[sendReceipt getSign:[dic objectForKey:@"data"] STR:receipt userInfo:protocolInfo]];
                break;
            case 4:
                argsStr = [argsStr stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"]];
                break;
            case 5:
                //静态数据
                argsStr = [argsStr stringByAppendingString:[dic objectForKey:@"data"]];
                break;
            default:
                break;
        }
        argsStr = [argsStr stringByAppendingString:@"&"];
    }
    argsStr =  [argsStr substringToIndex:argsStr.length-1];
    
    //合成请求
    NSLog(@"%@",urlStr);
    NSLog(@"%@",argsStr);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 30.0;//设置请求超时为5秒
    request.HTTPBody = [argsStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == NULL) {
            NSDictionary* dic =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error == NULL) {
                
                //start---
                int ret = [[dic objectForKey:@"ret"] intValue];
                if(ret == 0){
                    [duole_log WriteLog:@"======交易成功，充钱到账======"];
                    [[iapFileRW share] removeReceipt];//删除收据
                    if (successBlock)successBlock(protocolInfo);
                    
                }else if (ret == -2 && ret == -3){
                    //验证失败，参数错误，这两种情况可能是参数组合错误或者其他网络错误，需要重新发送。
                    [duole_log WriteLog:[NSString stringWithFormat:@"收据验证错误:%@",[dic objectForKey:@"msg"]]];
                    [[duole_iap share] showMessage:[NSString stringWithFormat:@"ERROR:%@",[dic objectForKey:@"msg"]]];
                }else{
                    //验证失败
                    [duole_log WriteLog:[NSString stringWithFormat:@"收据验证错误:%@",[dic objectForKey:@"msg"]]];
                    [[duole_iap share] showMessage:[NSString stringWithFormat:@"ERROR:%@",[dic objectForKey:@"msg"]]];
                    [[iapFileRW share] removeReceipt];//删除收据
                }
                [sendReceipt start:successBlock];
                //end---

            }else{
                NSString* str = [NSString stringWithFormat:@"服务器返回数据错误：%@", [error localizedDescription]];
                [[duole_iap share] showMessage:[NSString stringWithFormat:@"ERROR:%@",[error localizedDescription]]];

                [duole_log WriteLog:str];
                [sendReceipt start:successBlock];
            }
        }else{
            NSLog(@"++++++++%@++++++++",[error localizedDescription]);
            //请求数据失败
            [duole_log WriteLog:[NSString stringWithFormat:@"请求数据失败：%@",[error localizedDescription]]];
            [[duole_iap share] showMessage:[NSString stringWithFormat:@"ERROR:%@",[error localizedDescription]]];
        }
    }] resume];
}


//合成的类型3参数
+(NSString*)getSign:(NSArray*)arr STR:(NSString*)STR userInfo:(NSDictionary*)userInfo{
    NSString* sign = [[NSString alloc] init];
    for (int i = 0;  i < arr.count ; i++ ) {
        NSString* str = arr[i];
        if ([str isEqualToString:@"STR"]) {
            sign = [sign stringByAppendingString:STR];
        }else{
            sign = [sign stringByAppendingString:[userInfo objectForKey:str]];
        }
    }
    sign = [sendReceipt md5:sign];
    
    return sign;
}


//合成传入交易的协议信息
+(NSString*)getProtocolInfo:(NSDictionary*)userInfo URL:(NSString*)url{
    //检测网址
    if(url.length == 0){
        NSLog(@"缺少服务器地址");
        return @"";
    }
    //检测userInfo
    iapFileRW* fileRw = [[iapFileRW alloc] init];
    NSDictionary* Parameters = [fileRw getProtocolParameters];
    for (NSString* key in Parameters) {
        NSInteger type = [[[Parameters objectForKey:key] objectForKey:@"type"]integerValue];
        if (type == 1&&[userInfo objectForKey:key]==NULL){ //普通传入的 参数类型
            return @"";
        }else if (type == 3){//组合类型
            NSArray* arr = [[Parameters objectForKey:key] objectForKey:@"data"];
            for (NSString* str in arr) {
                if([str isEqualToString:@"STR"] == NO&&[userInfo objectForKey:str]==NULL)
                    return @"";
            }
        }
    }
    
    //组合参数
    NSMutableDictionary* Dic = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [Dic setObject:url forKey:@"URL"];
    return [sendReceipt dictionaryToJson:Dic];
}

+ (NSString *)md5:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}
/**
 *  JSON字符串转NSDictionary
 *
 *  @param jsonString JSON字符串
 *
 *  @return NSDictionary
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return dic;
}
/**
 *  字典转JSON字符串
 *
 *  @param dic 字典
 *
 *  @return JSON字符串
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
