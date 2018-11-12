//
//  JLChatError.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/9.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kJLChatErrorDomain = @"JLChatErrorDomain";

static NSInteger const kJLChatErrorUnknown = -1;
static NSInteger const kJLChatErrorInvalidRoom = -2;
static NSInteger const kJLChatErrorCreateRoomFailed = -3;
static NSInteger const kJLChatErrorJoinRoomFailed = -4;
static NSInteger const kJLChatErrorInvalidMessage = -5;

NS_ASSUME_NONNULL_BEGIN

@interface JLChatError : NSError

+ (instancetype)errorWithCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
