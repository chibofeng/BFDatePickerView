//
//  BFDatePickerView.m
//  BFDatePickView
//
//  Created by BF on 2018/5/11.
//  Copyright © 2018年 迟博峰. All rights reserved.
//

#import "BFDatePickerView.h"

#define KMoreSection 100
#define KRowHeight 37
#define UIColorFromHex(s) [UIColor colorWithRed:((s & 0xFF0000) >> 16)/255.0 green:((s &0xFF00) >>8)/255.0 blue:((s &0xFF))/255.0 alpha:1.0]
#define is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@interface BFDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIButton *shadowButton;
@property (nonatomic, weak) UILabel *titleLabel; // 标题
@property (nonatomic, weak) UILabel *timeMarginLabel;
@property (nonatomic, weak) UIPickerView *pickerView; // 选择器

@property (nonatomic, strong) NSMutableArray *dataArray; // 数据源
@property (nonatomic, strong) NSMutableArray *yearArr; // 年数组
@property (nonatomic, strong) NSMutableArray *monthArr; // 月数组
@property (nonatomic, strong) NSMutableArray *dayArr; // 日数组
@property (nonatomic, strong) NSMutableArray *hourArr; // 时数组
@property (nonatomic, strong) NSMutableArray *minuteArr; // 分数组
@property (nonatomic, strong) NSMutableArray *secondArr; // 秒数组
@property (nonatomic, strong) NSMutableArray *enterTimeArr; // 当前时间数组

@property (nonatomic, copy) NSString *enterTimeFlag;//pickView显示的时候的时间戳
@property (nonatomic, copy) NSString *year; // 选中年
@property (nonatomic, copy) NSString *month; //选中月
@property (nonatomic, copy) NSString *day; //选中日
@property (nonatomic, copy) NSString *hour; //选中时
@property (nonatomic, copy) NSString *minute; //选中分
@property (nonatomic, copy) NSString *second; //选中秒

@end

@implementation BFDatePickerView

#pragma mark - init
// 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self prepareData];
        [self prepareUI];
    }
    return self;
}

- (void)prepareData{
    
    [self.dataArray addObject:self.yearArr];
    [self.dataArray addObject:self.monthArr];
    [self.dataArray addObject:self.dayArr];
    [self.dataArray addObject:self.hourArr];
    [self.dataArray addObject:self.minuteArr];
    [self.dataArray addObject:self.secondArr];
}

