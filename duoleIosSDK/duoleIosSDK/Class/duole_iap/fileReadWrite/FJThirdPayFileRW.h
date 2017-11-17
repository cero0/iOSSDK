//
//  FJThirdPayFileRW.h
//  duoleIosSDK
//
//  Created by duole on 17/2/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class FJThirdPaySendReceipt;
@class FJThirdPay;
@interface FJThirdPayFileRW : NSObject<NSURLSessionDelegate>

+(instancetype)share;

-(NSDictionary *)getProtocol;

//获取风际的订单号地址
-(NSString*)getOrderIdPath;

//读取默认的服务器地址
-(NSString*)getURL;

//读取请求参数
-(NSMutableDictionary*)getProtocolParameters;

//获取消息字符串
-(NSString*)getMessageStr:(NSString*)key;

//获取商品ID
-(NSDictionary*)getProducts;

//获取风际的订单id保存数组
-(NSMutableArray*)getTransId;

//获取收据
-(NSMutableArray*)getReceipts;

//把收据写入本地
-(void)wiretReceipt:(SKPaymentTransaction*)transaction;

//删除第一个收据
-(void)removeReceipt;
@end
