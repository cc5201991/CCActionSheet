//
//  CCActionSheet.h
//  
//
//  Created by Chen on 2017/5/31.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

//! 按钮样式
typedef NS_ENUM(NSInteger, CCActionButtonStyle) {
    CCActionButtonStyleDefault = 0,
    CCActionButtonStyleDestructive
};


@interface CCActionSheet : UIView

//! 按钮的数量(不包括取消按钮)
@property (nonatomic, assign, readonly)     NSInteger countOfButtons;

- (instancetype)initWithTitle:(NSString *)title;

//! 添加一个按钮
- (void)cc_addActionWithTitle:(NSString *)title handle:(void (^)(UIButton *sender))handler;
- (void)cc_addActionWithTitle:(NSString *)title style:(CCActionButtonStyle)style handle:(void (^)(UIButton *sender))handler;

//! 显示
- (void)cc_showInView:(UIView *)vTarget;

//! 消失
- (void)cc_hide;



@end
