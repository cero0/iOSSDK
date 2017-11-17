//
//  loginFileReadWrite.m
//  duoleIosSDK
//
//  Created by cxh on 16/7/26.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "loginFileReadWrite.h"
#import <AdSupport/ASIdentifierManager.h>
#import "KeychainItemWrapper.h"
#import "Macro.h"

@implementation loginFileReadWrite{
    NSMutableDictionary* Text_Dic;
}

+(instancetype)share{
    return [[loginFileReadWrite alloc] init];
}



- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
}


/**
 *  判断登录状态
 *  0 无帐号登录
 *  1 有帐号登录
 *  2 临时帐号登录
 */
-(NSInteger)GetInitMode{
    //检查路径(本可以放到readUserInfo，因为读去用户信息会用到很多次，故在这里检查。)
    //判断路径是否正确
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: [self getPath] ] == NO){
    //第一次进入
        NSLog(@"文件不存在!第一次进入开始创建......");
        //初始化用户信息
        [self InitUserInfo];
    }
    //888888888888888888888888888888888888888888888888
    
    NSMutableDictionary* userInfo = [self readUserInfo];
    NSMutableArray* user_Arr = [userInfo objectForKey:@"用户数组"];
    if (user_Arr.count==0) {
        return 0;//没有数据 无帐号登录
    }else {
        NSMutableDictionary* user = user_Arr[0];
        int userType = [[user objectForKey:@"userType"] intValue] ;
        if (userType == 0) {
            return 1;//有账号
        } else if (userType == 1){
            return 2;//临时账号
        }
    }
    //888888888888888888888888888888888888888888888888
    return 0;
}

// 根据用户名获取用户类型 0(正常账号) 1(临时账号)
-(NSInteger)GetUserType:(NSString*)name{
    NSMutableDictionary* userInfo = [self readUserInfo];
    NSMutableArray* user_Arr = [userInfo objectForKey:@"用户数组"];
    for (NSMutableDictionary* dic in user_Arr) {
        if ([name isEqualToString:[dic objectForKey:@"name"]]) {
            int userType = [[dic objectForKey:@"userType"] intValue] ;
            return userType;
        }
    }
    return 0;
}


//添加用户信息
-(void)AddOBjectAtName:(NSString*)name PassWord:(NSString*)password UserType:(NSInteger)usertype{
    //解析成功保存到本地
    [self removeOBjectAtName:name];//先删除原来可能有的
    NSMutableDictionary* user = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":name,
                                                                                  @"pass":password,
                                                                                  @"userType":@(usertype)}];
    
    NSMutableDictionary* userinfo = [self readUserInfo];
    NSMutableArray* user_arr = [userinfo objectForKey:@"用户数组"];
    [user_arr insertObject:user atIndex:0];
    [self writeUserInfo:userinfo];
}



// 删除用户信息  按照名字
-(void)removeOBjectAtName:(NSString*)name{
    NSMutableDictionary* userinfo = [self readUserInfo];
    NSMutableArray* user_arr = [userinfo objectForKey:@"用户数组"];
    for (NSMutableDictionary* dic in user_arr) {
        if ([name isEqualToString:[dic objectForKey:@"name"]]) {
            [user_arr removeObject:dic];
            [self writeUserInfo:userinfo];
            return;//ios并不是真的判断条件循环，防止溢出
        }
    }
}



//得到完整的文件名
-(NSString*)getPath{
    //检查路径(本可以放到readUserInfo，因为读去用户信息会用到很多次，故在这里检查。)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *path=[plistPath1 stringByAppendingPathComponent:Duole_IOSSDK_userinfo_PATH];
    
    return path;
}



//初始化用户信息（只有安装后的第一次进入）
-(void)InitUserInfo{
    //得到完整的文件名
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *plistPath1 = [paths objectAtIndex:0];
    //创建文件夹
    NSString *path2=[plistPath1 stringByAppendingPathComponent:Duole_IOSSDK_Catalog];
    BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:path2 withIntermediateDirectories:YES attributes:nil error:nil];
    if (!bo) NSLog(@"文件夹创建失败！");
    
    
    //看看钥匙串里有没有补充的。
//    NSMutableArray* user_arr = [self readUserInfo_keychain];
    NSMutableArray* user_arr = [[NSMutableArray alloc] init];
    //读取以前小精灵中可能存在的账号密码
    [user_arr addObjectsFromArray:[self readUserInfo_oldSDK]];
    
    //初始化数据
    NSMutableDictionary* userinfo = [[NSMutableDictionary alloc] init];
    [userinfo setObject:user_arr forKey:@"用户数组"];
    [self writeUserInfo:userinfo];
}







//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝读＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

-(NSString*)getText:(NSString*)key{
    if (Text_Dic == nil) {
       
        Text_Dic = [[self GetduoleIosLoginInfo] objectForKey:@"text"];
    }
    
    return  [Text_Dic objectForKey:key];
}