- (void)prepareUI{
    
    // 导航条
    UIView *toolView = [[UIView alloc] init];
    CGFloat toolViewHeight = 50;
    toolView.frame = CGRectMake(0, 0, self.frame.size.width, 50);
    toolView.backgroundColor = UIColorFromHex(0x222222);
    [self addSubview:toolView];
    
    // 保存按钮(导航条右边)
    UIButton *saveBtn = [[UIButton alloc] init];
    saveBtn.frame = CGRectMake(self.frame.size.width - 50, 0, toolViewHeight, toolViewHeight);
    [saveBtn setImage:[UIImage imageNamed:@"pickerView_rightButton_select"] forState:UIControlStateNormal];
    if (!saveBtn.currentImage) {
        [saveBtn setTitle:@"确定" forState:UIControlStateNormal];
        [saveBtn setTitle:@"确定" forState:UIControlStateHighlighted];
    }
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:saveBtn];
    
    // 取消按钮(导航条左边)
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(10, 0, toolViewHeight, toolViewHeight);
    [cancelBtn setImage:[UIImage imageNamed:@"pickerView_rightButton_cancel"] forState:UIControlStateNormal];
    if (!cancelBtn.currentImage) {
        [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        [cancelBtn setTitle:@"返回" forState:UIControlStateHighlighted];
    }
    [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:cancelBtn];
    
    // 标题文本(导航条中间)
    UILabel *titleLabel = [[UILabel alloc] init];
    self.titleLabel = titleLabel;
    titleLabel.frame = CGRectMake(CGRectGetMaxX(cancelBtn.frame), 2, CGRectGetMinX(saveBtn.frame) - CGRectGetMaxX(cancelBtn.frame), toolViewHeight);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [toolView addSubview:titleLabel];
    
    // 年月日时分秒
    UILabel *tipTimeLabel = [[UILabel alloc] init];
    tipTimeLabel.frame = CGRectMake(0, toolViewHeight, toolView.frame.size.width, 30);
    tipTimeLabel.backgroundColor = UIColorFromHex(0x333333);
    [self addSubview:tipTimeLabel];
    
    CGFloat itemWidth = self.frame.size.width / self.dataArray.count;
    for (int i = 0; i < self.dataArray.count; ++i) {
        
        UILabel *typeLabel = [[UILabel alloc] init];
        typeLabel.frame = CGRectMake(i * itemWidth, 0, itemWidth, CGRectGetHeight(tipTimeLabel.frame));
        switch (i) {
            case 0:
                typeLabel.text = @"年";
                break;
            case 1:
                typeLabel.text = @"月";
                break;
            case 2:
                typeLabel.text = @"日";
                break;
            case 3:
                typeLabel.text = @"时";
                break;
            case 4:
                typeLabel.text = @"分";
                break;
            case 5:
                typeLabel.text = @"秒";
                break;
        }
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.font = [UIFont systemFontOfSize:15];
        typeLabel.textColor = UIColorFromHex(0x999999);
        [tipTimeLabel addSubview:typeLabel];
    }
    
    // 底部时间差框
    UIView *spaceFixView = [[UIView alloc] init];
    spaceFixView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, is_iPhoneX * 20);
    spaceFixView.backgroundColor = UIColorFromHex(0x222222);
    [self addSubview:spaceFixView];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height + CGRectGetHeight(spaceFixView.frame));
    
    UILabel *timeMarginButtomView = [[UILabel alloc] init];
    timeMarginButtomView.frame = CGRectMake(0, CGRectGetMinY(spaceFixView.frame) - 60, self.frame.size.width, 60);
    timeMarginButtomView.backgroundColor = spaceFixView.backgroundColor;
    [self addSubview:timeMarginButtomView];
    
    UILabel *timeMarginLabel = [[UILabel alloc] init];
    self.timeMarginLabel = timeMarginLabel;
    timeMarginLabel.font = [UIFont systemFontOfSize:14];
    timeMarginLabel.textColor = UIColorFromHex(0x999999);
    timeMarginLabel.frame = CGRectMake(20, 0, CGRectGetWidth(timeMarginButtomView.frame) - 20 * 2, CGRectGetHeight(timeMarginButtomView.frame));
    [timeMarginButtomView addSubview:timeMarginLabel];
    
    UIImageView *pickImageView = [[UIImageView alloc] init];
    pickImageView.frame = CGRectMake(0, CGRectGetMaxY(tipTimeLabel.frame), self.frame.size.width, CGRectGetMinY(timeMarginButtomView.frame) - CGRectGetMaxY(tipTimeLabel.frame));
    pickImageView.userInteractionEnabled = YES;
    pickImageView.image = [UIImage imageNamed:@"pickerView_back_image"];
    [self addSubview:pickImageView];
    
    // UIPickerView
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    self.pickerView = pickerView;
    pickerView.frame = CGRectMake(0, 0, pickImageView.bounds.size.width, pickImageView.bounds.size.height);
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickImageView addSubview:pickerView];
}

- (void)show:(BOOL)show{
    self.show = show;
}

