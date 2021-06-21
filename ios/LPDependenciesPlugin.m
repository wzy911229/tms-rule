//
//  LPDependenciesPlugin.m
//  example
//
//  Created by zhiyu on 2020/12/24.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "LPDependenciesPlugin.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <stdarg.h>
#include <mach-o/loader.h>
#include <mach-o/getsect.h>

static NSString *const kRCTESConfigurationKey = @"kRCTESConfigurationUserDefaultKey";

static NSMutableArray<Class>* plugins;

static NSDictionary* pConfig;

@implementation LPDependenciesPlugin

+ (void)load {
    
    id Plugin = NSClassFromString(@"LPAppDelegatePlugin");
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

    if (Plugin && [Plugin respondsToSelector:@selector(registerAppDelegateClass:)]) {
       [Plugin performSelector:@selector(registerAppDelegateClass:) withObject:[self class]];
    }
    
#pragma clang diagnostic pop

}



#pragma mark - LPAppDelegatePlugin

// start launch
+ (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
        // 解析配置文件
     NSDictionary * config =  [self configs];
     pConfig = config;
     plugins = [NSMutableArray array];
     
     NSDictionary*  tms = [config objectForKey:@"tms"];
    
    if (tms && ![tms objectForKey:@"userProtocol"]) {
        [self startInit];
    }
    
    NSDictionary* modules = [config objectForKey:@"modules"];
    
    for (NSString *key in modules) {
        NSString *module = key;
        NSDictionary* moduleName  = [modules objectForKey:key];
        NSDictionary* iosConfig  =  [moduleName objectForKey:@"ios"] ? [moduleName objectForKey:@"ios"] : nil;
        NSArray* claszs = iosConfig ? [iosConfig objectForKey:@"mainclass"] : nil;

        if (!iosConfig || claszs.count == 0) {
            continue;
        }
        
        [plugins addObjectsFromArray:claszs];

        [claszs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class<LPPluginProtocol> clasz =  NSClassFromString(obj);
            if (claszs && [[clasz sharedInstance] respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
                [[clasz sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
            }
        }];
        
    }
    return  true;
}

// push
+ (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);

        if ([[clasz sharedInstance]  respondsToSelector:@selector(registerForRemoteNotificationsWithDeviceToken:)]) {
            [[clasz sharedInstance] registerForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }];

}

+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);

        if ([[clasz sharedInstance] respondsToSelector:@selector(failToRegisterForRemoteNotificationsWithError:)]) {
            [[clasz sharedInstance] failToRegisterForRemoteNotificationsWithError:error];
        }
    }];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);
        if ([[clasz sharedInstance]  respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [[clasz sharedInstance] application:application
                  didReceiveRemoteNotification:userInfo
                        fetchCompletionHandler:completionHandler];
        }
    }];
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);

        if ([[clasz sharedInstance] respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            [[clasz sharedInstance] application:application
                  didReceiveRemoteNotification:userInfo];
        }
    }];
    
}

//handle URL

+ (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);
        if ([[clasz sharedInstance] respondsToSelector:@selector(handleUrl:)]) {
            [[clasz sharedInstance] handleUrl:url];
        }
    }];
}

+ (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);
        BOOL is = [clasz respondsToSelector:@selector(handleUrl:options:)];
        if ([[clasz sharedInstance] respondsToSelector:@selector(handleUrl:options:)]) {
            [[clasz sharedInstance] handleUrl:url options:options];
        }
    }];
    
}

+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);

        if ([[clasz sharedInstance] respondsToSelector:@selector(handleUrl:sourceApplication:annotation:)]) {
            [[clasz sharedInstance] handleUrl:url sourceApplication:sourceApplication annotation:annotation];
        }
        

    }];
}


+ (BOOL)application:(UIApplication *)application
continueUserActivity:(nonnull NSUserActivity *)userActivity
 restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    
    [plugins enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz = NSClassFromString(obj);
        if ([[clasz sharedInstance] respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            [[clasz sharedInstance] application:application
                          continueUserActivity:userActivity
                            restorationHandler:restorationHandler];
        }

    }];
    
    
}


