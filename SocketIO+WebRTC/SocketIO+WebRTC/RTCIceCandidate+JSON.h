//
//  RTCIceCandidate+JSON.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/1.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <WebRTC/WebRTC.h>

@interface RTCIceCandidate (JSON)

+ (RTCIceCandidate *)candidateFromJSONDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)dictionary;

@end
