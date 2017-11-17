//
//  sendFile.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/5.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sendFile : NSObject



/**
 *  获取网络上的用户信息，用来比对是否发送
 *
 *  @param block 成功回调（请求失败时返回nil）
 */
-(void)getWedUserInfo:(void(^)(NSDictionary* dic))block;

/**
 *  发送日志文件
 *
 *  @param userInfo 用户信息
 */
-(void)SendOutLog:(NSDictionary*)userInfo;



@end
