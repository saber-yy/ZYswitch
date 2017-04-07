//
//  ZASwitch.h
//  swtichBtn
//
//  Created by ZhuoApp on 2017/3/29.
//  Copyright © 2017年 ZhuoApp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZASwitch;

typedef void(^SwitchBtnStatusDidChangedBlock)(ZASwitch * switchBtn);

@protocol ZASwitchDelegate <NSObject>

-(void)switchBtnStatuChanged:(ZASwitch *)switchBtn;

@end

@interface ZASwitch : UIButton

/**
 开启条的颜色，默认颜色为蓝色
 */
@property (nonatomic , strong) UIColor * onColor ;

/**
 关闭条的颜色，默认颜色为灰色
 */
@property (nonatomic , strong) UIColor * offColor ;

/**
 开关状态，默认加载为YES
 */
@property (nonatomic , assign) BOOL isOn;

/**
 设置开关状态
 
 @param isOn 开关状态
 @param animated 不设置动画则不会将按钮状态进行回调
 */
-(void)setIsOn:(BOOL)isOn animated:(BOOL)animated;

#pragma mark - 状态回调
//------------------ 以下三种方式都可以收到状态回调 -----------------//

//实现代理可通过代理方法获取按钮的状态
@property (nonatomic , weak) id <ZASwitchDelegate> delegate;

//实现回调块获取按钮的状态
@property (nonatomic , copy) SwitchBtnStatusDidChangedBlock statusBlock;

//设置回调块获取按钮的状态
-(void)setStatusChangedBlock:(SwitchBtnStatusDidChangedBlock)block;

@end
