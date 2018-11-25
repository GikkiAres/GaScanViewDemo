//
//  GaScanView.h
//  GaScanViewDemo
//
//  Created by GikkiAres on 05/06/2017.
//  Copyright © 2017 HeartFollowerCom. All rights reserved.
//  Current Version:0.0.2   20181125
//  Previous Version:0.0.1  20181124

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

- (void)startScanning;
- (void)stopScanning;
- (void)setInterestSize:(CGSize)size centerPoint:(CGPoint)point;
- (void)swapFrontAndBackCameras;
@end
