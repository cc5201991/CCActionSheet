//
//  UIButton+CCActionSheet.h
//  ProjectManager
//
//  Created by ChenChang on 2017/6/1.
//  Copyright © 2017年 DTE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (CCActionSheet)

//! 添加一个事件
- (void)cc_addEventHandler:(void (^)(UIButton * sender))handler forEvent:(UIControlEvents)event;

//! 移除一个事件
- (void)cc_removeEventHandlersForEvent:(UIControlEvents)event;


@end
