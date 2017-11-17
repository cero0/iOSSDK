//
//  duole_iap.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/2.
//  Copyright © 2016年 cxh. All rights reserved.
//


#import "RMStore.h"
#import "MBProgressHUD.h"

#import "Macro.h"

#import "duole_iap.h"
#import "duole_log.h"
#import "iapFileRW.h"
#import "sendReceipt.h"

UIWebView *webView;
static duole_iap* duole_iap_share;
@interface duole_iap()<RMStoreObserver>

@end

@implementation duole_iap{
    NSMutableDictionary *userInfo;//存放用户数据
    NSDictionary *message_dic;//存放消息映射字典
    NSDictionary *ProductList;//商品映射字典
    NSDictionary* Protocol_main_dic;//存放协议的字典
    
    BOOL initBl;//商品是否初始化成功.
    iapFileRW *fileRw;
    MBProgressHUD *_hud;//load....
}
+(instancetype)share{
    @synchronized (self) {
        if (duole_iap_share == NULL) {
            duole_iap_share = [[duole_iap alloc] init];
        }
    }
    return duole_iap_share;
}
-(instancetype)init{
    self =[super init];
    if (self) {
        initBl = NO;
        fileRw = [[iapFileRW alloc] init];
        
        ProductList = [fileRw getProducts];
        _URL = [fileRw getURL];
        [[RMStore defaultStore] addStoreObserver:self];
    }
    return self;
}
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

/**
 *  初始化
 *
 *  @param userInfoDIC  用户信息
 */
-(void)InitUserInfo:(NSDictionary*) userInfoDIC{
    NSLog(@"支付2.1.1 增加发送失败重新发送");

    
    userInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfoDIC];
    //加日志
    NSString* str = @"初始化支付。初始化信息:";
    for (NSString* key in userInfoDIC) {
        if([key rangeOfString:@"key" options:NSCaseInsensitiveSearch].length>0){
            str = [str stringByAppendingString:[NSString stringWithFormat:@" %@:%@ ",key,[userInfoDIC objectForKey:key]]];
        }
    }
    [duole_log WriteLog:str];
    //end
    
    //查看玩家是否有掉单
    if ([fileRw getReceipts].count > 0) {
        NSString* str = [NSString stringWithFormat:[fileRw getMessageStr:@"发现有%lu订单为发送失败，正在补单..."],[fileRw getReceipts].count];
        [self showMessage:str];
        [duole_log WriteLog:str];
        
        //发送收据
        [sendReceipt start:^(NSDictionary *dic) {
            if (_PaySuccessBlock)  _PaySuccessBlock(dic);
        }];//发送收据
    }
    
    NSLog(@"请求商品:%@",ProductList);
    //请求商品
    [[RMStore defaultStore] requestProducts:[NSSet setWithArray:[ProductList allValues]] success:nil failure:nil];
 
    
}



//购买商品
-(void)PayStart:(NSString*)commodityID Data:(NSDictionary*)data success:(void(^)(NSDictionary* dic))success fail:(void(^)(NSDictionary* dic)) fail{
    self->_PaySuccessBlock = success;
    self->_PayFailBlock = fail;
    [self PayStart:commodityID Data:data];
}

-(void)PayStart:(NSString*)commodityID Data:(NSDictionary*)data{
    [sendReceipt start:^(NSDictionary *dic) {
        if (_PaySuccessBlock)  _PaySuccessBlock(dic);
    }];//发送收据
    
    NSLog(@"ProductList==%@",ProductList);
    [duole_log WriteLog:[NSString stringWithFormat:@"＝＝＝开始购买商品：%@＝＝＝",[ProductList objectForKey:commodityID]]];
    
    
    [userInfo addEntriesFromDictionary:data];//添加参数
    //NSLog(@"%@",userInfo);
    
    [self showHub];
    
    //合成传入订单的数据
    NSString* ProtocolInfo = [sendReceipt getProtocolInfo:userInfo URL:_URL];
    if (ProtocolInfo.length == 0) {
        [self showMessage:@"缺少参数"];
        [self hideHub];
        return;
    }
    
    //判断是否重新请求商品
    if(initBl == NO){
        [[RMStore defaultStore] requestProducts:[NSSet setWithArray:[ProductList allValues]] success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
            initBl = YES;
            [self PayStart:commodityID Data:data];
        } failure:^(NSError *error) {
            [self hideHub];
        }];
        return;
    }
    
    //开始购买
    [[RMStore defaultStore] addPayment:[ProductList objectForKey:commodityID] user:ProtocolInfo success:^(SKPaymentTransaction *transaction) {
        [self hideHub];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        [self hideHub];       
    }];
    //
    
}





#pragma RMStoreObserver

//商品请求失败
- (void)storeProductsRequestFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
    NSLog(@"商品请求失败");
    NSString* str = [NSString stringWithFormat:[fileRw getMessageStr:@"商品信息加载失败：%@"],[error localizedDescription]];
    [duole_log WriteLog:str];
    [self showMessage:str];
}

//商品请求成功
- (void)storeProductsRequestFinished:(NSNotification*)notification
{
//    NSArray *products = notification.rm_products;
    NSArray *invalidProductIdentifiers = notification.rm_invalidProductIdentifiers;
    [duole_log WriteLog:@"商品加载成功"];
    initBl = YES;
    //是否有不可用商品
    if (invalidProductIdentifiers.count>0) {
        NSString* str = [NSString stringWithFormat:[fileRw getMessageStr:@"有%lu个商品不可用"],invalidProductIdentifiers.count];
        [self showMessage:str];
        [duole_log WriteLog:str];
    }
}


