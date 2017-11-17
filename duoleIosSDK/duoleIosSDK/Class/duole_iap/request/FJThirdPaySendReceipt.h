//
//  FJThirdPaySendReceipt.h
//  duoleIosSDK
//
//  Created by duole on 17/2/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FJThirdPaySendReceipt : NSObject

/*
 //错误 recode
const SUCCESS = 0; //成功 (ios google 需要删除本地票据) const FAIL = 1; //失败
const CLOSE = 16; //充值关闭
const READLINE_USED = 101; //票据已经使用,请删除票据 const READLINE_FAIL = 102; //票据错误,请删除票据 const GAME_SERVER_ERROR = 500; //失败
const PARAM_FAIL = 3; //请求参数错误失败
const APP_ID_ERROR = 4; //请求参数错误失败
const NO_CHANGE = 10; //数据没有更新
const CALL_BACK_GM_ERROR = 501; //回调游戏服务器失败 const LOGIN_CHECK_ERROR = 2001; //登陆认证授权失效! const OK = 200; //成功
const CPORDERID_ERROR = 1506; // 商户订单错误
const SIGN_CHECK_FAIL = 1525; //签名验证失败
const VIVO_TRAN_FAIL = 1110; //失败
const IOS_RETURN_FAIL = 1111; //ios 验证失败
*/


+(instancetype)share;



-(void)start:(void(^)(NSDictionary* dic))successBlock;


-(void )getOrderID:(NSDictionary*)dic;

//合成传入交易的协议信息
+(NSString*)getProtocolInfo:(NSDictionary*)userInfo URL:(NSString*)url;
@end
