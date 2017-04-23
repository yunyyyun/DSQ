//
//  Chessboard.m
//  DSQ
//
//  Created by mengyun on 2017/4/4.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "Chessboard.h"
#import "Common.h"

@implementation Chessboard

- (instancetype)init{
    if (self = [super init]) {
        self.lastPos = 0;
        self.currentPos = 0;
        self.backUpNum = 16; //未翻开牌的数量
        self.roundCount = 1;
        self.youFirst = 1;   //1表示先走,0表示后走
        self.yourCampId = -1; //红蓝动物
        self.animals = [[NSMutableArray alloc]init];
        NSMutableArray *arr1 = [[NSMutableArray alloc]init];
        NSMutableArray *arr2 = [[NSMutableArray alloc]init];
        [self.animals addObject:arr1];
        [self.animals addObject:arr2];
        
        self.messageToClient = [NSString stringWithFormat:@"1"];
        self.animalNameArray = @[@"",@"红象",@"红狮",@"红虎",@"红豹",@"红狼",@"红狗",@"红猫",@"红鼠",@"",@"",@"",@"",
                               @"蓝象",@"蓝狮",@"蓝虎",@"蓝豹",@"蓝狼",@"蓝狗",@"蓝猫",@"蓝鼠"];
        self.pieces = [[NSMutableArray alloc]init];
        NSArray *orginArry = @[@1,@2,@3,@4,@5,@6,@7,@8,@13,@14,@15,@16,@17,@18,@19,@20];

        NSArray *randomArry = [self randomArry:orginArry];
        id piece = @0;
        [_pieces addObject:piece]; //0位置保留
        for (int i=0; i<8; ++i) {  //己方动物
            piece = [[randomArry objectAtIndex:i]copy];
            [_pieces addObject:piece];
        }
        piece = @0;
        for (int i=0; i<4; ++i) {  //河界
            [_pieces addObject:piece];
        }
        for (int i=0; i<8; ++i) {   //对方动物
            NSNumber *tmp = [[randomArry objectAtIndex:i+8]copy];
            piece = [NSNumber numberWithInt:[tmp intValue]];
            [_pieces addObject:piece];
        }
        piece = @0;
        for (int i=0; i<20; ++i) {//动物是否翻开
            [_pieces addObject:piece];
        }
    }
    return self;
}

- (NSArray *)randomArry:(NSArray *)arry
{
    // 对数组乱序
    arry = [arry sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int seed = arc4random_uniform(2);
        
        if (seed == 1) {
            return [obj1 integerValue] < [obj2 integerValue];
        } else {
            return [obj2 integerValue] < [obj1 integerValue];
        }
    }];
    return arry;
}

- (NSString *)getMessage{
    return _messageToClient;
}

