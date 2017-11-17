//
//  moreFunctionFileRW.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/1.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "moreFunctionFileRW.h"

@implementation moreFunctionFileRW
+(instancetype)share{
    return [[moreFunctionFileRW alloc] init];
}

//删除更新文件（其实是把除了duoleIosSdk文件夹的所有本地文件删除)
-(void)removeUpdateFile{
    //需要排除的文件夹名  或者文件名
    NSArray* arr = @[@"duoleIosSdk"];
    
    //获取子文件
    NSArray * PathArr = [self BianLiPathList:NSHomeDirectory() FileNamePanDuan:^BOOL(NSString *str) {
        return  [arr indexOfObject:str] == NSNotFound;
    }];
    
    NSLog(@"%@",PathArr);
    NSFileManager * fm = [NSFileManager defaultManager];
    [PathArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSError* error;
        [fm removeItemAtPath:obj error:&error];
        if(error) NSLog(@"%@",[error localizedDescription]);
    }];
}

-(NSMutableArray *)BianLiPathList:(NSString*)path FileNamePanDuan:(BOOL (^)(NSString *str))panduan{
    NSMutableArray* PathList = [[NSMutableArray alloc] init] ;
    //获取子文件
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray * array = [fm contentsOfDirectoryAtPath:path error:nil];
    //    NSLog(@"%@",array);
    
    for(NSString *str in array){
        NSLog(@"%@",str);
        //排除文件
        if(panduan){
            if (!panduan(str)) {
                continue;
            }
        }
        
        //字符串文件名预处理
        NSString *pathin = [[NSString alloc] initWithFormat:@"%@/%@",path,str];
        
        BOOL isDir;
        if ([fm fileExistsAtPath:pathin isDirectory:&isDir] && isDir) {
            //            NSLog(@"%@ is a directory", pathin);
            [PathList addObjectsFromArray:[self BianLiPathList:pathin FileNamePanDuan:panduan]];
        }
        else {
            //            NSLog (@"%@ is a file", pathin);
            [PathList addObject:pathin];
        }
    }
    
    return PathList;
}

@end
