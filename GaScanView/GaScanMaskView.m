//
//  GaScanMaskView.m
//  GaScanViewDemo
//
//  Created by GikkiAres on 2018/11/25.
//  Copyright © 2018 GikkiAres. All rights reserved.
//

#import "GaScanMaskView.h"

@interface GaScanMaskView ()

@property (nonatomic,assign) CGRect rcScan;

//[0-100]
@property (nonatomic,assign) CGFloat stepScanLineX;
@property (nonatomic,assign) CGFloat stepScanLineY;
@property (nonatomic,strong) CADisplayLink *displayLink;
@property (nonatomic,assign) BOOL isScanning;
@end


@implementation GaScanMaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置 背景为clear
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //宽高都大于30才进行绘制
    if((_rcScan.size.width>30&&_rcScan.size.height>30)) {
    //全部为半透明区域
    [[UIColor colorWithWhite:0 alpha:0.5] setFill];
    UIRectFill(rect);
    //中间为透明
    CGRect rcHollow = _rcScan;
    [[UIColor clearColor] setFill];
    UIRectFill(rcHollow);
    
    
    //设置四条边
    UIColor *strokeColor = [UIColor colorWithRed:0.5 green:1 blue:0.5 alpha:1];
    [strokeColor setStroke];
     UIRectFrame(rcHollow);
    
    //绘制四个角落
    [self drawFourColor];
    
    //绘制中间扫描线
    if(_isScanning) {
        [self drawScanLine];
    }
    }
}

- (void)drawScanLine {
    CGFloat lineWidthMax = self.rcScan.size.width * 0.8;
    CGFloat lineTopStart = 10;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat ptStartXBegin = self.rcScan.origin.x + self.rcScan.size.width/2;
    CGFloat ptStartXFinish = self.rcScan.origin.x + self.rcScan.size.width/2-lineWidthMax/2;
    CGFloat ptEndXBegin = self.rcScan.origin.x + self.rcScan.size.width/2;
    CGFloat ptEndXFinish = self.rcScan.origin.x + self.rcScan.size.width/2+lineWidthMax/2;
    CGFloat ptYStart = self.rcScan.origin.y + lineTopStart;
    CGFloat ptYEnd = self.rcScan.origin.y + self.rcScan.size.height-10;
    CGFloat ptYCurrent = [self valueCaseInCaseOutChangeFrom:ptYStart to:ptYEnd at:_stepScanLineY];

    CGFloat ptStartXCurrent = [self valueCaseOutChangeFrom:ptStartXBegin to:ptStartXFinish at:_stepScanLineX];
    CGFloat ptEndXCurrent = [self valueCaseOutChangeFrom:ptEndXBegin to:ptEndXFinish at:_stepScanLineX];
    CGPoint ptStart = CGPointMake(ptStartXCurrent, ptYCurrent);
    CGPoint ptEnd = CGPointMake(ptEndXCurrent, ptYCurrent);
    
    [path moveToPoint:ptStart];
    [path addLineToPoint:ptEnd];
    [path setLineWidth:2];
    [path stroke];
    
    [self increaseStep];
    
}

- (void)increaseStep {
    if(_stepScanLineX == 100) {
        _stepScanLineY += 0.5;
        if(_stepScanLineY>100) {
            _stepScanLineY = 0;
        }
    }
    else {
        _stepScanLineX +=2;
        if(_stepScanLineX > 100) {
            _stepScanLineX = 100;
        }
    }
    [self setNeedsDisplay];
}

