//
//  Macro.h
//  bilibili fake
//
//  Created by cezr on 16/6/23.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#ifndef Macro_h
#define Macro_h
#import <AdSupport/ASIdentifierManager.h>

#pragma mark-- PATH

#define Duole_IOSSDK_Catalog @"duoleIosSdk"//用户信息文件夹名字
#define Duole_IOSSDK_userinfo_PATH  @"duoleIosSdk/userinfo.plist" //用户信息存取地址
#define Duole_IOSSDK_FJuserinfo_PATH  @"duoleIosSdk/FJuserinfo.plist" //风际用户信息存取地址
#define Duole_IOSSDK_localNotification_PATH  @"duoleIosSdk/localNotification.plist" //本地推送存取地址
#define Duole_IOSSDK_iapReceipt_PATH @"duoleIosSdk/iapReceipt.plist"//付款收据临时存放地址
#define Duole_IOSSDK_orderId_PATH @"duoleIosSdk/orderId.plist"//风际订单号临时存放地址
#define Duole_IOSSDK_log_PATH @"duoleIosSdk/Log.plist"//日志存放地址


#pragma mark -  UI


#define SSize   [UIScreen mainScreen].bounds.size


#pragma mark - Color

#define ColorRGBA(r, g, b, a)               [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define ColorRGB(r, g, b)                   ColorRGBA((r), (g), (b), 1.0)
#define ColorWhiteAlpha(white, _alpha)      [UIColor colorWithWhite:(white)/255.0 alpha:_alpha]
#define ColorWhite(white)                   ColorWhiteAlpha(white, 1.0)



#define Font(size) [UIFont systemFontOfSize:size]


#define ImageWithName(name)  [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[name stringByAppendingString:@".png"]]]






#pragma mark - Deviece

#define DevieceUUID                         [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]
#endif /* Macro_h */
