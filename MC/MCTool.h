//
//  MCTool.h
//  DSQ
//
//  Created by mengyun on 2017/4/16.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "Common.h"

@protocol MCToolDelegate <NSObject>

@optional
- (void)session:(MCSession *)session didReceiveString:(NSString *)str fromPeer:(MCPeerID *)peer;
- (void)session:(MCSession *)session didChangeState:(MCSessionState)state fromPeer:(MCPeerID *)peer;
- (void)browserControllerConnectedConfirm;

@end

@interface MCTool : NSObject

@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic,assign)int readyCount;
@property (nonatomic, assign) id<MCToolDelegate> delegate;
+ (instancetype)sharedTool;
- (void)destoryTool;

/**
 *  开启广播和初始化peer 和 session 和 advertiser
 */
- (void)setupPeerSessionAdvertiser;

/**
 *  关闭广播
 */
- (void)closeAdvertiser;

/**
 *  发送数据
 */
- (void)sendMessage:(NSString *)message error:(NSError *)error;
@end
