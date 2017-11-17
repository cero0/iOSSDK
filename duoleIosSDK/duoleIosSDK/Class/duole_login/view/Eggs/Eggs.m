//
//  Eggs.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/17.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "Eggs.h"

@implementation Eggs
+(void)xunMing:(UIView*)MainView{
    
    if (arc4random()%3 != 1) return;
    
    for (int i = 0; i < 4; i++) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(230, 270, 20, 7)];
        label.text = @"+1s";
        label.font = [UIFont systemFontOfSize:7];
        label.textColor = [UIColor blackColor];
        [MainView addSubview:label];
        
        [UIView animateWithDuration:2 delay:i*0.5 options:UIViewAnimationOptionRepeat animations:^{
            label.frame = CGRectMake(230, 240, 20, 5);
            label.alpha = 0;
        } completion:nil];
    }

}
@end
