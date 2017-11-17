//
//  FJThirdPaySendReceipt.m
//  duoleIosSDK
//
//  Created by duole on 17/2/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FJThirdPaySendReceipt.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "FJThirdPayFileRW.h"
#import "duole_log.h"
#import "Macro.h"


static FJThirdPaySendReceipt *FJThirdPaySendReceipt_share;
@implementation FJThirdPaySendReceipt{
//    NSString *trans_id;//风际服务器返回的订单id
}

+(instancetype)share{
    if (FJThirdPaySendReceipt_share == NULL) {
        FJThirdPaySendReceipt_share = [[FJThirdPaySendReceipt alloc] init];
    }
    return FJThirdPaySendReceipt_share;
}
-(instancetype)init{
    self =[super init];
    if (self) {
//        trans_id = [[NSString alloc] init];
    }
    return self;
}



-(void)start:(void(^)(NSDictionary* dic))successBlock
{
    FJThirdPayFileRW* fileRw = [[FJThirdPayFileRW alloc] init];
    NSDictionary *protocolDic = [fileRw getProtocol];
    
    NSMutableArray* Receipts = [fileRw getReceipts];
    if (Receipts.count == 0) return;
    
    
    
    //拆分数据
    NSDictionary* Dic = Receipts[0];
    //Ios:支付验证票据
    NSString* receipt = [Dic objectForKey:@"receipt"];
    //订单号
    NSString* orderId = [Dic objectForKey:@"transId"];
    //NSLog(@"%@",protocolInfo);

    if (orderId==nil) {
        return;
    }
    
    //苹果支付:ios 谷歌官方支付 :google 第三方支付:other
    NSString *pay_type = [protocolDic objectForKey:@"payType"];
    //1 测试沙盒环境 2 正式环境
    int environment = [[protocolDic objectForKey:@"environment"] intValue];
    //appID
    NSString *appid = [protocolDic objectForKey:@"appid"];
    //秘钥public_key
    NSString *key = [protocolDic objectForKey:@"key"];
    
    
    NSString* sign = [self hmacSha1:key data:[NSString stringWithFormat:@"pay/payment&appid=%@&environment=%i&order=%@&pay_type=%@&receipt=%@&%@",
                                 appid,environment,orderId,pay_type,receipt,key]];
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&environment=%i&order=%@&pay_type=%@&receipt=%@&sign=%@",
                         appid,environment,orderId,pay_type,receipt,sign];
    NSString *URL_str = [[[FJThirdPayFileRW share] getURL] stringByAppendingString:@"pay/payment"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 30.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    NSLog(@"上传票据成功");
                    [duole_log WriteLog:@"上传票据成功"];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    NSLog(@"上传票据失败");
                    [duole_log WriteLog:[NSString stringWithFormat:@"上传票据失败,错误说明：%@",msg]];
                    return;
                }
            }
        }
    }] resume];
    
}

-(void )getOrderID:(NSDictionary*)dic
{
    FJThirdPayFileRW* fileRw = [[FJThirdPayFileRW alloc] init];
    NSLog(@"dic==%@",dic);
    //开始发送
    NSLog(@"开始发送数据生成订单号");
    NSString *roleName = [dic objectForKey:@"roleName"];
    
    NSString *openID = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (NSMutableDictionary *dic in userArr) {
        if ([[dic objectForKey:@"account"] isEqualToString:roleName]) {
            openID = [dic objectForKey:@"open_id"];
        }
    }
    //苹果支付:ios 谷歌官方支付 :google 第三方支付:other
    NSString *pay_type = [[fileRw getProtocol] objectForKey:@"payType"];
    //发送地址
    NSString *payURL = [fileRw getURL];
    //服务器ID
    NSString *sid = [dic objectForKey:@"serverId"];
    //账号 ID 或 open_id
    NSString *uid = openID;
    //角色 ID 或者 char_id 如果没有角色传 uid
    NSString *cid = [dic objectForKey:@"roleId"];
    //渠道 ID
    NSString *channelid = [[fileRw getProtocol] objectForKey:@"channelid"];
    //支付类型 CNY 人民币 USD 美元
    NSString *currency = @"CNY";
    //商品标示id
    NSString *productid = [dic objectForKey:@"productId"];
    //appID
    NSString *appid = [[fileRw getProtocol] objectForKey:@"appid"];
    //秘钥public_key
    NSString *key = [[fileRw getProtocol] objectForKey:@"key"];
    //支付金币
    int totalmoney = [[dic objectForKey:@"money"] intValue];
    
    NSString* sign = [self hmacSha1:key data:[NSString stringWithFormat:@"pay/get_order&appid=%@&channelid=%@&cid=%@&client_type=1&currency=%@&pay_type=%@&productid=%@&sid=%@&totalmoney=%i&%@",
                                              appid,channelid,cid,currency,pay_type,productid,sid,totalmoney,key]];
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&channelid=%@&cid=%@&client_type=1&currency=%@&pay_type=%@&productid=%@&sid=%@&sign=%@&totalmoney=%i",
                         appid,channelid,cid,currency,pay_type,productid,sid,sign,totalmoney];
    NSString *URL_str = [payURL stringByAppendingString:@"pay/get_order"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 30.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    NSLog(@"订单号获取成功");
                    [duole_log WriteLog:@"订单号获取成功"];
                    NSString *trans_id = [dic objectForKey:@"trans_id"];
                    
                    NSMutableArray *arr = [fileRw getTransId];
                    [arr insertObject:trans_id atIndex:0];
                    [arr writeToFile:[fileRw getOrderIdPath] atomically:YES];
                    [duole_log WriteLog:@"保存风际订单号"];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    NSLog(@"订单号获取失败");
                    [duole_log WriteLog:[NSString stringWithFormat:@"订单号获取失败,错误说明：%@",msg]];
                    return;
                }
            }
        }
    }] resume];
    
    
}


//合成传入交易的协议信息
+(NSString*)getProtocolInfo:(NSDictionary*)userInfo URL:(NSString*)url{
    //检测网址
    if(url.length == 0){
        NSLog(@"缺少服务器地址");
        return @"";
    }
    //检测userInfo
    FJThirdPayFileRW* fileRw = [[FJThirdPayFileRW alloc] init];
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
    return [FJThirdPaySendReceipt dictionaryToJson:Dic];
}

//hmacSha1加密
- (NSString*)hmacSha1:(NSString *)key data:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    //NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:CC_SHA1_DIGEST_LENGTH];
    NSString *hash;
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", cHMAC[i]];
    hash = output;
    
    return [hash lowercaseString];
}
//md5加密
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
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
