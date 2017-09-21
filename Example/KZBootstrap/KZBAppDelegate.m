//
//  KZBAppDelegate.m
//  KZBootstrap
//
//  Created by CocoaPods on 10/14/2014.
//  Copyright (c) 2014 Krzysztof Zablocki. All rights reserved.
//

#import "KZBAppDelegate.h"
#import "KZBootstrap.h"
#import "CocoaLumberjack.h"
#import "KZBootstrapLogFormatter.h"
#import "AFNetworking.h"
static const int ddLogLevel = DDLogLevelInfo;

@implementation KZBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [self setupLogging];
  NSLog(@"user variable = %@, launch argument %@", KZBEnv, [[NSUserDefaults standardUserDefaults] objectForKey:@"KZBEnvOverride"]);
  KZBootstrap.defaultBuildEnvironment = KZBEnv;
  KZBootstrap.onCurrentEnvironmentChanged = ^(NSString *newEnv, NSString *oldEnv) {
    DDLogInfo(@"Changing env from %@ to %@", oldEnv, newEnv);
  };
  [KZBootstrap ready];
  DDLogInfo(@"KZBootstrap:\n\tshortVersion: %@\n\tbranch: %@\n\tbuildNumber: %@\n\tenvironment: %@", KZBootstrap.shortVersionString, KZBootstrap.gitBranch, @(KZBootstrap.buildNumber), KZBootstrap.currentEnvironment);
  DDLogInfo(@"keyPath %@", KZB_KEYPATH(window.windowLevel));
  DDLogInfo(@"MyVariable %@", [KZBootstrap envVariableForKey:@"MyVariable"]);
  [self testUIKitOverride];
  [self testAFNetworkingInterceptor];
  return YES;
}

- (void)doSomethingWithCompletion:(dispatch_block_t)completion
{

}

- (void)testUIKitOverride
{
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
  [self.window addSubview:view];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //! this should throw assertion if KZBootstrap/Debug is included
//    [view setNeedsDisplay];
  });
}

- (void)testAFNetworkingInterceptor
{
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager GET:@"http://api.openweathermap.org/data/2.5/weather?lat=35&lon=139" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
  }];
}

- (void)setupLogging
{
  KZBootstrapLogFormatter *logFormatter = [[KZBootstrapLogFormatter alloc] init];
  [[DDASLLogger sharedInstance] setLogFormatter:logFormatter];
  [[DDTTYLogger sharedInstance] setLogFormatter:logFormatter];

  [DDLog addLogger:[DDASLLogger sharedInstance]];
  [DDLog addLogger:[DDTTYLogger sharedInstance]];

  [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