- (void)drawFourColor {
    
    
    //设置四个角落的线条
#define kGaScanMaskView_Length 15
#define kGaScanMaskView_Width 5
    CGRect rcInner = CGRectInset(_rcScan, kGaScanMaskView_Width/2, kGaScanMaskView_Width/2);
    CGFloat ptLeftTopX = rcInner.origin.x;
    CGFloat ptLeftTopY = rcInner.origin.y;
    CGFloat ptRightTopX = rcInner.origin.x+rcInner.size.width;
    CGFloat ptRightTopY = rcInner.origin.y;
    CGFloat ptLeftBottomX = rcInner.origin.x;
    CGFloat ptLeftBottomY = rcInner.origin.y+rcInner.size.height;
    CGFloat ptRightBottomX = rcInner.origin.x+rcInner.size.width;
    CGFloat ptRightBottomY = rcInner.origin.y+rcInner.size.height;
    
    
    //左上角的下面一点逆时针绘制
    CGPoint ptLeftTop1 = CGPointMake(ptLeftTopX, ptLeftTopY+kGaScanMaskView_Length);
    CGPoint ptLeftTop2 = CGPointMake(ptLeftTopX, ptLeftTopY);
    CGPoint ptLeftTop3 = CGPointMake(ptLeftTopX+kGaScanMaskView_Length, ptLeftTopY);
    
    CGPoint ptRightTop1 = CGPointMake(ptRightTopX-kGaScanMaskView_Length, ptRightTopY);
    CGPoint ptRightTop2 = CGPointMake(ptRightTopX, ptRightTopY);
    CGPoint ptRightTop3 = CGPointMake(ptRightTopX, ptRightTopY+kGaScanMaskView_Length);
    
    CGPoint ptRightBottom1 = CGPointMake(ptRightBottomX, ptRightBottomY-kGaScanMaskView_Length);
    CGPoint ptRightBottom2 =  CGPointMake(ptRightBottomX, ptRightBottomY);
    CGPoint ptRightBottom3 = CGPointMake(ptRightBottomX-kGaScanMaskView_Length, ptRightBottomY);
    
    CGPoint ptLeftBottom1 = CGPointMake(ptLeftBottomX+kGaScanMaskView_Length, ptLeftBottomY);
    CGPoint ptLeftBottom2 = CGPointMake(ptLeftBottomX, ptLeftBottomY);
    CGPoint ptLeftBottom3 = CGPointMake(ptLeftBottomX, ptLeftBottomY-kGaScanMaskView_Length);
    
    UIBezierPath *pathLeftTop = [UIBezierPath bezierPath];
    UIBezierPath *pathRightTop = [UIBezierPath bezierPath];
    UIBezierPath *pathRightBottom = [UIBezierPath bezierPath];
    UIBezierPath *pathLeftBottom = [UIBezierPath bezierPath];
    
    [pathLeftTop moveToPoint:ptLeftTop1];
    [pathLeftTop addLineToPoint:ptLeftTop2];
    [pathLeftTop addLineToPoint:ptLeftTop3];
    
    [pathRightTop moveToPoint:ptRightTop1];
    [pathRightTop addLineToPoint:ptRightTop2];
    [pathRightTop addLineToPoint:ptRightTop3];
    
    [pathRightBottom moveToPoint:ptRightBottom1];
    [pathRightBottom addLineToPoint:ptRightBottom2];
    [pathRightBottom addLineToPoint:ptRightBottom3];
    
    [pathLeftBottom moveToPoint:ptLeftBottom1];
    [pathLeftBottom addLineToPoint:ptLeftBottom2];
    [pathLeftBottom addLineToPoint:ptLeftBottom3];
    
    [pathLeftTop setLineWidth:kGaScanMaskView_Width];
    [pathRightTop setLineWidth:kGaScanMaskView_Width];
    [pathRightBottom setLineWidth:kGaScanMaskView_Width];
    [pathLeftBottom setLineWidth:kGaScanMaskView_Width];
    [pathLeftTop strokeWithBlendMode:kCGBlendModeDestinationIn alpha:1];
    [pathLeftTop stroke];
    [pathRightTop stroke];
    [pathRightBottom stroke];
    [pathLeftBottom stroke];
}

#pragma mark Interface
- (void)showInSuperview:(UIView *)superview {
    [superview addSubview:self];
    self.frame = superview.bounds;
}

