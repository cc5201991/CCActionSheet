//
//  ViewController.m
//  CCActionSheet
//
//  Created by Chen on 2018/10/14.
//  Copyright © 2018年 Chen. All rights reserved.
//

#import "ViewController.h"
#import "CCActionSheet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton * button = ({
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(50, 300, self.view.frame.size.width-100, 40);
        [btn setTitle:@"点击按钮" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(onClickButton) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    [self.view addSubview:button];
}


#pragma mark - onClick
//! 点击按钮
- (void)onClickButton {
    CCActionSheet * sheet = [[CCActionSheet alloc] initWithTitle:@"这是一个很长很长很长很长很长很长很长很长很长很长的标题"];
    [sheet cc_addActionWithTitle:@"变" handle:^(UIButton *sender) {
        NSLog(@"略略略");
    }];
    [sheet cc_addActionWithTitle:@"按钮2" style:CCActionButtonStyleDestructive handle:^(UIButton *sender) {
        NSLog(@"嗯哼");
    }];
    [sheet cc_showInView:self.view.window];
}




@end
