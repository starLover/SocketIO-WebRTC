//
//  JLRTCManager.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/10/31.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import "JLSignalingChannel.h"

typedef NS_ENUM(NSUInteger, JLRoomState) {
    JLRoomStateDisconnected,
    JLRoomStateConnecting,
    JLRoomStateConnected,
    JLRoomStateNewPeerJoined,
};

@class JLRTCManager;
@protocol JLRTCManagerDelegate <NSObject>

- (void)manager:(JLRTCManager *)manager didChangeState:(JLRoomState)state;

- (void)manager:(JLRTCManager *)manager didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer;

- (void)manager:(JLRTCManager *)manager didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)manager:(JLRTCManager *)manager didRemoveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)manager:(JLRTCManager *)manager didRemoveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)manager:(JLRTCManager *)manager didReceiveLeaveUserId:(NSString *)userId isEmpty:(BOOL)empty;

- (void)manager:(JLRTCManager *)manager didReceiveMessage:(id)message error:(NSError *)error;

@end

@interface JLRTCManager : NSObject

@property (nonatomic, readonly) JLRoomState state;

@property (nonatomic, readonly) JLMediaChannelType mediaType;

@property (nonatomic, weak) id<JLRTCManagerDelegate> delegate;

- (void)chatWithUserId:(NSString *)userId chatType:(JLMediaChannelType)type;

- (void)changeToChatType:(JLMediaChannelType)type;

- (void)disconnect;

- (void)sendMessage:(id)message;

@end
