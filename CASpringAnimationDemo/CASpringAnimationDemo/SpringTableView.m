//
//  SpringTableView.m
//  CASpringAnimationDemo
//
//  Created by Xx on 2020/6/5.
//  Copyright © 2020 Xx. All rights reserved.
//

#import "SpringTableView.h"

@implementation SpringTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//点击事件透传

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    if ( !self.dragging ) {
        [[self nextResponder] touchesBegan:touches withEvent:event];
    }
}
 
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if ( !self.dragging ) {
        [[self nextResponder] touchesEnded:touches withEvent:event];
    }
}

@end
