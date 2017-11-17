//
//  iapLogFileRW.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/5.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface logFileRW : NSObject

+(instancetype)share;

/**
 *  写日志
 *
 *  @param log 日志内容
 */
-(void)WriteLog:(NSString*)log;


/**
 *   读取日志
 */
-(NSMutableArray*)ReadLog;

@end
