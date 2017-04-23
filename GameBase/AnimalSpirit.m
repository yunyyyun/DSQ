//
//  AnimalSpirit.m
//  DSQ
//
//  Created by mengyun on 2017/4/6.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "AnimalSpirit.h"

@implementation AnimalSpirit

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.type=0;
        self.isBackUp=YES;
        self.spinTime=0.6;
        self.isSelected=NO;
    }
    return self;
}

- (void)setAnimalIndex:(NSInteger)animalIndex{
    _animalIndex = animalIndex;
}

- (void)setIsBackUp:(BOOL)isBackUp{
    //if (_isBackUp && !isBackUp){
        [self flip];
    //}
    _isBackUp = isBackUp;
}

- (void)setIsSelected:(BOOL)isSelected{//选中和非选中状态切换
    if (_isSelected!=isSelected){
        if (!_isSelected){
            //[self.gameView bringSubviewToFront:selectButton];
            [self.superview bringSubviewToFront:self];
            CGFloat widthIncrement = 4.0;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.1];
            
            CGRect tempF = _positiveView.frame;
            _tmpFrame = tempF;
            tempF.origin.x -= widthIncrement;
            tempF.origin.y -= widthIncrement;
            tempF.size.width += 2*widthIncrement;
            tempF.size.height += 2*widthIncrement;
            _positiveView.frame = tempF;
            [UIView commitAnimations];
        }
        else{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.1];
            _positiveView.frame = _tmpFrame;
            [self roundView: self.positiveView];
            [UIView commitAnimations];
        }
    }
    _isSelected = isSelected;
}

- (void) setBackView:(UIView *)backView{
    _backView = backView;
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.backView setFrame: frame];
    //[self roundView: self.primaryView];
    self.backView.userInteractionEnabled = YES;
    [self addSubview: self.backView];
    self.backView.userInteractionEnabled = NO;
}

- (void) setPositiveView:(UIView *)positiveView{
    _positiveView = positiveView;
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.positiveView setFrame: frame];
    [self roundView: self.positiveView];
    self.positiveView.userInteractionEnabled = YES;
    [self addSubview: self.positiveView];
    [self sendSubviewToBack:self.positiveView];
    self.positiveView.userInteractionEnabled = NO;
    
}

- (void)roundView:(UIView *)view{
    
    [view.layer setCornerRadius:6];
    [view.layer setMasksToBounds:YES];
    
    [view.layer setBorderWidth:2.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,_animalIndex<9?(CGFloat[]){ 1, 0, 0, 1 }:(CGFloat[]){ 0, 0, 1, 1 });
    [view.layer setBorderColor:colorref];//边框颜色
}

- (void)roundViewSelected:(UIView *)view{
    [view.layer setCornerRadius:6];
    [view.layer setMasksToBounds:YES];
    
    [view.layer setBorderWidth:4.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,_animalIndex<9?(CGFloat[]){ 1, 0, 0, 1 }:(CGFloat[]){ 0, 0, 1, 1 });
    [view.layer setBorderColor:colorref];//边框颜色
}

-(void) flip{
    [UIView transitionFromView:(_isBackUp?_backView:_positiveView)
                        toView:(_isBackUp?_positiveView:_backView)
                      duration: _spinTime
                       options: UIViewAnimationOptionTransitionFlipFromLeft+UIViewAnimationOptionCurveEaseInOut
                    completion:^(BOOL finished) {
                        if (finished) {
                        }
                    }];
}

@end
