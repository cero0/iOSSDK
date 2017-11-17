//
//  FJFateLoginRequest.m
//  duoleIosSDK
//
//  Created by duole on 17/2/9.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FJFateLoginRequest.h"
#import "loginFileReadWrite.h"

static NSString* const SUCCESS = @"成功";//0 成功
static NSString* const FAIL = @"失败";  //1 失败
static NSString* const PARAM_FAIL = @"请求参数错误失败"; //3 请求参数错误失败
static NSString* const NO_CHANGE = @"数据没有更新"; //10 数据没有更新
static NSString* const USERR_NAME_DUPLICATE = @"账号名已存在"; //1000账号存在
static NSString* const USERR_NAME_CREAT_FAIL = @"账号创建失败"; //1001账号创建失败
static NSString* const USERR_NAME_NOT_EXIST = @"账号不存在"; //1002账号不存在
static NSString* const PASS_WORD_ERROR = @"密码错误"; //1003密码错误
static NSString* const PASS_WORD_TOO_LONG = @"密码太长"; //1004密码太长
static NSString* const SAFE_PASS_EXIST = @"二级密保存在"; //1005二级密保存在
static NSString* const SAFE_PASS_NOT_EXIST = @"二级密保不存在"; //1006二级密保不存在
static NSString* const SAFE_PASS_ERROR = @"二级密保错误"; //1007二级密保错误
static NSString* const USER_INFO_PHON_EXIST = @"该账号已经绑定手机号码"; //1008改账号已经绑定手机号码
static NSString* const LOGIN_CHECK_ERROR = @"登陆认证授权失效"; //2001登陆认证授权失效!
static NSString* const SEND_CODE_TIME_ERROR = @"短信验证码发动太频繁"; //3001短信验证码发动太频繁
static NSString* const SEND_CODE_ERROR = @"短信验证码错误"; //3002短信验证码错误


@implementation FJFateLoginRequest{
    
    loginFileReadWrite *_loginFileData;
    
    NSString* loginURL;
    NSInteger cpId;
    NSInteger gameId;
    NSString* loginKey;
    NSString* appid;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        _loginFileData = [loginFileReadWrite share];
        NSMutableDictionary* Dic =  [_loginFileData GetduoleIosLoginInfo];
        NSDictionary* dic = [Dic objectForKey:@"FJFateRequest"];
        //        NSLog(@"%@",dic);
        
        loginURL = [dic objectForKey:@"LoginURL"];//登陆地址
        cpId = [[dic objectForKey:@"CpID"] integerValue];//合作方id
        gameId = [[dic objectForKey:@"GameID"] integerValue];//游戏id
        loginKey = [dic objectForKey:@"Key"];//登陆密匙
        appid = [dic objectForKey:@"appid"];//应用id
    }
    return self;
}

