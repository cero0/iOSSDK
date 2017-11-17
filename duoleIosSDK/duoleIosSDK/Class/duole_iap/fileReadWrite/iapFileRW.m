//
//  iapFileRW.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/3.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "iapFileRW.h"
#import "Macro.h"
#import "duole_log.h"

@implementation iapFileRW{
    NSMutableDictionary* plistDataDIC;
}

+(instancetype)share{
    return [[iapFileRW alloc] init];
}


-(instancetype)init{
    self = [super init];
    if (self) {
        NSString* path = [[NSBundle mainBundle] pathForResource:@"duole_iap" ofType:@"plist"];
        plistDataDIC = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] objectForKey:@"DuoleIap"];
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
//---------------读------------------

//读取默认的服务器地址
-(NSString*)getURL{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"URL"];
}
//获取pay_type_url
-(NSString* )getPayTypeURL{
    return [[plistDataDIC objectForKey:@"Protocol"] objectForKey:@"pay_type_url"];
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

//---------------写------------------
//把收据写入本地
-(void)wiretReceipt:(SKPaymentTransaction*)transaction{
    NSMutableArray* arr = [self getReceipts];

//    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0){
//        //ios7.0之后新的收据获取方式
//        NSURL *url = [[NSBundle mainBundle] appStoreReceiptURL];
//        NSString *receipt = [[NSData dataWithContentsOfURL:url] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
////            NSString *receipt = [[NSData dataWithContentsOfURL:url] base64Encoding];
//        NSLog(@"appStoreReceiptURL===%@",receipt);
//    }else{
//        
//    }
    
    NSString* protocolInfo = transaction.payment.applicationUsername;
    NSString* receipt = [transaction.transactionReceipt base64Encoding];
    NSLog(@"transactionReceipt===%@",receipt);
    
    
    
    
    NSDictionary* dic = @{@"receipt":receipt,
                          @"protocolInfo":protocolInfo};
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

//下载pay_type文件
-(void)downloadPayType{
    NSURL *url = [NSURL URLWithString:[self getPayTypeURL]];
    // 得到session对象
    NSURLSession* session = [NSURLSession sharedSession];
    
    // 创建任务
    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        // location : 临时文件的路径（下载好的文件）
        
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
        NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
        NSLog(@"%@",response.suggestedFilename);
        // 将临时文件剪切或者复制Caches文件夹
        NSFileManager *mgr = [NSFileManager defaultManager];
        
        // AtPath : 剪切前的文件路径
        // ToPath : 剪切后的文件路径

        [mgr moveItemAtPath:location.path toPath:file error:nil];
    }];
    // 开始任务
    [downloadTask resume];
}

@end
