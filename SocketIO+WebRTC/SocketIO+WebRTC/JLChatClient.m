//
//  JLChatManager.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/9.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLChatClient.h"
#import "JLSocketIOManager.h"
#import "JLRTCManager.h"

@interface JLChatClient ()

{
}
@property (nonatomic, strong) JLRTCManager *rtcManager;
@property (nonatomic, strong) JLSocketIOManager *socketManager;

@end

@implementation JLChatClient

+ (JLChatClient *)sharedClient{
    static JLChatClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[[self class] alloc] init];
    });
    return sharedClient;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initSocketManager];
    }
    return self;
}

#pragma - Public

- (void)connect{
    [self.socketManager connect];
}

#pragma - Private

- (void)initSocketManager{
    _socketManager = [[JLSocketIOManager alloc] init];
}

- (void)initRTCManager{
    _rtcManager = [[JLRTCManager alloc] init];
}

- (void)mediaChatWithType:(JLMediaChannelType)type toId:(NSString *)toId handler:(JLRoomHanlder)handler{
    if (!_rtcManager) {
        [self initRTCManager];
    }
    [_rtcManager chatWithUserId:toId chatType:type handler:handler];
}

- (id<JLChatManager>)chatManager{
    return _socketManager;
}

- (id<JLCallManager>)callManager{
    if (!_rtcManager) {
        [self initRTCManager];
    }
    return _rtcManager;
}

@end
