//
//  JLChatManager.h
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/11/9.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLSignalingChannel.h"
#import "JLCallManager.h"
#import "JLChatManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface JLChatClient : NSObject

@property (nonatomic, copy, readonly) NSString *userId;

+ (JLChatClient *)sharedClient;

@property (nonatomic, strong, readonly) id<JLChatManager> chatManager;

@property (nonatomic, strong, readonly) id<JLCallManager> callManager;

- (void)connect;

@end

NS_ASSUME_NONNULL_END
