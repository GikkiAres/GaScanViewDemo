//
//  GaScanView.h
//  GaScanViewDemo
//
//  Created by GikkiAres on 05/06/2017.
//  Copyright © 2017 HeartFollowerCom. All rights reserved.
//  Version 0.0.1

#import <UIKit/UIKit.h>
@class GaScanView;
@protocol GaScanViewDelegate <NSObject>
@required
- (void)gaScanView:(GaScanView *)scanView didScanInfo:(NSString *)info;
@optional
- (void)gaScanViewNotGetAuthoration:(GaScanView *)scanView;
@end


@interface GaScanView : UIView
@property (nonatomic,weak)id <GaScanViewDelegate> delegate;

@property (nonatomic,assign) CGRect scanFrame;
@property (nonatomic,strong) UIImage *scanImage;
@property (nonatomic,assign) BOOL limitInterestRect;


- (void)startScanning;
- (void)stopScanning;
- (void)configLimitInterestRect:(BOOL)shouldLimitInterestRect;
- (void)swapFrontAndBackCameras;
@end