- (int)clickOnPosition:(NSInteger)pos
{
    NSLog(@"%ld,pos=%ld",(long)_lastPos,(long)pos);
    _messageToClient = [NSString stringWithFormat:@""];
    if (![_pieces[pos] isEqual:@0] && [self isBackUp:pos] && (pos<9||pos>12)){//陆地是未翻开的动物
        if (_lastPos !=0){
            _lastPos = 0;
            return Msg_CancelLastSelected; //将上次的选中取消
        }
        _pieces[pos+20] = @1;
        _messageToClient = [NSString stringWithFormat:@"翻开%@",[self animalName:pos]];
        _backUpNum -= 1;
        [self animalsChangeWithAnimalType:[_pieces[pos] intValue] andType:0];
        _roundCount += 1;
        return Msg_TurnOver; //翻牌
    }
    if (_lastPos==0 && [_pieces[pos] intValue]>0 && ![self isBackUp:pos]){
        if ([self judgeIsCurrentRoundPlayersAnimals:[_pieces[pos] intValue]]){
            _lastPos = pos;
            _messageToClient = [NSString stringWithFormat:@"选择%@",[self animalName:pos]];
            //_roundCount += 1;
            return Msg_Selected; //选中动物
        }
        
    }
    if (_lastPos==pos && ![self isBackUp:pos]){
        _lastPos = 0;
        _messageToClient = [NSString stringWithFormat:@"取消选择%@",[self animalName:pos]];
        return Msg_CancelSelected;  //取消选中
    }
    if (_lastPos>0 && _lastPos!=pos){  //尝试移动或者吃子
        NSLog(@"ccc,%ld>>%ld",(long)_lastPos,(long)pos);
        if (![self canMove:pos]){
            _lastPos = 0;
            return Msg_CancelLastSelected; //将上次的选中取消
        }
        if ([_pieces[pos] isEqual:@0]){ //目的地是空地
            //move;
            NSLog(@"move");
            _pieces[pos] = _pieces[_lastPos];
            _pieces[_lastPos] = @0;
            _lastPos = 0;
            _messageToClient = [NSString stringWithFormat:@"%@移动",[self animalName:pos]];
            _roundCount += 1;
            return Msg_Move;
        }
        if (![_pieces[pos] isEqual:@0]){ //目的地有动物
            if (![self isBackUp:pos] && ([self canEat:pos])){
                //eat
                NSLog(@"eat");
                _messageToClient = [NSString stringWithFormat:@"吃掉%@",[self animalName:pos]];
                [self animalsChangeWithAnimalType:[_pieces[pos] intValue] andType:1];
                _pieces[pos] = _pieces[_lastPos];
                _pieces[_lastPos] = @0; //吃pos的动物
                _lastPos = 0;
                _roundCount += 1;
                return  Msg_Eat;
            }
            else{
                NSLog(@"cancel");
                _lastPos = 0;
                return Msg_CancelLastSelected;
            }
        }
    }
    _lastPos = 0;
    return Msg_Nothing;
}

- (BOOL)isBackUp:(NSInteger)pos{
    if (pos>8&&pos<13){
        return NO;
    }
    return [_pieces[pos+20] isEqual:@0]?YES:NO;
}

- (NSString*)animalName:(NSInteger)pos{
    return _animalNameArray[[_pieces[pos] intValue]];
}

- (BOOL)canEat:(NSInteger)pos{
    if (pos>8&&pos<13){  //不可以吃水里的东西
        return NO;
    }
    int activeAnimalType = [_pieces[_lastPos] intValue];
    int passiveAnimalType = [_pieces[pos] intValue];
    if ((activeAnimalType>12 && passiveAnimalType>12) || (activeAnimalType<9&&passiveAnimalType<9)){
        NSLog(@"yibian%d>%d",activeAnimalType,passiveAnimalType);
        return NO;
    }
    passiveAnimalType = passiveAnimalType>12?passiveAnimalType-12:passiveAnimalType;
    activeAnimalType = activeAnimalType>12?activeAnimalType-12:activeAnimalType;
    NSLog(@"%d>%d",activeAnimalType,passiveAnimalType);
    if ((activeAnimalType<=passiveAnimalType && !(activeAnimalType==1 && passiveAnimalType==8)) ||(activeAnimalType==8 && passiveAnimalType==1)){
        return YES;
    }
    return NO;
}

