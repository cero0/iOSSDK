//
//  localNotification.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/2.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface localNotification : NSObject

+(instancetype)share;

//推送开始（用于添加本地通知）
+(void)start;

/**
 *  lua -> oc 设置推送开关(fate老接口)
 */
+(void)setPush:(NSDictionary*)dic;

@end
