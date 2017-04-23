//
//  AIManager.m
//  DSQ
//
//  Created by mengyun on 2017/4/17.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "AIManager.h"

static AIManager *aiManager = nil;

@implementation AIManager

- (instancetype) init{
    self = [super init];
    if (self) {
        _fristTag = 0;
        _secondTag = 0;
    }
    return self;
}

// 单利获取对象
+ (instancetype)manager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aiManager = [[AIManager alloc] init];
    });
    return aiManager;
}

- (void)doAI{
    for (int pos=1; pos<21; ++pos){
        if (![_chessBoard.pieces[pos] isEqual:@0] && [_chessBoard isBackUp:pos]){
            NSInteger index = [_chessBoard.pieces[pos] intValue];
            _fristTag =  pos + 100*index;
            return;
        }
    }
    for (int pos=1; pos<21; ++pos){
        if ([_chessBoard clickOnPosition:pos]==Msg_Selected){
            //1 2 3 4
            //5 6 7 8
            //9 101112
            //13141516
            //17181920
            int nextPos = pos-1;
            if ((nextPos>0&&nextPos<21) && ([_chessBoard clickOnPosition:nextPos]==Msg_Move || [_chessBoard clickOnPosition:nextPos]==Msg_Eat)){
                NSInteger index = [_chessBoard.pieces[pos] intValue];
                _fristTag =  pos + 100*index;
                index = [_chessBoard.pieces[nextPos] intValue];
                _secondTag =  nextPos + 100*index;
                return;
            }
            nextPos = pos+1;
            if ((nextPos>0&&nextPos<21) && ([_chessBoard clickOnPosition:nextPos]==Msg_Move || [_chessBoard clickOnPosition:nextPos]==Msg_Eat)){
                NSInteger index = [_chessBoard.pieces[pos] intValue];
                _fristTag =  pos + 100*index;
                index = [_chessBoard.pieces[nextPos] intValue];
                _secondTag =  nextPos + 100*index;
                return;
            }
            nextPos = pos-4;
            if ((nextPos>0&&nextPos<21) && ([_chessBoard clickOnPosition:nextPos]==Msg_Move || [_chessBoard clickOnPosition:nextPos]==Msg_Eat)){
                NSInteger index = [_chessBoard.pieces[pos] intValue];
                _fristTag =  pos + 100*index;
                index = [_chessBoard.pieces[nextPos] intValue];
                _secondTag =  nextPos + 100*index;
                return;
            }
            nextPos = pos+4;
            if ((nextPos>0&&nextPos<21) && ([_chessBoard clickOnPosition:nextPos]==Msg_Move || [_chessBoard clickOnPosition:nextPos]==Msg_Eat)){
                NSInteger index = [_chessBoard.pieces[pos] intValue];
                _fristTag =  pos + 100*index;
                index = [_chessBoard.pieces[nextPos] intValue];
                _secondTag =  nextPos + 100*index;
                return;
            }
            return;
        }
    }
}

@end
