//
//  BFDatePickerView.h
//  BFDatePickView
//
//  Created by BF on 2018/5/11.
//  Copyright © 2018年 迟博峰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BFDatePickerView;

@protocol BFDatePickerViewDelegate <NSObject>

/**
 保存按钮代理方法
 @param datePickerView 自身view
 @param futureTime 选择的未来的某个时间
 @param timeStampMargin 时间戳间隔
 */
- (void)datePickerViewSaveBtnClickDelegateDatePickerView:(BFDatePickerView *)datePickerView futureTime:(NSString *)futureTime timeStampMargin:(long)timeStampMargin;

/**
 取消按钮代理方法
 */
- (void)datePickerViewCancelBtnClickDelegateDatePickerView:(BFDatePickerView *)datePickerView;

@end

@interface BFDatePickerView : UIView

@property (copy, nonatomic) NSString *title; // 标题
@property (assign, nonatomic) BOOL forbiddenAutoScrolled;// 是否禁止自动滑动 默认NO
@property (nonatomic, assign) NSUInteger showMaxRow; // 需要展示的行数限制 默认没有限制
@property (weak, nonatomic) id <BFDatePickerViewDelegate> delegate;
@property (nonatomic, assign) BOOL show;// pickView 的显示或隐藏

- (void)show:(BOOL)show; // 是否显示

@end
