//
//  ViewController.m
//  duoleIosSdkTestDemo
//
//  Created by cxh on 16/7/26.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "ViewController.h"
#import <duoleIOSSDK/duoleIOSSDK.h>
#import "IPCome.h"

UIWindow * overWin;
UIViewController *loginVC;
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.view.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:_btn1];
    [self.view addSubview:_btn2];
    

}



- (IBAction)login:(id)sender {
//    [[duole_iap share] downloadPayType];
//    [duoleLoginVC showWithMode:FJFATELogin success:^(NSDictionary *dic) {
//            NSLog(@"%@",dic);
//    }];
    IPCome *lunplay = [[IPCome alloc] init];
    loginVC = [lunplay addLoginView];
    [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:loginVC];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:loginVC.view];
    
//    IPCome *lunplay = [[IPCome alloc] init];
    if (overWin == nil) {
        [overWin removeFromSuperview];
        overWin = [lunplay setNewWithFrame:CGRectMake(0, 70, 60, 60)];
    }
    [lunplay xuanFuKangSeverCode:[NSString stringWithFormat:@"ylwzth%d",1001]
                          roleid:@"1"
                          glevel:[NSString stringWithFormat:@"%i",1]];
    if (overWin != nil) {
        //        [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:overWin.rootViewController];
        //        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:overWin];
        [[[[UIApplication sharedApplication] delegate] window] addSubview:overWin];
    }


    
}


- (IBAction)pay:(id)sender {
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString* timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    NSLog(@"timeString=%@",timeString);

//    [[duole_iap share] webPay];
    
//    int type = [[duole_iap share] getPayType];
//    
//    NSLog(@"%i",type);
//    if (type==1) {
//        [[duole_iap share] InitUserInfo:@{@"server_id":@"1",
//                                          @"pf":@"104",
//                                          @"uid":@"duole011",
//                                          @"key1":@"duole#fate",
//                                          @"product_id":@"3"}];
//        [[duole_iap share] PayStart:@"3" Data:@{} success:^(NSDictionary *dic) {
//            
//        } fail:^(NSDictionary *dic) {
//            
//        }];
//    }else {
//        return;
//    }
//    [[FJThirdPay share] InitUserInfo:@{@"roleName":@"test02",
//                                       @"serverId":@"1",
//                                       @"roleId":@"8029001",
//                                       @"product_id":@"3",
//                                       @"productId":@"com.sbzz.product10009",
//                                       @"money":@"648"}];
//    
//    
//    
//    [[FJThirdPay share] PayStart:@"3" Data:@{} success:^(NSDictionary *dic) {
//        NSLog(@"success");
//    } fail:^(NSDictionary *dic) {
//        
//    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
