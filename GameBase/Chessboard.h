//
//  Chessboard.h
//  DSQ
//
//  Created by mengyun on 2017/4/4.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chessboard : NSObject

@property (nonatomic, assign)NSInteger currentPos;
@property (nonatomic, assign)NSInteger lastPos;
@property (nonatomic, assign)NSInteger backUpNum;
@property (nonatomic, assign)NSInteger roundCount;
@property (nonatomic, assign)NSInteger youFirst;
@property (nonatomic, assign)NSInteger yourCampId;
@property (nonatomic, strong)NSMutableArray *animals;
//@property (nonatomic, strong)NSArray *enemyAnimals;
@property (nonatomic, strong)NSString* messageToClient;
@property (nonatomic, strong)NSMutableArray *pieces;
@property (nonatomic, strong)NSArray *animalNameArray;
/*
 pieces
 1~8,13~20,0?空地:有动物
 9~12,0?空河:有动物
 21~39,0?未翻开:已经翻开
 */

- (instancetype)init;
- (int)clickOnPosition:(NSInteger)pos;
- (NSString *)getMessage;
- (BOOL)isBackUp:(NSInteger)pos;

@end
