//
//  GameViewController.m
//  DSQ
//
//  Created by mengyun on 2017/4/3.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "GameViewController.h"
#import "AnimalSpirit.h"
#import "Common.h"

@interface GameViewController ()

@end

@implementation GameViewController


- (AIManager *)aiManager {
    
    if (!_aiManager) {
        _aiManager = [AIManager manager];
        _aiManager.chessBoard = self.chessboard;
    }
    return _aiManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hp"]];
    [self.view addSubview:backgroundView];
    if (_gameType==PLAYING_AGAINST_AI){
        self.navigationItem.title = @"人机对战";
        self.chessboard.youFirst = rand()%2;
        [self initGameView];
    }
    if (_gameType==PLAYING_AGAINST_PEOPLE_IN_SAME_VIEW){
        self.navigationItem.title = @"双人对局";
        [self initGameView];
    }
    if (_gameType==PLAYING_AGAINST_PEOPLE_ON_THE_INTERNET){
        self.navigationItem.title = @"网络对战";
        self.L = [[LuaFunc alloc]init];
        [_L lConnectWithAddr:"192.168.1.100" andPort:8888];
        [self initGameView];
    }
    if (_gameType==PLAYING_AGAINST_PEOPLE_ON_A_LAN){
        self.navigationItem.title = @"蓝牙对战";
        [MCTool sharedTool].delegate = self;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否抢先手" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定先手" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            MCTool *tool = [MCTool sharedTool];
            if (tool.readyCount==0){//抢到先手，主动
                [tool sendMessage:@"8" error:nil];
                tool.readyCount = 1;
            }
            else{//未抢到先手
                tool.readyCount = 2;
                self.chessboard.youFirst = 0;
                [self initGameView];
                self.gameType = PLAYING_AGAINST_PEOPLE_ON_A_LAN;
                NSString *str = [self.chessboard.pieces componentsJoinedByString:@"|"];
                NSLog(@"---=%@",str);
                [tool sendMessage:str error:nil];
            }
        }];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

}

- (void)viewDidDisappear:(BOOL)animated{
    MCTool *tool = [MCTool sharedTool];
    if (_gameType==PLAYING_AGAINST_PEOPLE_ON_A_LAN && tool.readyCount==2){
        [tool sendMessage:@"-1" error:nil];
        [tool closeAdvertiser];
        //[self.mcTool destoryTool];
        //[self.mcTool closeAdvertiser];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chessboard = [[Chessboard alloc]init];
        _chessboard.youFirst=1;
        _VCID = 1;
        //[MCTool sharedTool].readyCount = 0;
    }
    return self;
}

- (void)setChessboardWithNSArray:(NSArray*)arr{
    _chessboard.youFirst=1;
    NSInteger protoType = [arr[0] intValue];
    if (protoType==0){
        for (int i=1; i<41; ++i) {
            NSNumber *piece = @([arr[i] intValue]);
            _chessboard.pieces[i] = piece;
        }
    }
    if (self.gameView){
        [_gameView removeFromSuperview];
    }
    [self initGameView];
    
    NSLog(@"123====%@",_chessboard.pieces);
}

