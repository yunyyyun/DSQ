//
//  MCTool.m
//  DSQ
//
//  Created by mengyun on 2017/4/16.
//  Copyright © 2017年 mengyun. All rights reserved.
//

#import "MCTool.h"

static MCTool *tool = nil;

@interface MCTool()<MCSessionDelegate,MCAdvertiserAssistantDelegate,MCBrowserViewControllerDelegate>{
    MCPeerID *myPeer;
    MCAdvertiserAssistant *advertiser;
}

@end

@implementation MCTool

// 初始化
- (instancetype)init {
    
    if (self = [super init]) {
        myPeer = nil;
        self.session = nil;
        advertiser = nil;
        self.browser = nil;
        self.readyCount = 0;
        [self setupPeerSessionAdvertiser];
    }
    return self;
}

// xiaohui
- (void)destoryTool {
    if (tool) {
        myPeer = nil;
        self.session = nil;
        advertiser = nil;
        self.browser = nil;
    }
    tool = nil;
}

// 单利获取对象
+ (instancetype)sharedTool {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[MCTool alloc] init];
    });
    return tool;
}



#pragma mark - public mothed
- (void)setupPeerSessionAdvertiser {
    
    // 标识设备，通常是设备昵称
    myPeer = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    // 启用和管理Multipeer连接会话中的所有同行之间的沟通
    _session = [[MCSession alloc] initWithPeer:myPeer securityIdentity:nil encryptionPreference:MCEncryptionNone];
    // 发送广播，向用户呈现传入的邀请并处理用户的响应的UI
    advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"yun" discoveryInfo:nil session:_session];
    // 开启广播
    [advertiser start];
    _session.delegate = self;
    advertiser.delegate = self;
}

// 关闭广播
- (void)closeAdvertiser {
    NSLog(@"--------closeAdvertiser");
    if (advertiser){
        [advertiser stop];
        advertiser = nil;
    }
}

// 发送消息
- (void)sendMessage:(NSString *)message error:(NSError *)error{
    
    NSError *errors;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_session sendData:data toPeers:_session.connectedPeers withMode:MCSessionSendDataReliable error:&errors];
    error = errors;
}

// 查找蓝牙的浏览器控制器
- (MCBrowserViewController *)browser {
    
    if (!_browser) {
        _browser = [[MCBrowserViewController alloc] initWithServiceType:@"yun" session:_session];
    }
    _browser.delegate = self;
    return _browser;
}


#pragma mark - MCSessionDelegate
// 状态改变
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    
    NSLog(@"-------didChangeState");
    if (advertiser && self.delegate && [self.delegate respondsToSelector:@selector(session:didChangeState:fromPeer:)]) {
        [self.delegate session:session didChangeState:state fromPeer:peerID];
    }
}

// 收到消息
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"我收到的数据是:%@",str);
        NSArray  *array = [str componentsSeparatedByString:@"|"];
        NSInteger protoType = [array[0] intValue];
        if (protoType==PROTO_DETERMINE_FFENSIVE){//对方抢到先手，发来消息
            NSLog(@"对方抢到先手，发来消息");
            tool.readyCount = 1;
            return ;
        }
        if (tool && str && self.delegate && [self.delegate respondsToSelector:@selector(session:didReceiveString:fromPeer:)]) {
            [self.delegate session:session didReceiveString:str fromPeer:peerID];
        }
    });
}

- (void)    session:(MCSession *)session
   didReceiveStream:(NSInputStream *)stream
           withName:(NSString *)streamName
           fromPeer:(MCPeerID *)peerID {
    
    
}

- (void)                    session:(MCSession *)session
  didStartReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                       withProgress:(NSProgress *)progress {
    
    
}

- (void)                    session:(MCSession *)session
 didFinishReceivingResourceWithName:(NSString *)resourceName
                           fromPeer:(MCPeerID *)peerID
                              atURL:(NSURL *)localURL
                          withError:(nullable NSError *)error {
    
    
}

#pragma mark - MCBrowserViewControllerDelegate
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    NSLog(@"-------browserViewControllerDidFinish");
    [_browser dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerConnectedConfirm)]) {
            [self.delegate browserControllerConnectedConfirm];
        }
    }];
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    
    [_browser dismissViewControllerAnimated:YES completion:^{}];
}

@end
