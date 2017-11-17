//
//  moreFunctionFileRW.h
//  duoleIosSDK
//
//  Created by cxh on 16/8/1.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface moreFunctionFileRW : NSObject

+(instancetype)share;

//删除更新文件（其实是把除了duoleIosSdk文件夹的所有本地文件删除)
-(void)removeUpdateFile;

@end
