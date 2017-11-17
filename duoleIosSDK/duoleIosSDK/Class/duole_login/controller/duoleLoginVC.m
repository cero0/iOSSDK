//
//  duoleLoginVC.m
//  duole_ios_sdk
//
//  Created by cxh on 16/7/25.
//  Copyright © 2016年 cxh. All rights reserved.
//

#import "duoleLoginVC.h"
#import "loginFileReadWrite.h"
#import "Macro.h"
#import "UIComboBox.h"
//#import "Masonry.h"
#import <CoreMotion/CoreMotion.h>
#import "CAIanimations.h"
#import "loginRequest.h"
#import "JCAlertView.h"
#import "MBProgressHUD.h"

#import "moreFunctionVC.h"
#import "Eggs.h"

#define isIos7System [[[UIDevice currentDevice] systemVersion] floatValue] <= 7.0
duoleLoginVC* duoleIosSDKloginVC;

static NSString *const fontName = @"duole_ios_login.bundle/Marker Felt.ttf";

@interface duoleLoginVC()<UIComBoBoxDelegate,duoleLoginRequestDelegate,UITextFieldDelegate>
@property(nonatomic,copy) void(^loginSuccessBlock)(NSDictionary* dic);
@end

@implementation duoleLoginVC{
    CMMotionManager *motionManager;
    loginFileReadWrite *_loginFileData;
    loginRequest *_loginRequest;
    NSString* userName;//如果有帐号，当前的帐号名
    
    NSInteger SecondMainViewSubviewType;//第二主视图的
    UIImageView* bgimageView;
    UIButton* moreFunction_btn;
    
    UIView* mainViewBg;
    UIView* MainView;//主视图（刚显示时的）
    UIView* SecondMainView;//二级视图处理一些输入逻辑
    UIComboBox* box;

    NSMutableArray<UITextField*>* TF_arr;//文本输入框数组
    MBProgressHUD *hud;//load....
}

+(void)showWithMode:(LoginMode)mode success:(void(^)(NSDictionary* dic))block{
    NSLog(@"登陆2.0  1.0.0");
    if (duoleIosSDKloginVC == NULL) {
        duoleIosSDKloginVC = [[duoleLoginVC alloc] initWithMode:mode];
        duoleIosSDKloginVC.loginSuccessBlock = block;
        
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:duoleIosSDKloginVC];
        nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        UIViewController* rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        rootVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootVC presentViewController:nav animated:YES completion:^{}];
    }
}

-(instancetype)initWithMode:(LoginMode)mode{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        _loginFileData = [loginFileReadWrite share];
        _loginRequest = [[loginRequest alloc] initWithLoginMode:mode];
        _loginRequest.delegate = self;
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
    if (bgimageView.image) {
        [UIView animateWithDuration:2.0 animations:^{
            bgimageView.bounds = CGRectMake(0, 0, self.view.frame.size.width*1.2, self.view.frame.size.height*1.2);
            bgimageView.center = self.view.center;
            [bgimageView.superview layoutIfNeeded];
        }];
    }
}

