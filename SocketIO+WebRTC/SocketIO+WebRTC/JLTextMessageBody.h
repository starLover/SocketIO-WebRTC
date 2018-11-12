//
//  JLTextMessageBody.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/12.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "JLMessageBody.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLTextMessageBody : JLMessageBody

@property (nonatomic, copy, readonly) NSString *text;

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
