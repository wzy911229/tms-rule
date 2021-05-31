//
//  LPAppDelegatePlugin.m
//  TRNWAppTemplate
//
//  Created by zhiyu on 2020/11/18.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "LPAppDelegatePlugin.h"
#import <stdarg.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define ADD_SELECTOR_PREFIX(__SELECTOR__) @selector(LP_##__SELECTOR__)

#define SWIZZLE_DELEGATE_METHOD(__SELECTORSTRING__) Swizzle([delegate class], @selector(__SELECTORSTRING__), class_getClassMethod([LPAppDelegatePlugin class], ADD_SELECTOR_PREFIX(__SELECTORSTRING__)));


static NSMutableSet<id> * LPAppDelegatePluginObjects;
static NSMutableSet<Class> * LPAppDelegatePluginClass;


void call_AppDelegate_Plugins(SEL _cmd_, id _application_, id _args1_, id _args2_, id _args3_){
  
  for (id obj in LPAppDelegatePluginObjects) {
      if ([obj respondsToSelector:_cmd_]) {
          ((void (*)(id, SEL, id , id , id , id))(void *)objc_msgSend)(obj,_cmd_,_application_,_args1_,_args2_,_args3_);
      }
  }
  
  for (Class cla in LPAppDelegatePluginClass) {
      if ([cla respondsToSelector:_cmd_]) {
          ((void (*)(id, SEL, id , id , id , id))(void *)objc_msgSend)(cla,_cmd_,_application_,_args1_,_args2_,_args3_);
      }
  }
  
}


BOOL LP_Appdelegate_method_return(id _self_, SEL _cmd_, id _application_, id _args1_, id _args2_, id _args3_) {
    BOOL returnValue = NO;
    SEL LP_selector = NSSelectorFromString([NSString stringWithFormat:@"LP_%@", NSStringFromSelector(_cmd_)]);
    Method m = class_getClassMethod([LPAppDelegatePlugin class], LP_selector);
    IMP method = method_getImplementation(m);
    if (![NSStringFromSelector(_cmd_) hasPrefix:@"LP_"]) {
        BOOL (* callMethod)(id,SEL,id,id,id,id) = (void *)method;
        returnValue = callMethod(_self_,LP_selector,_application_,_args1_,_args2_,_args3_);
    }
   call_AppDelegate_Plugins(_cmd_, _application_, _args1_, _args2_, _args3_);
    return returnValue;
}

id LP_Appdelegate_method_obj_return(id _self_, SEL _cmd_, id _application_, id _args1_, id _args2_, id _args3_) {
    id returnValue = nil;
    SEL LP_selector = NSSelectorFromString([NSString stringWithFormat:@"LP_%@", NSStringFromSelector(_cmd_)]);
    Method m = class_getClassMethod([LPAppDelegatePlugin class], LP_selector);
    IMP method = method_getImplementation(m);
    if (![NSStringFromSelector(_cmd_) hasPrefix:@"LP_"]) {
        id (* callMethod)(id,SEL,id,id,id,id) = (void *)method;
        returnValue = callMethod(_self_,LP_selector,_application_,_args1_,_args2_,_args3_);
    }
   call_AppDelegate_Plugins(_cmd_, _application_, _args1_, _args2_, _args3_);
    return returnValue;
}



void LP_Appdelegate_method(id _self_, SEL _cmd_, id _application_, id _args1_, id _args2_) {
    SEL LP_selector = NSSelectorFromString([NSString stringWithFormat:@"LP_%@", NSStringFromSelector(_cmd_)]);
    Method m = class_getClassMethod([LPAppDelegatePlugin class], LP_selector);
    IMP method = method_getImplementation(m);
    if (![NSStringFromSelector(_cmd_) hasPrefix:@"LP_"]) {
        void (* callMethod)(id,SEL,id,id,id) = (void *)method;
        callMethod(_self_,LP_selector,_application_,_args1_,_args2_);
    }
    call_AppDelegate_Plugins(_cmd_, _application_, _args1_, _args2_, nil);
}



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

