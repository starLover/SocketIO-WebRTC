//
//  ViewController.m
//  SocketIO+WebRTC
//
//  Created by fairytale on 2018/10/26.
//  Copyright © 2018年 JLY. All rights reserved.
//

#import "ViewController.h"
#import "JLSocketIOManager.h"
#import "JLRTCManager.h"
#import <WebRTC/RTCCameraPreviewView.h>
#import <WebRTC/RTCEAGLVideoView.h>


@interface ViewController () <JLRTCManagerDelegate>

@property (nonatomic, strong) JLRTCManager *rtcManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[JLSocketIOManager sharedManager] connect];
    self.rtcManager = [[JLRTCManager alloc] init];
    self.rtcManager.delegate = self;
    [self.rtcManager chatWithUserId:@"111" chatType:JLMediaChannelTypeVideo];
}

- (void)manager:(JLRTCManager *)manager didRemoveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack{
    
}

- (void)manager:(JLRTCManager *)manager didCreateLocalCapturer:(RTCCameraVideoCapturer *)localCapturer{
    RTCCameraPreviewView *previewView = [[RTCCameraPreviewView alloc] initWithFrame:self.view.bounds];
    previewView.captureSession = localCapturer.captureSession;
    [self.view addSubview:previewView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
