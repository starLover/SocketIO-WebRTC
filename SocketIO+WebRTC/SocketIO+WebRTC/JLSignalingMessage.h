//
//  JLSignalingMessage.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/1.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCSessionDescription.h>

typedef enum {
    kJLSignalingMessageTypePeers,
    kJLSignalingMessageTypeNewPeer,
    kJLSignalingMessageTypeRemovePeer,
    kJLSignalingMessageTypeCandidate,
    kJLSignalingMessageTypeOffer,
    kJLSignalingMessageTypeAnswer,
    kJLSignalingMessageTypePrAnswer,
    kJLSignalingMessageTypeBye,
} kJLSignalingMessageType;

@interface JLSignalingMessage : NSObject

@property (nonatomic, readonly) kJLSignalingMessageType type;

+ (JLSignalingMessage *)messageFromJsonString:(NSString *)jsonString typeString:(NSString *)typeString;

@end

@interface JLPeersMessage : JLSignalingMessage

- (instancetype)initWithPeers:(NSMutableArray *)peers;

@property (nonatomic, readonly) NSMutableArray *connections;

@end

@interface JLPeerMessage : JLSignalingMessage

@property (nonatomic, readonly) NSString *socketId;

- (instancetype)initWithPeer:(NSString *)peerId type:(kJLSignalingMessageType)type;

@end

@interface JLSendMessage : JLPeerMessage

@property (nonatomic, readonly) NSString *typeString;

- (NSDictionary *)dictionary;

@end

@interface JLICECandidateMessage : JLSendMessage

@property (nonatomic, readonly) RTCIceCandidate *candidate;

- (instancetype)initWithCandidate:(RTCIceCandidate *)candidate socketId:(NSString *)socketId;

@end

@interface JLSessionDescriptionMessage : JLSendMessage

@property (nonatomic, readonly) RTCSessionDescription *sessionDescription;

- (instancetype)initWithDescription:(RTCSessionDescription *)description socketId:(NSString *)socketId;

@end

@interface JLByeMessage : JLSignalingMessage

@end
