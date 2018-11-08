//
//  RTCIceCandidate+JSON.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/1.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "RTCIceCandidate+JSON.h"

static NSString const *kRTCICECandidateMidKey = @"id";
static NSString const *kRTCICECandidateMLineIndexKey = @"label";
static NSString const *kRTCICECandidateSdpKey = @"candidate";

@implementation RTCIceCandidate (JSON)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary {
    NSString *sdpMid = dictionary[kRTCICECandidateMidKey];
    NSString *sdp = dictionary[kRTCICECandidateSdpKey];
    int sdpMLineIndex = [dictionary[kRTCICECandidateMLineIndexKey] intValue];
    return [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];
}

- (NSMutableDictionary *)dictionary{
    NSDictionary *dictionary = @{
                                 kRTCICECandidateMLineIndexKey : @(self.sdpMLineIndex),
                                 kRTCICECandidateMidKey : self.sdpMid,
                                 kRTCICECandidateSdpKey : self.sdp
                                 };
    return [NSMutableDictionary dictionaryWithDictionary:dictionary];
}

@end
