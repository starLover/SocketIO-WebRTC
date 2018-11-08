//
//  JLSignalingMessage.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/1.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLSignalingMessage.h"

#import "RTCIceCandidate+JSON.h"
#import "RTCSessionDescription+JSON.h"

/*
 // RTCSdpTypeOffer indicates that a description MUST be treated as an SDP
 // offer.
 RTCSdpTypeOffer RTCSdpType = iota + 1
 
 // RTCSdpTypePranswer indicates that a description MUST be treated as an
 // SDP answer, but not a final answer. A description used as an SDP
 // pranswer may be applied as a response to an SDP offer, or an update to
 // a previously sent SDP pranswer.
 // Pr could be provisional.
 RTCSdpTypePranswer
 
 // RTCSdpTypeAnswer indicates that a description MUST be treated as an SDP
 // final answer, and the offer-answer exchange MUST be considered complete.
 // A description used as an SDP answer may be applied as a response to an
 // SDP offer or as an update to a previously sent SDP pranswer.
 RTCSdpTypeAnswer
 
 // RTCSdpTypeRollback indicates that a description MUST be treated as
 // canceling the current SDP negotiation and moving the SDP offer and
 // answer back to what it was in the previous stable state. Note the
 // local or remote SDP descriptions in the previous stable state could be
 // null if there has not yet been a successful offer-answer negotiation.
 // Apparently we don't need to think about this situation for our platform doesn't support.
 RTCSdpTypeRollback
 */

static NSString *const kJLSignalingMessageTypeKey = @"type";

@implementation JLSignalingMessage

- (instancetype)initWithType:(kJLSignalingMessageType)type{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

+ (JLSignalingMessage *)messageFromJsonString:(NSString *)jsonString typeString:(NSString *)typeString{
    id values = [self objectWithJSONString:jsonString];
    if (!values) {
        NSLog(@"Error parsing signaling message JSON.");
        return nil;
    }
    
    JLSignalingMessage *message = nil;
    if ([typeString isEqualToString:@"peers"]) {
        message = [[JLPeersMessage alloc] initWithPeers:values];
        return message;
    }
    //
    NSString *socketId = values[@"socketId"];
    if ([typeString isEqualToString:@"newpeer"]) {
        message = [[JLPeerMessage alloc] initWithPeer:socketId type:kJLSignalingMessageTypeNewPeer];
    } else if ([typeString isEqualToString:@"removepeer"]) {
        message = [[JLPeerMessage alloc] initWithPeer:socketId type:kJLSignalingMessageTypeRemovePeer];
    } else if ([typeString isEqualToString:@"candidate"]) {
        RTCIceCandidate *candidate = [RTCIceCandidate candidateFromJSONDictionary:values];
        message = [[JLICECandidateMessage alloc] initWithCandidate:candidate socketId:socketId];
    } else if ([typeString isEqualToString:@"offer"] ||
               [typeString isEqualToString:@"answer"]) {
        RTCSessionDescription *sdp = [RTCSessionDescription descriptionFromJSONDictionary:values];
        message = [[JLSessionDescriptionMessage alloc] initWithDescription:sdp socketId:socketId];
    } else if ([typeString isEqualToString:@"bye"]) {
        message = [[JLByeMessage alloc] init];
    } else {
        
    }
    return message;
}

+ (id)objectWithJSONString:(NSString *)jsonString {
    NSParameterAssert(jsonString.length > 0);
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        NSLog(@"Error parsing JSON: %@", error.localizedDescription);
    }
    return object;
}

@end

@implementation JLPeersMessage

- (instancetype)initWithPeers:(NSMutableArray *)peers{
    self = [super initWithType:kJLSignalingMessageTypePeers];
    if (self) {
        _connections = peers;
    }
    return self;
}

@end

@implementation JLPeerMessage

@synthesize socketId = _socketId;

- (instancetype)initWithPeer:(NSString *)peerId type:(kJLSignalingMessageType)type{
    self = [super initWithType:type];
    if (self) {
        _socketId = peerId;
    }
    return self;
}

@end

static NSString const *kSocketIdKey = @"socketId";

@implementation JLSendMessage


@synthesize typeString =  _typeString;

- (instancetype)initWithPeer:(NSString *)peerId type:(kJLSignalingMessageType)type{
    self = [super initWithPeer:peerId type:type];
    if (self) {
        switch (type) {
            case kJLSignalingMessageTypeOffer:
                _typeString = @"__offer";
                break;
            case kJLSignalingMessageTypeAnswer:
                _typeString = @"__answer";
                break;
            case kJLSignalingMessageTypeCandidate:
                _typeString = @"__ice_candidate";
                break;
                
            default:
                break;
        }
    }
    return self;
}

- (NSDictionary *)dictionary{
    return nil;
}

@end

@implementation JLICECandidateMessage

- (instancetype)initWithCandidate:(RTCIceCandidate *)candidate socketId:(NSString *)socketId{
    self = [super initWithPeer:socketId type:kJLSignalingMessageTypeCandidate];
    if (self) {
        _candidate = candidate;
    }
    return self;
}

- (NSDictionary *)dictionary{
    NSMutableDictionary *dictionary = [_candidate dictionary];
    dictionary[kSocketIdKey] = self.socketId;
    return dictionary;
}

@end

@implementation JLSessionDescriptionMessage

- (instancetype)initWithDescription:(RTCSessionDescription *)sdp socketId:(NSString *)socketId{
    kJLSignalingMessageType type = kJLSignalingMessageTypeOffer;
    switch (sdp.type) {
        case RTCSdpTypeOffer:
        {
            type = kJLSignalingMessageTypeOffer;
        }
            break;
        case RTCSdpTypeAnswer:
        {
            type = kJLSignalingMessageTypeAnswer;
        }
        case RTCSdpTypePrAnswer:
        {
            type  = kJLSignalingMessageTypePrAnswer;
        }
        default:
        {
            return nil;
        }
            break;
    }
    
    self = [super initWithPeer:socketId type:type];
    if (self) {
        _sessionDescription = sdp;
    }
    return self;
}

- (NSDictionary *)dictionary{
    NSMutableDictionary *dictionary = [_sessionDescription dictionary];
    dictionary[kSocketIdKey] = self.socketId;
    return dictionary;
}

@end

@implementation JLByeMessage

- (instancetype)init{
    return [super initWithType:kJLSignalingMessageTypeBye];
}

- (NSData *)JSONData{
    NSDictionary *message = @{
                              @"type": @"bye"
                              };
    return [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:NULL];
}

@end
