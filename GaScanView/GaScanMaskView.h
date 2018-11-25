//
//  GaScanMaskView.h
//  GaScanViewDemo
//
//  Created by GikkiAres on 2018/11/25.
//  Copyright © 2018 GikkiAres. All rights reserved.
//  Current Version:0.0.1   20181125
//  Previous Version:

#import <UIKit/UIKit.h>



@interface GaScanMaskView : UIView

//父视图的尺寸必须调整后才调用.
- (void)showInSuperview:(UIView *)superview;
//设置scanrect
- (void)setScanRect:(CGRect)rcScan;
- (void)setScanRectCenter:(CGPoint)ptCenter;

- (void)startScanning;
- (void)stopScanning;

@end


