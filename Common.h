//
//  Common.h
//  DSQ
//
//  Created by mengyun on 2017/4/16.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#ifndef Common_h
#define Common_h

//游戏事件
#define Msg_TurnOver 1
#define Msg_Selected 2
#define Msg_CancelSelected 3
#define Msg_Move 4
#define Msg_Eat 5
#define Msg_CancelLastSelected 6
#define Msg_Nothing -1

//对局类型
#define PLAYING_AGAINST_AI 1
#define PLAYING_AGAINST_PEOPLE_IN_SAME_VIEW 2
#define PLAYING_AGAINST_PEOPLE_ON_THE_INTERNET 3
#define PLAYING_AGAINST_PEOPLE_ON_A_LAN 4


//协议类型
#define PROTO_DISCONNECT -1
#define PROTO_INIT 0
#define PROTO_STEP 1
#define PROTO_DETERMINE_FFENSIVE 8


#endif /* Common_h */
