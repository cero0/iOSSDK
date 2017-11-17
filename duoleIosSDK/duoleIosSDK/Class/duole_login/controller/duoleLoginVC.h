//
//  duoleLoginVC2.h
//  duole_ios_sdk
//
//  Created by cxh on 16/7/25.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, LoginMode) {
    FJFATELogin,//风际渠道包登录
    FATELogin,//fate登陆
    XJLLogin,//小精灵登陆
    CanTingLogin//餐厅登陆
};

@interface duoleLoginVC : UIViewController

+(void)showWithMode:(LoginMode)mode success:(void(^)(NSDictionary* dic))block;

@end
