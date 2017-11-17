//
//  localNotification.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/2.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "localNotification.h"
#import "Macro.h"

#import <UIKit/UIKit.h>
@implementation localNotification

+(void)start{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if([[localNotification share] isFisrtStart] == NO){return;}
    
    [[localNotification share] updateLocalNotification];
}

+(instancetype)share{
    return [[localNotification alloc] init];
}


/**
 *  lua -> oc 设置推送开关(fate老接口)
 */
+(void)setPush:(NSDictionary*)dic{
    [[localNotification share] setPush:dic];
}


-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}







//更新本地通知
-(void)updateLocalNotification{
    // ios8后，需要添加这个注册，才能得到授权
    if ([[UIDevice currentDevice].systemVersion doubleValue]>=8.0) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    //取消所有的本地推送
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //添加通知
    [[self GetNotificationArr] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //检查是否通知
        if([[obj objectForKey:@"on-off"] intValue]== 1){
            //创建本地推送
            UILocalNotification *noti = [[UILocalNotification alloc] init];
            if (noti) {
                
                //合成时间
                NSString *currentDateString =  [@"1995-11-22 " stringByAppendingString:[obj objectForKey:@"time"]];
                NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                [dateFormater setDateFormat:@"yyyy-MM-DD HH:mm"];
                
                NSDate *date = [dateFormater dateFromString:currentDateString];
                //设置推送时间
                noti.fireDate = date;
                //设置时区（为系统时区）［defaultTimeZone 默认时区］
                noti.timeZone = [NSTimeZone systemTimeZone];
                // noti.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:GMT];
                //设置重复间隔
                noti.repeatInterval = kCFCalendarUnitDay;
                //推送声音
                noti.soundName = UILocalNotificationDefaultSoundName;
                //内容
                noti.alertBody = [obj objectForKey:@"title"];
                NSLog(@"添加推送：%@",noti.alertBody);
                //显示在icon上的红色圈中的数子
                noti.applicationIconBadgeNumber += 1;
                // 执行通知注册
                [[UIApplication sharedApplication] scheduleLocalNotification:noti];
                
            }
        
        }
    }];
}

//返回路径
-(NSString*)getPath{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:Duole_IOSSDK_localNotification_PATH];
    
    return plistPath;
}
//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝写＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

//判断是否是第一次进入
-(BOOL)isFisrtStart{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: [self getPath] ] == NO){
        //第一次进入
        NSLog(@"文件不存在!第一次进入开始创建本地通知文件......");
        //创建文件夹
        NSString* CatalogPath = [[self getPath] stringByDeletingLastPathComponent];
        BOOL bo = [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (bo){
            //把初始数据复制到Document下
            NSString* path = [[NSBundle mainBundle] pathForResource:@"localNotification" ofType:@"plist"];
            NSMutableArray* Data = [NSMutableArray arrayWithContentsOfFile:path];
            [Data writeToFile:[self getPath] atomically:YES];
        } else{
            NSLog(@"文件夹创建失败！");
        }
        return YES;
    }
    return NO;
}

//Fate设置通知开关接口
-(void)setPush:(NSDictionary *)dic{

    NSMutableArray* PushArr = [self GetNotificationArr];    
    //解析数据
    NSString* time = [[NSString alloc] init];
    time = @"1";
    if ([[dic objectForKey:@"type"] isEqualToString:@"lunch"]) {
        time = @"12:00";
    }else if([[dic objectForKey:@"type"] isEqualToString:@"super"]){
        time = @"18:00";
    }
    
    BOOL onoff = YES;
    if ([[dic objectForKey:@"isPush"] intValue] == 0) {
        onoff = NO;
    }
    //    NSLog(@"%@",time);
    NSDictionary *Newdic;
    NSDictionary *olddic;
    //处理数据
    for(NSDictionary* dic2 in PushArr){
        if ([time isEqualToString:[dic2 objectForKey:@"time"]])
        {
            Newdic = @{@"time":time,@"title":[dic2 objectForKey:@"title"],@"on-off":@(onoff)};
            olddic = dic2;
        }
    }
    //写入数据
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"推送.plist"];
    
    [PushArr writeToFile:filename atomically:YES];
    //更新通知
    [self updateLocalNotification];
}


//＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝读＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
//返回需要推送的文本
-(NSMutableArray*)GetNotificationArr{
    //检查数据是否正确
    NSArray* Arr = [[NSArray alloc] initWithContentsOfFile:[self getPath]];
    
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for(NSDictionary* dic in Arr){
        //检查时间
        NSString* time = [dic objectForKey:@"time"];
        if (time.length == 5)/*判断长度*/ {
            NSString* hourStr = [time substringToIndex:2];
            NSString* str = [time substringWithRange:NSMakeRange(2, 1)];
            NSString* minStr = [time substringFromIndex:3];
            NSInteger hourInt = [hourStr intValue];
            NSInteger minInt = [minStr intValue];
            if (hourInt<0||hourInt>24    ||    [str isEqualToString:@":"]==NO    ||    minInt<0||minInt>60 )
            {
                NSLog(@"%@书写不合法",time);
                continue;
            }
        }else{
            NSLog(@"%@长度不对",time);
            continue;
        }
        //检查内容
        NSString* title = [dic objectForKey:@"title"];
        if (title.length == 0) {
            NSLog(@"内容为空");continue;
        }
        
        [arr addObject:dic];
    }
    
    return arr;
}
@end
