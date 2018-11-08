//
//  RTCSessionDescription+jl_JSON.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/1.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <WebRTC/RTCSessionDescription.h>

@interface RTCSessionDescription (JSON)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)dictionary;

@end