- (void)setScanRect:(CGRect)rcScan {
    _rcScan = rcScan;
    [self setNeedsDisplay];
}

//rcScan的尺寸不变,调整原点.
- (void)setScanRectCenter:(CGPoint)ptCenter {
    CGRect rcNew = CGRectMake(ptCenter.x-_rcScan.size.width/2, ptCenter.y-_rcScan.size.height/2, _rcScan.size.width, _rcScan.size.height);
    [self setScanRect:rcNew];
}

//扫描线条从顶部中间变宽,然后向下扫描,扫描速度先快后慢
- (void)startScanning {
    if(!_isScanning) {
        _isScanning = YES;
        [self setNeedsDisplay];
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTimer)];
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)onTimer {
    [self increaseStep];
}
//扫描线条从当前位置挺住,并向中间收缩直至消失.
- (void)stopScanning {
    if(_isScanning) {
        _isScanning = NO;
        _stepScanLineX = 0;
        _stepScanLineY = 0;
        [_displayLink invalidate];
        _displayLink = nil;
        [self setNeedsDisplay];
    }
}

//获取一个值从起始变化到结束点过程中的,处于变化过程进度[0,1]为step值d时的一个点
//线性变化
//变化的起点是Start,终点是End
- (CGFloat)valueLineChangeFrom:(CGFloat)valueStart to:(CGFloat)valueEnd at:(CGFloat)step {
    if(step<0) {
        step = 0;
    }
    if(step>100) {
        step = 100;
    }
    
    CGFloat length = valueEnd-valueStart;
    CGFloat delta = length*step/100.0;
    CGFloat current = valueStart + delta;
    return current;
}

//开始和结尾慢,中间快的变化趋势,就利用y=atan(x)来.
//x->[-1,1],y->[-pi/4,pi/4],变化趋势是先慢后快慢再慢
- (CGFloat)valueCaseInCaseOutChangeFrom:(CGFloat)valueStart to:(CGFloat)valueEnd at:(CGFloat)step {
    if(step<0) {
        step = 0;
    }
    if(step>100) {
        step = 100;
    }
    
    double x = [self valueLineChangeFrom:-1 to:1 at:step];
    double y = atan(x);
    double ration = (y-(-M_PI_4))/M_PI_2;
    CGFloat length = valueEnd-valueStart;
    CGFloat delta = length*ration;
    CGFloat current = valueStart + delta;
    return current;
}

//开始和结尾慢,中间快的变化趋势,就利用y=tan(x)来.
//x->[-pi/4,pi/4],y->[-1,1],变化趋势是先快后慢再快
- (CGFloat)valueCaseMiddleChangeFrom:(CGFloat)valueStart to:(CGFloat)valueEnd at:(CGFloat)step {
    if(step<0) {
        step = 0;
    }
    if(step>100) {
        step = 100;
    }
    
    double x = [self valueLineChangeFrom:-M_PI_4 to:M_PI_4 at:step];
    double y = tan(x);
    double ration = (y-(-1))/2.0;
    CGFloat length = valueEnd-valueStart;
    CGFloat delta = length*ration;
    CGFloat current = valueStart + delta;
    return current;
}

//开始快,结束慢
//用1/x在0.5到2的区间就好了(2,0.5)
- (CGFloat)valueCaseOutChangeFrom:(CGFloat)valueStart to:(CGFloat)valueEnd at:(int)step {
    if(step<0) {
        step = 0;
    }
    if(step>100) {
        step = 100;
    }
    double xStart = 0.5;
    double xEnd = 2;
    double yStart = 1/xStart;
    double yEnd = 1/xEnd;
    double x = [self valueLineChangeFrom:xStart to:xEnd at:step];
    double y = 1/x;
    double ration = (y-yStart)/(yEnd-yStart);
    CGFloat length = valueEnd-valueStart;
    CGFloat delta = length*ration;
    CGFloat current = valueStart + delta;
    return current;
}

@end
