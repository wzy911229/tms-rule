/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <AlipaySDK/AlipaySDK.h>
#import <UIKit/UIKit.h>
#import <RNPaymentModule.h>

//#define HISENSE_SCHEME                        @"hisenseMobile://"

//#define SOCIAL_UMENG_APPKEY                   @"59b927e9cae7e711bb0001bc"
//#define SOCIAL_WECHAT_APPKEY                  @"wxc3f83491b0498799"
//#define SOCIAL_WECHAT_APPSECRET               @"f438eca06588d0d1538b460591451900"
//#define SOCIAL_QQ_APPKEY                      @"1106335367"
//#define SOCIAL_QQ_APPSECRET                   @"wgtdvEkeADrwdpZJ"
//#define SOCIAL_SIAN_APPKEY                    @"2728687091"
//#define SOCIAL_SINA_APPSECRET                 @"6c614063c78ac9703bf11977f566c50f"
//#define SOCIAL_ALIPAYSHARE_APPID              @"2017091308702165"

//#define SOCIAL_UNION_APPID              @"2017091308702165"
//NSString *const KStripeKey = @"pk_test_51H4g1BKARacskkzS4RjHmSvX2zBKJ1hoiM4TQF0Aznt9q9VxFujgVYwvPbo9npCOUns3DKNPVmtW3FAsDhTa9axS00BP2ANIf2";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;
  
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"example"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];

  return YES;
  
}

@end
