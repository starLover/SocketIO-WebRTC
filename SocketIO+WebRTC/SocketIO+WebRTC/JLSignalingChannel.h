//
//  JLSignalingChannel.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/5.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JLSignalingMessage.h"

typedef NS_ENUM (NSInteger, JLSignalingChannelState) {
    /// The client has never been connected. Or the client has been reset.
    JLSignalingChannelStateNotConnected,
    /// The client was once connected, but not anymore.
    JLSignalingChannelStateDisconnected,
    /// The client is in the process of connecting.
    JLSignalingChannelStateConnecting,
    /// The client is currently connected.
    JLSignalingChannelStateConnected,
    ///
    JLSignalingChannelStateJoiningRoom,
    ///
    JLSignalingChannelStateJoinedRoom,
    ///
    JLSignalingChannelStateJoinedRoomError,
};

typedef NS_ENUM (NSInteger, JLMediaChannelType) {
    JLMediaChannelTypeData,
    JLMediaChannelTypeVideo,
    JLMediaChannelTypeAudio,
};

@protocol JLSignalingChannel;
@protocol JLSignalingChannelDelegate <NSObject>

- (void)channel:(id<JLSignalingChannel>)channel didChangeState:(JLSignalingChannelState)state;

- (void)channel:(id<JLSignalingChannel>)channel didReceiveMessage:(JLSignalingMessage *)message;

@end

/**
 音视频通话接收后的回调
 */
@protocol JLMediaChannelDelegate <NSObject>

- (void)didReceiveMediaCall:(JLMediaChannelType)type from:(NSString *)fromId;

- (void)didReceiveMediaCallCancel:(JLMediaChannelType)type from:(NSString *)fromId;

@end

@protocol JLSignalingChannel <NSObject>
@property (nonatomic, readonly) NSString *roomId;
@property (nonatomic, readonly) NSString *clientId;
@property (nonatomic, readonly) NSString *toId;
@property (nonatomic, readonly) JLSignalingChannelState state;
@property (nonatomic, weak) id<JLSignalingChannelDelegate> signalingDelegate;
@property (nonatomic, weak) id<JLMediaChannelDelegate> mediaChannelDelegate;

// 创建和加入房间结果将通过
// - (void)channel:(id<JLSignalingChannel>)channel didChangeState:(JLSignalingChannelState)state
// 代理方法回传
- (void)createAndJoinRoomWithToId:(NSString *)toId;

- (void)joinRoom:(NSString *)roomId;

// Sends signaling message over the channel.
- (void)sendMessage:(JLSignalingMessage *)message;

@end
