//
//  UIComboBox.m
//  box
//
//  Created by duole on 15/11/26.
//  Copyright © 2015年 duole. All rights reserved.
//

#import "UIComboBox.h"
#import "loginFileReadWrite.h"
#import "JCAlertView.h"
#import "Macro.h"

@implementation UIComboBox

-(id)initWithFrame:(CGRect)frame setListData:(NSMutableArray*)ListArr lastLabelText:(NSString *)text{
    
    NSMutableArray* modearr = [[NSMutableArray alloc] init];
    for (int i = 0; i < ListArr.count; i++) {
        [modearr addObject:@1];
    }
    
    [ListArr addObject:text];
    [modearr addObject:@0];
    
    return [[UIComboBox alloc] initWithFrame:frame setListData:ListArr ListMAX:3  ModeArr:modearr];
}

- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
}

/**
 *  设置基础数据。        列表里的数据，最大同时显示几行，模式［0什么都没有，1显示删除按钮］
 */
-(id)initWithFrame:(CGRect)frame setListData:(NSMutableArray*)listArr ListMAX:(NSInteger)listMAX  ModeArr:(NSMutableArray*)modeArr{
    _listMax = listArr.count>listMAX?listMAX:listArr.count;
    
    
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
//        self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height*(_listMax+1))];
    if (self) {
        _ZuanQuanCount = 0;
        _listMax = listArr.count>listMAX?listMAX:listArr.count;
        
        //如果是不可变转成可变
        if([[listArr class] isSubclassOfClass:[NSArray class]])
            _listArr = [[NSMutableArray alloc] initWithArray:listArr];
        else
            _listArr = listArr;
        if([[modeArr class] isSubclassOfClass:[NSArray class]])
            _modeArr = [[NSMutableArray alloc] initWithArray:modeArr];
        else
            _modeArr = modeArr;
        
        
        
        h = frame.size.height;
        w = frame.size.width;
//        NSLog(@"listMax:%lu. listArr:%@. modeArr:%@",_listMax,_listArr,_modeArr);
        
    
        //输入框
        _TF = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, w, h)];
        _TF.enabled = NO;
        [_TF setBorderStyle:UITextBorderStyleRoundedRect];
        _TF.text = listArr[0];
        [self addSubview:_TF];

        //按钮
        _BTN = [[UIButton alloc] initWithFrame:CGRectMake(w - (h-5) - 1, 3, (h-5)-1, (h-5)-2)];
        
        [_BTN setImage:ImageWithName(@"duole_ios_login.bundle/UIComboBox_btn") forState:UIControlStateNormal];
        [self addSubview:_BTN];
        [_BTN addTarget:self action:@selector(BTNaction) forControlEvents:UIControlEventTouchUpInside];
        
        //列表
        _TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, h, w, 0)];
         [[_TableView layer]setCornerRadius:5.0];//圆角
        _TableView.delegate = self;
        _TableView.dataSource = self;
        [self addSubview:_TableView];
    }
    return self;
}






//按钮点击
-(void)BTNaction{
        
    _ZuanQuanCount++;
    _zuanQuan(_ZuanQuanCount);
    if(_ZuanQuanCount==10)[_BTN setImage:  [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[@"duole_ios_login.bundle/UIComboBox_btn2.png" stringByAppendingString:@".png"]]] forState:UIControlStateNormal];
  
    [UIView animateWithDuration:0.3 animations:^{
        //把按钮旋转一下
        _BTN.transform =  CGAffineTransformRotate(_BTN.transform, M_PI );
        //把列表显示或者隐藏
        if(_ZuanQuanCount%2){
            _TableView.frame = CGRectMake( 0,h, w, h*_listMax);
            self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y, w, h*(_listMax+1));//子视图超过父视图无法响应点击消息。故加这个
        }
        else{
             _TableView.frame = CGRectMake( 0,h,w, 0);
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, w, h);
        }
    }];
//    [self.superview addSubview:self];
    [self.superview bringSubviewToFront:self];
}











#pragma UITableView delegate


//单元格
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    //享元
    NSString* modeStr = @"";
    //如果要自定义另一种模式在这里和下面加一下
    NSInteger ii =  indexPath.row>_modeArr.count?_modeArr.count:indexPath.row;//防止单元格类型写少了。
    NSInteger modeInt = [_modeArr[ii] intValue];
    switch (modeInt) {
        case 0:
            modeStr = @"mycell0";
            break;
        case 1:
            modeStr = @"mycell1";
            break;
        default:
            modeStr = @"mycell";
            break;
    }
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:modeStr];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]init];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //单元格里的元素，自定义可以在这里更改
    UILabel* lable = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, w - 10, h)];
    lable.text = _listArr[indexPath.row];
    [cell addSubview:lable];
    if (modeInt == 1) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(w - h - 3, 3, h - 6, h - 6)];
        [btn setImage:ImageWithName(@"duole_ios_login.bundle/UIComboBox_delbtn") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = indexPath.row+99;
        [cell addSubview:btn];
    }
    return cell;
}


//删除元素
-(void)btnAction:(UIButton*)sender{
    
    [JCAlertView showTwoButtonsWithTitle:[[loginFileReadWrite share] getText:@"删除账号"] Message:[[loginFileReadWrite share] getText:@"你确定删除该账号吗？"] ButtonType:JCAlertViewButtonTypeCancel ButtonTitle:[[loginFileReadWrite share] getText:@"确定"] Click:^{
        
        NSInteger row = sender.tag - 99;
        if([self.delegate DelsubArr:self Row:row] == NO){
                [self removeOBjectAtRow:row];
        }

    } ButtonType:JCAlertViewButtonTypeDefault ButtonTitle:[[loginFileReadWrite share] getText:@"取消"] Click:nil];

    
}

-(void)removeOBjectAtRow:(NSInteger)row{

    [_listArr removeObjectAtIndex:row];
    row =row>_modeArr.count?_modeArr.count:row;//防止溢出
    [_modeArr removeObjectAtIndex:row];
    [_TableView reloadData];
    _listMax = _listArr.count>_listMax?_listMax:_listArr.count;

    // 如果已经没有数据了
    if (_listArr.count == 0) {
        _TF.text = @"";
    }
    [self.delegate Select:self Row:0];
    _TF.text = _listArr[0];
}

//点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self.delegate Select:self Row:indexPath.row] == NO) {
        _TF.text = _listArr[indexPath.row];
    }
    [self BTNaction];
}











//设置一些列表宽高的
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return _listArr.count;
}

//行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return h;
}










////让超出父视图范围的子视图响应事件，在UIView范围外响应点击
//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    UIView *v = [super hitTest:point withEvent:event];
//    if (v == nil) {
//        CGPoint tp = [self.TableView convertPoint:point fromView:self];
//        if (CGRectContainsPoint(self.TableView.bounds, tp)) {
//            v = self.TableView;
//        }
//    }
//    return v;
//}

@end
