//
//  JLRTCManager.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/10/31.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLRTCManager.h"
#import "JLRTCHeader.h"
#import "JLRTCManager+Private.h"
#import "JLSocketIOManager.h"
#import "JLChatClient.h"

static NSString *const kJLDefaultSTUNServerURL = @"stun:39.105.48.72:3478";

@interface JLRTCManager () <RTCPeerConnectionDelegate, RTCDataChannelDelegate, JLSignalingChannelDelegate>

@property (nonatomic, strong) NSMutableDictionary *peerConnectionDic;
@property (nonatomic, strong) NSMutableDictionary *dataChannelDic;

@end

@implementation JLRTCManager

@synthesize channel = _channel;
@synthesize factory = _factory;
@synthesize messageQueue = _messageQueue;
@synthesize hasReceivedSdp = _hasReceivedSdp;
@synthesize clientId = _clientId;
@synthesize iceServers = _iceServers;
@synthesize defaultPeerConnectionConstraints = _defaultPeerConnectionConstraints;
@synthesize state = _state;
@synthesize mediaType = _mediaType;

- (instancetype)init{
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

#pragma mark - setters
- (void)setState:(JLRoomState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didChangeState:)]) {
        [self.delegate manager:self didChangeState:state];
    }
}

- (void)setMediaType:(JLMediaChannelType)mediaType{
    if (_mediaType == mediaType) {
        return;
    }
    _mediaType = mediaType;
    switch (mediaType) {
        case JLMediaChannelTypeData:
        {
            
        }
            break;
        case JLMediaChannelTypeVideo:
        {
            
        }
            break;
        case JLMediaChannelTypeAudio:
        {
            [self removeVideoTrack];
            [self.delegate manager:self didRemoveLocalVideoTrack:self.videoTrack];
            [self createOffers];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Public Methods

- (void)chatWithUserId:(NSString *)userId chatType:(JLMediaChannelType)type handler:(JLRoomHanlder)handler{
    NSParameterAssert(userId.length);
    if (self.channel.state != JLSignalingChannelStateConnected) {
        return;
    }
    self.mediaType = type;
    self.state = JLRoomStateConnecting;
    self.factory = [[RTCPeerConnectionFactory alloc] init];
    [self.channel createAndJoinRoomWithToId:userId mediaType:type handler:handler];
}

- (void)changeToChatType:(JLMediaChannelType)type{
    self.mediaType = type;
}

- (void)disconnect{
    if (_state == JLRoomStateDisconnected) {
        return;
    }
    JLByeMessage *byeMessage = [[JLByeMessage alloc] init];
    [self.channel sendSignalingMessage:byeMessage];

    _clientId = nil;
    [_peerConnectionDic removeAllObjects];
    self.state = JLRoomStateDisconnected;
}

- (void)sendMessage:(id)message{
    [self.dataChannelDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCDataChannel *dc, BOOL * _Nonnull stop) {
        [self sendData:message dataChannel:dc];
    }];
}

- (void)sendData:(id)message dataChannel:(RTCDataChannel *)dataChannel{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    RTCDataBuffer *dataBuffer = [[RTCDataBuffer alloc] initWithData:data isBinary:NO];
    [dataChannel sendData:dataBuffer];
}

#pragma mark - JLSignalingChannelDelegate
- (void)channel:(id<JLSignalingChannel>)channel didReceiveMessage:(JLSignalingMessage *)message{
    switch (message.type) {
        case kJLSignalingMessageTypePeers:
        {
            JLPeersMessage *peersMessage = (JLPeersMessage *)message;
            if (peersMessage.connections.count) {
                [self createAndSavePeerConnectionsForIdArray:peersMessage.connections];
                [self addStreams];
                [self createAndSaveDataChannels];
                [self createOffers];
            }
        }
            break;
        case kJLSignalingMessageTypeNewPeer:
        {
            JLPeerMessage *peerMessage = (JLPeerMessage *)message;
            RTCPeerConnection *pc = [self createAndSavePeerConnectionForId:peerMessage.socketId];
            [self createAndSaveDataChannelForId:peerMessage.socketId connection:pc];
            [pc addStream:self.localMediaStream];
        }
            break;
        case kJLSignalingMessageTypeRemovePeer:
        {
            JLPeerMessage *peerMessage = (JLPeerMessage *)message;
            [self closePeerConnectionForId:peerMessage.socketId];
        }
            break;
        case kJLSignalingMessageTypeCandidate:
        {
            JLICECandidateMessage *candidateMessage = (JLICECandidateMessage *)message;
            RTCPeerConnection *peerConnection = [self peerConnectionForId:candidateMessage.socketId];
            [peerConnection addIceCandidate:candidateMessage.candidate];
        }
            break;
        case kJLSignalingMessageTypeOffer:
        case kJLSignalingMessageTypeAnswer:
        {
            JLSessionDescriptionMessage *sdpMessage = (JLSessionDescriptionMessage *)message;
            RTCPeerConnection *peerConnection = [self peerConnectionForId:sdpMessage.socketId];
            [self setRemoteDescription:sdpMessage.sessionDescription peerConnection:peerConnection];
        }
            break;
        default:
            break;
    }
}

- (void)channel:(id<JLSignalingChannel>)channel didChangeState:(JLSignalingChannelState)state{
    switch (state) {
        case JLSignalingChannelStateNotConnected:
            break;
        case JLSignalingChannelStateDisconnected:
            break;
        case JLSignalingChannelStateConnecting:
            break;
        case JLSignalingChannelStateConnected:
            break;
        default:
            break;
    }
}

#pragma mark - RTCPeerConnectionDelegate
/** Called when the SignalingState changed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeSignalingState:(RTCSignalingState)stateChanged{
    
}

/** Called when media is received on a new stream from remote peer. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (stream.videoTracks.count) {
            RTCVideoTrack *videoTrack = stream.videoTracks[0];
            if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didReceiveRemoteVideoTrack:)]) {
                [self.delegate manager:self didReceiveRemoteVideoTrack:videoTrack];
            }
        }
    });
}

/** Called when a remote peer closes a stream.
 *  This is not called when RTCSdpSemanticsUnifiedPlan is specified.
 */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream{
    
}

/** Called when negotiation is needed, for example ICE has restarted. */
- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection{
    
}

/** Called any time the IceConnectionState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceConnectionState:(RTCIceConnectionState)newState{
    
}

/** Called any time the IceGatheringState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didChangeIceGatheringState:(RTCIceGatheringState)newState{
    
}

/** New ice candidate has been found. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didGenerateIceCandidate:(RTCIceCandidate *)candidate{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *socketId = [self socketIdForPeerConnection:peerConnection];
        JLICECandidateMessage *message = [[JLICECandidateMessage alloc] initWithCandidate:candidate socketId:socketId];
        [self.channel sendSignalingMessage:message];
    });
}

/** Called when a group of local Ice candidates have been removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates{
    
}

/** New data channel has been opened. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel{
    dataChannel.delegate = self;
}

#pragma mark - RTCDataChannelDelegate
/** The data channel state changed. */
- (void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel{
}

/** The data channel successfully received a data buffer. */
- (void)dataChannel:(RTCDataChannel *)dataChannel
didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        id message = [NSJSONSerialization JSONObjectWithData:buffer.data options:0 error:&error];
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didReceiveMessage:error:)]) {
            [self.delegate manager:self didReceiveMessage:message error:error];
        }
    });
}

