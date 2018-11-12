//
//  JLChatError.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/9.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLChatError.h"

@implementation JLChatError

+ (instancetype)errorWithCode:(NSInteger)code{
    NSDictionary *dict;
    switch (code) {
        case kJLChatErrorUnknown:
            dict = @{NSLocalizedDescriptionKey: @"未知错误"};
            break;
        case kJLChatErrorInvalidRoom:
            dict = @{NSLocalizedDescriptionKey: @"无效的房间"};
            break;
        case kJLChatErrorCreateRoomFailed:
        case kJLChatErrorJoinRoomFailed:
            dict = @{NSLocalizedDescriptionKey: @"建立连接失败"};
            break;
        case kJLChatErrorInvalidMessage:
            dict = @{NSLocalizedDescriptionKey: @"无效的信息"};
            break;
            
        default:
            break;
    }
    JLChatError *error = [JLChatError errorWithDomain:kJLChatErrorDomain code:code userInfo:dict];
    return error;
}

@end
