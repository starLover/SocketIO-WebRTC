//
//  JLTextMessageBody.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/12.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLTextMessageBody.h"

@implementation JLTextMessageBody

- (instancetype)initWithText:(NSString *)text{
    self = [super initWithType:JLMessageBodyTypeText];
    if (self) {
        _text = [text copy];
    }
    return self;
}

@end