void Swizzle(Class class, SEL originalSelector, Method swizzledMethod)
{
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    SEL swizzledSelector = method_getName(swizzledMethod);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod && originalMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@implementation UIApplication (DCX)

- (void)LP_setDelegate:(id <UIApplicationDelegate>)delegate {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        //launch Options
        SWIZZLE_DELEGATE_METHOD(applicationDidFinishLaunching:);
        SWIZZLE_DELEGATE_METHOD(application: willFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(application: didFinishLaunchingWithOptions:);
        SWIZZLE_DELEGATE_METHOD(applicationDidBecomeActive:)
        SWIZZLE_DELEGATE_METHOD(applicationWillResignActive:)
        SWIZZLE_DELEGATE_METHOD(applicationDidEnterBackground:)
        SWIZZLE_DELEGATE_METHOD(applicationWillEnterForeground:)
      
        //OpenURL Options
        SWIZZLE_DELEGATE_METHOD(application: handleOpenURL:)
        SWIZZLE_DELEGATE_METHOD(application: openURL:  sourceApplication: annotation:)
        SWIZZLE_DELEGATE_METHOD(application: openURL: options:)

        //User Activity Continuation
        SWIZZLE_DELEGATE_METHOD(application: continueUserActivity:restorationHandler:)
        SWIZZLE_DELEGATE_METHOD(application: willContinueUserActivityWithType:)
        SWIZZLE_DELEGATE_METHOD(application: didFailToContinueUserActivityWithType:error:)
        SWIZZLE_DELEGATE_METHOD(application: didUpdateUserActivity:)

        //ReceiveMemory
        SWIZZLE_DELEGATE_METHOD(applicationDidReceiveMemoryWarning:)
        SWIZZLE_DELEGATE_METHOD(applicationWillTerminate:)
        SWIZZLE_DELEGATE_METHOD(applicationSignificantTimeChange:);

        //apns
        SWIZZLE_DELEGATE_METHOD(application: didRegisterForRemoteNotificationsWithDeviceToken:)
        SWIZZLE_DELEGATE_METHOD(application: didFailToRegisterForRemoteNotificationsWithError:)
        SWIZZLE_DELEGATE_METHOD(application: didRegisterUserNotificationSettings:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification:fetchCompletionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveRemoteNotification:)
        SWIZZLE_DELEGATE_METHOD(application: didReceiveLocalNotification:)

        //State Restoration
        SWIZZLE_DELEGATE_METHOD(application: viewControllerWithRestorationIdentifierPath:coder:)
        SWIZZLE_DELEGATE_METHOD(application: shouldSaveSecureApplicationState:)
        SWIZZLE_DELEGATE_METHOD(application: shouldRestoreSecureApplicationState:)
        SWIZZLE_DELEGATE_METHOD(application: willEncodeRestorableStateWithCoder:)
        SWIZZLE_DELEGATE_METHOD(application: didDecodeRestorableStateWithCoder:)
//
        //handle session
        SWIZZLE_DELEGATE_METHOD(application: handleEventsForBackgroundURLSession: completionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: handleWatchKitExtensionRequest: reply:)
        SWIZZLE_DELEGATE_METHOD(applicationShouldRequestHealthAuthorization:)
        SWIZZLE_DELEGATE_METHOD(application: handlerForIntent:)
        SWIZZLE_DELEGATE_METHOD(application: handleIntent:completionHandler:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataWillBecomeUnavailable:)
        SWIZZLE_DELEGATE_METHOD(applicationProtectedDataDidBecomeAvailable:)

       //shortcutItem
        SWIZZLE_DELEGATE_METHOD(application: performActionForShortcutItem:completionHandler:)
        SWIZZLE_DELEGATE_METHOD(application: performFetchWithCompletionHandler:)

        // CloudKit
        SWIZZLE_DELEGATE_METHOD(application: userDidAcceptCloudKitShareWithMetadata:)
//
//
//        //UIScene Support
//        SWIZZLE_DELEGATE_METHOD(application: didDiscardSceneSessions:)

 
        //supported Orientations
        SWIZZLE_DELEGATE_METHOD(application: supportedInterfaceOrientationsForWindow:)
      
    });
    [self LP_setDelegate:delegate];
}

@end

@implementation LPAppDelegatePlugin

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Swizzle([UIApplication class], @selector(setDelegate:), class_getInstanceMethod([UIApplication class], @selector(LP_setDelegate:)));
    });
}

+ (void)registerAppDelegateObject:(nonnull id) obj {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      LPAppDelegatePluginObjects = [NSMutableSet new];
    });
    [LPAppDelegatePluginObjects addObject:obj];
}

+ (void)registerAppDelegateClass:(nonnull Class)cla {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      LPAppDelegatePluginClass = [NSMutableSet new];
    });
    [LPAppDelegatePluginClass addObject:cla];
}


#pragma mark - launch Options

+ (void)LP_applicationDidFinishLaunching:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)LP_applicationDidEnterBackground:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)LP_applicationWillEnterForeground:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)LP_applicationDidBecomeActive:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)LP_applicationWillResignActive:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

#if UIKIT_STRING_ENUMS
+ (BOOL)LP_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    return LP_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}

+ (BOOL)LP_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions  {
    return LP_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}

#else

+ (BOOL)LP_application:(UIApplication *)application willFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    return LP_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}

+ (BOOL)LP_application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    return LP_Appdelegate_method_return(self,_cmd,application, launchOptions,nil,nil);
}
#endif


#pragma mark - OpenURL Options

+ (BOOL)LP_application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return LP_Appdelegate_method_return(self,_cmd,application,url,nil,nil);
}

+ (BOOL)LP_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation  {
    return LP_Appdelegate_method_return(self,_cmd,application,url,sourceApplication,annotation);
}

+ (BOOL)LP_application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return LP_Appdelegate_method_return(self,_cmd,application,url,options,nil);
}


#pragma mark - User Activity Continuation

+ (void)LP_application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    LP_Appdelegate_method(self, _cmd, application, userActivity, restorationHandler);
}

+ (BOOL)LP_application:(UIApplication *)application willContinueUserActivityWithType:(nonnull NSString *)userActivityType{
   return  LP_Appdelegate_method_return(self, _cmd, application, userActivityType, nil, nil);
}


