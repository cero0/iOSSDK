//
//  loginFileReadWrite.h
//  duoleIosSDK
//
//  Created by cxh on 16/7/26.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface loginFileReadWrite : NSObject

+(instancetype)share;

//判断登录状态
-(NSInteger)GetInitMode;

//获取文字映射表（防止以后有英语繁体需求之类的）
-(NSString*)getText:(NSString*)key;


//读取用户信息
-(NSMutableDictionary*)readUserInfo;

// 根据用户名获取用户类型 0(正常账号) 1(临时账号)
-(NSInteger)GetUserType:(NSString*)name;

//读取配置文件
-(NSMutableDictionary*)GetduoleIosLoginInfo;

//添加用户信息
-(void)AddOBjectAtName:(NSString*)name PassWord:(NSString*)password UserType:(NSInteger)usertype;

// 删除用户信息  按照名字
-(void)removeOBjectAtName:(NSString*)name;



@end
