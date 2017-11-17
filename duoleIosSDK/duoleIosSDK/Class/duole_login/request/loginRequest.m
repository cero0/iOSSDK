//
//  loginRequest.m
//  duoleIosSDK
//
//  Created by cxh on 16/7/27.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "loginRequest.h"
#import "GameLoginRequest.h"
#import "XJLLoginRequest.h"
#import "FateLoginRequest.h"
#import "CanTingLoginRequest.h"
#import "FJFateLoginRequest.h"
//#import "Toast.h"

@interface loginRequest()<GameLoginRequestDelegate>

@end

@implementation loginRequest{
    LoginMode _mode;
    GameLoginRequest* _gameLR;
}


-(instancetype)initWithLoginMode:(LoginMode)mode{
    self = [super init];
    if (self) {
        _mode = mode;
        switch (mode) {
            case XJLLogin:
                _gameLR = [[XJLLoginRequest alloc] init];
                break;
            case FATELogin:
                _gameLR = [[FateLoginRequest alloc] init];
                break;
            case FJFATELogin:
                _gameLR = [[FJFateLoginRequest alloc] init];
                break;
            case CanTingLogin:
                _gameLR = [[CanTingLoginRequest alloc] init];
                break;
            default:
                break;
        }
        _gameLR.delegate = self;
    }
    return self;
}

- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
}


//快速登录
-(void)QuickLogin{
//    if(_mode == FJFATELogin){
//        NSLog(@"风际渠道包登录");
////        [[Toast shareToast] makeText:@"目前不支持游客登录,请注册登录" duration:1];
//        
//    }else{
//        [_gameLR QuickLogin];
//    }
    [_gameLR QuickLogin];
}
//登陆       帐号 密码 是否是新账号
-(void)Login:(NSString*)account Password:(NSString*)password isNewAccount:(BOOL)isNewAccount{
    [_gameLR Login:account Password:password isNewAccount:isNewAccount];
}
//注册        帐号 密码
-(void)Register:(NSString*)accounts Password:(NSString*)password{
    [_gameLR Register:accounts Password:password];
}

//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)accounts Password:(NSString*)password{
    [_gameLR Bound:quick_id account:accounts Password:password];
}

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)accounts oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword{
    [_gameLR ChangPassword:accounts oldPassword:oldPassword newPassword:newPassword];
}
#pragma GameLoginRequestDelegate--

-(void)loginFail:(NSString*)error{
    [_delegate loginFail:error];
}

-(void)loginSuccess:(NSMutableDictionary*)data{
    [_delegate loginSuccess:data];
}
@end
