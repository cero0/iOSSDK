//
//  FJThirdPayFileRW.m
//  duoleIosSDK
//
//  Created by duole on 17/2/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FJThirdPayFileRW.h"
#import "Macro.h"
#import "duole_log.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation FJThirdPayFileRW{
    NSMutableDictionary* plistDataDIC;
}

+(instancetype)share{
    return [[FJThirdPayFileRW alloc] init];
}


-(instancetype)init{
    self = [super init];
    if (self) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"duole_iap" ofType:@"plist"];
        plistDataDIC = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] objectForKey:@"FJThirdPay"];
    }
    return self;
}
//路径
-(NSString*)getPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:Duole_IOSSDK_iapReceipt_PATH];
    
    return plistPath;
}
-(NSString*)getOrderIdPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:Duole_IOSSDK_orderId_PATH];
    
    return plistPath;
}

//---------------读------------------

-(NSDictionary *)getProtocol{
    return [plistDataDIC objectForKey:@"Protocol"];
}

//读取服务器地址
-(NSString*)getURL{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"URL"];
}
//获取正式的服务器地址
-(NSString* )getPayTypeURL{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"URL"];
}

//读取请求参数
-(NSMutableDictionary*)getProtocolParameters{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"main_dic"];
}
//获取消息字符串
-(NSString*)getMessageStr:(NSString*)key{
    return [[plistDataDIC objectForKey:@"message"] objectForKey:key];
}
//获取商品ID
-(NSDictionary*)getProducts{
    return [plistDataDIC objectForKey:@"ProductList"];
}

//获取收据
-(NSMutableArray*)getReceipts{
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSMutableArray* LostReceipts_arr;
    if ([filemgr fileExistsAtPath: [self getPath] ] == NO){
        NSLog(@"文件不存在");
        //创建文件夹
        NSString* CatalogPath = [[self getPath] stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
        LostReceipts_arr = [[NSMutableArray alloc] init];
        [LostReceipts_arr writeToFile:[self getPath] atomically:YES];
    }else{
        LostReceipts_arr = [[NSMutableArray alloc] initWithContentsOfFile:[self getPath]];
    }
    return LostReceipts_arr;
}

//获取风际的订单id保存数组
-(NSMutableArray*)getTransId{
    
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    NSMutableArray* LostTransId_arr;
    if ([filemgr fileExistsAtPath: [self getOrderIdPath] ] == NO){
        NSLog(@"文件不存在");
        //创建文件夹
        NSString* CatalogPath = [[self getOrderIdPath] stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
        LostTransId_arr = [[NSMutableArray alloc] init];
        [LostTransId_arr writeToFile:[self getOrderIdPath] atomically:YES];
    }else{
        LostTransId_arr = [[NSMutableArray alloc] initWithContentsOfFile:[self getOrderIdPath]];
    }
    return LostTransId_arr;
}

//---------------写------------------
//把收据写入本地
-(void)wiretReceipt:(SKPaymentTransaction*)transaction{

    NSMutableArray* arr = [self getReceipts];
    
    NSString* protocolInfo = transaction.payment.applicationUsername;
    NSString* receipt = [transaction.transactionReceipt base64Encoding];
//    NSLog(@"transactionReceipt===%@",receipt);
    
    //获取返回的风际订单id，添加到收据中后删除
    NSMutableArray *trandIdArr = [self getTransId];
    NSString *transId = [trandIdArr objectAtIndex:0];
    [trandIdArr removeObjectAtIndex:0];
    [trandIdArr writeToFile:[self getOrderIdPath] atomically:YES];
    
    NSDictionary* dic = @{@"receipt":receipt,@"protocolInfo":protocolInfo,@"transId":transId};

    
    [arr addObject:dic];
    
    
    [arr writeToFile:[self getPath] atomically:YES];
    [duole_log WriteLog:@"保存收据"];
    
}




//删除收据
-(void)removeReceipt{
    
    NSMutableArray* arr = [self getReceipts];
    if (arr.count == 0) return;
    
    [arr removeObjectAtIndex:0];
    [arr writeToFile:[self getPath] atomically:YES];
    
    [duole_log WriteLog:@"删除收据"];

}

@end