// pickView 的显示或隐藏
- (void)setShow:(BOOL)show{
    
    __weak __typeof(self) weakSelf = self;
    if (show){// 显示
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - weakSelf.frame.size.height, weakSelf.frame.size.width, weakSelf.frame.size.height);
            [weakSelf scrollToCurrentTimeOnPickView];
        }];
    } else{// 隐藏
        
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, weakSelf.frame.size.width, weakSelf.frame.size.height);
        }];
    }
    
    if (!self.hidden) {
        self.shadowButton.hidden = !show;
    }else{
        NSLog(@"pickView 隐藏中...");
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setShowMaxRow:(NSUInteger)showMaxRow{
    
    _showMaxRow = showMaxRow;
    self.pickerView.frame = CGRectMake(_pickerView.frame.origin.x, _pickerView.frame.origin.y, _pickerView.frame.size.width, showMaxRow * KRowHeight);
}

// 自动滑动到当前时间
- (void)scrollToCurrentTimeOnPickView{
    
    // 获取当前时间
    [self.enterTimeArr removeAllObjects];
    NSDate *date = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *time = [dateFormatter stringFromDate:date];
    self.enterTimeFlag = time;
    NSArray *enterTimeArr = [time componentsSeparatedByString:@"-"];
    for (NSString *str in enterTimeArr) {// 变更以0开头的日期, 比如 09号, 变更为 9号
        [self.enterTimeArr addObject:[NSString stringWithFormat:@"%zd", str.integerValue]];
    }
    
    self.year = self.enterTimeArr[0];
    self.month = self.enterTimeArr[1];
    self.day = self.enterTimeArr[2];
    self.hour = self.enterTimeArr[3];
    self.minute = self.enterTimeArr[4];
    self.second = self.enterTimeArr[5];
    
    NSInteger flag = KMoreSection / 2;
    NSInteger scrollIndexForYear = [self.yearArr indexOfObject:self.year];
    NSInteger scrollIndexForMonth = [self.monthArr indexOfObject:self.month];
    NSInteger scrollIndexForDay = [self.dayArr indexOfObject:self.day];
    NSInteger scrollIndexForHour = [self.hourArr indexOfObject:self.hour];
    NSInteger scrollIndexForMinute = [self.minuteArr indexOfObject:self.minute];
    NSInteger scrollIndexForSeconde = [self.secondArr indexOfObject:self.second];
    
    if (flag > 1) {
        scrollIndexForYear += self.yearArr.count * flag;
        scrollIndexForMonth += self.monthArr.count * flag;
        scrollIndexForDay += self.dayArr.count * flag;
        scrollIndexForHour += self.hourArr.count * flag;
        scrollIndexForMinute += self.minuteArr.count * flag;
        scrollIndexForSeconde += self.secondArr.count * flag;
    }
    
    [self.pickerView selectRow:scrollIndexForYear inComponent:0 animated:YES];
    [self.pickerView selectRow:scrollIndexForMonth inComponent:1 animated:YES];
    [self.pickerView selectRow:scrollIndexForDay inComponent:2 animated:YES];
    [self.pickerView selectRow:scrollIndexForHour inComponent:3 animated:YES];
    [self.pickerView selectRow:scrollIndexForMinute inComponent:4 animated:YES];
    [self.pickerView selectRow:scrollIndexForSeconde inComponent:5 animated:YES];
    
    // 刷新日
    [self refreshDay];
    [self caculateTimeIntervalResultBlock:nil];
}

#pragma mark - 点击方法
// 保存按钮点击方法
- (void)saveBtnClick {
    
    NSLog(@"点击了保存");
    [self show:NO];
    [self caculateTimeIntervalResultBlock:^(NSString *futureTime, long timeStampMargin) {
        
        if ([self.delegate respondsToSelector:@selector(datePickerViewSaveBtnClickDelegateDatePickerView:futureTime:timeStampMargin:)]) {
            [self.delegate datePickerViewSaveBtnClickDelegateDatePickerView:self futureTime:futureTime timeStampMargin:timeStampMargin];
        }
    }];
}

// 取消按钮点击方法
- (void)cancelBtnClick {
    
    NSLog(@"点击了取消");
    [self show:NO];
    if ([self.delegate respondsToSelector:@selector(datePickerViewCancelBtnClickDelegateDatePickerView:)]) {
        [self.delegate datePickerViewCancelBtnClickDelegateDatePickerView:self];
    }
}

- (void)caculateTimeIntervalResultBlock:(void(^)(NSString *futureTime, long timeStampMargin))resultBlock{
    
    NSString *year = [NSString stringWithFormat:@"%04zd", self.year.integerValue];
    NSString *month = [NSString stringWithFormat:@"%02zd", self.month.integerValue];
    NSString *day = [NSString stringWithFormat:@"%02zd", self.day.integerValue];
    NSString *hour = [NSString stringWithFormat:@"%02zd", self.hour.integerValue];
    NSString *minute = [NSString stringWithFormat:@"%02zd", self.minute.integerValue];
    NSString *second = [NSString stringWithFormat:@"%02zd", self.second.integerValue];
    NSString *futureTimeTemp = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@", year, month, day, hour, minute, second];
    NSString *futureTime = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", year, month, day, hour, minute, second];//回调用于显示
    
    __weak __typeof(self) weakSelf = self;
    __block long timeStampMargin = 0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 目标时间戳
        long futureTimeStamp = [weakSelf getTimeStampForTimeString:futureTimeTemp];
        
        // 当前时间戳
        long currentTimeStamp = [weakSelf getTimeStampForTimeString:weakSelf.enterTimeFlag];
        
        // 时间戳间隔
        timeStampMargin = futureTimeStamp - currentTimeStamp;
        
        // 计算 年月日时分秒
        long secondInOneHour = 60 * 60;
        long secondInOneDay = secondInOneHour * 24;
        int days = (int)(timeStampMargin / secondInOneDay);
        int hours = (int) (timeStampMargin % secondInOneDay / secondInOneHour);
        int minutes = (int)(timeStampMargin % (secondInOneHour * 24) % secondInOneHour / 60);
        int seconds = (int)(timeStampMargin % (secondInOneHour * 24) % secondInOneHour % 60);
        NSString *dateContent = [[NSString alloc] initWithFormat:@"距离现在还有：%d天%d小时%d分钟%d秒",days, hours, minutes, seconds];// 距离失效还有：16天12小时50分钟10秒
        
        // 更新ui
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.timeMarginLabel.text = dateContent;
            
            if (resultBlock) {
                resultBlock(futureTime, timeStampMargin);
            }
        });
    });
}

