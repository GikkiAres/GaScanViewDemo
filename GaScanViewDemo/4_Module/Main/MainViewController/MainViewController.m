//
//  MainViewController.m
//  GaCustomDemo
//
//  Created by GikkiAres on 2018/11/23.
//  Copyright © 2018 GikkiAres. All rights reserved.
//

#import "MainViewController.h"
#import "GaScanView.h"
#import "GaScanMaskView.h"

@interface MainViewController ()<
GaScanViewDelegate
>


@property (weak, nonatomic) IBOutlet GaScanView *scanView;
@property (strong, nonatomic) GaScanMaskView *maskView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scanView.delegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [_maskView showInSuperview:self.view];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark
- (IBAction)clickStartScanBtn:(id)sender {
    [_scanView startScanning];
}
#pragma mark Delegate
- (void)gaScanView:(GaScanView *)scanView didScanInfo:(NSString *)info {
    NSLog(@"%@",info);
    [_scanView stopScanning];
}
- (IBAction)clickSwapBtn:(id)sender {
    [_scanView swapFrontAndBackCameras];
}

- (IBAction)clickSetInterestRectBtn:(id)sender {
    CGSize size = _scanView.bounds.size;
    [_scanView setInterestSize:CGSizeMake(100, 100) centerPoint:CGPointMake(size.width/2, size.height/2)];
}
@end
