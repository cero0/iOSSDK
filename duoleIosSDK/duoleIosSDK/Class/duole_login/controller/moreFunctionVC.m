//
//  moreFunctionVC.m
//  duoleIosSDK
//
//  Created by cxh on 16/8/1.
//  Copyright © 2016年 cxh. All rights reserved.
//
#import "moreFunctionVC.h"
#import "moreFunctionFileRW.h"
#import "Macro.h"
//#import "Masonry.h"
#import "JCAlertView.h"

@interface moreFunctionVC()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)NSArray<NSDictionary *>* tableData;
@end

@implementation moreFunctionVC

-(instancetype)init{
    self = [super init];
    if (self) {
        _tableData = @[@{@"title":@"删除更新包"},
                       @{@"title":@"设置推送"}];
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

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma action--
-(void)backbtn{
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = @"pageCurl";
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)removeFile{
    [JCAlertView showTwoButtonsWithTitle:@"删除更新包" Message:@"将删除所有本地文件，你需要重新下载所有更新包。" ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:@"确定" Click:^{
        [[moreFunctionFileRW share] removeUpdateFile];
    } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:@"取消" Click:nil];

}
#pragma UITableDelegate--

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   NSLog(@"%lu",indexPath.row);
    switch (indexPath.row) {
        case 0:
            [[moreFunctionFileRW share] removeUpdateFile];
            break;
        default:
            break;
    }

}

//分组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableData.count;
}
//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"moreFunction"];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = [_tableData[indexPath.row] objectForKey:@"title"];
    return cell;
}

#pragma loadSubviews

-(void)loadSubviews{
    
    self.view.backgroundColor = ColorRGBA(230, 230, 230, 1);
    //返回按钮
    UIButton* backbtn = [[UIButton alloc] init];
    backbtn.showsTouchWhenHighlighted = YES; //按下发光
    [backbtn setImage:ImageWithName(@"duole_ios_login.bundle/LoginUI_button_back_normal") forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backbtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbtn];
    
    //删除文件按钮
    UIButton* removeFileBtn = [[UIButton alloc] init];
    removeFileBtn.backgroundColor = [UIColor colorWithRed:0.2 green:0.7 blue:0.6 alpha:1];
    removeFileBtn.layer.cornerRadius = 5.0;
    [removeFileBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    removeFileBtn.showsTouchWhenHighlighted = YES;
    [removeFileBtn setTitle:@"删除更新包" forState:UIControlStateNormal];
    [removeFileBtn addTarget:self action:@selector(removeFile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:removeFileBtn];
    
//    UITableView* table = [[UITableView alloc] init];
//    table.separatorStyle = UITableViewCellSeparatorStyleNone;
//    table.delegate = self;
//    table.dataSource = self;
//    [self.view addSubview:table];
    //layout

    backbtn.frame = CGRectMake(5, 5, 40, 40);
    removeFileBtn.frame = CGRectMake(5, 60, 70, 30);

    
//    [table mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.bottom.equalTo(self.view);
//        make.top.equalTo(self.view).offset(40);
//        make.right.equalTo(self.view.mas_centerX);
//    }];
    
}
@end
