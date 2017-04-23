//
//  AIManager.h
//  DSQ
//
//  Created by mengyun on 2017/4/17.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chessboard.h"
#import "Common.h"

@interface AIManager : NSObject

@property (nonatomic, strong)Chessboard *chessBoard;
@property (nonatomic, assign)NSInteger fristTag;
@property (nonatomic, assign)NSInteger secondTag;
+ (instancetype)manager;
- (void)doAI;
@end
