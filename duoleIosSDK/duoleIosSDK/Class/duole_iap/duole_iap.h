//
//  duole_iap.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/2.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface duole_iap : NSObject

/**
 *  购买成功－》收据发送成功后的回调
 */
@property(nonatomic,copy)void(^PaySuccessBlock)(NSDictionary* dic);
/**
 *  购买失败回调
 */
@property(nonatomic,copy)void(^PayFailBlock)(NSDictionary* dic);

/**
 *  服务器地址
 */
@property(nonatomic,strong)NSString* URL;

+(instancetype)share;




/**
 *  初始化
 *
 *  @param userInfoDIC  用户信息
 */
-(void)InitUserInfo:(NSDictionary*) userInfoDIC;


/**
 *  购买商品方法
 *
 *  @param commodityID 商品id(和duole_ios_iap.plist里对应)
 *  @param data 商品id＋其它一下玩家信息
 */
-(void)PayStart:(NSString*)commodityID Data:(NSDictionary*)data;


/**
 *  购买商品方法
 *
 *  @param commodityID 商品id(和duole_ios_iap.plist里对应)
 *  @param data 商品id＋其它一下玩家信息
 *  @param success     成功返回
 *  @param fail        失败返回
 */
-(void)PayStart:(NSString*)commodityID Data:(NSDictionary*)data success:(void(^)(NSDictionary* dic))success fail:(void(^)(NSDictionary* dic)) fail;



/**
 *  把收据写入本地
 *
 *  @param transaction 收据
 */
//-(void)WiretReceipt:(id)transaction;



//获取pay_type
-(int)getPayType;

//下载pay_type文件
-(void)downloadPayType;

/**
 *  恢复订单(没啥用)
 */
//-(void)resumedPay;

-(void)showMessage:(NSString*)message;


-(void )webPay;
@end