- (void)viewDidLoad {
 
    [super viewDidLoad];
    
    [self LayoutIOS7];
    [self loadSubviews];
    

    [self loadSecondMainView];

    [self loadMainView];
    [self loadMainViewSubviews];
    
    [self loadActions];
    
    //+1s
    [Eggs xunMing:MainView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma action--
-(void)loadActions{
    if (bgimageView.image) {
       [self addPerspectiveBackground];
    }
    __block UIButton* blokbtn = moreFunction_btn;
    box.zuanQuan = ^(NSInteger i){
        if (i==10) {
            blokbtn.alpha = 1;
            blokbtn.enabled = YES;
        }
    };


    //使用NSNotificationCenter 键盘出现时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    //使用NSNotificationCenter 键盘隐藏时
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}



//退出
-(void)back{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [CAIanimations animateOut:mainViewBg BgRect:mainViewBg.bounds];
    
    [UIView animateWithDuration:2.0 animations:^{
        if(bgimageView.image){
//            [bgimageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(self.view);
//                make.center.equalTo(self.view);
//            }];
            bgimageView.frame = self.view.frame;
            bgimageView.center = self.view.center;
            [bgimageView.superview layoutIfNeeded];
        }
         self.view.backgroundColor = ColorRGBA(0, 0, 0, 0);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
        duoleIosSDKloginVC = nil;
        [motionManager stopGyroUpdates];
    }];
    

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
-(void)goSecondMainView{

    SecondMainView.alpha = 0.95;
    MainView.alpha = 0.01;
    NSInteger num1 = [[mainViewBg subviews] indexOfObject:SecondMainView];
    NSInteger num2 = [[mainViewBg subviews] indexOfObject:MainView];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [mainViewBg exchangeSubviewAtIndex:num2 withSubviewAtIndex:num1];
    [UIView setAnimationTransition:[self getAnimtionTransition]  forView:mainViewBg cache:YES];
    [UIView commitAnimations];
    
}
-(UIViewAnimationTransition)getAnimtionTransition{
    
    switch (arc4random()%2) {
        case 0:return UIViewAnimationTransitionFlipFromLeft;break;
        case 1:return UIViewAnimationTransitionFlipFromRight;break;
        default:return UIViewAnimationTransitionFlipFromRight;break;
            break;
    }
    return UIViewAnimationTransitionFlipFromRight;
}
//增加透视背景
-(void)addPerspectiveBackground{
    motionManager = [[CMMotionManager alloc]init];
    motionManager.gyroUpdateInterval = 1.0/10.0;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    motionManager.accelerometerUpdateInterval = 0.2; // 告诉manager，更新频率是10Hz
    [motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData,NSError *error){
        NSString *labelText;
        if (error) {
            [motionManager stopGyroUpdates];
            labelText = [NSString stringWithFormat:@"Gyroscope encountered error: %@",error];
        }else{
           
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CGPoint point = bgimageView.center;
            point =  CGPointMake(point.x-(gyroData.rotationRate.x)*2, point.y-(gyroData.rotationRate.y)*2);
            if(fabs(point.x-SSize.width*0.5)<SSize.width*0.1&&fabs(point.y-SSize.height*0.5)<SSize.height*0.1){
                [UIView animateWithDuration:0.2 animations:^{
                    bgimageView.center = point;
                    [bgimageView.superview layoutIfNeeded];
                }];
            }
            //NSLog(@"x:%f,y:%f",point.x,point.y);
        });
    }];
}



#pragma mark - btnAction

//更多功能
-(void)moreFunction{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"pageUnCurl";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    moreFunctionVC* vc =[[moreFunctionVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//退出第二界面
-(void)backSecondMainView{
    //取消第一相应者
    [SecondMainView endEditing:YES];
    
    SecondMainView.alpha = 0.01;
    MainView.alpha = 0.95;
    NSInteger num1 = [[mainViewBg subviews] indexOfObject:SecondMainView];
    NSInteger num2 = [[mainViewBg subviews] indexOfObject:MainView];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [mainViewBg exchangeSubviewAtIndex:num1 withSubviewAtIndex:num2];
//    [mainViewBg mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//        make.size.mas_equalTo(CGSizeMake(250, 280));
//    }];
    mainViewBg.bounds = CGRectMake(0, 0, 250, 280);
    mainViewBg.center = self.view.center;
    
    [mainViewBg.superview layoutIfNeeded];
    [UIView setAnimationTransition:[self getAnimtionTransition]  forView:mainViewBg cache:YES];
    [UIView commitAnimations];
}


//快速登录
-(void)FastLogin{
//    [self ShowHub];
    [_loginRequest QuickLogin];
}
//有密码直接登陆
-(void)DirectLogin{
    [self ShowHub];
    [_loginRequest Login:userName Password:@"" isNewAccount:NO];
}



//进入登陆界面
-(void)goLoginView{
    [self loadSecondMainViewSubviews:1];
    [self goSecondMainView];
}
//进入注册或绑定界面（因为无法事先判断用户选择的是不是临时账号）
-(void)goRegisterOrboundView{
    if ([_loginFileData GetUserType:userName] == 0) {
        [self loadSecondMainViewSubviews:2];
    }else{
        [self loadSecondMainViewSubviews:3];
    }
   
    [self goSecondMainView];
}

//进入修改密码界面
-(void)goChangePasswordView{
    [self loadSecondMainViewSubviews:4];
    [self goSecondMainView];
}




//帐号密码登陆
-(void)Login{
    if ([self nullTf]==NO) {
        [self ShowHub];
        [_loginRequest Login:TF_arr[0].text Password:TF_arr[1].text isNewAccount:NO];
    }
}
//注册
-(void)Register{
    if([self RegisterErrorTF]==NO&&[self nullTf]==NO){
        [self ShowHub];
        [_loginRequest Register:TF_arr[0].text Password:TF_arr[1].text];
    }
}
//绑定
-(void)Bound{
    if([self RegisterErrorTF]==NO&&[self nullTf]==NO){
        [self ShowHub];
       [_loginRequest Bound:userName account:TF_arr[0].text Password:TF_arr[1].text];
    }
}
//修改密码
-(void)ChangePassword{
    if([self ChangePasswordErrorTF]==NO&&[self nullTf]==NO){
        [self ShowHub];
        [_loginRequest ChangPassword:TF_arr[0].text oldPassword:TF_arr[1].text newPassword:TF_arr[2].text];
    }
}

#pragma mark - 输入判断
//显示load
-(void)ShowHub{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.backgroundColor = ColorRGBA(0, 0, 0, 0.95);
    hud.label.text = @"Loading...";
    hud.label.textColor = [UIColor whiteColor];
}


//判断是否有空值
-(BOOL)nullTf{
    for (UITextField* tf in TF_arr) {
        if (tf.text.length == 0){
            [self loginFail:[_loginFileData getText:@"账号密码不得为空"]];
            return YES;
        }
    }
    return NO;
}
//检查修改密码是否有非法输入
-(BOOL)ChangePasswordErrorTF{
    for (int i = 2;i < TF_arr.count;i++) {
        if ( 0 < TF_arr[i].text.length&&TF_arr[i].text.length < 6){
            [self loginFail:[_loginFileData getText:@"太短了,新密码最少为6位"]];
            return YES;
        }
        if ([self isLetterAndNumber:TF_arr[i].text] == NO) {
            [self loginFail:[_loginFileData getText:@"账号密码只能是数字或字母！（别输入奇怪的东西进来~）"]];
            return YES;
        }
    }
    
    if ([TF_arr[2].text isEqualToString:TF_arr[3].text]==NO) {
        TF_arr[2].secureTextEntry = NO;
        TF_arr[3].secureTextEntry = NO;
        [self loginFail:[_loginFileData getText:@"两次密码输入不一致"]];
        return YES;
    }
    
    return NO;
}


//检查注册是否有非法输入
-(BOOL)RegisterErrorTF{
    for (UITextField* tf in TF_arr) {
        if ( 0 < tf.text.length&&tf.text.length < 6){
            [self loginFail:[_loginFileData getText:@"太短了,账号密码最少为6位"]];
            return YES;
        }
        if ([self isLetterAndNumber:tf.text] == NO) {
            [self loginFail:[_loginFileData getText:@"新密码只能是数字或字母！（别输入奇怪的东西进来~）"]];
            return YES;
        }
    }
    
    if ([TF_arr[1].text isEqualToString:TF_arr[2].text]==NO) {
        TF_arr[1].secureTextEntry = NO;
        TF_arr[2].secureTextEntry = NO;
        [self loginFail:[_loginFileData getText:@"两次密码输入不一致"]];
        return YES;
    }
    
    return NO;
}


//判断字符是否符合要求
-(BOOL)isLetterAndNumber:(NSString*)string{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""]; //按cs分离出数组,数组按@""分离出字符串
    return [string isEqualToString:filtered];
}

#pragma mark - duoleLoginRequestDelegate
-(void)loginFail:(NSString*)error{
    NSLog(@"%@",error);
    if ([error isEqualToString:@"The Internet connection appears to be offline."]) error = @"请检查网络";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];hud = nil;
        [JCAlertView showOneButtonWithTitle:[_loginFileData getText:@"登录失败"] Message:error ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:[_loginFileData getText:@"确定"] Click:nil];
    });
}

