//
//  AnimalSpirit.h
//  DSQ
//
//  Created by mengyun on 2017/4/6.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "PiecesSpirit.h"

@interface AnimalSpirit : PiecesSpirit

@property (nonatomic, assign)NSInteger animalIndex;
/*
 1 xiang 13
 2 shi   14
 3 hu    15
 4 bao   16
 5 lang  17
 6 gou   18
 7 mao   19
 8 shu   20
 */
@property (nonatomic, assign)BOOL isBackUp;
@property (nonatomic, assign)BOOL isSelected;
@property (nonatomic, assign) CGRect tmpFrame;

//-(id)initWithBackView:(UIView *)backView andSPositiveView:(UIView *)positiveView;
//- (void)spiritClick;

@property (nonatomic, retain) UIView *backView;
@property (nonatomic, retain) UIView *positiveView;
- (void)roundView:(UIView *)view;
@property float spinTime;

@end
