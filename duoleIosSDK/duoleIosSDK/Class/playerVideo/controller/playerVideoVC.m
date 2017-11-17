//
//  playerVideoVC.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/17.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "playerVideoVC.h"
#import <AVFoundation/AVFoundation.h>
#import "CusNavViewController.h"
#define isIos7System [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0

playerVideoVC* playVideo;

@interface playerVideoVC()
@property(nonatomic,strong) NSString* path;
@property(nonatomic,assign) BOOL isFisttPlay;
@property(nonatomic,strong) AVPlayer *player;
@end

@implementation playerVideoVC{

}

+(void)playVideo:(NSString*)path{
    if (playVideo == NULL) {
        //强制横屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeLeft] forKey:@"orientation"];
        
        playVideo = [[playerVideoVC alloc] initWithPath:path];
        
        UIViewController* rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        rootVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootVC presentViewController:playVideo animated:YES completion:^{}];
    }
}

-(instancetype)initWithPath:(NSString*)path{
    self = [super init];
    if (self) {
        _path = path;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
        _isFisttPlay = ![[NSUserDefaults standardUserDefaults] boolForKey:@"duolePlayVideo"];
        if (_isFisttPlay == YES) {
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"duolePlayVideo"];
        }
    }
    return self;
}


- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma UIViewControllerDelegate

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewDidDisappear {
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL* url = [NSURL fileURLWithPath:_path];
    _player = [[AVPlayer alloc] initWithURL:url];

    [self LayoutIOS7];
    AVPlayerLayer* playerLaye = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLaye.frame = self.view.bounds;
    [self.view.layer addSublayer:playerLaye];
    [self.view.layer setNeedsLayout];
    [_player play];
    [_player setRate:1];//播放速度

    //播放完成通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    

    //监听旋转
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];


    
    

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Layout IOS7
-(void)LayoutIOS7{
    //得到系统版本号
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    //如果系统版本号小于8.0f，即是7.X或以下,且还是横屏
    if(version<8.0f&&(self.interfaceOrientation==UIDeviceOrientationLandscapeRight||self.interfaceOrientation==UIDeviceOrientationLandscapeLeft)){
        //那么要得到的宽高要反过来
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        [self.view layoutSubviews];
        [self.view layoutIfNeeded];
    }
}
//屏幕旋转
//- (void)statusBarOrientationChange:(NSNotification *)notification
//{
//    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
//    if(orientation == UIInterfaceOrientationPortrait||orientation == UIInterfaceOrientationPortraitUpsideDown){
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
//    }
//    
//}

//屏幕方向
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


#pragma action
//点击事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_isFisttPlay == NO) {
       [self back];
    }
}


-(void)playEnd{
    NSLog(@"播放完成");
   [self back];
}

#pragma back
-(void)back{
    playVideo = nil;
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
