//
//  LPAppDelegatePlugin.h
//  TRNWAppTemplate
//
//  Created by zhiyu on 2020/11/18.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LPAppDelegatePlugin : NSObject


+ (void)registerAppDelegateClass:(nonnull Class)cla;

+ (void)registerAppDelegateObject:(nonnull id)obj;


@end

NS_ASSUME_NONNULL_END