- (BOOL)canMove:(NSInteger)pos{
    if (pos>8&&pos<13&&
        (![self canJumpIntoTheWater:[_pieces[_lastPos] intValue]])){  //其它动物不能下水，除了老鼠
        return NO;
    }
    long pos1 = pos>_lastPos?pos:_lastPos;
    long x1 = (pos1-1)%4;
    long y1 = (pos1-1)/4;
    long pos2 = pos+_lastPos - pos1;
    long x2 = (pos2-1)%4;
    long y2 = (pos2-1)/4;
    NSLog(@"(%ld,%ld),(%ld,%ld)",x1,y1,x2,y2);
    if ((y1==y2)&&(x1==x2+1)){
        return YES;
    }
    if ((x1==x2)&&(y1==y2+1)){
        return YES;
    }
    if ((x1==x2)&&(y1==3)&&(y2==1)&&([self canJumpAcrossTheRiver:[_pieces[_lastPos] intValue]])){//狮子和老虎可跳过河
        long middleWaterPos = 9 + x1;
        if (![self judgeInTheSameCamp:[_pieces[middleWaterPos] intValue]]){
            _messageToClient = [NSString stringWithFormat:@"不能过河，因为水里面有敌方%@",[self animalName:middleWaterPos]];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)canJumpAcrossTheRiver:(NSInteger)animalType{
    if (animalType==2 || animalType==3 || animalType==14 || animalType==15){
        return YES;
    }
    _messageToClient = [NSString stringWithFormat:@"只有老虎河狮子能跳过河！"];
    return NO;
}

- (BOOL)canJumpIntoTheWater:(NSInteger)animalType{
    if (animalType==8 || animalType==20){
        return YES;
    }
    _messageToClient = [NSString stringWithFormat:@"只有老鼠能下水！"];
    return NO;
}

- (BOOL)judgeInTheSameCamp:(NSInteger)animalType{
    int lastAnimalType = [_pieces[_lastPos] intValue];
    if (animalType==0){
        return YES;
    }
    if (lastAnimalType<9&&animalType<9){
        return YES;
    }
    if (lastAnimalType>12&&animalType>12){
        return YES;
    }
    return NO;
}

- (void)animalsChangeWithAnimalType:(NSInteger)animalType andType:(NSInteger) type{
    if (type==0){  //表示翻牌
        if (animalType<9 && animalType>0){
            [_animals[0] addObject:[NSNumber numberWithInteger:animalType]];
        }
        if (animalType<21 && animalType>12){
            [_animals[1] addObject:[NSNumber numberWithInteger:animalType]];
        }
        if ([_animals[0] count]>0 && [_animals[1] count]>0&&_yourCampId==-1){ //确定红蓝
            NSLog(@"----------确定红蓝:%ld",_roundCount);
            if ((animalType<9 && animalType>0 &&_roundCount%2==_youFirst)||   //你的回合，翻出红棋子
                (animalType<21 && animalType>13 &&_roundCount%2!=_youFirst)){ //对手回合，翻出蓝棋子
                _yourCampId = 0;
            }
            else{
                _yourCampId = 1;
            }
        }
    }
    if (type==1){ //表示吃子
        if (animalType<9 && animalType>0){
            [_animals[0] removeObject:[NSNumber numberWithInteger:animalType]];
        }
        if (animalType<21 && animalType>12){
            [_animals[1] removeObject:[NSNumber numberWithInteger:animalType]];
        }
        if ([_animals[0] count]==0 && _backUpNum==0){ //游戏结束
            if (_yourCampId == 1){
                _messageToClient = [NSString stringWithFormat:@"吃掉%@，蓝方（你）胜利！",_animalNameArray[animalType]];
            }
            else{
                _messageToClient = [NSString stringWithFormat:@"吃掉%@，蓝方（对手）胜利！",_animalNameArray[animalType]];
            }
        }
        if ([_animals[1] count]==0 && _backUpNum==0){
            if (_yourCampId == 0){
                _messageToClient = [NSString stringWithFormat:@"吃掉%@，红方（你）胜利！",_animalNameArray[animalType]];
            }
            else{
                _messageToClient = [NSString stringWithFormat:@"吃掉%@，红方（对手）胜利！",_animalNameArray[animalType]];
            }
        }
    }
}
- (BOOL)judgeIsCurrentRoundPlayersAnimals:(NSInteger)animalType{
    if ([_animals[1] count]==0 || [_animals[0] count]==0){
        return NO;
    }
    if (_roundCount%2==_youFirst && [_animals[_yourCampId] containsObject: [NSNumber numberWithInteger:animalType]]){
        return YES;
    }
    if (_roundCount%2!=_youFirst && [_animals[1-_yourCampId] containsObject: [NSNumber numberWithInteger:animalType]]){
        return YES;
    }
    return NO;
}

@end
