//
//  FJThirdPay.m
//  duoleIosSDK
//
//  Created by duole on 17/2/13.
//  Copyright © 2017年 cxh. All rights reserved.
//

#import "FJThirdPay.h"
#import "FJThirdPayFileRW.h"
#import "MBProgressHUD.h"
#import "Macro.h"
#import "duole_log.h"
#import "FJThirdPaySendReceipt.h"
#import "RMStore.h"

static FJThirdPay* FJThirdPay_share;
@interface FJThirdPay()<RMStoreObserver>

@end

@implementation FJThirdPay{
    NSMutableDictionary *userInfo;//存放用户数据
    NSDictionary *message_dic;//存放消息映射字典
    NSDictionary *ProductList;//商品映射字典
    NSDictionary* Protocol_main_dic;//存放协议的字典
    
    BOOL initBl;//商品是否初始化成功.
    FJThirdPayFileRW *fileRw;
    MBProgressHUD *_hud;//load....
    NSString *transId;
}


+(instancetype)share{
    if (FJThirdPay_share == NULL) {
        FJThirdPay_share = [[FJThirdPay alloc] init];
    }
    return FJThirdPay_share;
}
-(instancetype)init{
    self =[super init];
    if (self) {
        initBl = NO;
        fileRw = [[FJThirdPayFileRW alloc] init];
        
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
        [[FJThirdPaySendReceipt share] start:^(NSDictionary *dic) {
            if (_PaySuccessBlock)  _PaySuccessBlock(dic);
        }];//发送收据
    }
    
    
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
    [[FJThirdPaySendReceipt share] start:^(NSDictionary *dic) {
        if (_PaySuccessBlock)  _PaySuccessBlock(dic);
    }];//发送收据
    
    NSLog(@"%@",ProductList);
    [duole_log WriteLog:[NSString stringWithFormat:@"＝＝＝开始购买商品：%@＝＝＝",[ProductList objectForKey:commodityID]]];
    
    
    [userInfo addEntriesFromDictionary:data];//添加参数
    //NSLog(@"%@",userInfo);
    
    [self showHub];
    
    //合成传入订单的数据
    NSString* ProtocolInfo = [FJThirdPaySendReceipt getProtocolInfo:userInfo URL:_URL];
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
    
    [[FJThirdPaySendReceipt share] getOrderID:userInfo];
    
    
    //开始购买
    [[RMStore defaultStore] addPayment:[ProductList objectForKey:commodityID] user:ProtocolInfo success:^(SKPaymentTransaction *transaction) {
        NSLog(@"%@",transaction);
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
    
    [[FJThirdPaySendReceipt share] start:^(NSDictionary *dic) {
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
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    // Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    [hud hideAnimated:YES afterDelay:3.f];
}

//显示loading
-(void)showHub{
    [self hideHub];
    _hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    _hud.bezelView.backgroundColor = ColorRGBA(0, 0, 0, 0.4);
    _hud.label.text = @"Loading...";
    _hud.label.textColor = [UIColor whiteColor];
}

//隐藏loading
-(void)hideHub{
    if (_hud) {
        [_hud hideAnimated:YES];
        _hud = nil;
    }
}



@end