+ (void)LP_application:(UIApplication *)application didFailToContinueUserActivityWithType:(nonnull NSString *)userActivityType error:(nonnull NSError *)error {
    LP_Appdelegate_method(self, _cmd, application, userActivityType,  nil);
}

+ (void)LP_application:(UIApplication *)application didUpdateUserActivity:(nonnull NSUserActivity *)userActivity {
   LP_Appdelegate_method(self, _cmd, application, userActivity,  nil);
}


#pragma mark - Receive Memory

+ (void)LP_applicationDidReceiveMemoryWarning:(UIApplication *)application{
  LP_Appdelegate_method(self, _cmd, application, nil, nil);

}

+ (void)LP_applicationWillTerminate:(UIApplication *)application{
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)LP_applicationSignificantTimeChange:(UIApplication *)application{
  LP_Appdelegate_method(self, _cmd, application, nil, nil);

}



#pragma mark - apns

+ (void)LP_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  LP_Appdelegate_method(self, _cmd, application, deviceToken, nil);
}

+ (void)LP_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  LP_Appdelegate_method(self, _cmd, application, error, nil);
}

+ (void)LP_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  LP_Appdelegate_method(self, _cmd, application, userInfo, nil);
}

+ (void)LP_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
  LP_Appdelegate_method(self, _cmd, application, userInfo, completionHandler);
}

+ (void)LP_application:(UIApplication *)application didReceiveLocalNotification:(nonnull UILocalNotification *)notification{
   LP_Appdelegate_method(self, _cmd, application, notification, nil);

}

+ (void)LP_application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings{
  LP_Appdelegate_method(self, _cmd, application, notificationSettings, nil);

}

#pragma mark - State Restoration


+ (BOOL)LP_application:(UIApplication *)application viewControllerWithRestorationIdentifierPath:(nonnull NSArray<NSString *> *)identifierComponents coder:(nonnull NSCoder *)coder{
  return  LP_Appdelegate_method_return(self, _cmd, identifierComponents, coder, nil, nil);

}

+ (BOOL)LP_application:(UIApplication *)application shouldSaveApplicationState:(nonnull NSCoder *)coder{
   return LP_Appdelegate_method_return(self, _cmd, coder, nil, nil, nil);

}

+ (BOOL)LP_application:(UIApplication *)application shouldRestoreSecureApplicationState:(nonnull NSCoder *)coder{
  return LP_Appdelegate_method_return(self, _cmd, coder, nil, nil, nil);
}


+  (BOOL)LP_application:(UIApplication *)application shouldSaveSecureApplicationState:(NSCoder *)coder {
    return LP_Appdelegate_method_return(self, _cmd, coder, nil, nil, nil);

}


+ (void)LP_application:(UIApplication *)application willEncodeRestorableStateWithCoder:(nonnull NSCoder *)coder{
   LP_Appdelegate_method(self, _cmd, application, coder, nil);
}


+ (void)LP_application:(UIApplication *)application didDecodeRestorableStateWithCoder:(nonnull NSCoder *)coder{
   LP_Appdelegate_method(self, _cmd, application, coder, nil);
}



#pragma mark - handle session

+ (void)LP_application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
  LP_Appdelegate_method(self, _cmd, application, identifier, completionHandler);
}



+ (void)LP_application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply {
  LP_Appdelegate_method(self, _cmd, application, userInfo, reply);
}

+ (void)LP_applicationShouldRequestHealthAuthorization:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (nullable id)LP_application:(UIApplication *)application handlerForIntent:(INIntent *)inten{
  return   LP_Appdelegate_method_obj_return(self, _cmd, inten, nil, nil, nil);
}


+ (void)LP_application:(UIApplication *)application handleIntent:(INIntent *)intent completionHandler:(void(^)(INIntentResponse *intentResponse))completionHandler {
  LP_Appdelegate_method(self, _cmd, application, intent, completionHandler);

}

+ (void)LP_applicationProtectedDataWillBecomeUnavailable:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}

+ (void)LP_applicationProtectedDataDidBecomeAvailable:(UIApplication *)application {
  LP_Appdelegate_method(self, _cmd, application, nil, nil);
}


#pragma mark - shortcutItem

+ (void)LP_application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler {
  LP_Appdelegate_method(self, _cmd, shortcutItem, nil, completionHandler);

}


+ (void)LP_application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
  LP_Appdelegate_method(self, _cmd, nil, nil, completionHandler);

}

#pragma mark - CloudKit

+ (void)LP_application:(UIApplication *)application userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata {
  LP_Appdelegate_method(self, _cmd, cloudKitShareMetadata, nil, nil);
}


#pragma mark - UIScene Support


+ (void)LP_application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions API_AVAILABLE(ios(13.0)){
  LP_Appdelegate_method(self, _cmd, sceneSessions, nil, nil);

}


+ (UIInterfaceOrientationMask)LP_application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
    return  LP_Appdelegate_method_obj_return(self, _cmd, window, nil, nil, nil);
}


@end