-(void)loginSuccess:(NSMutableDictionary*)data{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];hud = nil;
        [self back];
        if(_loginSuccessBlock)_loginSuccessBlock(data);
    });
    
}
#pragma mark - UIComBoBoxDelegate
//下拉列表的点击事件代理
-(BOOL)Select:(UIView *)box Row:(NSInteger)row{
    
    if (row == ((UIComboBox*)box).listArr.count-1 && ((UIComboBox*)box).listArr.count > 1) {
        [self goLoginView];
        return YES;
    }
    
    userName = ((UIComboBox*)box).listArr[row];
    [self updateBtn];
    return NO;
}

//下拉列表的删除事件代理
-(BOOL)DelsubArr:(UIView *)box Row:(NSInteger)row{
    //如果删除完重新初始化 一级主界面
    UIComboBox* Box = (UIComboBox*)box;
    //删除文件里的
    [_loginFileData removeOBjectAtName:Box.listArr[row]];
    //如果删除最后一个
    if (Box.listArr.count == 2) {
        [self loadMainView];
        [self loadMainViewSubviews];
    }
    return NO;
}
#pragma mark - UITextFieldDelegate

//实现当键盘出现的时候计算键盘的高度大小。用于输入框显示位置
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    [UIView animateWithDuration:0.3 animations:^{
        //获得相应的键盘
        UIView* firstResponder = [self findFirstResponder];
        //获取键盘的绝对坐标
        CGRect firstResponder_frame =  [self getAbsoluteCoordinate:firstResponder];
        float h1 = firstResponder_frame.origin.y + firstResponder_frame.size.height;//当前uiview底部的高度
        float h2 = self.view.frame.size.height - kbSize.height;//键盘顶部的高度
        if(isIos7System)h2 = self.view.frame.size.height - kbSize.width;
        //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
        if (h1 > h2) {
            mainViewBg.center = CGPointMake(self.view.center.x, self.view.center.y+h2-h1);
            [mainViewBg layoutIfNeeded];

        }else{
            mainViewBg.center = self.view.center;
            [mainViewBg layoutIfNeeded];
        }
    }];
    
}
//获取相对于屏幕的坐标
-(CGRect)getAbsoluteCoordinate:(UIView*)view{

    CGRect frame = view.frame;
    CGPoint pos = CGPointZero;
    while (1) {
        pos.x += view.frame.origin.x;
        pos.y += view.frame.origin.y;
        CGSize size1 = view.frame.size;
        CGSize size2 =  [UIScreen mainScreen].bounds.size;
        //用是否是屏幕大小来判断结束（并不科学，如有需要，自己改吧）
        if (size1.height == size2.height&&size1.width == size2.width)
            break;
        else
            view = [view superview];
    }
    frame = CGRectMake(pos.x, pos.y, frame.size.width,frame.size.height);
    return frame;
}

