//
//  GaScanView.m
//  GaScanViewDemo
//
//  Created by GikkiAres on 05/06/2017.
//  Copyright © 2017 HeartFollowerCom. All rights reserved.
//


#import "GaScanView.h"
#import "GaScanMaskView.h"
#import <AVFoundation/AVFoundation.h>

#define kGaScanView_HardwareTint @"未检测到摄像设备"
#define kGaScanView_NoAuthorizationTint @"请在设置中打开照片权限"

@interface  GaScanView ()<
AVCaptureMetadataOutputObjectsDelegate
>

@property (nonatomic ,strong) AVCaptureSession *captureSession;
@property (nonatomic ,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) CALayer *imageLayer;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) UILabel *lbTint;
@property (nonatomic,strong) GaScanMaskView *scanMaskView;
@property (nonatomic,assign) CGRect rcInterest;
@property (nonatomic,assign) CGSize sizeInterestRc;
@property (nonatomic,assign) CGPoint ptInterestRcCenter;

@end

@implementation GaScanView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self =[super initWithCoder:aDecoder]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self commonInit];
        });
    }
    return self;
}

- (void) commonInit {
    // 先判断摄像头硬件是否好用
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        //读取媒体类型
        NSString *mediaType = AVMediaTypeVideo;
        //读取设备授权状态
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        switch (authStatus) {
            case AVAuthorizationStatusRestricted:{
                NSLog(@"拒绝授权,restricted");
                [self initAsNoAuthorization];
                break;
            }
            case AVAuthorizationStatusDenied: {
                NSLog(@"拒绝授权,denied");
                [self initAsNoAuthorization];
                break;
            }
            case AVAuthorizationStatusNotDetermined:{
                NSLog(@"第一次运行,未决定权限");
                __weak typeof (self) weakSelf = self;
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted) {
                        NSLog(@"获取到权限");
                        [weakSelf initNormal];
                    }
                    else {
                        NSLog(@"没有获取到权限");
                        [weakSelf initAsNoAuthorization];
                    }
                }];
                break;
            }
            case AVAuthorizationStatusAuthorized:{
                NSLog(@"已授权");
                [self initNormal];
                break;
            }
            default:
                break;
        }
    }
    else {
        [self initAsNoCamera];
    }
}

//没有检测到摄像头的初始化
- (void)initAsNoCamera {
    [self showLabelWithText:kGaScanView_HardwareTint];
}

//没有权限的初始化
- (void)initAsNoAuthorization {
    [self showLabelWithText:kGaScanView_NoAuthorizationTint];
    if([self.delegate respondsToSelector:@selector(gaScanViewNotGetAuthoration:)]) {
        [self.delegate gaScanViewNotGetAuthoration:self];
    }
}

//正常初始化
- (void)initNormal {
    AVCaptureDevice * device =[self cameraWithPosition:AVCaptureDevicePositionFront];
    _scanMaskView = [[GaScanMaskView alloc]init];
    [self displayVedioFromDevice:device];
    [self layoutSubviews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)showLabelWithText:(NSString *)text {
    UILabel *lb = _lbTint;
    if(!lb) {
        lb = [UILabel new];
        [self addSubview:lb];
    }
    lb.frame = self.bounds;
    lb.text = text;
    lb.numberOfLines = 0;
    lb.font = [UIFont systemFontOfSize:30];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.textColor = [UIColor blackColor];
}

#pragma mark

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
    [_captureSession addInput:input];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsLayout];
    });
    
}

//设置兴趣点和中心.但是必须自己的bounds确定后才能正确设置.那就只能在layoutSubview中设置了.
- (void)setInterestSize:(CGSize)size centerPoint:(CGPoint)point {
    _sizeInterestRc = size;
    _ptInterestRcCenter = point;
    [self setNeedsLayout];
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
    if(CGSizeEqualToSize(_sizeInterestRc, CGSizeZero)) {
        [_scanMaskView setScanRect:self.bounds];
    }
    else {
        CGPoint ptOrigin = CGPointMake(_ptInterestRcCenter.x-_sizeInterestRc.width/2, _ptInterestRcCenter.y-_sizeInterestRc.height/2);
        _rcInterest = CGRectMake(ptOrigin.x, ptOrigin.y, _sizeInterestRc.width, _sizeInterestRc.height);
        [_scanMaskView setScanRect:_rcInterest];
        CGRect metadataRect = [_captureVideoPreviewLayer metadataOutputRectOfInterestForRect:_rcInterest];
        _output.rectOfInterest = metadataRect;
    }
    [_scanMaskView showInSuperview:self];
}


- (void)startScanning {
    if(_input) {
        [_captureSession startRunning];
        [_scanMaskView startScanning];
    }
}

- (void)stopScanning {
    [_captureSession stopRunning];
    [_scanMaskView stopScanning];
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
            [self stopScanning];
            if([_delegate respondsToSelector:@selector(gaScanView:didScanInfo:)]) {
                [_delegate gaScanView:self didScanInfo:result];
            }
        }else{
            NSLog(@"不是二维码");
        }
    }
}


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




