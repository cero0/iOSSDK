//
//  XJLLoginRequest.m
//  duoleIosSDK
//
//  Created by cxh on 16/7/27.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "XJLLoginRequest.h"
#import "loginFileReadWrite.h"


@implementation XJLLoginRequest{
    
    loginFileReadWrite *_loginFileData;
    
    NSString* Regist_URL;
    NSString* QuickLogin_URL;
    NSString* SIGNKEY;
    NSString* SignKey9158;
    NSString* ChangePassword_URL9158;
    NSString* Login_URL9158;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _loginFileData = [loginFileReadWrite share];
        NSMutableDictionary* Dic =  [_loginFileData GetduoleIosLoginInfo];
        NSDictionary* dic = [Dic objectForKey:@"XJLRequest"];
//        NSLog(@"%@",dic);
        
        Regist_URL = [dic objectForKey:@"Regist_URL"];
        QuickLogin_URL = [dic objectForKey:@"QuickLogin_URL"];
        SIGNKEY = [dic objectForKey:@"SIGNKEY"];//密匙(临时账号)
        SignKey9158 = [dic objectForKey:@"9158SignKey"];//9158登陆的密匙
        ChangePassword_URL9158 = [dic objectForKey:@"9158ChangePassword_URL"];
        Login_URL9158 = [dic objectForKey:@"9158Login_URL"];
        
    }
    return self;
}

- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
}


//快速登录
-(void)QuickLogin{
     NSString *sign  =[self md5:[DevieceUUID stringByAppendingString:SIGNKEY]] ;
     NSString *requestAddress = [[NSString alloc] initWithFormat:@"%@?func=1&device=%@&sign=%@",QuickLogin_URL,DevieceUUID,sign];
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:requestAddress] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            //如果解析错误
            if (error == nil) {
            //解析成功保存到本地
            [_loginFileData AddOBjectAtName:[dic objectForKey:@"temp_uid"] PassWord:@"" UserType:1];
            //然后调用登陆
            [self Login:[dic objectForKey:@"temp_uid"] Password:@"" isNewAccount:YES];
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
                [self.delegate loginSuccess:[NSMutableDictionary dictionaryWithDictionary:@{@"1":@"",@"2":account,@"3":DevieceUUID,@"4":@YES}]];
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
    
    //正常账号登陆
    NSString *sign = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",@"38",account,password,@"1",SignKey9158];
    sign = [self md5:sign];
    NSString *requestAddress =  [[NSString alloc] initWithFormat:@"%@?appID=38&memberName=%@&password=%@&memberType=1&sign=%@",Login_URL9158,account,password,sign] ;
    NSLog(@"%@",requestAddress);
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:requestAddress] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            //如果解析错误
            if (error == nil) {
                if ([[dic objectForKey:@"result"] intValue] == 1) {
                    //解析成功保存到本地
                    [_loginFileData AddOBjectAtName:account PassWord:password UserType:0];
                    //然后调用登陆
                    [self.delegate loginSuccess:[NSMutableDictionary dictionaryWithDictionary:@{@"1":@"",@"2":account,@"3":password}]];
                }else{
                    NSString* errorStr = [NSString stringWithFormat:@"登陆失败:%@",[dic objectForKey:@"message"]];
                    [self.delegate loginFail:errorStr];
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
        
    }] resume];
}



//注册        帐号 密码
-(void)Register:(NSString*)account Password:(NSString*)password{
    NSString *sign = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",@"cwxjl",@"001",account,password,SignKey9158];
    sign = [self md5:sign];
    NSString *requestAddress =  [[NSString alloc] initWithFormat:@"%@?memberName=%@&password=%@&func=1&device=%@&sign=%@",Regist_URL,account,password,DevieceUUID,sign] ;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:requestAddress] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            //如果解析错误
            if (error == nil) {
                if ([[dic objectForKey:@"result"] intValue] == 1) {
                    //直接登陆
                    [self Login:account Password:password isNewAccount:YES];
                }else{
                    NSString* errorStr = [NSString stringWithFormat:@"注册失败:%@",[dic objectForKey:@"message"]];
                    [self.delegate loginFail:errorStr];
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}


//绑定        临时账号 帐号 密码
-(void)Bound:(NSString*)quick_id account:(NSString*)account Password:(NSString*)password{
    NSString *sign = [[NSString alloc] initWithFormat:@"%@%@%@%@%@",@"cwxjl",@"001",account,password,SignKey9158];
    sign = [self md5:sign];
    NSString *requestAddress =  [[NSString alloc] initWithFormat:@"%@?memberName=%@&password=%@&func=1&device=%@&sign=%@",Regist_URL,account,password,DevieceUUID,sign] ;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:requestAddress] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            if (error == nil) {
                if ([[dic objectForKey:@"result"] intValue] == 1) {
                  //-------绑定-------
                    
                    
                    NSString *sign  = [self md5:[DevieceUUID stringByAppendingString:SIGNKEY]];
                    NSString *requestAddress =  [[NSString alloc] initWithFormat:@"%@?temp_uid=%@&pf_uid=%@&func=2&device=%@&sign=%@",QuickLogin_URL,quick_id,account,DevieceUUID,sign] ;
                    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:requestAddress] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (error == nil) {
                            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                            NSLog(@"%@",dic);
                            if (error == nil) {
                                if ([[dic objectForKey:@"ret"] intValue] == 0) {
                                    //直接登陆
                                    [_loginFileData removeOBjectAtName:quick_id];
                                    [self Login:account Password:password isNewAccount:YES];
                                }else{
                                    NSString* errorStr = [NSString stringWithFormat:@"绑定失败:%@",[dic objectForKey:@"msg"]];
                                    [self.delegate loginFail:errorStr];
                                }
                            }
                        }
                        if(error)[self.delegate loginFail:[error localizedDescription]];
                    }] resume];
                    
                    
                    
                 //--------------
                }else{
                    NSString* errorStr = [NSString stringWithFormat:@"注册失败:%@",[dic objectForKey:@"message"]];
                    [self.delegate loginFail:errorStr];
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];

}

//修改密码   账号  旧密码 新密码
-(void)ChangPassword:(NSString*)accounts oldPassword:(NSString*)oldPassword  newPassword:(NSString*)newPassword{
    NSString *sign  = [[NSString alloc] initWithFormat:@"%@%@%@%@",accounts,oldPassword,newPassword,SignKey9158];
    sign = [self md5:sign];
    NSString *requestAddress = [[NSString alloc] initWithFormat:@"%@?memberName=%@&oldPwd=%@&newPwd=%@&sign=%@",ChangePassword_URL9158,accounts,oldPassword,newPassword,sign] ;
    [[[NSURLSession sharedSession] dataTaskWithRequest:[self getRequestWithURL:requestAddress] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary* dic =  [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            //如果解析错误
            if (error == nil) {
                if ([[dic objectForKey:@"result"] intValue] == 1) {
                    //直接登陆
                    [self Login:accounts Password:newPassword isNewAccount:NO];
                }else{
                    NSString* errorStr = [NSString stringWithFormat:@"修改密码失败:%@",[dic objectForKey:@"message"]];
                    [self.delegate loginFail:errorStr];
                }
            }
        }
        if(error)[self.delegate loginFail:[error localizedDescription]];
    }] resume];
}
@end
