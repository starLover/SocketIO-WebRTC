//
//  JLRTCManager+Private.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/5.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLRTCManager.h"

#import <WebRTC/RTCPeerConnection.h>

#import "JLSignalingChannel.h"

@class RTCPeerConnectionFactory;

@interface  JLRTCManager () <JLSignalingChannelDelegate, RTCPeerConnectionDelegate>

//@property (nonatomic, strong) id<JLSignalingChannel> channel;

@property(nonatomic, strong) RTCPeerConnectionFactory *factory;
@property(nonatomic, strong) RTCMediaStream *localMediaStream;
@property(nonatomic, strong) RTCAudioTrack *audioTrack;
@property(nonatomic, strong) RTCVideoTrack *videoTrack;
@property(nonatomic, strong) NSMutableArray *messageQueue;

@property(nonatomic, assign) BOOL hasReceivedSdp;
@property(nonatomic, readonly) BOOL hasJoinedRoomServerRoom;

@property(nonatomic, strong) NSString *clientId;
@property(nonatomic, assign) BOOL isInitiator;
@property(nonatomic, strong) NSMutableArray *iceServers;

@property(nonatomic, strong) RTCMediaConstraints *defaultPeerConnectionConstraints;

@end
