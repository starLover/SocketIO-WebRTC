//
//  JLMessageBody.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/12.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLMessageBody.h"

@implementation JLMessageBody

- (instancetype)initWithType:(JLMessageBodyType)type{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

@end