#pragma mark - Private

- (void)configure{
    //信令通道
    _channel = (JLSocketIOManager *)[JLChatClient sharedClient].chatManager;
    //初始化点对点工厂, 初始化ICE穿透服务器数组, 初始化点对点连接数组
    self.iceServers = [NSMutableArray arrayWithObjects:[self defaultSTUNServer], nil];
    self.peerConnectionDic = [NSMutableDictionary new];
}

- (void)offer:(RTCPeerConnection *)pc{
    __weak typeof(self)weakSelf = self;
    [pc offerForConstraints:[self defaultOfferConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            //容错处理
            
        } else {
            [weakSelf setLocalDescription:sdp peerConnection:pc];
        }
    }];
}

- (void)answer:(RTCPeerConnection *)pc{
    __weak typeof(self)weakSelf = self;
    [pc answerForConstraints:[self defaultAnswerConstraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            //容错处理
        } else {
            [weakSelf setLocalDescription:sdp peerConnection:pc];
        }
    }];
}

- (void)setLocalDescription:(RTCSessionDescription *)sdp peerConnection:(RTCPeerConnection *)pc{
    __weak typeof(self)weakSelf = self;
    __weak RTCPeerConnection *weakPC = pc;
    [pc setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
        if (error) {
            //容错处理
        } else {
            //描述发送给对等端, 提议/应答
            NSString *socketId = [weakSelf socketIdForPeerConnection:weakPC];
            JLSessionDescriptionMessage *message = [[JLSessionDescriptionMessage alloc] initWithDescription:sdp socketId:socketId];
            [self.channel sendSignalingMessage:message];
        }
    }];
}

