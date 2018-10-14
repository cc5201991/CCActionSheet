//
//  UIButton+CCActionSheet.m
//  ProjectManager
//
//  Created by ChenChang on 2017/6/1.
//  Copyright © 2017年 DTE. All rights reserved.
//

#import "UIButton+CCActionSheet.h"
#import <objc/runtime.h>

static const void *CCControlHandlersKey = &CCControlHandlersKey;


@interface CCControlWrapper : NSObject <NSCopying>

- (instancetype)initWithHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents;

@property (nonatomic) UIControlEvents controlEvents;
@property (nonatomic, copy) void (^handler)(id sender);

@end

@implementation CCControlWrapper

- (instancetype)initWithHandler:(void (^)(id sender))handler forControlEvents:(UIControlEvents)controlEvents {
    self = [super init];
    if (!self) return nil;
    
    self.handler = handler;
    self.controlEvents = controlEvents;
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return [[CCControlWrapper alloc] initWithHandler:self.handler forControlEvents:self.controlEvents];
}

- (void)invoke:(id)sender {
    self.handler(sender);
}

@end





@implementation UIButton (CCActionSheet)

- (void)cc_addEventHandler:(void (^)(UIButton * sender))handler forEvent:(UIControlEvents)event {
    NSParameterAssert(handler);
    
    NSMutableDictionary *events = objc_getAssociatedObject(self, CCControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, CCControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSNumber *key = @(event);
    NSMutableSet *handlers = events[key];
    if (!handlers) {
        handlers = [NSMutableSet set];
        events[key] = handlers;
    }
    
    CCControlWrapper *target = [[CCControlWrapper alloc] initWithHandler:handler forControlEvents:event];
    [handlers addObject:target];
    [self addTarget:target action:@selector(invoke:) forControlEvents:event];
}


- (void)cc_removeEventHandlersForEvent:(UIControlEvents)event {
    NSMutableDictionary *events = objc_getAssociatedObject(self, CCControlHandlersKey);
    if (!events) {
        events = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, CCControlHandlersKey, events, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    NSNumber *key = @(event);
    NSSet *handlers = events[key];
    
    if (!handlers)
        return;
    
    [handlers enumerateObjectsUsingBlock:^(id sender, BOOL *stop) {
        [self removeTarget:sender action:NULL forControlEvents:event];
    }];
    
    [events removeObjectForKey:key];
}


@end
