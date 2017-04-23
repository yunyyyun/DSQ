//
//  PiecesSpirit.m
//  DSQ
//
//  Created by mengyun on 2017/4/6.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "PiecesSpirit.h"

@implementation PiecesSpirit

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setType:(NSInteger)type{
    _type = type;
    if (_type == 1){
        [self setBackgroundColor:[UIColor colorWithRed:166/255.0 green:88/255.0 blue:44/255.0 alpha:1]];
    }
    if (_type == 2){
        [self setBackgroundColor:[UIColor colorWithRed:133/255.0 green:204/255.0 blue:244/255.0 alpha:1]];
    }
}

//- (void)spiritClick{
//}

@end
