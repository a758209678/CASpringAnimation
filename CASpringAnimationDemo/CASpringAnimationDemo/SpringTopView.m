//
//  SpringTopView.m
//  CASpringAnimationDemo
//
//  Created by Xx on 2020/6/5.
//  Copyright © 2020 Xx. All rights reserved.
//

#import "SpringTopView.h"

@implementation SpringTopView {
    
    UIButton *_blackButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    
    UIView *bacgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 250)];
    bacgroundView.backgroundColor = [UIColor redColor];
    [self addSubview:bacgroundView];
    
    _blackButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 250 - 80, [UIScreen mainScreen].bounds.size.width - 20, 80)];
    _blackButton.backgroundColor = [UIColor blackColor];
    _blackButton.layer.cornerRadius = 8;
    [self addSubview:_blackButton];
}

- (void)buttonClickAction:(UIView *)sender {
    
    if (sender == _blackButton) {
        NSLog(@"点击了黑色按钮");
    }
    
    //如果这里有其他按钮直接判断即可
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isKindOfClass:[UIButton class]]) {
        [self buttonClickAction:view];
    }
    return view;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