//返回键盘第一响应对象
- (id)findFirstResponder
{
    for(UIView *subView in SecondMainView.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }
    }
    return nil;
}


//当键盘隐藏的时候
- (void)keyboardWillBeHidden:(NSNotification*)aNotification{
    [UIView animateWithDuration:0.3 animations:^{
//        [mainViewBg mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.view);
//            make.size.mas_equalTo(CGSizeMake(250, 280));
//        }];
        mainViewBg.center = self.view.center;
        [mainViewBg layoutIfNeeded];
    }];
}


//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    //如果是最后一个取消键盘
    if (textField.tag == self->TF_arr.count+250-1) {
        [textField resignFirstResponder];
        return YES;
    }
    //不是进入下一项
    textField = [SecondMainView viewWithTag:textField.tag+1];
    [textField becomeFirstResponder];
    return NO;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //取消第一相应者
    [SecondMainView endEditing:YES];
}
#pragma mark - Private method
- (UIImage *)snapshot:(UIView *)snapshotview
{
    //得到系统版本号//如果系统版本号小于8.0f，即是7.X或以下,且还是横屏
    CGSize size =  snapshotview.bounds.size;    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    [snapshotview drawViewHierarchyInRect:snapshotview.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
 
    return image;
}
#pragma loadSubviews

-(void)loadSubviews{

    self.view.backgroundColor = ColorRGBA(0, 0, 0, 0.01);
    
    bgimageView= [[UIImageView alloc] init];
    [self.view addSubview:bgimageView];
    
    mainViewBg = [[UIView alloc] init];
    [self.view addSubview:mainViewBg];
    

    // Layout
    bgimageView.frame = self.view.frame;
    bgimageView.center = self.view.center;
    [bgimageView.superview layoutIfNeeded];
    mainViewBg.bounds = CGRectMake(0, 0, 250, 280);
    
    mainViewBg.center = self.view.center;
    
}
-(void)loadMainView{
    if (MainView) [MainView removeFromSuperview];
    
    //黑色地板
    MainView = [[UIView alloc] init];
    MainView.alpha = 0.95;
//    MainView.backgroundColor = ColorRGBA(0, 0, 0, 0.6);
    MainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"duole_ios_login.bundle/bg.jpg"]];//风际界面
    [[MainView layer]setCornerRadius:10.0];//圆角
    [mainViewBg addSubview:MainView];
    
    
   
    //更多方法的按钮
    
    moreFunction_btn = [[UIButton alloc] init];
    moreFunction_btn.showsTouchWhenHighlighted = YES; //按下发光
    [moreFunction_btn setImage:ImageWithName(@"duole_ios_login.bundle/more_function.png") forState:UIControlStateNormal];
    [moreFunction_btn addTarget:self action:@selector(moreFunction) forControlEvents:UIControlEventTouchUpInside];
    [MainView addSubview:moreFunction_btn];
    
    moreFunction_btn.alpha = 0;
    moreFunction_btn.enabled = NO;
    

    //layout
    MainView.frame  = CGRectMake(0, 0, 250, 280);
    
    moreFunction_btn.frame = CGRectMake(210, 10, 20, 20);
}

