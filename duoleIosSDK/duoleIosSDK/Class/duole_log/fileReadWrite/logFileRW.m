//
//  iapLogFileRW.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/5.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "logFileRW.h"
#import "Macro.h"

#define MAX_LOG 2000//最大记录数量

@implementation logFileRW
+(instancetype)share{
    return [[logFileRW alloc] init];
}

-(instancetype)init{
    self = [super init];
    if (self) {
    
    }
    return self;
}
//日志存储路径
-(NSString*)getSavePath{
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    plistPath = [plistPath stringByAppendingPathComponent:Duole_IOSSDK_log_PATH];
    
    return plistPath;
}
/**
 *   读取日志
 */
-(NSMutableArray*)ReadLog{
    NSMutableArray* arr = [NSMutableArray arrayWithContentsOfFile:[self getSavePath]];
    //路径检查
    if (arr==nil) {
        arr = [[NSMutableArray alloc] init];
        //创建文件夹
        NSString* CatalogPath = [[self getSavePath] stringByDeletingLastPathComponent];
        [[NSFileManager defaultManager] createDirectoryAtPath:CatalogPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return arr;
}
/**
 *  写日志
 *
 *  @param log 日志内容
 */
-(void)WriteLog:(NSString*)log{
    //获取时间
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY.MM.dd-HH:mm:ss "];
    NSString* timeStr = [dateformatter stringFromDate:senddate];
    log = [timeStr stringByAppendingString:log];
    
    
    NSMutableArray* arr = [self ReadLog];
    //删除多余的的纪录防止记录太多
    if (arr.count>=MAX_LOG) {
         [arr removeObjectsInRange:NSMakeRange(0, arr.count - MAX_LOG)];
    }
    [arr addObject:log];
    NSLog(@"%@",log);
    
    [arr writeToFile:[self getSavePath] atomically:YES];
}
@end
