//
//  KZBAppDelegate.h
//  KZBootstrap
//
//  Created by CocoaPods on 10/14/2014.
//  Copyright (c) 2014 Krzysztof Zablocki. All rights reserved.
//
#import "KZBootstrapMacros.h"
@import UIKit;

@interface KZBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)doSomethingWithCompletion:(dispatch_block_t)completion KZB_REQUIRE_ALL_PARAMS;
@end