//读取用户信息
-(NSMutableDictionary*)readUserInfo{
    
    NSMutableDictionary* duole_UserInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:[self getPath]];
    return duole_UserInfo;
}



//从钥匙串中读取用户名和密码
-(NSMutableArray*)readUserInfo_keychain{
  
    //读取钥匙串中的信息
    KeychainItemWrapper *keychain=[[KeychainItemWrapper alloc] initWithIdentifier:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"] accessGroup:nil];// 自定义
    NSString* NAME = [keychain objectForKey:(id)kSecAttrAccount];
    NSString* PASS = [keychain objectForKey:(id)kSecValueData];
    
    if(NAME.length==0)return [[NSMutableArray alloc] init];
    //分解
    NSArray* name_arr = [NAME componentsSeparatedByString:@"*"];
    NSArray* pass_arr = [PASS componentsSeparatedByString:@"*"];
    
    NSMutableArray* user_arr = [[NSMutableArray alloc] init];
    //防止数据读取错误
    if (name_arr.count != pass_arr.count) {
        NSLog(@"keychain里的数据不对啊！");
        return user_arr;
    }
    
    //写入本地
    for (int i = 0; i < name_arr.count; i++) {
        NSMutableDictionary* user;
        NSString* name = name_arr[i];
        NSString* pass = pass_arr[i];
        if (pass.length == 0) {
            //临时账号
            user = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":name,
                                                                     @"pass":@"",
                                                                     @"userType":@1}];
        }else{
            //正常账号
            user = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":name,
                                                                     @"pass":pass,
                                                                     @"userType":@0}];
        }
        [user_arr addObject:user];
    }
    
    return user_arr;
}


// 读取以前小精灵中可能存在的账号密码
-(NSMutableArray*)readUserInfo_oldSDK{
    
    NSMutableArray* user_arr = [[NSMutableArray alloc] init];
    //获取文件路径
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString* path = NSHomeDirectory();
    path = [path stringByAppendingString:@"/Library/Preferences/"];
    path = [path stringByAppendingString:identifier];
    path = [path stringByAppendingString:@".plist"];
    //开始读取文件信息
    NSMutableDictionary* dic =  [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    int userSum = [[dic objectForKey:@"userSum"] intValue];
    
    for (int i = 0; i < userSum; i++)
    {
        NSString* name = [[NSString alloc] initWithFormat:@"user%d",i];
        NSString* mima = [[NSString alloc] initWithFormat:@"mima%d",i];
        //帐号
        name = [dic objectForKey:name];
        NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:name options:0];
        name = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        //密码
        mima = [dic objectForKey:mima];
        nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:mima options:0];
        mima = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
        //判断类型
        NSMutableDictionary* user;
        [self removeOBjectAtName:name];//先删除原来可能有的
        if([name rangeOfString:@"duole@"].location != NSNotFound){
            user = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":name,
                                                                     @"pass":@"",
                                                                     @"userType":@1}];
        }else{
            user = [[NSMutableDictionary alloc] initWithDictionary:@{@"name":name,
                                                                     @"pass":mima,
                                                                     @"userType":@0}];
        }
        
        [user_arr addObject:user];
    }
    
    return user_arr;
}


//读取配置文件
-(NSMutableDictionary*)GetduoleIosLoginInfo{
    NSString* bundle =[[NSBundle mainBundle] pathForResource:@"duole_ios_login" ofType:@"bundle"];
    NSString* path = [bundle stringByAppendingPathComponent:@"duole_ios_login.plist"];
    return [[NSMutableDictionary alloc] initWithContentsOfFile:path];
}


//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝写＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

// 写入用户信息
-(void)writeUserInfo:(NSMutableDictionary*)userifno{
    BOOL bl = [userifno writeToFile:[self getPath] atomically:YES];
    if (bl == NO) NSLog(@"文件写入失败");
    //把用户信息写入keychain
//    [self writeUserInfo_keychain];
}



//  把用户信息写入keychain
-(void)writeUserInfo_keychain{

    NSMutableDictionary* duole_UserInfo = [self readUserInfo];
    //合成用户名和密码
    NSMutableArray* user_arr = [duole_UserInfo objectForKey:@"用户数组"];
    NSMutableArray* name_arr = [[NSMutableArray alloc] init];
    NSMutableArray* pass_arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < user_arr.count; i++) {
        [name_arr addObject:[user_arr[i] objectForKey:@"name"]];
        [pass_arr addObject:[user_arr[i] objectForKey:@"pass"]];
    }
    
    NSString* NAME = [name_arr componentsJoinedByString:@"*"];
    NSString* PASS = [pass_arr componentsJoinedByString:@"*"];
    
    //写入钥匙串
    KeychainItemWrapper *keychain=[[KeychainItemWrapper alloc] initWithIdentifier:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"] accessGroup:nil];// 自定义
    
    [keychain setObject:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"] forKey:(id)kSecAttrService];
    [keychain setObject:NAME forKey:(id)kSecAttrAccount];
    [keychain setObject:PASS forKey:(id)kSecValueData];
 
    
    
}



@end