- (void)initGameView{
    CGFloat mar = self.navigationController.navigationBar.frame.size.height;
    CGFloat marginalWidth = 10.0;
    CGFloat titleViewHeigh = 1.0;
    CGFloat gameViewWidth = self.view.frame.size.width - 2*marginalWidth;
    CGFloat unitWidth = gameViewWidth/4;
    CGFloat gameViewHeigh = titleViewHeigh + unitWidth*6;
    _gameView = [[UIView alloc]initWithFrame:CGRectMake(marginalWidth,mar+marginalWidth*2.0,gameViewWidth,gameViewHeigh)];
    _gameView.backgroundColor = [UIColor colorWithRed:156.3/255.0 green:167.8/255.0 blue:178.9/255.0 alpha:0.2];
    
    CGFloat gapWidth = 1.0;
    for(int i=0;i<4;++i){
        for(int j=0;j<5;++j){
            CGFloat animalViewWidth = unitWidth - gapWidth*2;
            CGFloat _x = i*unitWidth + gapWidth;
            CGFloat _y = j*unitWidth + titleViewHeigh + gapWidth;
            int tag = 1 + i + 4*j;
            PiecesSpirit *piecesSpirit = [[PiecesSpirit alloc] initWithFrame:CGRectMake(_x, _y, animalViewWidth, animalViewWidth)];
            piecesSpirit.x = i;
            piecesSpirit.y = j;
            piecesSpirit.tag = tag;
            if (j==2){  //河水
                //piecesSpirit.frame = CGRectMake(i*unitWidth, _y + titleViewHeigh, unitWidth, animalViewWidth);
                piecesSpirit.type = 2;
                [_gameView addSubview:piecesSpirit];
            }
            else{
                piecesSpirit.type = 1;
                [_gameView addSubview:piecesSpirit];
                
                AnimalSpirit *animalSpirit = [[AnimalSpirit alloc] initWithFrame:CGRectMake(_x, _y, animalViewWidth, animalViewWidth)];
                NSInteger index = [_chessboard.pieces[tag] intValue];
                animalSpirit.animalIndex = index;
                animalSpirit.tag =  tag + 100*animalSpirit.animalIndex;
                //NSLog(@"tttag = %d",animalSpirit.tag);
                animalSpirit.x = i;
                animalSpirit.y = j;
                
                UIImageView *u1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld_1",(long)(index<9?index:index-12)]]];
                UIImageView *u2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"turnOver"]];
                
                
                [animalSpirit setBackView:u2];
                [animalSpirit setPositiveView:u1];
                
                [animalSpirit addTarget:self action:@selector(spiritClick:) forControlEvents:UIControlEventTouchUpInside];
                [_gameView addSubview:animalSpirit];
                
            }
            [piecesSpirit addTarget:self action:@selector(spiritClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    _noticeSpirit = [[AnimalSpirit alloc] initWithFrame:CGRectMake(gapWidth, 5*unitWidth + titleViewHeigh + gapWidth, 44, 44)];
    [_noticeSpirit setBackgroundColor:[UIColor clearColor]];
    [_gameView addSubview:_noticeSpirit];
    _noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(45+gapWidth, 5*unitWidth + titleViewHeigh + gapWidth, 300, 44)];
    [_noticeLabel setBackgroundColor:[UIColor grayColor]];
    [_gameView addSubview:_noticeLabel];
    //_chessboard.roundCount=2;
    [self setNotice];
    _noticeIsInited = NO;
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, gameViewHeigh-44, gameViewWidth-4, 40)];
    msgLabel.tag = 1111;
    [_gameView addSubview:msgLabel];
    [msgLabel setText:@"野兽棋"];
    [self msgLabelSetText:@"初始化成功"];
    
    [self.view addSubview:_gameView];
}

- (void)msgLabelSetText:(NSString*)string{
    UILabel *msgLabel = (UILabel*)[_gameView viewWithTag:1111];
    [msgLabel setText:string];
}

- (void)setNotice{
    //_roundCount%2!=_youFirst
    NSInteger roundCount = _chessboard.roundCount;
    NSInteger youFirst = _chessboard.youFirst;
    if (!_noticeIsInited && [_chessboard.animals[0] count]>0 && [_chessboard.animals[1] count]>0){
        
        if ([_chessboard.animals[_chessboard.yourCampId][0] intValue]<9) {
            _yourColorType=1;//红色
        }
        else{
            _yourColorType=2;//蓝色
        }
        _noticeIsInited = YES;
    }
    if ((roundCount)%2==youFirst){
        _noticeLabel.text = @"-你的回合-";
        if (_noticeIsInited){
            if (_yourColorType==1){
                [_noticeSpirit setBackgroundColor:[UIColor redColor]];
            }
            else{
                [_noticeSpirit setBackgroundColor:[UIColor blueColor]];
            }
            return;
        }
    }
    else{
        _noticeLabel.text = @"-对方回合-";
        if (_noticeIsInited){
            if (_yourColorType==1){
                [_noticeSpirit setBackgroundColor:[UIColor blueColor]];
            }
            else{
                [_noticeSpirit setBackgroundColor:[UIColor redColor]];
            }
            return;
        }
    }
}

- (void)spiritClick:(PiecesSpirit *)sender{
    NSString *str = [NSString stringWithFormat:@"1|%ld",(long)sender.tag];
    if (_gameType == PLAYING_AGAINST_PEOPLE_ON_A_LAN){
        [[MCTool sharedTool] sendMessage:str error:nil];
    }
    if ([self didClick:sender]){
        return;
    }
    if (_gameType == PLAYING_AGAINST_AI){
        [self.aiManager doAI];
        if (_aiManager.fristTag!=0){
            AnimalSpirit *aButton = (AnimalSpirit*)[_gameView viewWithTag:_aiManager.fristTag];
            [self didClick:aButton];
        }
        if (_aiManager.secondTag!=0){
            AnimalSpirit *aButton = (AnimalSpirit*)[_gameView viewWithTag:_aiManager.secondTag];
            [self didClick:aButton];
        }
    }
}

