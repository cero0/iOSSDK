//
//  FateLoginRequest.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/2.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "CanTingLoginRequest.h"
#import "loginFileReadWrite.h"


@interface CanTingLoginRequest()

@end


@implementation CanTingLoginRequest{
    
    loginFileReadWrite *_loginFileData;
    
    NSString* loginURL;
    NSInteger cpId;
    NSInteger gameId;
    NSString* loginKey;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _loginFileData = [loginFileReadWrite share];
        NSMutableDictionary* Dic =  [_loginFileData GetduoleIosLoginInfo];
        NSDictionary* dic = [Dic objectForKey:@"CanTingRequest"];
        //        NSLog(@"%@",dic);
        
        loginURL = [dic objectForKey:@"LoginURL"];//登陆地址
        cpId = [[dic objectForKey:@"CpID"] integerValue];//合作方id
        gameId = [[dic objectForKey:@"GameID"] integerValue];//游戏id
        loginKey = [dic objectForKey:@"Key"];//登陆密匙
        
    }
    return self;
}

//快速登录
-(void)QuickLogin{
    NSString *sign  = [self md5:[DevieceUUID stringByAppendingString:loginKey]];
    NSString* URL_str =  [[NSString alloc] initWithFormat:@"%@quick_register.php?device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,DevieceUUID,cpId,gameId,sign];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            //如果解析错误
            if (error == nil) {
                int ret = [[dic objectForKey:@"ret"] intValue];
                if (ret == 0){
                    
                    //解析成功也返回成功
                    NSString *quick_id = [[dic objectForKey:@"data"] objectForKey:@"quick_id"];
                    [_loginFileData AddOBjectAtName:quick_id PassWord:@"" UserType:1];//保存到本地
                    //然后调用登录
                    [self Login:quick_id Password:@"" isNewAccount:YES];
                    
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//登陆 帐号 密码 是否是新账号
-(void)Login:(NSString*)account Password:(NSString*)password isNewAccount:(BOOL)isNewAccount{
    //检查账号类型
    NSMutableDictionary* userinfo = [_loginFileData readUserInfo];
    NSMutableArray* user_arr = [userinfo objectForKey:@"用户数组"];
    
    //判断是否是临时账号
    for (NSMutableDictionary *dic in user_arr) {
        if ([account isEqualToString:[dic objectForKey:@"name"]]) {
            int i = [[dic objectForKey:@"userType"] intValue];
            if(i == 1){
                
                
                NSString *sign = [self md5:[NSString stringWithFormat:@"%@%@%@",account,DevieceUUID,loginKey]];
                NSString *URL_str =  [[NSString alloc] initWithFormat:@"%@quick_login.php?quick_id=%@&device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,DevieceUUID,cpId,gameId,sign] ;
                [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error == nil) {
                        NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                        if (error == nil) {
                            int ret = [[dic objectForKey:@"ret"] intValue];
                            if (ret == 0){
                                //解析成功保存到本地
                                [_loginFileData AddOBjectAtName:account PassWord:password UserType:1];
                
                                NSMutableDictionary* newdic = [[NSMutableDictionary alloc] initWithDictionary:[dic objectForKey:@"data"]];
                                [newdic setObject:account forKey:@"account"];
                                if (isNewAccount) [newdic setObject:@(isNewAccount) forKey:@"newAccount"];
                                [self.delegate loginSuccess:newdic];
                                
                            }
                            else{
                                NSString *msg = [dic objectForKey:@"msg"];
                                [self.delegate loginFail:msg];return;
                            }
                        }
                    }
                    if(error)[self.delegate loginFail:[error localizedDescription]];
                }] resume];
                
                return;
                
            } if (i == 0) {
                //正常账号
                //赋值密码
                if (password.length == 0) {
                    password = [dic objectForKey:@"pass"];
                }
            }
        }
    }

    //---------------正常账号登录-------------------
    //别忘了将平台号改成正常账号登录的
    NSString *sign = [self md5:[NSString stringWithFormat:@"%@%@%@",account,password,loginKey]];
     NSString *URL_str = [[NSString alloc] initWithFormat:@"%@login.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,password,cpId,gameId,sign] ;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"ret"] intValue];
                if (ret == 0){
                    //解析成功保存到本地
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:0];
                    
                    NSMutableDictionary* newdic = [[NSMutableDictionary alloc] initWithDictionary:[dic objectForKey:@"data"]];
                    
                    [newdic setObject:account forKey:@"account"];
                    if (isNewAccount)[newdic setObject:@(isNewAccount) forKey:@"newAccount"];
                    [self.delegate loginSuccess:newdic];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//注册        帐号 密码
-(void)Register:(NSString*)account Password:(NSString*)password{
    
    NSString* sign = [self md5:[NSString stringWithFormat:@"%@%@%@%@",account,password,DevieceUUID,loginKey]];
    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@register.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&device=%@&sign=%@",loginURL,account,password,cpId,gameId,DevieceUUID,sign] ;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"ret"] intValue];
                if (ret == 0){
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)account Password:(NSString*)password{
    NSString* sign = [self md5:[NSString stringWithFormat:@"%@%@%@%@%@",quick_id,account,password,DevieceUUID,loginKey]];
    NSString *URL_str =  [[NSString alloc] initWithFormat:@"%@bind.php?quick_id=%@&user_name=%@&passwd=%@&device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,quick_id,account,password,DevieceUUID,cpId,gameId,sign];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"ret"] intValue];
                if (ret == 0){
                    //删除临时账号
                    [_loginFileData removeOBjectAtName:quick_id];
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)account oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword{
    NSString* sign = [self md5:[NSString stringWithFormat:@"%@%@%@%@",account,oldPassword,newPassword,loginKey]];
    NSString *URL_str =      [[NSString alloc] initWithFormat:@"%@change_passwd.php?user_name=%@&old_passwd=%@&new_passwd=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,oldPassword,newPassword,cpId,gameId,sign] ;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"ret"] intValue];
                if (ret == 0){
                    //调用登陆
                    [self Login:account Password:newPassword isNewAccount:NO];
                }
                else{
                    NSString *msg = [dic objectForKey:@"msg"];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}
@end
