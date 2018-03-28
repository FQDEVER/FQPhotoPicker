//
//  FQVideoStreamCollectionCell.m
//  FQPhotoPicker
//
//  Created by 龙腾飞 on 2018/3/26.
//  Copyright © 2018年 fanqi. All rights reserved.
//

#import "FQVideoStreamCollectionCell.h"
#import <AVKit/AVKit.h>

@interface FQVideoStreamCollectionCell()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) AVCaptureSession *session;

@end

@implementation FQVideoStreamCollectionCell


-(instancetype)init
{
    if (self = [super init]) {
        [self.layer addSublayer:self.previewLayer];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.previewLayer];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self.layer addSublayer:self.previewLayer];
    }
    return self;
}


//实现代理方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetHigh;//设置分辨率
        
        
        AVCaptureDevice *device;
        NSArray *devideArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *devides in devideArray) { //这里使用后置摄像头
            if ([devides position] == AVCaptureDevicePositionBack) {
                device = devides;
            }
        }
        
        NSError * error;
        AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        if ([_session canAddInput:input]) {
            [_session addInput:input];
        }
        
        [_session startRunning];
        
    }
    return _session;
}

-(AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.frame = self.bounds;
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        UIImageView * imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"相机"]];
        imgView.frame = CGRectMake(0, 0, 40, 40);
        imgView.center = self.center;
        [_previewLayer  addSublayer:imgView.layer];
    }
    return _previewLayer;
}


@end
