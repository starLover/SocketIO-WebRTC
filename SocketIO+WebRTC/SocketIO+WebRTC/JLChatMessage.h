//
//  JLChatMessage.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/9.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLMessageBody.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    JLMessageStatePending,                //还未发送
    JLMessageStateDelivering,             //正在发送
    JLMessageStateSucceed,                //发送成功
    JLMessageStateFailed,                 //发送失败
} JLMessageState;

@interface JLChatMessage : NSObject

/**
 消息的唯一标识符
 */
@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, copy) NSString *fromId;

@property (nonatomic, copy) NSString *toId;

/**
 服务器时间
 */
@property (nonatomic) long long serverTime;

/**
 本机时间
 */
@property (nonatomic) long long localTime;

/**
 消息状态
 */
@property (nonatomic) JLMessageState state;

/**
 是否是群聊, YES是, NO不是
 */
@property (nonatomic, assign) BOOL isGroup;

/**
 是否是发送者, YES发送出的消息, NO接收到的消息
 */
@property (nonatomic, assign) BOOL isSender;

/**
 是否已读
 */
@property (nonatomic, assign) BOOL isRead;

@property (nonatomic, strong) JLMessageBody *body;

+ (instancetype)messageWithBody:(JLMessageBody *)body from:(NSString *)from to:(NSString *)to;

@end

NS_ASSUME_NONNULL_END