-(void)loadSecondMainView{
    if (SecondMainView) [SecondMainView removeFromSuperview];
    SecondMainViewSubviewType = 0;
    //黑色地板
    SecondMainView = [[UIView alloc] init];
    SecondMainView.alpha = 0.01;
//    SecondMainView.backgroundColor = ColorRGBA(0,0, 0, 0.6);//原界面
    SecondMainView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"duole_ios_login.bundle/bg.jpg"]];//风际界面
    [[SecondMainView layer]setCornerRadius:1.0];//圆角
    [mainViewBg addSubview:SecondMainView];
    
    SecondMainView.frame  = CGRectMake(0, 0, 250, 280);

}



//界面类型 1，登录 2，注册 3，绑定 4，修改密码
-(void)loadSecondMainViewSubviews:(NSInteger)Type;{
    if(SecondMainViewSubviewType == Type)return;
    
    [self loadSecondMainView];
    SecondMainViewSubviewType = Type;
    //返回按钮
    UIButton* back = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 35, 35)];
    [back setImage:ImageWithName(@"duole_ios_login.bundle/LoginUI_button_back_normal") forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backSecondMainView) forControlEvents:UIControlEventTouchUpInside];
    [SecondMainView addSubview:back];
    
    //----------------------------------
    NSArray* titleText_arr;//文本输入框文本
    NSString* btn_title;//按钮名字
    SEL btn_selector = NULL;//按钮事件
    TF_arr = [[NSMutableArray alloc] init];
    if (Type == 1) {
        
        titleText_arr = @[[_loginFileData getText:@"帐号"],[_loginFileData getText:@"密码"]];
        btn_title = [_loginFileData getText:@"登录"];
        btn_selector = @selector(Login);
        
    }else if(Type == 2){
        
        titleText_arr = @[[_loginFileData getText:@"帐号(最少6位)"],[_loginFileData getText:@"密码(最少6位)"],[_loginFileData getText:@"确认密码(最少6位)"]];
        btn_title = [_loginFileData getText:@"注册"];
        btn_selector = @selector(Register);
        
    }else if(Type == 3){
        
        titleText_arr = @[[_loginFileData getText:@"帐号(最少6位)"],[_loginFileData getText:@"密码(最少6位)"],[_loginFileData getText:@"确认密码(最少6位)"]];
        btn_title = [_loginFileData getText:@"注册并绑定"];
        btn_selector = @selector(Bound);
        
        
    }else if(Type == 4){
        
        titleText_arr = @[[_loginFileData getText:@"帐号"],[_loginFileData getText:@"原密码"],[_loginFileData getText:@"新密码(最少6位)"],[_loginFileData getText:@"确认密码(最少6位)"]];
        btn_title = [_loginFileData getText:@"修改密码"];
        btn_selector = @selector(ChangePassword);
        
    }
    //----------------------------------
    for(int i = 0; i < titleText_arr.count;i++){
        UITextField* tf = [[UITextField alloc] init];
        tf.frame = CGRectMake(20, 45*i+45, 210, 40);
        tf.placeholder = titleText_arr[i];
        tf.backgroundColor = [[UIColor alloc] initWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1];
        [tf.layer setCornerRadius:5.0];//圆角大小
        tf.tag = 250+i;
        tf.delegate  = self;
        //密码输入 and 左侧图标
        if (i!=0) {
            tf.secureTextEntry = YES;
            tf.leftView =[[UIImageView alloc] initWithImage:ImageWithName(@"duole_ios_login.bundle/LoginUI_duole_password")] ;
            tf.leftViewMode = UITextFieldViewModeAlways;
        }else{
            tf.leftView =[[UIImageView alloc] initWithImage:ImageWithName(@"duole_ios_login.bundle/LoginUI_duole_account")] ;
            tf.leftViewMode = UITextFieldViewModeAlways;
        }
        tf.leftView.frame = CGRectMake(3, 3, 34, 34);
        
        tf.clearButtonMode = UITextFieldViewModeAlways;//右方的小叉
        //设置键盘的样式
        tf.keyboardType = UIKeyboardTypeASCIICapable;
        //return键变成什么键
        if(i!=titleText_arr.count-1){
            tf.returnKeyType = UIReturnKeyNext;
        }else{
            tf.returnKeyType = UIReturnKeyGo;
        }
        [TF_arr addObject:tf];
        [SecondMainView addSubview:tf];
        
    }
    //----------------------------------
    if(Type == 4){
        UITextField* tf  =  TF_arr[0];
        tf.text = userName;
    }
    //----------------------------------
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    btn.backgroundColor = [[UIColor alloc] initWithRed:250/255.0 green:183/255.0 blue:0 alpha:1];
    btn.backgroundColor = [UIColor colorWithRed:0.27 green:0.51 blue:0.55 alpha:1.00];
    [btn setTintColor:[UIColor whiteColor]];
    [btn setTitle:btn_title forState:UIControlStateNormal];
    [btn.layer setCornerRadius:1.0];//圆角大小
    btn.showsTouchWhenHighlighted = YES; //按下发光
    btn.titleLabel.font = [UIFont fontWithName:fontName size:20];//字体大小
    btn.frame = CGRectMake(40, (45*titleText_arr.count)+50, 170, 40);
    [btn addTarget:self action:btn_selector forControlEvents:UIControlEventTouchUpInside];
    [SecondMainView addSubview:btn];
}




