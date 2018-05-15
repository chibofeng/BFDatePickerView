//
//  ViewController.m
//  BFDatePickView
//
//  Created by 迟博峰 on 2018/5/11.
//  Copyright © 2018年 迟博峰. All rights reserved.
//

#import "ViewController.h"

#import "BFDatePickerView.h"

@interface ViewController () <BFDatePickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *timeResultLabel;
@property (weak, nonatomic) BFDatePickerView *dateView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BFDatePickerView *dateView = [[BFDatePickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 250)];
    dateView.delegate = self;
    dateView.title = @"请选择时间";
    dateView.showMaxRow = 3;
    self.dateView = dateView;
    [self.view addSubview:dateView];
}

// 显示
- (IBAction)timerButtonClick:(id)sender {
    
    [self.dateView show:YES];
}

#pragma mark - BFDatePickerViewDelegate
/**
 保存按钮代理方法
 
 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegateDatePickerView:(BFDatePickerView *)datePickerView futureTime:(NSString *)futureTime timeStampMargin:(long)timeStampMargin{
    
    NSLog(@"保存点击");
    self.timeResultLabel.text = futureTime;
}

/**
 取消按钮代理方法
 */
- (void)datePickerViewCancelBtnClickDelegateDatePickerView:(BFDatePickerView *)datePickerView{
    
    NSLog(@"取消点击");
}

@end
