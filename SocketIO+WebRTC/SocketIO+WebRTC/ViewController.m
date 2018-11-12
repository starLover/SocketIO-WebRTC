//
//  ViewController.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/10/26.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "ViewController.h"
#import "JLChatClient.h"
#import <WebRTC/RTCCameraPreviewView.h>

@interface ViewController () <JLCallManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[JLChatClient sharedClient] connect];
    [[JLChatClient sharedClient].callManager chatWithUserId:@"111" chatType:JLMediaChannelTypeVideo handler:^(NSString *roomId, JLChatError *error) {
        
    }];
}

- (void)manager:(id<JLCallManager>)manager didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer{
    RTCCameraPreviewView *previewView = [[RTCCameraPreviewView alloc] initWithFrame:self.view.bounds];
    previewView.captureSession = localCapturer.captureSession;
    [self.view addSubview:previewView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