-(void)loadMainViewSubviews{
    //获取登录状态
    NSInteger loginMode = [_loginFileData GetInitMode];
    
    NSArray* btn_titleArr,*btn_colorArr;//按钮标题，颜色数组
    SEL btn_selector[5];//事件数组
    NSInteger fisrtBtnH = 35;//第一个按钮的高度
    
    //无帐号登录
    if(loginMode == 0)
    {
        btn_titleArr = @[[_loginFileData getText:@"快速登录"],[_loginFileData getText:@"登录"],[_loginFileData getText:@"注册"]];
//        btn_colorArr = @[ColorRGB(253, 183, 0),ColorRGB(91, 208, 172), ColorRGB(102, 153, 236)];
        btn_colorArr = @[[UIColor colorWithRed:0.48 green:0.76 blue:0.75 alpha:1.00],[UIColor colorWithRed:0.27 green:0.51 blue:0.55 alpha:1.00], [UIColor colorWithRed:0.34 green:0.55 blue:0.74 alpha:1.00]];
        btn_selector[0] = @selector(FastLogin);
        btn_selector[1] = @selector(goLoginView);
        btn_selector[2] = @selector(goRegisterOrboundView);
        
    }
    //有帐号登录
    else
    {
        NSMutableDictionary* userInfo = [_loginFileData readUserInfo];
        NSMutableArray* user_Arr = [userInfo objectForKey:@"用户数组"];
        
        NSMutableArray* username_Arr = [[NSMutableArray alloc] init];
        for (int i = 0; i < user_Arr.count; i++) {
            [username_Arr addObject:[user_Arr[i] objectForKey:@"name"]];
        }
        
        userName = username_Arr[0];
        box = [[UIComboBox alloc] initWithFrame:CGRectMake(20, fisrtBtnH, 210, 40) setListData:username_Arr lastLabelText:[_loginFileData getText:@"其它帐号"]];
        box.delegate = self;
        [MainView addSubview:box];
        fisrtBtnH += 50;
        
        btn_titleArr = @[[_loginFileData getText:@"登录"],[_loginFileData getText:@"注册"],[_loginFileData getText:@"修改密码"]];
//        btn_colorArr = @[ColorRGB(253, 183, 0),[UIColor brownColor],ColorRGB(102, 153, 236)];
        btn_colorArr = @[[UIColor colorWithRed:0.27 green:0.51 blue:0.55 alpha:1.00],[UIColor colorWithRed:0.34 green:0.55 blue:0.74 alpha:1.00],[UIColor colorWithRed:0.93 green:0.87 blue:0.74 alpha:1.00]];
        btn_selector[0] = @selector(DirectLogin);
        btn_selector[1] = @selector(goRegisterOrboundView);
        btn_selector[2] = @selector(goChangePasswordView);
        
    }
    //临时账号提示
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, (50*2+fisrtBtnH)+50, 210, 40)];
    messageLabel.alpha = 1;
    messageLabel.text = [_loginFileData getText:@"临时账号在删除客户端后会丢失。为了安全，建议绑定。"];
    messageLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];//字粗体大小
    messageLabel.textColor = [UIColor redColor];
    messageLabel.numberOfLines = 0;
    [MainView addSubview:messageLabel];
    
    //循环创建按钮
    for (int i = 0; i < btn_titleArr.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.backgroundColor = btn_colorArr[i];
        [btn setTintColor:[UIColor whiteColor]];
        [btn setTitle:btn_titleArr[i] forState:UIControlStateNormal];
        [btn.layer setCornerRadius:3.0];//圆角大小
        btn.showsTouchWhenHighlighted = YES; //按下发光
        btn.tag = 300+i;
        //原界面
//        btn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];//字粗体大小
//        btn.frame = CGRectMake(20, (60*i)+fisrtBtnH, 210, 50);
        //风际换界面
        btn.titleLabel.font = [UIFont fontWithName:fontName size:20];//字粗体大小
        btn.frame = CGRectMake(40, (50*i)+fisrtBtnH, 170, 40 );
        
        [btn addTarget:self action:btn_selector[i] forControlEvents:UIControlEventTouchUpInside];
        [MainView addSubview:btn];
    }
    
    
    [self updateBtn];
}
// 刷新按钮(主要是检查账号是临时账号还是正常账号
-(void)updateBtn{
    if ([_loginFileData GetInitMode] == 0)return;
    UIButton* btn1 = [self.view viewWithTag:301];
    UIButton* btn2 = [self.view viewWithTag:302];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    if ([_loginFileData GetUserType:userName] == 0) {
        //一般账号
        [btn1 setTitle:[_loginFileData getText:@"注册"] forState:UIControlStateNormal];
        btn2.alpha = 1;
    }else{
        //临时账号
        [btn1 setTitle:[_loginFileData getText:@"绑定"] forState:UIControlStateNormal];
        btn2.alpha = 0;
    }
    [UIView commitAnimations];
}


@end
