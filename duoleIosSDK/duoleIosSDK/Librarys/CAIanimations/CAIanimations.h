//
//  CAIanimations.h
//  视频播放实验
//
//  Created by duole on 15/12/18.
//  Copyright © 2015年 cai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAIanimations : NSObject
/**
 *  仿电视关机动画（不太像）
 *
 *  @param theView 要移除的视图
 *  @param rect    动画的大小
 */
+(void)animateOut:(UIView *)theView BgRect:(CGRect)rect;


/**
 *  抖动视图
 *  @param theView 要抖动的uiview
 */
+(void)ShakeAnimate:(UIView *)theView;
/**
 *  播放loading动画
 */
+(void)ShowLoading;

/**
 *  关闭loading动画
 */
+(void)StopLoading;

@end