- (void)setRemoteDescription:(RTCSessionDescription *)sdp peerConnection:(RTCPeerConnection *)pc{
    __weak typeof(self)weakSelf = self;
    __weak RTCPeerConnection *weakPC = pc;
    [pc setRemoteDescription:sdp completionHandler:^(NSError * _Nullable error) {
        if (error) {
            //容错处理
        } else {
            //收到提议设置后需要应答
            if (sdp.type == RTCSdpTypeOffer) {
                [weakSelf answer:weakPC];
            }
        }
    }];
}

- (void)createAndSavePeerConnectionsForIdArray:(NSArray *)connectionIdArray{
    for (NSString *socketId in connectionIdArray) {
        RTCPeerConnection *pc = [self peerConnection];
        self.peerConnectionDic[socketId] = pc;
    }
}

- (RTCPeerConnection *)createAndSavePeerConnectionForId:(NSString *)connectionId{
    if (connectionId.length > 0) {
        RTCPeerConnection *pc = [self peerConnection];
        self.peerConnectionDic[connectionId] = pc;
        return pc;
    }
    return nil;
}

- (void)createAndSaveDataChannels{
    [self.peerConnectionDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCPeerConnection *pc, BOOL * _Nonnull stop) {
        [self createAndSaveDataChannelForId:key connection:pc];
    }];
}

- (void)createAndSaveDataChannelForId:(NSString *)connectionId connection:(RTCPeerConnection *)peerConnection{
    RTCDataChannel *dc = [self dataChannel:peerConnection];
    self.dataChannelDic[connectionId] = dc;
}

- (void)addStreams{
    [self.peerConnectionDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCPeerConnection *pc, BOOL * _Nonnull stop) {
        [pc addStream:self.localMediaStream];
    }];
}

- (void)addVideoTracks{
    [self.peerConnectionDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCPeerConnection *pc, BOOL * _Nonnull stop) {
    }];
}

- (void)removeVideoTrack{
    [self.peerConnectionDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCPeerConnection *pc, BOOL * _Nonnull stop) {
        RTCMediaStream *mediaStream = [pc.localStreams lastObject];
        [mediaStream removeVideoTrack:self.videoTrack];
    }];
}

- (void)createOffers{
    [self.peerConnectionDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, RTCPeerConnection *pc, BOOL * _Nonnull stop) {
        [self offer:pc];
    }];
}

- (void)closePeerConnectionForId:(NSString *)socketId{
    if (!socketId.length) {
        return;
    }
    RTCPeerConnection *pc = self.peerConnectionDic[socketId];
    [pc close];
    [self.peerConnectionDic removeObjectForKey:socketId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didReceiveLeaveUserId:isEmpty:)]) {
            [self.delegate manager:self didReceiveLeaveUserId:socketId isEmpty:[self.peerConnectionDic allKeys].count];
        }
    });
}

