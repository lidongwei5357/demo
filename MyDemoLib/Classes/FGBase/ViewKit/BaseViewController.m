//
//  BaseFirstClassViewController.m
//  FYGOMS
//
//  Created by wangkun on 15/6/8.
//  Copyright (c) 2015年 feeyo. All rights reserved.
//
 
#import "BaseViewController.h"
#import "FGUIConfiguration.h"


@interface BaseViewController ()
@end

@implementation BaseViewController

- (void)dealloc {
    NSLog(@"dealloc❌ %@", [self getCurrentName]);
    NSLog(@"\n");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.view.backgroundColor = [FGUIConfiguration sharedInstance].BGColor;

    [self setupNavigationBar];
}

- (void)setupNavigationBar {

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear✅: %@", [self getCurrentName]);
    NSLog(@"\n");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear🔵: %@", [self getCurrentName]);
    NSLog(@"\n");

}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear❎: %@", [self getCurrentName]);
    NSLog(@"\n");
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear🔴: %@", [self getCurrentName]);
    NSLog(@"\n");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSString *)getCurrentName {
    return [NSString stringWithFormat:@"%@", [self class]];
}

@end