- (BOOL) didClick:(PiecesSpirit *)sender{
    NSString *msgHead = [NSString stringWithFormat:@"(%ld,%ld):",sender.x,sender.y];
    NSInteger position = 1 + sender.x + (long)sender.y*4;
    int msgID = [self.chessboard clickOnPosition:position];
     NSLog(@"--------msgID::%d",msgID);
    if (msgID==Msg_TurnOver){
        AnimalSpirit *aButton = (AnimalSpirit*)sender;
        aButton.isBackUp = NO;
        [self setNotice];
    }
    if (msgID==Msg_Selected){
        AnimalSpirit *aButton = (AnimalSpirit*)sender;
        aButton.isSelected = YES;
        return YES;
    }
    if (msgID==Msg_CancelSelected){
        AnimalSpirit *aButton = (AnimalSpirit*)sender;
        aButton.isSelected = NO;
        return YES;
    }
    if (msgID==Msg_CancelLastSelected){
        AnimalSpirit *aButton = (AnimalSpirit*)[_gameView viewWithTag:_lastTag];
        aButton.isSelected = NO;
        return YES;
    }
    
    if (msgID==Msg_Eat){
        AnimalSpirit *activeAnimalSpirit = (AnimalSpirit*)[_gameView viewWithTag:_lastTag];
        AnimalSpirit *passiveAnimalSpirit = (AnimalSpirit*)sender;
        
        CGRect tempF = passiveAnimalSpirit.frame;
        
        [UIView animateKeyframesWithDuration:0.6 delay:0.0
                                     options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
                                         [UIView addKeyframeWithRelativeStartTime:0.0
                                                                 relativeDuration:0.6 animations:^{
                                                                     activeAnimalSpirit.isSelected = NO;
                                                                     activeAnimalSpirit.frame = tempF;
                                                                 }];}completion:^(BOOL finished) {
                                                                     activeAnimalSpirit.x = passiveAnimalSpirit.x;
                                                                     activeAnimalSpirit.y = passiveAnimalSpirit.y;
                                                                     [passiveAnimalSpirit removeFromSuperview];
                                                                 }];
        [self setNotice];
    }
    
    if (msgID==Msg_Move){
        AnimalSpirit *activeAnimalSpirit = (AnimalSpirit*)[_gameView viewWithTag:_lastTag];
        activeAnimalSpirit.isSelected = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect tempF = sender.frame;
        CGFloat _width = activeAnimalSpirit.frame.size.width;
        CGFloat _height = activeAnimalSpirit.frame.size.height;
        if (sender.y==2){
            activeAnimalSpirit.positiveView.frame = CGRectMake(4, 4, _width-8, _height-8);
        }
        else{
            activeAnimalSpirit.positiveView.frame = CGRectMake(0, 0, _width, _height);
        }
        activeAnimalSpirit.frame = tempF;
        [UIView commitAnimations];
        if (sender.y==2){
            activeAnimalSpirit.alpha = 0.4;
        }
        else{
            activeAnimalSpirit.alpha = 1.0;
        }
        activeAnimalSpirit.x = sender.x;
        activeAnimalSpirit.y = sender.y;
        [self setNotice];
    }
    _lastTag = sender.tag;
    
    if (_chessboard.yourCampId!=-1){
        NSLog(@"你的动物:%@",_chessboard.animals[_chessboard.yourCampId]);
        NSLog(@"对方动物:%@",_chessboard.animals[1-_chessboard.yourCampId]);
    }
    
    [self msgLabelSetText:[msgHead stringByAppendingString:[_chessboard getMessage]]];
    return NO;
}

- (void)session:(MCSession *)session didReceiveString:(NSString *)str fromPeer:(MCPeerID *)peer {
    NSLog(@"我收到的数据是:%@",str);
    NSArray  *array = [str componentsSeparatedByString:@"|"];
    NSInteger protoType = [array[0] intValue];
    if (protoType==PROTO_DISCONNECT){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"游戏结束" message:@"对方断开了连接" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //[self.mcTool closeAdvertiser];
            [MCTool sharedTool].readyCount=1;
        }];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    if (protoType==PROTO_INIT){
        [self setChessboardWithNSArray:array];
    }
    if (protoType==PROTO_STEP){
        int tag = [array[1] intValue];
        AnimalSpirit *aButton = (AnimalSpirit*)[_gameView viewWithTag:tag];
        [self didClick:aButton];
    }
//    if (protoType==8){//对方抢到先手，发来消息
//        self.mcTool.readyCount = 1;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
