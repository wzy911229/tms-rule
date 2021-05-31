package com.sanlux.app;

import android.app.Application;
import android.content.Intent;
import android.os.Bundle;

import com.facebook.react.ReactActivity;
import com.mobilepay.pay.model.PayManager;
import com.mobilepay.pay.model.Constants;

import com.mobilepay.pay.PayEnvUtils;

//

import static com.mobilepay.pay.model.Constants.CHANNEL_ALIPAY;
import static com.mobilepay.pay.model.Constants.CHANNEL_STRIPE_PAY;
import static com.mobilepay.pay.model.Constants.CHANNEL_UNIFY_PAY;
import static com.mobilepay.pay.model.Constants.CHANNEL_UNION_pay;
import static com.mobilepay.pay.model.Constants.CHANNEL_WECHAT_PAY;


public class MainActivity extends ReactActivity  {
    private  String appKey = "pk_test_51H9nWlLQQWKY5C6z2CR9LcTrXbQm0C7NhWf0WzGCylVbVvjfYMeBvR7IWW6jaGOMgdDjXidXwrbLlpBXsYICXUj700298qd14x";
    /**
     * Returns the name of the main component registered from JavaScript.
     * This is used to schedule rendering of the component.
     */
    @Override
    protected String getMainComponentName() {
        return "example";
    }



    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        PayEnvUtils.setEnv(PayEnvUtils.EnvEnum.SANDBOX);

//
        PayManager.getInstance().init(this ,CHANNEL_ALIPAY);
        PayManager.getInstance().init(this ,CHANNEL_WECHAT_PAY,"wxc3f83491b0498799");
        PayManager.getInstance().init(this ,CHANNEL_STRIPE_PAY,"pk_test_51H4g1BKARacskkzS4RjHmSvX2zBKJ1hoiM4TQF0Aznt9q9VxFujgVYwvPbo9npCOUns3DKNPVmtW3FAsDhTa9axS00BP2ANIf2");
        PayManager.getInstance().init(this ,CHANNEL_UNION_pay,"01");
       PayManager.getInstance().init(this ,CHANNEL_UNIFY_PAY,"01");




    }


    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        PayManager.getInstance().handleActivityResult(requestCode,resultCode,data);
    }
}