//交易成功
- (void)storePaymentTransactionFinished:(NSNotification*)notification
{
//    NSString *productIdentifier = notification.rm_productIdentifier;
    [duole_log WriteLog:@"付款成功"];
    
    SKPaymentTransaction *transaction = notification.rm_transaction;
    [fileRw wiretReceipt:transaction];
   
    //发送收据
    [sendReceipt start:^(NSDictionary *dic) {
        if (_PaySuccessBlock)  _PaySuccessBlock(dic);    
    }];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}
//支付失败
- (void)storePaymentTransactionFailed:(NSNotification*)notification
{
    NSError *error = notification.rm_storeError;
    NSString* str = [NSString stringWithFormat:[fileRw getMessageStr:@"支付失败:%@"],[error localizedDescription]];
    [self showMessage:str];
    [duole_log WriteLog:str];
    
     if(_PayFailBlock)_PayFailBlock(@{});

    [[SKPaymentQueue defaultQueue] finishTransaction:notification.rm_transaction];
}

// iOS 8+ only
//延期付款
- (void)storePaymentTransactionDeferred:(NSNotification*)notification
{
//    NSString *productIdentifier = notification.rm_productIdentifier;
//    SKPaymentTransaction *transaction = notification.rm_transaction;
    [duole_log WriteLog:@"延期付款"];
    NSLog(@"延期支付交易");
}

#pragma --------UI--------
//提示
-(void)showMessage:(NSString*)message{
    if(message.length == 0)return;
    if([UIApplication sharedApplication].keyWindow==NULL)return;
    

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        
        // Set the annular determinate mode to show task progress.
        hud.mode = MBProgressHUDModeText;
        hud.label.text = message;
        // Move to bottm center.
        hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
        [hud hideAnimated:YES afterDelay:3.f];
    }];


}

//显示loading
-(void)showHub{
    [self hideHub];
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        _hud.bezelView.backgroundColor = ColorRGBA(0, 0, 0, 0.4);
        _hud.label.text = @"Loading...";
        _hud.label.textColor = [UIColor whiteColor];
//    }];

}

//隐藏loading
-(void)hideHub{
    if (_hud) {
//        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_hud hideAnimated:YES];
            _hud = nil;
//        }];
        
    }
}

//获取pay_type
-(int)getPayType{
//    [self deletePayType];
//    [self downloadPayType];
    
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *file = [caches stringByAppendingPathComponent:@"pay_type.txt"];
    
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:file];
    if (blHave) {
        NSLog(@"此文件存在");
    }else{
        NSLog(@"此文件不存在");
//        [self downloadPayType];
        file = [caches stringByAppendingPathComponent:@"pay_type.txt"];
        
    }
    
    NSString* content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"NSString类方法读取的内容是：\n%@",content);
    NSString *typeStr = [content substringWithRange:NSMakeRange(9, 1)];
    
    int type = [typeStr intValue];
    NSLog(@"%i",type);
//    [self deletePayType];
    return type;
}
//删除pay_type文件
-(void)deletePayType{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
    NSString *file = [caches stringByAppendingPathComponent:@"pay_type.txt"];
    
    //文件名
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:file];
    if (!blHave) {
        NSLog(@"此文件不存在");
        return ;
    }else {
        NSLog(@"此文件存在");
        BOOL blDele= [fileManager removeItemAtPath:file error:nil];
        if (blDele) {
            NSLog(@"文件删除成功");
        }else {
            NSLog(@"文件删除失败");
        }
        
    }
}

//下载pay_type文件
-(void)downloadPayType{
    [self deletePayType];
    NSURL *url = [NSURL URLWithString:[[iapFileRW share] getPayTypeURL]];
    // 得到session对象
    NSURLSession* session = [NSURLSession sharedSession];
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 创建任务
    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            // 下载成功
            // 注意 location是下载后的临时保存路径, 需要将它移动到需要保存的位置
            NSError *saveError;
            // 创建一个自定义存储路径
            NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *savePath = [cachePath stringByAppendingPathComponent:response.suggestedFilename];
            NSURL *saveURL = [NSURL fileURLWithPath:savePath];
            
            // 文件复制到cache路径中
            [[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&saveError];
            if (!saveError) {
                NSLog(@"保存成功");
            } else {
                NSLog(@"error is %@", saveError.localizedDescription);
            }
        } else {
            NSLog(@"error is : %@", error.localizedDescription);
        }
    }];
    
//    NSURLSessionDownloadTask* downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        // location : 临时文件的路径（下载好的文件）
//        NSLog(@"location==%@,response==%@",location,response);
//        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        // response.suggestedFilename ： 建议使用的文件名，一般跟服务器端的文件名一致
//        NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
//        // 将临时文件剪切或者复制Caches文件夹
//        NSFileManager *mgr = [NSFileManager defaultManager];
//        // AtPath : 剪切前的文件路径   ToPath : 剪切后的文件路径
//        [mgr moveItemAtPath:location.path toPath:file error:nil];
//    }];
    
    // 开始任务
    [downloadTask resume];
}

-(void )webPay{//跳出网页支付
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    UIButton* button_back = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-60, 10, 50, 50)];
    [button_back setBackgroundImage:[UIImage imageNamed:@"UIComboBox_delbtn"] forState:UIControlStateNormal];
    //    [button_back setTitle:@"取消" forState:UIControlStateNormal];
    //    [button_back setTitleColor:[UIColor colorWithRed:0.93 green:0.87 blue:0.74 alpha:1.00] forState:UIControlStateNormal];
    //    button_back.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button_back addTarget:self action:@selector(paySelectUIBack) forControlEvents:UIControlEventTouchUpInside];
    [webView addSubview:button_back];
    
    [webView loadRequest:request];
    webView.scalesPageToFit = YES;
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:webView];
    
}


-(void)paySelectUIBack{
    [webView removeFromSuperview];
}

@end