// 将时间文本转换成 时间戳
- (long)getTimeStampForTimeString:(NSString *)timeString{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    NSDate *lastDate = [formatter dateFromString:timeString];
    long timeStamp = [lastDate timeIntervalSince1970];
    return timeStamp;
}

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource
// UIPickerView返回多少组
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return self.dataArray.count;
}

// UIPickerView返回每组多少条数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [self.dataArray[component] count] * KMoreSection;// 让数据重复, 这样就可以实现轮番滑动了
}

// UIPickerView返回每一行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return KRowHeight;
}

// UIPickerView返回每一行的View
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *titleLabel = (UILabel *)view;
    if (!titleLabel) {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width / self.dataArray.count, KRowHeight)];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = UIColorFromHex(0xFFFFFF);
        titleLabel.text = [self.dataArray[component] objectAtIndex:row%[self.dataArray[component] count]];
    }
    return titleLabel;
}

// UIPickerView选择哪一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    switch (component) {
        case 0: { // 年
            
            NSString *selectYearStr = self.yearArr[row%[self.dataArray[component] count]];
            if (self.forbiddenAutoScrolled) {
                self.year = selectYearStr;
                return;
            }
            
            NSString *enterTime_Year = self.enterTimeArr[component];
            if (selectYearStr.integerValue < enterTime_Year.integerValue) {
                
                // 如果选择的年小于当前的年, 需要重置到当前的年
                NSInteger currentYearIndex = [self.dataArray[component] indexOfObject:enterTime_Year];
                [pickerView selectRow:currentYearIndex inComponent:component animated:YES];
            } else {
                
                self.year = selectYearStr;
                [self refreshDay]; // 刷新天数
                // 根据当前选择的年份和月份获取当月的天数
                NSString *dayStr = [self getDayNumberWithYearStr:self.year monthStr:self.month];
                if (self.dayArr.count > dayStr.integerValue) {// 可能突然变成闰年, 同时又是2月
                    if (self.day.integerValue > dayStr.integerValue) {// 之前是31号, 现在需要变成29号
                        
                        [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                    }
                }
            }
        } break;
        case 1: { // 月
            
            NSString *month_value = self.monthArr[row%[self.dataArray[component] count]];
            
            if (self.forbiddenAutoScrolled) {
                self.month = month_value;
                [self refreshDay];// 刷新日
                return;
            }
            
            // 1. 如果选择年大于当前年 就直接赋值月
            if ([self.year integerValue] > [self.enterTimeArr[0] integerValue]) {
                
                self.month = month_value;
                
                // 根据当前选择的年份和月份获取当月的天数
                NSString *dayStr = [self getDayNumberWithYearStr:self.year monthStr:self.month];
                if (self.dayArr.count > dayStr.integerValue) {
                    if (self.day.integerValue > dayStr.integerValue) {
                        
                        [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                    }
                }
                // 如果选择的年等于当前年，就判断月份
            } else if ([self.year integerValue] == [self.enterTimeArr[0] integerValue]) {
                
                if (month_value.integerValue < [self.enterTimeArr[component] integerValue]) {
                    
                    // 如果选择的月份小于当前月份 就刷新到当前月份
                    NSString *currentMonth = self.enterTimeArr[component];
                    NSInteger currentMonthIndex = [self.dataArray[component] indexOfObject:currentMonth];
                    [pickerView selectRow:currentMonthIndex inComponent:component animated:YES];
                } else {
                    
                    // 如果选择的月份大于当前月份，就直接赋值月份
                    self.month = month_value;
                    
                    // 根据当前选择的年份和月份获取当月的天数
                    NSString *dayStr = [self getDayNumberWithYearStr:self.year monthStr:self.month];
                    if (self.dayArr.count > dayStr.integerValue) {
                        if (self.day.integerValue > dayStr.integerValue) {
                            
                            [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                        }
                    }
                }
            }
        } break;
        case 2: { // 日
            
            // 根据当前选择的年份和月份获取当月的天数
            NSString *dayStr = [self getDayNumberWithYearStr:self.year monthStr:self.month];
            
            // 如果选择年大于当前年 就直接赋值日
            NSString *day_value = self.dayArr[row%[self.dataArray[component] count]];
            
            if (self.forbiddenAutoScrolled) {
                self.day = day_value;
                return;
            }
            
            if ([self.year integerValue] > [self.enterTimeArr[0] integerValue]) {
                if ((self.dayArr.count > dayStr.integerValue) && (day_value.integerValue > dayStr.integerValue)) {
                    [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                } else {
                    self.day = day_value;
                }
            } else if ([self.year integerValue] == [self.enterTimeArr[0] integerValue]) {
                
                // 如果选择的年等于当前年，就判断月份
                
                // 如果选择的月份大于当前月份 就直接复制
                if ([self.month integerValue] > [self.enterTimeArr[1] integerValue]) {
                    if ((self.dayArr.count > dayStr.integerValue) && (day_value.integerValue > dayStr.integerValue)) {
                        [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                    } else {
                        self.day = day_value;
                    }
                } else if ([self.month integerValue] == [self.enterTimeArr[1] integerValue]) {
                    
                    // 如果选择的月份等于当前月份，就判断日
                    
                    // 如果选择的日小于当前日，就刷新到当前日
                    if (day_value.integerValue < [self.enterTimeArr[component] integerValue]) {
                        
                        [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                    } else {
                        
                        // 如果选择的日大于当前日，就复制日
                        if ((self.dayArr.count > dayStr.integerValue) && (day_value.integerValue > dayStr.integerValue)) {
                            [self updateDayTimeWithPickerView:pickerView dayStr:dayStr];
                        } else {
                            self.day = day_value;
                        }
                    }
                }
            }
        } break;
        case 3: { // 时
            
            NSString *hour_value = self.hourArr[row%[self.dataArray[component] count]];
            if (self.forbiddenAutoScrolled) {
                self.hour = hour_value;
                return;
            }
            
            // 如果选择年大于当前年 就直接赋值时
            if ([self.year integerValue] > [self.enterTimeArr[0] integerValue]) {
                
                self.hour = hour_value;
            } else if ([self.year integerValue] == [self.enterTimeArr[0] integerValue]) {
                
                // 如果选择的年等于当前年，就判断月份
                
                // 如果选择的月份大于当前月份 就直接复制时
                if ([self.month integerValue] > [self.enterTimeArr[1] integerValue]) {
                    
                    self.hour = hour_value;
                } else if ([self.month integerValue] == [self.enterTimeArr[1] integerValue]) {
                    
                    // 如果选择的月份等于当前月份，就判断日
                    if ([self.day integerValue] > [self.enterTimeArr[2] integerValue]) {
                        
                        // 如果选择的日大于当前日，就直接复制时
                        self.hour = hour_value;
                    } else if ([self.day integerValue] == [self.enterTimeArr[2] integerValue]) {
                        
                        // 如果选择的日等于当前日，就判断时
                        if ([hour_value integerValue] < [self.enterTimeArr[3] integerValue]) {
                            
                            // 如果选择的时小于当前时，就刷新到当前时
                            NSInteger maxHourIndex = [self.dataArray[3] indexOfObject:self.enterTimeArr[component]];
                            [pickerView selectRow:maxHourIndex inComponent:3 animated:YES];
                        } else {
                            // 如果选择的时大于当前时，就直接赋值
                            self.hour = hour_value;
                        }
                    }
                }
            }
        } break;
        case 4: { // 分
            
            NSString *minute_value = self.minuteArr[row%[self.dataArray[component] count]];
            if (self.forbiddenAutoScrolled) {
                self.minute = minute_value;
                return;
            }
            // 如果选择年大于当前年 就直接赋值时
            if ([self.year integerValue] > [self.enterTimeArr[0] integerValue]) {
                
                self.minute = minute_value;
                // 如果选择的年等于当前年，就判断月份
            } else if ([self.year integerValue] == [self.enterTimeArr[0] integerValue]) {
                
                // 如果选择的月份大于当前月份 就直接复制时
                if ([self.month integerValue] > [self.enterTimeArr[1] integerValue]) {
                    
                    self.minute = minute_value;
                    // 如果选择的月份等于当前月份，就判断日
                } else if ([self.month integerValue] == [self.enterTimeArr[1] integerValue]) {
                    
                    // 如果选择的日大于当前日，就直接复制时
                    if ([self.day integerValue] > [self.enterTimeArr[2] integerValue]) {
                        
                        self.minute = minute_value;
                        // 如果选择的日等于当前日，就判断时
                    } else if ([self.day integerValue] == [self.enterTimeArr[2] integerValue]) {
                        
                        // 如果选择的时大于当前时，就直接赋值
                        if ([self.hour integerValue] > [self.enterTimeArr[3] integerValue]) {
                            
                            self.minute = minute_value;
                            // 如果选择的时等于当前时,就判断分
                        } else if ([self.hour integerValue] == [self.enterTimeArr[3] integerValue]) {
                            
                            // 如果选择的分小于当前分，就刷新分
                            if ([minute_value integerValue] < [self.enterTimeArr[4] integerValue]) {
                                
                                NSInteger maxMinuteIndex = [self.dataArray[4] indexOfObject:self.enterTimeArr[component]];
                                [pickerView selectRow:maxMinuteIndex inComponent:4 animated:YES];
                                // 如果选择分大于当前分，就直接赋值
                            } else {
                                self.minute = minute_value;
                            }
                        }
                    }
                }
            }
        } break;
        case 5:{ // 秒
            
            NSString *second_value = self.secondArr[row%[self.dataArray[component] count]];
            if (self.forbiddenAutoScrolled) {
                self.second = second_value;
                return;
            }
            // 如果选择年大于当前年 就直接赋值时
            if ([self.year integerValue] > [self.enterTimeArr[0] integerValue]) {
                
                self.second = second_value;
                // 如果选择的年等于当前年，就判断月份
            } else if ([self.year integerValue] == [self.enterTimeArr[0] integerValue]) {
                
                // 如果选择的月份大于当前月份 就直接复制时
                if ([self.month integerValue] > [self.enterTimeArr[1] integerValue]) {
                    
                    self.second = second_value;
                    // 如果选择的月份等于当前月份，就判断日
                } else if ([self.month integerValue] == [self.enterTimeArr[1] integerValue]) {
                    
                    // 如果选择的日大于当前日，就直接复制时
                    if ([self.day integerValue] > [self.enterTimeArr[2] integerValue]) {
                        
                        self.second = second_value;
                        // 如果选择的日等于当前日，就判断时
                    } else if ([self.day integerValue] == [self.enterTimeArr[2] integerValue]) {
                        
                        // 如果选择的时大于当前时，就直接赋值
                        if ([self.hour integerValue] > [self.enterTimeArr[3] integerValue]) {
                            
                            self.second = second_value;
                            // 如果选择的时等于当前时,就判断分
                        } else if ([self.hour integerValue] == [self.enterTimeArr[3] integerValue]) {
                            
                            // 如果选择的分大于当前分，就直接赋值
                            if ([self.minute integerValue] > [self.enterTimeArr[4] integerValue]) {
                                
                                self.second = second_value;
                            } else if([self.minute integerValue] == [self.enterTimeArr[4] integerValue]){
                                
                                // 如果选择的秒小于当前分，就刷新分
                                if ([second_value integerValue] < [self.enterTimeArr[5] integerValue]) {
                                    
                                    NSInteger maxSecondIndex = [self.dataArray[5] indexOfObject:self.enterTimeArr[component]];
                                    [pickerView selectRow:maxSecondIndex inComponent:5 animated:YES];
                                    // 如果选择分大于当前分，就直接赋值
                                } else {
                                    self.second = second_value;
                                }
                            }
                        }
                    }
                }
            }
        }break;
        default: break;
    }
    
    // 刷新日
    [self refreshDay];
    
    // 滑动后就计算剩余时间
    [self caculateTimeIntervalResultBlock:nil];
}

// 自动矫正 - 月
- (void)updateDayTimeWithPickerView:(UIPickerView *)pickerView dayStr:(NSString *)dayStr{
    
    NSInteger maxDayIndex = [self.dataArray[2] indexOfObject:dayStr];
    [pickerView selectRow:maxDayIndex inComponent:2 animated:YES];
}

- (UIButton *)shadowButton{
    
    if (_shadowButton == nil) {
        _shadowButton = [[UIButton alloc] init];
        _shadowButton.frame = [UIScreen mainScreen].bounds;
        [_shadowButton addTarget:self action:@selector(shutDownMySelf) forControlEvents:UIControlEventTouchUpInside];
        _shadowButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.superview insertSubview:_shadowButton belowSubview:self];
    }
    return _shadowButton;
}

- (void)shutDownMySelf{
    
    self.shadowButton.hidden = YES;
    self.show = NO;
}

- (NSMutableArray *)enterTimeArr{
    
    if (_enterTimeArr == nil) {
        _enterTimeArr = [[NSMutableArray alloc] init];
    }
    return _enterTimeArr;
}

- (NSMutableArray *)dataArray{
    
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

// 获取年份
- (NSMutableArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [NSMutableArray array];
        for (int i = 1970; i < 2099; i ++) {
            [_yearArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _yearArr;
}

// 获取月份
- (NSMutableArray *)monthArr {
    
    if (!_monthArr) {
        _monthArr = [NSMutableArray array];
        for (int i = 1; i <= 12; i ++) {
            [_monthArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _monthArr;
}

// 获取当前月的天数
- (NSMutableArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [NSMutableArray array];
        for (int i = 1; i <= 31; i ++) {
            [_dayArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _dayArr;
}

// 获取小时
- (NSMutableArray *)hourArr {
    if (!_hourArr) {
        _hourArr = [NSMutableArray array];
        for (int i = 0; i < 24; i ++) {
            [_hourArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _hourArr;
}

- (NSMutableArray *)minuteArr{
    
    if (!_minuteArr) {
        _minuteArr = [NSMutableArray array];
        for (int i = 0; i < 60; i ++) {
            [_minuteArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _minuteArr;
}

- (NSMutableArray *)secondArr{
    
    if (!_secondArr) {
        _secondArr = [NSMutableArray array];
        for (int i = 0; i < 60; i ++) {
            [_secondArr addObject:[NSString stringWithFormat:@"%d", i]];
        }
    }
    return _secondArr;
}

- (void)refreshDay {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 1; i < [self getDayNumberWithYearStr:self.year monthStr:self.month].integerValue + 1; i ++) {
        [arr addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    [self.dataArray replaceObjectAtIndex:2 withObject:arr];// 替换数据源
    [self.pickerView reloadComponent:2];// 刷新数据
}

- (NSString *)getDayNumberWithYearStr:(NSString *)yearStr monthStr:(NSString *)monthStr{
    NSInteger year = yearStr.integerValue;
    NSInteger month = monthStr.integerValue;
    NSArray *days = @[@"31", @"28", @"31", @"30", @"31", @"30", @"31", @"31", @"30", @"31", @"30", @"31"];
    if (2 == month && 0 == (year % 4) && (0 != (year % 100) || 0 == (year % 400))) {
        return @"29";
    }
    return days[month - 1];
}

@end
