//
//  loginRequest.h
//  duoleIosSDK
//
//  Created by cxh on 16/7/27.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "duoleLoginVC.h"

@protocol duoleLoginRequestDelegate <NSObject>

-(void)loginFail:(NSString*)error;

-(void)loginSuccess:(NSMutableDictionary*)data;

@end



@interface loginRequest : NSObject

@property(nonatomic,weak)id<duoleLoginRequestDelegate> delegate;


-(instancetype)initWithLoginMode:(LoginMode)mode;

//快速登录
-(void)QuickLogin;

//登陆 帐号 密码 是否是新账号
-(void)Login:(NSString*)account Password:(NSString*)password isNewAccount:(BOOL)isNewAccount;

//注册        帐号 密码
-(void)Register:(NSString*)accounts Password:(NSString*)password;

//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)accounts Password:(NSString*)password;

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)accounts oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword;

@end
