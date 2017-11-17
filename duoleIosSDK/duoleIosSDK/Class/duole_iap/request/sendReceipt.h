//
//  sendReceipt.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/5.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sendReceipt : NSObject
//开始发送订单
+(void)start:(void(^)(NSDictionary* dic))successBlock;

//合成传入交易的协议信息
+(NSString*)getProtocolInfo:(NSDictionary*)userInfo URL:(NSString*)url;


@end
