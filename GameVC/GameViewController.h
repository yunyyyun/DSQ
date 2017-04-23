//
//  GameViewController.h
//  DSQ
//
//  Created by mengyun on 2017/4/3.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Chessboard.h"
#import "AnimalSpirit.h"
#import "MCTool.h"
#import "AIManager.h"

@interface GameViewController : UIViewController<MCToolDelegate>

@property (nonatomic, strong)Chessboard *chessboard;
@property (nonatomic, strong) UIView *gameView;
@property (nonatomic, assign)NSInteger lastTag;

@property (nonatomic, strong)AVAudioPlayer* audioPlayer;

@property (nonatomic,strong)UILabel *noticeLabel;
@property (nonatomic,strong)AnimalSpirit *noticeSpirit;
@property (nonatomic,assign)BOOL noticeIsInited;
@property (nonatomic,assign)int yourColorType;
@property (nonatomic,assign)int gameType;
@property (nonatomic,assign)int VCID;
//@property (nonatomic, strong) MCTool *mcTool;
@property (nonatomic, strong) AIManager *aiManager;

@end

