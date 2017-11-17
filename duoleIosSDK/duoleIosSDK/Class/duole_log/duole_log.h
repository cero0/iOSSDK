//
//  duole_log.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/3.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface duole_log : NSObject

/**
 *  写日志
 *
 *  @param log 日志内容
 */
+(void)WriteLog:(NSString*)log;


/**
 *  设置玩家信息用来判断是否发送文件
 *
 *  @param userInfo 玩家信息
 */
+(void)setUserInfo:(NSDictionary*)userInfo;



@end
