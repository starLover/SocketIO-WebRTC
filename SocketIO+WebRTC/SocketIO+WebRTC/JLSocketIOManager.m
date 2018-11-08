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

@end

static NSString *const kSocketIOURL = @"http://192.168.1.204:3000";

@implementation JLSocketIOManager

@synthesize signalingDelegate = _signalingDelegate;
@synthesize mediaChannelDelegate = _mediaChannelDelegate;
@synthesize state = _state;
@synthesize roomId = _roomId;
@synthesize clientId = _clientId;
@synthesize toId = _toId;

+ (instancetype)sharedManager {
    static JLSocketIOManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[JLSocketIOManager alloc] init];
    });
    return sharedManager;
}

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
    [self configureCallBack];
    [self.socket connect];
}

- (void)createAndJoinRoomWithToId:(NSString *)toId{
    NSParameterAssert(toId.length);
    _toId = toId;
    __weak typeof(self)weakSelf = self;
    if (_state == JLSignalingChannelStateConnected) {
        self.state = JLSignalingChannelStateJoiningRoom;
        [[self.socket emitWithAck:@"videoChat" with:@[@{@"from_user":_clientId, @"to_user":_toId, @"chat_type":@(0)}]] timingOutAfter:10.f callback:^(NSArray * _Nonnull data) {
            if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {
                weakSelf.state = JLSignalingChannelStateJoinedRoomError;
            } else {
                [weakSelf joinRoom:data.firstObject];
            }
        }];
    }
}

- (void)joinRoom:(NSString *)roomId{
    _roomId = roomId;
    [self addSocketHandlers];
    [self joinRoom];
}

- (void)joinRoom{
    __weak typeof(self)weakSelf = self;
    if (self.state == JLSignalingChannelStateConnected) {
        [[self.socket emitWithAck:@"__join" with:@[@{@"room": _roomId}]] timingOutAfter:10.f callback:^(NSArray * _Nonnull data) {
            if ([data.firstObject isKindOfClass:[NSString class]] && [data.firstObject isEqualToString:@"NO ACK"]) {
                weakSelf.state = JLSignalingChannelStateJoinedRoomError;
            } else {
                weakSelf.state = JLSignalingChannelStateJoinedRoom;
            }
        }];;
    }
}

- (void)sendMessage:(JLSendMessage *)message{
    NSParameterAssert(_clientId.length);
    NSParameterAssert(_roomId.length);
    NSDictionary *dictionary = [message dictionary];
    [self. socket emit:message.typeString with:@[dictionary]];
}

- (void)configureCallBack{
    __weak typeof(self)weakSelf = self;
    [self.socket connectWithTimeoutAfter:15.f withHandler:^{
        
    }];
    
    [self.socket once:@"connect" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        
    }];
    
    [self.socket onAny:^(SocketAnyEvent * _Nonnull event) {
        //                NSLog(@"事件: %@ items: %@", event.event, event.items);
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
}

- (void)addSocketHandlers{
    __weak typeof(self)weakSelf = self;
    [self.socket on:@"cancelVideoChat" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        //        [weakSelf didReceiveMessage:data.firstObject event:@"cancelVideoChat"];
    }];
    
    [self.socket on:@"__peers" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveMessage:data.firstObject event:@"peers"];
    }];
    
    [self.socket on:@"_new_peer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveMessage:data.firstObject event:@"newpeer"];
    }];
    
    [self.socket on:@"_remove_peer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveMessage:data.firstObject event:@"removepeer"];
    }];
    
    [self.socket on:@"_ice_candidate" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveMessage:data.firstObject event:@"candidate"];
    }];
    
    [self.socket on:@"_offer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveMessage:data.firstObject event:@"offer"];
    }];
    
    [self.socket on:@"_answer" callback:^(NSArray * _Nonnull data, SocketAckEmitter * _Nonnull ack) {
        [weakSelf didReceiveMessage:data.firstObject event:@"answer"];
    }];
}

- (void)didReceiveMessage:(id)message event:(NSString *)event{
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
