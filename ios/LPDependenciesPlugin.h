//
//  LPDependenciesPlugin.h
//  example
//
//  Created by zhiyu on 2020/12/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LPPluginProtocol <NSObject>

@optional

//统一实例化方法
+ (id)sharedInstance;

//统一注册
- (void)initEvent:(NSDictionary *)param;

//启动方法监听，用于特殊注册需要
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

//统一接受推送
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)failToRegisterForRemoteNotificationsWithError:(NSError *)error;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;


// 统一处理handleUrl的回调
- (BOOL)handleUrl: (NSURL *)url;

- (BOOL)handleUrl: (NSURL *)url
          options:(NSDictionary *)options;

- (BOOL)handleUrl: (NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation;

- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;


@end

NS_ASSUME_NONNULL_BEGIN

@interface LPDependenciesPlugin : NSObject<UIApplicationDelegate>

+(id)configs;
+(void)startInit;

@end

NS_ASSUME_NONNULL_END
