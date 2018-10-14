//
//  CCActionSheet.m
//
//
//  Created by Chen on 2017/5/31.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCActionSheet.h"
#import "UIButton+CCActionSheet.h"
#import <sys/utsname.h>

#ifndef CC_ScreenWidth
    #define CC_ScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#endif

#ifndef CC_ScreenHeight
    #define CC_ScreenHeight   ([UIScreen mainScreen].bounds.size.height)
#endif


//! 每个按钮的高度
static CGFloat const cc_buttonHeight    =   49.5f;
//! 两个按钮的间距
static CGFloat const cc_buttonPadding   =   0.5f;
//! 取消按钮与上一按钮的间距
static CGFloat const cc_cancelPadding   =   5.f;

//! 计算title所占的尺寸
CGSize cc_sizeWithString (NSString * string, UIFont * font, CGFloat maxWidth) {
    if (string == nil || [string isKindOfClass:[NSNull class]]) {
        return CGSizeZero;
    }
    CGSize maxSize = CGSizeMake(maxWidth, MAXFLOAT);
    CGSize stringSize;
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        stringSize = [string boundingRectWithSize:maxSize options:options attributes:@{NSFontAttributeName:font} context:nil].size;
    } else {
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
        [attrStr addAttribute:NSFontAttributeName value:font range:[string rangeOfString:string]];
        stringSize = [attrStr boundingRectWithSize:maxSize options:options context:nil].size;
    }
    return stringSize;
}

//! 底部高度，给iPhoneX准备的
CGFloat cc_heightOfBottom () {
    struct utsname systemInfo;
    uname(&systemInfo);
    BOOL isPhoneX = NO;
    NSString * platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"]) {
        isPhoneX = YES;
    }
    //  如果是模拟器，通过尺寸来判断是不是iPhoneX
    else if ([platform isEqualToString:@"x86_64"] || [platform isEqualToString:@"i386"]) {
        isPhoneX = [UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO;
    }
    return isPhoneX ? 34 : 0;
}



@interface CCActionSheet () {
    CGSize size;
}

//! 背景
@property (nonatomic, strong)   UIView * vBack;

//! 显示标题的view
@property (nonatomic, strong)   UIView * vTitle;
@property (nonatomic, strong)   UILabel * lblTitle;

//! 取消按钮
@property (nonatomic, strong)   UIButton * btnCancel;
//! bottomView，用于iPhoneX
@property (nonatomic, strong)   UIView * vBottom;

//! 按钮数组，除取消按钮外，都在这
@property (nonatomic, strong)   NSMutableArray * arrBtns;

@end

@implementation CCActionSheet

//! 刷新subview的frame
- (void)resizeFrame {
    self.vBack.frame = CGRectMake(0, CC_ScreenHeight, CC_ScreenWidth, cc_cancelPadding+self.vTitle.frame.size.height+cc_buttonPadding+(1+self.arrBtns.count)*(cc_buttonPadding+cc_buttonHeight));
    self.btnCancel.frame = CGRectMake(0, _vBack.frame.size.height-cc_buttonHeight-cc_heightOfBottom(), CC_ScreenWidth, cc_buttonHeight);
    self.vBottom.frame = CGRectMake(0, _vBack.frame.size.height-cc_heightOfBottom(), CC_ScreenWidth, cc_heightOfBottom());
    
    for (int i = 0; i < self.arrBtns.count; i ++) {
        UIButton * btn = self.arrBtns[i];
        btn.frame = CGRectMake(0, CGRectGetMinY(self.btnCancel.frame)-cc_cancelPadding-(cc_buttonHeight+cc_buttonPadding)*(i+1), CC_ScreenWidth, cc_buttonHeight);
    }
}

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super initWithFrame:CGRectMake(0, 0, CC_ScreenWidth, CC_ScreenHeight)]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        __weak typeof(self) weakSelf = self;
        UITapGestureRecognizer * ges = ({
            UITapGestureRecognizer * ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickBackground)];
            ges;
        });
        [self addGestureRecognizer:ges];
        _arrBtns = [NSMutableArray new];
        _vBack = ({
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, CC_ScreenHeight, CC_ScreenWidth, 0)];
            view.backgroundColor = [UIColor colorWithRed:0xe9/255.0 green:0xe9/255.0 blue:0xe9/255.0 alpha:1.0];
            view;
        });
        _vBottom = ({
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, CC_ScreenHeight, CC_ScreenWidth, cc_heightOfBottom())];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
        _btnCancel = ({
            UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(0, _vBack.frame.size.height-cc_buttonHeight, CC_ScreenWidth, cc_buttonHeight);
            btn.backgroundColor = [UIColor whiteColor];
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn cc_addEventHandler:^(UIButton *sender) {
                [weakSelf cc_hide];
            } forEvent:UIControlEventTouchUpInside];
            btn;
        });
        
        //! title文字所要占据的高度
        CGSize szTitle = cc_sizeWithString(title, [UIFont systemFontOfSize:14], CC_ScreenWidth-30);
        _vTitle = ({
            UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CC_ScreenWidth, szTitle.height ? szTitle.height+30 : 0)];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
        _lblTitle = ({
            UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, CC_ScreenWidth-30, szTitle.height)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.font = [UIFont systemFontOfSize:14];
            lbl.textColor = [UIColor grayColor];
            lbl.numberOfLines = 0;
            lbl.text = title;
            lbl;
        });
        
        self.lblTitle.center = self.vTitle.center;
        [self.vTitle addSubview:_lblTitle];
        [self.vBack addSubview:_vBottom];
        [self.vBack addSubview:_vTitle];
        [self.vBack addSubview:_btnCancel];
        
        [self addSubview:self.vBack];
    }
    return self;
}

#pragma mark - get

- (NSInteger)countOfButtons {
    return _arrBtns.count;
}

#pragma mark - public
//! 添加一个按钮
- (void)cc_addActionWithTitle:(NSString *)title handle:(void (^)(UIButton *sender))handler {
    [self cc_addActionWithTitle:title style:CCActionButtonStyleDefault handle:handler];
}

- (void)cc_addActionWithTitle:(NSString *)title style:(CCActionButtonStyle)style handle:(void (^)(UIButton *sender))handler {
    __weak typeof(self) weakSelf = self;
    UIButton * button = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIColor * titleColor = style == CCActionButtonStyleDestructive ? [UIColor redColor] : [UIColor blackColor];
        btn.frame = CGRectMake(0, _vBack.frame.size.height-cc_buttonHeight, CC_ScreenWidth, cc_buttonHeight);
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
        [btn cc_addEventHandler:^(UIButton *sender) {
            [weakSelf cc_hide];
            handler(sender);
        } forEvent:UIControlEventTouchUpInside];
        btn;
    });
    [self.arrBtns addObject:button];
    [self.vBack addSubview:button];
    
    [self resizeFrame];
}

//! 显示
- (void)cc_showInView:(UIView *)vTarget {
    if ([vTarget isMemberOfClass:[UIWindow class]]) {
        [vTarget addSubview:self];
    } else {
        [vTarget.window addSubview:self];
    }
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.vBack.frame;
        frame.origin.y -= frame.size.height;
        self.vBack.frame = frame;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    }];
}

- (void)cc_hide {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.vBack.frame;
        frame.origin.y += frame.size.height;
        self.vBack.frame = frame;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


#pragma mark -

//! 点击背景，隐藏
- (void)onClickBackground {
    [self cc_hide];
}

@end
