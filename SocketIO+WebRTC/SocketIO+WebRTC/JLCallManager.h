//
//  JLCallManager.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/12.
//  Copyright © 2018年 JLY. All rights reserved.
//

#ifndef JLCallManager_h
#define JLCallManager_h

#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>

typedef NS_ENUM(NSUInteger, JLRoomState) {
    JLRoomStateDisconnected,
    JLRoomStateConnecting,
    JLRoomStateConnected,
    JLRoomStateNewPeerJoined,
};

@protocol JLCallManager;
@protocol JLCallManagerDelegate <NSObject>

- (void)manager:(id<JLCallManager>)manager didChangeState:(JLRoomState)state;

- (void)manager:(id<JLCallManager>)manager didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer;

- (void)manager:(id<JLCallManager>)manager didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)manager:(id<JLCallManager>)manager didRemoveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)manager:(id<JLCallManager>)manager didRemoveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)manager:(id<JLCallManager>)manager didReceiveLeaveUserId:(NSString *)userId isEmpty:(BOOL)empty;

- (void)manager:(id<JLCallManager>)manager didReceiveMessage:(id)message error:(NSError *)error;

@end

@protocol JLCallManager <NSObject>

@property (nonatomic, readonly) JLRoomState state;

@property (nonatomic, readonly) JLMediaChannelType mediaType;

@property (nonatomic, weak) id<JLCallManagerDelegate> delegate;

- (void)chatWithUserId:(NSString *)userId chatType:(JLMediaChannelType)type handler:(JLRoomHanlder)handler;

- (void)changeToChatType:(JLMediaChannelType)type;

- (void)disconnect;

- (void)sendMessage:(id)message;

@end

#endif /* JLCallManager_h */
