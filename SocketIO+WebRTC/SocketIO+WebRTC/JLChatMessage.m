//
//  JLChatMessage.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/9.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLChatMessage.h"

@implementation JLChatMessage

+ (instancetype)messageWithBody:(JLMessageBody *)body from:(NSString *)from to:(NSString *)to{
    return [[[self class] alloc] initWithBody:body from:from to:to];
}

- (instancetype)initWithBody:(JLMessageBody *)body from:(NSString *)from to:(NSString *)to{
    self = [super init];
    if (self) {
        _body = body;
        _fromId = [from copy];
        _toId = [to copy];
    }
    return self;
}

@end
