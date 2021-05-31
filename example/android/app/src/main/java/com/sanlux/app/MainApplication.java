package com.sanlux.app;

import android.app.Application;

import com.facebook.react.ReactApplication;

import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.react.shell.MainReactPackage;
import com.terminus.tms.TMSReactPackage;

import com.facebook.soloader.SoLoader;
import com.mobilepay.pay.ReactNativePayPackage;
import java.util.Arrays;
import java.util.List;


/**
 * User : yehao
 * Date : 16/9/26
 * Email : yh@terminus.io
 */

public class MainApplication extends Application implements ReactApplication {
    private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
        /**
         * Returns whether dev mode should be enabled.
         * This enables e.g. the dev menu.
         */
        @Override
        public boolean getUseDeveloperSupport() {
            return BuildConfig.DEBUG;
        }


        /**
         * A list of packages used by the app. If the app uses additional views
         * or modules besides the default ones, add more packages here.
         */
        @Override
        protected List<ReactPackage> getPackages() {

            return Arrays.<ReactPackage>asList(
                    new MainReactPackage(),
                    new ReactNativePayPackage(),
                    new TMSReactPackage()
            );
        }


        @Override
        protected String getJSMainModuleName() {
            return "index.android.js";
        }


    };

    @Override
    public ReactNativeHost getReactNativeHost() {
        return mReactNativeHost;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
    }
}
