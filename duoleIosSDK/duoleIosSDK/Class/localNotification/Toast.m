//
//  Toast.m
//  单例模式
//
//  Created by wjcao on 15/10/14.
//  Copyright (c) 2015年 lanqiao. All rights reserved.
//

#import "Toast.h"

static Toast *single;
@implementation Toast

+(Toast *)shareToast
{
    @synchronized(self){
        if (single==nil) {
            single = [[Toast alloc] init];
        }
    }
    return single;
}
-(void)makeText:(NSString *)textContent duration:(int)duration{
    UIFont *font = [UIFont systemFontOfSize:16];
    CGRect rect = [textContent boundingRectWithSize:CGSizeMake(280, 150) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width+20, rect.size.height+20)];
    [bgView setBackgroundColor:[UIColor blackColor]];
    bgView.alpha = 0.8f;
    bgView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    bgView.layer.cornerRadius = 5;
    bgView.layer.masksToBounds = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    UILabel *lbMsg = [[UILabel alloc] initWithFrame:rect];
    lbMsg.text = textContent;
    lbMsg.font = font;
    lbMsg.numberOfLines = 0;
    [lbMsg setTextColor:[UIColor whiteColor]];
    lbMsg.textAlignment = NSTextAlignmentCenter;
    lbMsg.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
    [[UIApplication sharedApplication].keyWindow addSubview:lbMsg];
    
    NSDictionary *dic = @{@"view":bgView,@"label":lbMsg};
    [self performSelector:@selector(hide:) withObject:dic afterDelay:duration];
    
}
-(void)hide:(NSDictionary *)dic{
    UIView *view = [dic objectForKey:@"view"];
    UILabel *label = [dic objectForKey:@"label"];
    
    [view removeFromSuperview];
    [label removeFromSuperview];
}







@end
