//
//  RTCSessionDescription+jl_JSON.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/1.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "RTCSessionDescription+JSON.h"

static NSString const *kRTCSessionDescriptionTypeKey = @"type";
static NSString const *kRTCSessionDescriptionSdpKey = @"sdp";

@implementation RTCSessionDescription (JSON)

+ (RTCSessionDescription *)descriptionFromJSONDictionary:(NSDictionary *)dictionary {
    NSInteger type = [dictionary[kRTCSessionDescriptionTypeKey] integerValue];
    NSString *sdp = dictionary[kRTCSessionDescriptionSdpKey];
    return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

- (NSMutableDictionary *)dictionary{
    NSDictionary *dictionary = @{
                           kRTCSessionDescriptionTypeKey : @(self.type),
                           kRTCSessionDescriptionSdpKey : self.description
                           };
    return [NSMutableDictionary dictionaryWithDictionary:dictionary];
}

- (NSData *)JSONData {
    NSDictionary *json = @{
                           kRTCSessionDescriptionTypeKey : @(self.type),
                           kRTCSessionDescriptionSdpKey : self.description
                           };
    return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
}

@end
