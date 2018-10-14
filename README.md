# CCActionSheet
仿微信的actionsheet

酱紫用

CCActionSheet * sheet = [[CCActionSheet alloc] initWithTitle:@"这是一个很长很长很长很长很长很长很长很长很长很长的标题"];
[sheet cc_addActionWithTitle:@"变" handle:^(UIButton *sender) {
    NSLog(@"略略略");
}];
[sheet cc_addActionWithTitle:@"按钮2" style:CCActionButtonStyleDestructive handle:^(UIButton *sender) {
    NSLog(@"嗯哼");
}];
[sheet cc_showInView:self.view.window];
