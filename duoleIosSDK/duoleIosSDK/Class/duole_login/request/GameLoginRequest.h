//
//  GameLoginRequest.h
//  duoleIosSDK
//
//  Created by cxh on 16/7/27.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macro.h"

@protocol GameLoginRequestDelegate <NSObject>

-(void)loginFail:(NSString*)error;

-(void)loginSuccess:(NSMutableDictionary*)data;

@end



@interface GameLoginRequest : NSObject


@property(nonatomic,weak)id<GameLoginRequestDelegate> delegate;

@property(nonatomic,assign)NSString* str;

//hmacSha1加密
- (NSString*)hmacSha1:(NSString *)key data:(NSString *)data;

//md5加密
- (NSString *)md5:(NSString *)str;

//sha1加密
- (NSString*)sha1:(NSString *)str;

//请求合成
-(NSMutableURLRequest*)getRequestWithURL:(NSString*)url;

//＋＋＋＋＋必须重写＋＋＋＋＋
//快速登录
-(void)QuickLogin;

//登陆 帐号 密码 是否是新账号
-(void)Login:(NSString*)account Password:(NSString*)password isNewAccount:(BOOL)isNewAccount;

//注册        帐号 密码
-(void)Register:(NSString*)account Password:(NSString*)password;

//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)accounts Password:(NSString*)password;

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)account oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword;
@end
