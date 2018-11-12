//
//  JLSocketIOManager.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/10/26.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLSocketIOManager.h"
#import "JLSignalingMessage.h"

@import SocketIO;

@interface JLSocketIOManager ()

@property (nonatomic, strong) SocketIOClient *socket;

@property (nonatomic, copy) JLRoomHanlder roomHandler;

@end

static NSString *const kSocketIOURL = @"http://192.168.1.204:3000";

@implementation JLSocketIOManager

@synthesize signalingDelegate = _signalingDelegate;
@synthesize mediaChannelDelegate = _mediaChannelDelegate;
@synthesize state = _state;
@synthesize roomId = _roomId;
@synthesize clientId = _clientId;
@synthesize toId = _toId;
@synthesize mediaType = _mediaType;

//+ (instancetype)sharedManager {
//    static JLSocketIOManager *sharedManager = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedManager = [[JLSocketIOManager alloc] init];
//    });
//    return sharedManager;
//}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSURL *url = [[NSURL alloc] initWithString:kSocketIOURL];
        self.socket = [[SocketIOClient alloc] initWithSocketURL:url config:[self defaultConfiguration]];
    }
    return self;
}

- (void)setState:(JLSignalingChannelState)state{
    if (_state == state) {
        return;
    }
    _state = state;
    [_signalingDelegate channel:self didChangeState:_state];
}

- (void)connect{
    [self addHandlers];
    [self.socket connect];
}

- (void)disconnect{
    [self.socket disconnect];
}

- (void)addHandlers{
    __weak typeof(self)weakSelf = self;
    
    [self.socket on:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
    
    [self.socket on:@"disconnect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
    
    [self.socket on:@"statusChange" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        switch (weakSelf.socket.status) {
                case SocketIOClientStatusNotConnected:
            {
                weakSelf.state = JLSignalingChannelStateNotConnected;
            }
                break;
                case SocketIOClientStatusDisconnected:
            {
                weakSelf.state = JLSignalingChannelStateDisconnected;
            }
                break;
                case SocketIOClientStatusConnecting:
            {
                weakSelf.state = JLSignalingChannelStateConnecting;
            }
                break;
                case SocketIOClientStatusConnected:
            {
                weakSelf.state = JLSignalingChannelStateConnected;
            }
                break;
                
            default:
                break;
        }
    }];
    
    [self.socket on:@"chat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
    
    [self.socket on:@"videoChat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
    
    [self.socket on:@"cancelVideoChat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
}

#pragma mark -- Signaling
#pragma mark - Public

- (void)createAndJoinRoomWithToId:(NSString *)toId mediaType:(JLMediaChannelType)type handler:(JLRoomHanlder)handler{
    NSParameterAssert(toId.length);
    _toId = toId;
    _mediaType = type;
    self.roomHandler = handler;
    if (_state == JLSignalingChannelStateConnected) {
        [self createRoom];
    }
}

- (void)joinRoom:(NSString *)roomId handler:(JLRoomHanlder)handler{
    _roomId = roomId;
    self.roomHandler = handler;
    [self addSignalingHandlers];
    [self joinRoom];
}

- (void)leaveRoom:(NSString *)roomId{
    NSParameterAssert(roomId.length);
    [self.socket emit:@"cancelVideoChat" with:@[roomId]];
}

- (void)sendSignalingMessage:(JLSendMessage *)message{
    NSParameterAssert(_clientId.length);
    NSParameterAssert(_roomId.length);
    NSDictionary *dictionary = [message dictionary];
    [self. socket emit:message.typeString with:@[dictionary]];
}

#pragma mark - Private

- (void)createRoom{
    __weak typeof(self)weakSelf = self;
    [[self.socket emitWithAck:@"videoChat" with:@[@{@"from_user":_clientId, @"to_user":_toId, @"chat_type":@(_mediaType)}]] timingOutAfter:10.f callback:^(NSArray * _Nonnull data) {
        if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {
            if (weakSelf.roomHandler) {
                JLChatError *error = [JLChatError errorWithCode:kJLChatErrorCreateRoomFailed];
                weakSelf.roomHandler(nil, error);
            }
        } else {
            //创建完毕后加入房间
            [weakSelf joinRoom:data.firstObject handler:weakSelf.roomHandler];
        }
    }];
}

- (void)joinRoom{
    __weak typeof(self)weakSelf = self;
    if (self.state == JLSignalingChannelStateConnected) {
        [[self.socket emitWithAck:@"__join" with:@[@{@"room": _roomId}]] timingOutAfter:10.f callback:^(NSArray * _Nonnull data) {
            if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {
                if (weakSelf.roomHandler) {
                    JLChatError *error = [JLChatError errorWithCode:kJLChatErrorJoinRoomFailed];
                    weakSelf.roomHandler(weakSelf.roomId, error);
                }
            } else {
                if (weakSelf.roomHandler) {
                    weakSelf.roomHandler(weakSelf.roomId, nil);
                }
            }
        }];
    }
}

- (void)addSignalingHandlers{
    __weak typeof(self)weakSelf = self;
    [self.socket on:@"__peers" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveSignalingMessage:data.firstObject event:@"peers"];
    }];
    
    [self.socket on:@"_new_peer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveSignalingMessage:data.firstObject event:@"newpeer"];
    }];
    
    [self.socket on:@"_remove_peer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveSignalingMessage:data.firstObject event:@"removepeer"];
    }];
    
    [self.socket on:@"_ice_candidate" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveSignalingMessage:data.firstObject event:@"candidate"];
    }];
    
    [self.socket on:@"_offer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveSignalingMessage:data.firstObject event:@"offer"];
    }];
    
    [self.socket on:@"_answer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveSignalingMessage:data.firstObject event:@"answer"];
    }];
}

- (void)didReceiveSignalingMessage:(id)message event:(NSString *)event{
    JLSignalingMessage *signalingMessage = [JLSignalingMessage messageFromJsonString:message typeString:event];
    [self.signalingDelegate channel:self didReceiveMessage:signalingMessage];
}

- (NSDictionary *)defaultConfiguration{
    return @{@"log": @YES,
             @"forceNew" : @YES,
             @"forcePolling": @NO,
             @"reconnectAttempts":@(-1),
             @"reconnectWait" : @4,
             @"forceWebsockets" : @NO};
}

@end