#pragma mark - init

+ (void)startInit {
    NSDictionary * dict = pConfig ? pConfig : [self configs];
    
    if (!dict) {
        return;
    }
    
    id tms = [dict objectForKey:@"tms"];
    id nconfig = [dict objectForKey:@"nconfig"];
    NSDictionary* modules = [dict objectForKey:@"modules"];
    
    
    for (NSString *key in modules) {
        NSString *module = key;
        NSDictionary* moduleName  = [modules objectForKey:key];
        NSDictionary* iosConfig  =  [moduleName objectForKey:@"ios"] ? [moduleName objectForKey:@"ios"] : nil;
        NSArray* claszs = iosConfig ? [iosConfig objectForKey:@"mainclass"] : nil;

        if (!iosConfig || claszs.count == 0) {
            continue;
        }
        

        //读取初始化参数
        NSDictionary* dependencies = [tms objectForKey:@"dependencies"];
        NSDictionary* channel = [tms objectForKey:@"channel"];

        NSDictionary * moduleConfig = dependencies != nil ? [dependencies objectForKey:module] : nil;

        NSDictionary* defaultArgs = moduleConfig != nil ? [moduleConfig objectForKey:@"args"] : nil;
        NSArray* subspecs = moduleConfig != nil ? [moduleConfig objectForKey:@"subspecs"] : nil;
        

        
        //是否有子渠道，有就需要合并渠道参数，并分别注册
        if (subspecs && subspecs.count > 0) {
            [subspecs enumerateObjectsUsingBlock:^(id  _Nonnull subspec, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:defaultArgs];
                id channelParams = [channel objectForKey:subspec];
                [params setObject:subspec forKey:@"channel"];
                [params addEntriesFromDictionary:channelParams];
                [self initEvent:claszs params:params];
            }];
        }else{
            [self initEvent:claszs params:defaultArgs];
        }
        
    }

}




+ (NSDictionary*)configs {
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tms" ofType:@"plist"]];
    NSDictionary *defaultTMSMap = [dict valueForKey:@"tms"];
    
#ifdef RELEASE
  // 正式环境，直接返回production 数据
    if([defaultTMSMap.allKeys containsObject:@"production"]){
        [dict setValue:[defaultTMSMap objectForKey:@"production"] forKey:@"tms"];
    }
    
#else
    // NSArray<RCTESComponent *> * configs = [RCTESConfig shareInstance].envConfigs;
    
    NSString *envId = [[NSUserDefaults standardUserDefaults] stringForKey:kRCTESConfigurationKey];
    NSMutableDictionary * resultTms = [NSMutableDictionary dictionary];
    
    if (envId) {
        resultTms = [defaultTMSMap objectForKey:envId];
    }
    
    resultTms.allKeys.count > 0 ?  [dict setValue:resultTms forKey:@"tms"] : [dict setValue: defaultTMSMap.allValues[0] forKey:@"tms"];
#endif
    
    return dict;
    
}

+ (void)initEvent:(NSArray*) claszs params:(NSDictionary*)params{
    
    [claszs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class<LPPluginProtocol> clasz =  NSClassFromString(obj);
        if (claszs) {
            [[clasz sharedInstance] initEvent:params];;
        }
    }];
}


NSArray<Class>* pluginClasses() {
    static NSString *configuration = @"";
    NSMutableArray *collection = [NSMutableArray array];

    Dl_info info;
    dladdr((__bridge const void *)(configuration), &info);
    uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section =  getsectbynamefromheader_64(mach_header, "__DATA","__objc_classlist");
    
    if(section == NULL){
        return nil;
    }
    
    for (uint64_t addr = section->offset; addr < section->offset + section->size; addr += sizeof(const char **)) {
        Class cls = (__bridge  Class)(*(void **)(mach_header + addr));
      
       if (class_conformsToProtocol(cls, @protocol(LPPluginProtocol))) {
           [collection addObject:cls];
       }
    }
   return [collection copy];
}


@end

