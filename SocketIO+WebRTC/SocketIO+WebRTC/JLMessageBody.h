//
//  JLMessageBody.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/12.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    JLMessageBodyTypeText = 1,
    JLMessageBodyTypeImage,
    JLMessageBodyTypeVideo,
    JLMessageBodyTypeVoice,
    JLMessageBodyTypeLocation,
    JLMessageBodyTypeFile,
} JLMessageBodyType;


/**
 消息体
 */
@interface JLMessageBody : NSObject

/**
 消息体类型
 */
@property (nonatomic, readonly) JLMessageBodyType type;

- (instancetype)initWithType:(JLMessageBodyType)type;

@end

NS_ASSUME_NONNULL_END