//快速登录
-(void)QuickLogin{
//    NSString *sign  = [self md5:[DevieceUUID stringByAppendingString:loginKey]];
//    NSString* URL_str =  [[NSString alloc] initWithFormat:@"%@quick_register.php?device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,DevieceUUID,cpId,gameId,sign];
//    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (error == nil) {
//            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//            //如果解析错误
//            if (error == nil) {
//                int ret = [[dic objectForKey:@"ret"] intValue];
//                if (ret == 0){
//                    
//                    //解析成功也返回成功
//                    NSString *quick_id = [[dic objectForKey:@"data"] objectForKey:@"quick_id"];
//                    [_loginFileData AddOBjectAtName:quick_id PassWord:@"" UserType:1];//保存到本地
//                    //然后调用登录
//                    [self Login:quick_id Password:@"" isNewAccount:YES];
//                    
//                }
//                else{
//                    NSString *msg = [dic objectForKey:@"msg"];
//                    [self.delegate loginFail:msg];return;
//                }
//            }
//        }
//        if(error)[self.delegate loginFail:[error localizedDescription]];
//    }] resume];
    
    
    
    NSString *password = @"123456";
    NSString *account = [DevieceUUID substringToIndex:8];
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/register&appid=%@&channel=2&password=%@&username=%@&%@",appid,password,account,loginKey]];
    //    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@register.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&device=%@&sign=%@",loginURL,account,password,cpId,gameId,DevieceUUID,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&channel=2&password=%@&sign=%@&username=%@",appid,password,sign,account];
    
    NSString *URL_str = [loginURL stringByAppendingString:@"user/register"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:1];
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else if (ret == 3){
                    [self.delegate loginFail:PARAM_FAIL];
                }
                else if (ret == 10){
                    [self.delegate loginFail:NO_CHANGE];
                }
                else if (ret == 1000){
                    if(account == [DevieceUUID substringToIndex:8]){
                        [_loginFileData AddOBjectAtName:account PassWord:password UserType:1];
                        [self Login:account Password:password isNewAccount:YES];

                    }else{
                        [self.delegate loginFail:USERR_NAME_DUPLICATE];
                    }
                    
                }
                else if (ret == 1001){
                    [self.delegate loginFail:USERR_NAME_CREAT_FAIL];
                }
                else if (ret == 1002){
                    [self.delegate loginFail:USERR_NAME_NOT_EXIST];
                }
                else if (ret == 1003){
                    [self.delegate loginFail:PASS_WORD_ERROR];
                }
                else if (ret == 1004){
                    [self.delegate loginFail:PASS_WORD_TOO_LONG];
                }
                else if (ret == 1005){
                    [self.delegate loginFail:SAFE_PASS_EXIST];
                }
                else if (ret == 1006){
                    [self.delegate loginFail:SAFE_PASS_NOT_EXIST];
                }
                else if (ret == 1007){
                    [self.delegate loginFail:SAFE_PASS_ERROR];
                }
                else if (ret == 1008){
                    [self.delegate loginFail:USER_INFO_PHON_EXIST];
                }
                else if (ret == 2001){
                    [self.delegate loginFail:LOGIN_CHECK_ERROR];
                }
                else if (ret == 3001){
                    [self.delegate loginFail:SEND_CODE_TIME_ERROR];
                }
                else if (ret == 3002){
                    [self.delegate loginFail:SEND_CODE_ERROR];
                }

                else{
                    NSString *msg = [NSString stringWithFormat:@"%@,recode=%i",[dic objectForKey:@"msg"],ret];
                    [self.delegate loginFail:msg];
                    return;
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
    
    int usertype = 0;
    //判断是否是临时账号
    for (NSMutableDictionary *dic in user_arr) {
        if ([account isEqualToString:[dic objectForKey:@"name"]]) {
            int i = [[dic objectForKey:@"userType"] intValue];
            if(i == 1){
                usertype = 1;
                password = @"123456";
//                NSString *sign = [self md5:[NSString stringWithFormat:@"%@%@%@",account,DevieceUUID,loginKey]];
//                NSString *URL_str =  [[NSString alloc] initWithFormat:@"%@quick_login.php?quick_id=%@&device=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,DevieceUUID,cpId,gameId,sign] ;
//                [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:URL_str] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                    if (error == nil) {
//                        NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//                        if (error == nil) {
//                            int ret = [[dic objectForKey:@"ret"] intValue];
//                            if (ret == 0){
//                                //解析成功保存到本地
//                                [_loginFileData AddOBjectAtName:account PassWord:password UserType:1];
//                                
//                                NSMutableDictionary* newdic = [[NSMutableDictionary alloc] initWithDictionary:[dic objectForKey:@"data"]];
//                                [newdic setObject:account forKey:@"account"];
//                                if (isNewAccount) [newdic setObject:@(isNewAccount) forKey:@"newAccount"];
//                                [self.delegate loginSuccess:newdic];
//                                
//                            }
//                            else{
//                                NSString *msg = [dic objectForKey:@"msg"];
//                                [self.delegate loginFail:msg];return;
//                            }
//                        }
//                    }
//                    if(error)[self.delegate loginFail:[error localizedDescription]];
//                }] resume];
                
//                return;
                
            } if (i == 0) {
                //正常账号
                usertype = 0;
                //赋值密码
                if (password.length == 0) {
                    password = [dic objectForKey:@"pass"];
                }
                
            }
        }
    }
    
    //---------------正常账号登录-------------------
    //别忘了将平台号改成正常账号登录的
    NSString *sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/login&appid=%@&password=%@&username=%@&%@",appid,[self md5:password],account,loginKey]];
//    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@login.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,password,cpId,gameId,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&password=%@&sign=%@&username=%@",appid,[self md5:password],sign,account];
    
    NSString *URL_str = [loginURL stringByAppendingString:@"user/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    //解析成功保存到本地
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:usertype];
                    
                    NSString *open_id = [NSString stringWithFormat:@"%@",[dic objectForKey:@"open_id"]];
                    
                    NSMutableDictionary* newdic = [[NSMutableDictionary alloc] initWithDictionary:@{@"open_id":open_id,
                                                                                                    @"token":[dic objectForKey:@"token"]
                                                                                                    }];
                    
                    [newdic setObject:account forKey:@"account"];
                    if (isNewAccount)[newdic setObject:@(isNewAccount) forKey:@"newAccount"];
                    [self.delegate loginSuccess:newdic];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *plistPath1 = [paths objectAtIndex:0];
                    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
                    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
                    if (userArr == nil) {
                        userArr = [[NSMutableArray alloc] init];
                        BOOL bl = [userArr writeToFile:path atomically:YES];
                        if (bl == NO) NSLog(@"文件写入失败");
                    }else{
                        NSMutableDictionary *dictemp = [[NSMutableDictionary alloc] init];
                        for (NSMutableDictionary *dic in userArr) {
                            if ([[dic objectForKey:@"account"] isEqualToString:account]) {
                                dictemp = dic;
                            }
                        }
                        [userArr removeObject:dictemp];
                    }
                    [userArr insertObject:newdic atIndex:0];
                    BOOL bl = [userArr writeToFile:path atomically:YES];
                    if (bl == NO) NSLog(@"文件写入失败");
                    
                }
                else if (ret == 3){
                    [self.delegate loginFail:PARAM_FAIL];
                }
                else if (ret == 10){
                    [self.delegate loginFail:NO_CHANGE];
                }
                else if (ret == 1000){
                    [self.delegate loginFail:USERR_NAME_DUPLICATE];
                }
                else if (ret == 1001){
                    [self.delegate loginFail:USERR_NAME_CREAT_FAIL];
                }
                else if (ret == 1002){
                    [self.delegate loginFail:USERR_NAME_NOT_EXIST];
                }
                else if (ret == 1003){
                    [self.delegate loginFail:PASS_WORD_ERROR];
                }
                else if (ret == 1004){
                    [self.delegate loginFail:PASS_WORD_TOO_LONG];
                }
                else if (ret == 1005){
                    [self.delegate loginFail:SAFE_PASS_EXIST];
                }
                else if (ret == 1006){
                    [self.delegate loginFail:SAFE_PASS_NOT_EXIST];
                }
                else if (ret == 1007){
                    [self.delegate loginFail:SAFE_PASS_ERROR];
                }
                else if (ret == 1008){
                    [self.delegate loginFail:USER_INFO_PHON_EXIST];
                }
                else if (ret == 2001){
                    [self.delegate loginFail:LOGIN_CHECK_ERROR];
                }
                else if (ret == 3001){
                    [self.delegate loginFail:SEND_CODE_TIME_ERROR];
                }
                else if (ret == 3002){
                    [self.delegate loginFail:SEND_CODE_ERROR];
                }
                else{
                    NSString *msg = [NSString stringWithFormat:@"%@,recode=%i",[dic objectForKey:@"msg"],ret];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//注册        帐号 密码
-(void)Register:(NSString*)account Password:(NSString*)password{
    
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/register&appid=%@&password=%@&username=%@&%@",appid,password,account,loginKey]];
//    NSString *URL_str = [[NSString alloc] initWithFormat:@"%@register.php?user_name=%@&passwd=%@&cp_id=%lu&game_id=%lu&device=%@&sign=%@",loginURL,account,password,cpId,gameId,DevieceUUID,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&password=%@&sign=%@&username=%@",appid,password,sign,account];

    NSString *URL_str = [loginURL stringByAppendingString:@"user/register"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else if (ret == 3){
                    [self.delegate loginFail:PARAM_FAIL];
                }
                else if (ret == 10){
                    [self.delegate loginFail:NO_CHANGE];
                }
                else if (ret == 1000){
                    [self.delegate loginFail:USERR_NAME_DUPLICATE];
                }
                else if (ret == 1001){
                    [self.delegate loginFail:USERR_NAME_CREAT_FAIL];
                }
                else if (ret == 1002){
                    [self.delegate loginFail:USERR_NAME_NOT_EXIST];
                }
                else if (ret == 1003){
                    [self.delegate loginFail:PASS_WORD_ERROR];
                }
                else if (ret == 1004){
                    [self.delegate loginFail:PASS_WORD_TOO_LONG];
                }
                else if (ret == 1005){
                    [self.delegate loginFail:SAFE_PASS_EXIST];
                }
                else if (ret == 1006){
                    [self.delegate loginFail:SAFE_PASS_NOT_EXIST];
                }
                else if (ret == 1007){
                    [self.delegate loginFail:SAFE_PASS_ERROR];
                }
                else if (ret == 1008){
                    [self.delegate loginFail:USER_INFO_PHON_EXIST];
                }
                else if (ret == 2001){
                    [self.delegate loginFail:LOGIN_CHECK_ERROR];
                }
                else if (ret == 3001){
                    [self.delegate loginFail:SEND_CODE_TIME_ERROR];
                }
                else if (ret == 3002){
                    [self.delegate loginFail:SEND_CODE_ERROR];
                }

                else{
                    NSString *msg = [NSString stringWithFormat:@"%@,recode=%i",[dic objectForKey:@"msg"],ret];
                    [self.delegate loginFail:msg];
                    return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)account Password:(NSString*)password{
    
    NSString *open_id = [[NSString alloc] init];
    NSString *token = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (NSMutableDictionary *dic in userArr) {
        if ([[dic objectForKey:@"account"] isEqualToString:[DevieceUUID substringToIndex:8]]) {
            open_id = [dic objectForKey:@"open_id"];
            token = [dic objectForKey:@"token"];
        }
    }
    
    
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/bind_account&appid=%@&open_id=%@&password=%@&token=%@&username=%@&%@",appid,open_id,password,token,account,loginKey]];
    NSString *bodyStr =  [[NSString alloc] initWithFormat:@"appid=%@&open_id=%@&password=%@&sign=%@&token=%@&username=%@",appid,open_id,password,sign,token,account];
    NSString *URL_str = [loginURL stringByAppendingString:@"user/bind_account"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    
                    //删除临时账号
                    [_loginFileData removeOBjectAtName:[DevieceUUID substringToIndex:8]];
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:0];
                    //调用登陆
                    [self Login:account Password:password isNewAccount:YES];
                }
                else if (ret == 3){
                    [self.delegate loginFail:PARAM_FAIL];
                }
                else if (ret == 10){
                    [self.delegate loginFail:NO_CHANGE];
                }
                else if (ret == 1000){
                    [self.delegate loginFail:USERR_NAME_DUPLICATE];
                }
                else if (ret == 1001){
                    [self.delegate loginFail:USERR_NAME_CREAT_FAIL];
                }
                else if (ret == 1002){
                    [self.delegate loginFail:USERR_NAME_NOT_EXIST];
                }
                else if (ret == 1003){
                    [self.delegate loginFail:PASS_WORD_ERROR];
                }
                else if (ret == 1004){
                    [self.delegate loginFail:PASS_WORD_TOO_LONG];
                }
                else if (ret == 1005){
                    [self.delegate loginFail:SAFE_PASS_EXIST];
                }
                else if (ret == 1006){
                    [self.delegate loginFail:SAFE_PASS_NOT_EXIST];
                }
                else if (ret == 1007){
                    [self.delegate loginFail:SAFE_PASS_ERROR];
                }
                else if (ret == 1008){
                    [self.delegate loginFail:USER_INFO_PHON_EXIST];
                }
                else if (ret == 2001){
                    [self.delegate loginFail:LOGIN_CHECK_ERROR];
                }
                else if (ret == 3001){
                    [self.delegate loginFail:SEND_CODE_TIME_ERROR];
                }
                else if (ret == 3002){
                    [self.delegate loginFail:SEND_CODE_ERROR];
                }

                else{
                    NSString *msg = [NSString stringWithFormat:@"%@,recode=%i",[dic objectForKey:@"msg"],ret];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)account oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword{
    NSString *openID = [[NSString alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:@"duoleIosSdk/FJuserinfo.plist"];
    NSMutableArray *userArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    for (NSMutableDictionary *dic in userArr) {
        if ([[dic objectForKey:@"account"] isEqualToString:account]) {
            openID = [dic objectForKey:@"open_id"];
        }
    }
    
    NSString* sign = [self hmacSha1:loginKey data:[NSString stringWithFormat:@"user/change_pass&appid=%@&new_password=%@&old_password=%@&open_id=%@&%@",appid,newPassword,[self md5:oldPassword],openID,loginKey]];
//    NSString *URL_str =      [[NSString alloc] initWithFormat:@"%@change_passwd.php?user_name=%@&old_passwd=%@&new_passwd=%@&cp_id=%lu&game_id=%lu&sign=%@",loginURL,account,oldPassword,newPassword,cpId,gameId,sign] ;
    NSString *bodyStr = [[NSString alloc] initWithFormat:@"appid=%@&new_password=%@&old_password=%@&open_id=%@&sign=%@",appid,newPassword,[self md5:oldPassword],openID,sign];
    
    NSString *URL_str = [loginURL stringByAppendingString:@"user/change_pass"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL_str]];
    request.HTTPMethod = @"POST";//请求方法
    request.timeoutInterval = 5.0;//设置请求超时为5秒
    request.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                int ret = [[dic objectForKey:@"rs"] intValue];
                if (ret == 0){
                    //调用登陆
                    [self Login:account Password:newPassword isNewAccount:NO];
                }
                else if (ret == 3){
                    [self.delegate loginFail:PARAM_FAIL];
                }
                else if (ret == 10){
                    [self.delegate loginFail:NO_CHANGE];
                }
                else if (ret == 1000){
                    [self.delegate loginFail:USERR_NAME_DUPLICATE];
                }
                else if (ret == 1001){
                    [self.delegate loginFail:USERR_NAME_CREAT_FAIL];
                }
                else if (ret == 1002){
                    [self.delegate loginFail:USERR_NAME_NOT_EXIST];
                }
                else if (ret == 1003){
                    [self.delegate loginFail:PASS_WORD_ERROR];
                }
                else if (ret == 1004){
                    [self.delegate loginFail:PASS_WORD_TOO_LONG];
                }
                else if (ret == 1005){
                    [self.delegate loginFail:SAFE_PASS_EXIST];
                }
                else if (ret == 1006){
                    [self.delegate loginFail:SAFE_PASS_NOT_EXIST];
                }
                else if (ret == 1007){
                    [self.delegate loginFail:SAFE_PASS_ERROR];
                }
                else if (ret == 1008){
                    [self.delegate loginFail:USER_INFO_PHON_EXIST];
                }
                else if (ret == 2001){
                    [self.delegate loginFail:LOGIN_CHECK_ERROR];
                }
                else if (ret == 3001){
                    [self.delegate loginFail:SEND_CODE_TIME_ERROR];
                }
                else if (ret == 3002){
                    [self.delegate loginFail:SEND_CODE_ERROR];
                }

                else{
                    NSString *msg = [NSString stringWithFormat:@"%@,recode=%i",[dic objectForKey:@"msg"],ret];
                    [self.delegate loginFail:msg];return;
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}

@end
