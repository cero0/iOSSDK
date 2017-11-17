//
//  CAIanimations.m
//  视频播放实验
//
//  Created by duole on 15/12/18.
//  Copyright © 2015年 cai. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CAIanimations.h"

#define isIos7System [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0
static UIView* loading_View;
//88888888888888888888888888888888888888888888888888888888888888888888888888
//自定义的一种特殊形状的uiview子类，用来规划闪光形状
//88888888888888888888888888888888888888888888888888888888888888888888888888
@interface myView : UIView

@end

@implementation myView
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    float offset = 1.5;
    float my = rect.size.height/2.0;
    float mx = rect.size.width/2.0;
    UIBezierPath* aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(mx-2*offset, my-offset, 4*offset, 2*offset)];
    [aPath moveToPoint:CGPointMake(0, my)];
    [aPath addLineToPoint:CGPointMake(mx, my-offset)];
    [aPath addLineToPoint:CGPointMake(2*mx, my)];
    [aPath addLineToPoint:CGPointMake(mx, my+offset)];
    [aPath closePath];
    

    
    [[UIColor whiteColor] setFill];
    [aPath fill];
   
}
@end
//88888888888888888888888888888888888888888888888888888888888888888888888888
//88888888888888888888888888888888888888888888888888888888888888888888888888


@implementation CAIanimations

//88888888888888888888888888888888888888888888888888888888888888888888888888
//88888888888888888888888888888888888888888888888888888888888888888888888888
+(void)animateOut:(UIView *)theView BgRect:(CGRect)rect
{
 

    [UIView animateWithDuration:0.5 animations:^{
        //0.5 变小宽度
        theView.transform = CGAffineTransformMakeScale(1, 0.005);
        
    } completion:^(BOOL finished){
        //显示闪光视图
        myView *view = [[myView alloc]initWithFrame:rect];
        view.backgroundColor = [UIColor clearColor];
        view.center = theView.center;
        [[theView superview] addSubview:view];
        
        //原视图变0。闪光视图变窄
        [UIView animateWithDuration:0.31 animations:^{
            theView.transform = CGAffineTransformMakeScale(0, 0);

            view.transform = CGAffineTransformMakeScale(1, 0.0000001);
        } completion:^(BOOL finished) {
        //移除

                [view removeFromSuperview];
                [theView removeFromSuperview];
        }];
    }];
}
//88888888888888888888888888888888888888888888888888888888888888888888888888
//88888888888888888888888888888888888888888888888888888888888888888888888888

+(void)ShakeAnimate:(UIView *)theView{
    // 获取到当前的View
    
    CALayer *viewLayer = theView.layer;
    
    // 获取当前View的位置
    
    CGPoint position = viewLayer.position;
    
    // 移动的两个终点位置
    
    CGPoint x = CGPointMake(position.x + 5, position.y);
    
    CGPoint y = CGPointMake(position.x - 5, position.y);
    
    // 设置动画
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    
    // 设置运动形式
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    // 设置开始位置
    
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    
    // 设置结束位置
    
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    
    // 设置自动反转
    
    [animation setAutoreverses:YES];
    
    // 设置时间
    
    [animation setDuration:.03];
    
    // 设置次数
    
    [animation setRepeatCount:3];
    
    // 添加上动画
    
    [viewLayer addAnimation:animation forKey:nil];
    
    
}

//88888888888888888888888888888888888888888888888888888888888888888888888888
//88888888888888888888888888888888888888888888888888888888888888888888888888

+(void)ShowLoading{
    if (loading_View) {
        return;
    }
    
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    loading_View =  [[UIView alloc]init];
    //    showview.backgroundColor = [UIColor whiteColor];
    loading_View.frame = [[UIScreen mainScreen] bounds];
    loading_View.alpha = 1.0f;
    loading_View.layer.cornerRadius = 5.0f;
    loading_View.layer.masksToBounds = YES;
    [window addSubview:loading_View];
    //初始化:
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    //设置显示样式,见UIActivityIndicatorViewStyle的定义
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    //设置背景色
    indicator.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.8];
    //设置背景为圆角矩形
    indicator.layer.cornerRadius = 6;
    indicator.layer.masksToBounds = YES;
    //设置显示位置
    [indicator setCenter:loading_View.center];
    
    //开始显示Loading动画
    [indicator startAnimating];
    UILabel *loadLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 70, 90, 30)];
    [loadLabel setTextColor:[UIColor whiteColor]];
    loadLabel.textAlignment = NSTextAlignmentCenter;
    loadLabel.text = @"loading...";
    [indicator addSubview:loadLabel];
    [loading_View addSubview:indicator];

}

+(void)StopLoading{
    if (loading_View) {
        [loading_View removeFromSuperview];
        loading_View = nil;
    }
    
}

//88888888888888888888888888888888888888888888888888888888888888888888888888
//88888888888888888888888888888888888888888888888888888888888888888888888888
@end
