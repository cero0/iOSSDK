//
//  iapFileRW.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/3.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface iapFileRW : NSObject<NSURLSessionDelegate>

+(instancetype)share;

//读取默认的服务器地址
-(NSString*)getURL;

//读取请求参数
-(NSMutableDictionary*)getProtocolParameters;

//获取消息字符串
-(NSString*)getMessageStr:(NSString*)key;

//获取商品ID
-(NSDictionary*)getProducts;

//获取收据
-(NSMutableArray*)getReceipts;

//把收据写入本地
-(void)wiretReceipt:(SKPaymentTransaction*)transaction;

//删除第一个收据
-(void)removeReceipt;

//获取pay_type_url
-(NSString* )getPayTypeURL;

//下载pay_type文件
-(void)downloadPayType;
@end
