//
//  GaScanView.m
//  GaScanViewDemo
//
//  Created by GikkiAres on 05/06/2017.
//  Copyright © 2017 HeartFollowerCom. All rights reserved.
//


#import "GaScanView.h"
#import <AVFoundation/AVFoundation.h>

@interface  GaScanView ()<
AVCaptureMetadataOutputObjectsDelegate
>

@property (nonatomic ,strong) AVCaptureSession *captureSession;
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) CALayer *imageLayer;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) AVCaptureDeviceInput *input;

@end

@implementation GaScanView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self =[super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    dispatch_async(dispatch_get_main_queue()
                   , ^{
                       [self checkHasAuthority];
                       AVCaptureDevice * device =[self cameraWithPosition:AVCaptureDevicePositionFront];
                       [self displayVedioFromDevice:device];
                       [self layoutSubviews];
                       [self setLimitInterestRect:self->_limitInterestRect];
                       
                       
                       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
                   });
}

//判断是否开启相机权限
- (void)checkHasAuthority {
    //读取媒体类型
    NSString *mediaType = AVMediaTypeVideo;
    //读取设备授权状态
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        if([_delegate respondsToSelector:@selector(gaScanViewNotGetAuthoration:)]) {
            [_delegate gaScanViewNotGetAuthoration:self];
        }
        //    return;
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            NSLog(@"111");
        }];
    }
}

//可以重复使用该方法.
-(void)displayVedioFromDevice:(AVCaptureDevice *) device{
    //清理已存在的数据
    if(_captureVideoPreviewLayer) {
        [_captureVideoPreviewLayer removeFromSuperlayer];
        _captureVideoPreviewLayer = nil;
    }
    if(_captureSession) {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
    if(_input) {
        _input = nil;
    }
    if(_output) {
        _output = nil;
    }
    
    //初始化输入流
    NSError *error = nil;
    //获取摄像设备
    //      AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    _input = input;
    //创建会话
    _captureSession = [[AVCaptureSession alloc]init];
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    //添加输入流
    if(!_input) {
        NSLog(@"这是模拟器!没有照相机!!");
        UILabel *layer = [UILabel new];
        layer.frame = self.bounds;
        layer.text = @"请在设置中开启相机权限";
        layer.font = [UIFont systemFontOfSize:30];
        layer.textAlignment = NSTextAlignmentCenter;
        layer.textColor = [UIColor blackColor];
        [self addSubview:layer];
        return;
    }
    @try {
        [_captureSession addInput:input];
    } @catch (NSException *exception) {
        return;
    } @finally {
        
    }
    //初始化输出流
//    AVCaptureVideoDataOutput
//    AVCaptureMetadataOutput
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc]init];
    _output = captureMetadataOutput;
    //设置视频的格式
    
    //添加输出流
    [_captureSession addOutput:captureMetadataOutput];
    
    
    //设置扫描内容,必须写在添加到session之后吗?
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    
    //设置代理方法和回调线程
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //  dispatch_queue_t dispatchQueue = dispatch_queue_create("ScanQRCodeQueue", NULL);
    //  [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    
    //创建扫描view的layer层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
    //将图层设置为视频样式
    [_captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [self.layer insertSublayer:_captureVideoPreviewLayer atIndex:0];
    
    
    //调整方向
    [self adjustOrientation];
    
    [self startScanning];
    
}



- (void)configLimitInterestRect:(BOOL)shouldLimitInterestRect {
    _limitInterestRect = shouldLimitInterestRect;
}

- (void)adjustOrientation {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        //
        _captureVideoPreviewLayer.connection.videoOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        //
        _captureVideoPreviewLayer.connection.videoOrientation  = UIDeviceOrientationLandscapeRight;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //设置layer的位置
    _captureVideoPreviewLayer.frame = self.bounds;
    //设置兴趣点
    if (_scanImage) {
        if(!_imageView) {
            _imageView = [[UIImageView alloc]init];
            [self addSubview:_imageView];
            //            [self.layer addSublayer:_imageLayer];
            //            _imageLayer.backgroundColor = [UIColor redColor].CGColor;
        }
        _imageView.frame = _scanFrame;
        _imageView.image = _scanImage;
        
        [self setLimitInterestRect:_limitInterestRect];
    }
}


- (void)startScanning {
    //开始扫描
    if(_input) {
        [_captureSession startRunning];
    }
}

- (void)stopScanning {
    [_captureSession stopRunning];
}



-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSLog(@"scanning...");
    //判断扫描是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *result;
        //判断的扫描的结果是否是二维码
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObject.stringValue;
            //            NSLog(@"扫描到了");
            [self stopScanning];
            if([_delegate respondsToSelector:@selector(gaScanView:didScanInfo:)]) {
                [_delegate gaScanView:self didScanInfo:result];
            }
        }else{
            NSLog(@"不是二维码");
        }
    }
}


- (void)setLimitInterestRect:(BOOL)limitInterestRect {
    _limitInterestRect = limitInterestRect;
    if (_limitInterestRect) {
        if(_captureVideoPreviewLayer) {
            CGRect metadataRect = [_captureVideoPreviewLayer metadataOutputRectOfInterestForRect:_scanFrame];
            _output.rectOfInterest = metadataRect;
        }
    }
    else {
        _output.rectOfInterest = CGRectMake(0,0 ,1,1);
    }
}



//切换前置、后置摄像头
//- (AVCaptureDevice *)cameraWithPostion:(AVCaptureDevicePosition)position{
//    AVCaptureDeviceDiscoverySession *devicesIOS10 = [AVCaptureDeviceDiscoverySession  discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
//    NSArray *devicesIOS  = devicesIOS10.devices;
//    for (AVCaptureDevice *device in devicesIOS) {
//        if ([device position] == position) {
//            return device;
//        }
//    }
//    return nil;
//}


- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    //获取设备上可用的视频设备.
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}




#pragma mark Interface
//前后摄像头切换
- (void)swapFrontAndBackCameras {
    //获取device信息.
    AVCaptureDevice *device = _input.device;
    if ( [device hasMediaType:AVMediaTypeVideo] ) {
        AVCaptureDevicePosition position = device.position;
        AVCaptureDevice *deviceNew = nil;
        
        if (position == AVCaptureDevicePositionFront) {
            deviceNew = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        else {
            deviceNew = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        [self displayVedioFromDevice:deviceNew];
    }
}

@end

