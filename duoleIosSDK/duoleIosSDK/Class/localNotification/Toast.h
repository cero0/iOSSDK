//
//  Toast.h
//  单例模式
//
//  Created by wjcao on 15/10/14.
//  Copyright (c) 2015年 lanqiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Toast : NSObject

+(Toast *)shareToast;
-(void)makeText:(NSString *)textContent duration:(int)duration;



@end
