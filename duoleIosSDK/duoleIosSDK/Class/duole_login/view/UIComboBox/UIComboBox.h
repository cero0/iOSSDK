//调用案例
//NSMutableArray* listArr = [[NSMutableArray alloc] initWithArray:@[@"11",@"22",@"333",@"444"]];
//NSMutableArray* modeArr = [[NSMutableArray alloc] initWithArray:@[@1,@0,@1,@0]];//不用太整齐
////    UIComboBox* cb = [[UIComboBox alloc] initWithFrame:CGRectMake(50, 50, 150, 30) setListData:listArr];
//UIComboBox* cb = [[UIComboBox alloc] initWithFrame:CGRectMake(50, 50, 150, 30) setListData:listArr ListMAX:4 ModeArr:modeArr];
//cb.delegate = self;
//[self.view addSubview:cb];
//
//  UIComboBox.h
//  box
//
//  Created by duole on 15/11/26.
//  Copyright © 2015年 duole. All rights reserved.
//

#import <UIKit/UIKit.h>
//代理
@protocol UIComBoBoxDelegate <NSObject>
/**
 *  点击删除时触发。（返回YES的时候不执行自带操作）
 */
-(BOOL)DelsubArr:(UIView*)box Row:(NSInteger)row;

/**
 *  点击单元格的时候触发。（返回YES的时候不执行自带操作）
 */
-(BOOL)Select:(UIView*)box Row:(NSInteger)row;

@end






@interface UIComboBox : UIView<UITableViewDelegate,UITableViewDataSource>
{
    float h;//基准高
    float w;//基准宽
}
@property(nonatomic,weak) id<UIComBoBoxDelegate> delegate;


@property(nonatomic,retain)UITextField *TF;//输入框
@property(nonatomic,retain)UIButton *BTN;//按钮
@property(nonatomic,retain)UITableView *TableView;//列表


@property(nonatomic,retain)NSMutableArray* listArr;//列表数据
@property(nonatomic,assign)NSInteger listMax;//列表最多显示几行
@property(nonatomic,strong)NSMutableArray* modeArr;//列表样式


//不必要参数
@property(nonatomic,assign)NSInteger ZuanQuanCount;//转了几圈
@property(nonatomic,copy)void(^zuanQuan)(NSInteger ZuanQuanCount);





/**
 *  设置基础数据。（一般自定义）        列表里的数据，最大同时显示几行，模式［0什么都没有，1显示删除按钮］
 */
-(id)initWithFrame:(CGRect)frame setListData:(NSMutableArray*)listArr ListMAX:(NSInteger)listMAX ModeArr:(NSMutableArray*)modeArr;


/**
 *
 */
/**
 *  初始化.(无脑特例)
 *
 *  @param frame   frame
 *  @param ListArr 列表里的数据,3行,模式[000.....1]
 *  @param text    最后一个的text
 *
 *  @return 返回对象
 */
-(id)initWithFrame:(CGRect)frame setListData:(NSMutableArray*)ListArr lastLabelText:(NSString*)text;

/**
 *  删除某一项
 */
-(void)removeOBjectAtRow:(NSInteger)row;


@end