- (RTCPeerConnection *)peerConnection{
    RTCPeerConnection *pc = [self.factory peerConnectionWithConfiguration:[self defaultPeerConnectionConfiguration] constraints:[self defaultPeerConnectionConstraints] delegate:self];
    return pc;
}

- (RTCConfiguration *)defaultPeerConnectionConfiguration{
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    configuration.iceServers = self.iceServers;
    return configuration;
}

- (RTCDataChannel *)dataChannel:(RTCPeerConnection *)pc{
    RTCDataChannelConfiguration *configuration = [[RTCDataChannelConfiguration alloc] init];
    configuration.channelId = 1;
    configuration.maxRetransmits = 3;
    configuration.maxPacketLifeTime = 30000;
    configuration.isOrdered = YES;
    configuration.isNegotiated = YES;
    RTCDataChannel *dc = [pc dataChannelForLabel:@"commands" configuration:configuration];
    dc.delegate = self;
    return dc;
}

- (RTCMediaStream *)localMediaStream{
    if (!_localMediaStream) {
        _localMediaStream = [_factory mediaStreamWithStreamId:@"ARDAMS"];
        if (self.mediaType == JLMediaChannelTypeVideo) {
            [_localMediaStream addAudioTrack:self.audioTrack];
            [_localMediaStream addVideoTrack:self.videoTrack];
        } else if (self.mediaType == JLMediaChannelTypeAudio) {
            [_localMediaStream addAudioTrack:self.audioTrack];
        }
    }
    return _localMediaStream;
}

- (RTCAudioTrack *)audioTrack{
    if (!_audioTrack) {
        RTCAudioTrack *audioTrack = [_factory audioTrackWithTrackId:@"ARDAMSa0"];
        _audioTrack = audioTrack;
    }
    return _audioTrack;
}

- (RTCVideoTrack *)videoTrack{
    if (!_videoTrack) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            
        } else {
            RTCVideoSource *videoSource = [_factory videoSource];
            RTCCameraVideoCapturer *capturer = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
            if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didCreateLocalCapturer:)]) {
                [self.delegate manager:self didCreateLocalCapturer:capturer];
            }
            AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
            AVCaptureDevice *device = [self findDeviceForPosition:position];
            AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
            int fps = [self selectFpsForFormat:format];
            [capturer startCaptureWithDevice:device format:format fps:fps];
            RTCVideoTrack *videoTrack = [_factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];
            _videoTrack = videoTrack;
        }
    }
    return _videoTrack;
}

#pragma mark - Private

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }
    return captureDevices[0];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    int targetWidth =  640;
    int targetHeight = 480;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        }
    }
    
    NSAssert(selectedFormat != nil, @"No suitable capture format found.");
    return [formats lastObject];
}

- (int)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
    }
    return maxFramerate;
}

- (RTCPeerConnection *)peerConnectionForId:(NSString *)socketId{
    return self.peerConnectionDic[socketId];
}

- (NSString *)socketIdForPeerConnection:(RTCPeerConnection *)peerConnection{
    __block NSString *socketId = nil;
    [self.peerConnectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj == peerConnection) {
            socketId = key;
            *stop = YES;
        }
    }];
    return socketId;
}

#pragma mark - Defaults
- (RTCMediaConstraints *)defaultMeidaStreamConstraints{
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{}
                                                                             optionalConstraints:nil];
    return constraints;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints{
    if (!_defaultPeerConnectionConstraints) {
        _defaultPeerConnectionConstraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:nil optionalConstraints:@{@"DtlsSrtpKeyAgreement" : kRTCMediaConstraintsValueTrue}];
    }
    return _defaultPeerConnectionConstraints;
}

- (RTCMediaConstraints *)defaultOfferConstraints{
    return [self defaultAnswerConstraints];
}

- (RTCMediaConstraints *)defaultAnswerConstraints{
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:
                                        @{kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                          kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue} optionalConstraints:nil];
    return constraints;
}

- (RTCIceServer *)defaultSTUNServer{
    return [[RTCIceServer alloc] initWithURLStrings:@[kJLDefaultSTUNServerURL]];
}

@end
