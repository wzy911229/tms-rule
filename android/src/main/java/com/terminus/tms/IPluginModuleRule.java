package com.terminus.tms;

import android.content.Context;
import android.content.Intent;

import java.util.Map;


public interface  IPluginModuleRule {

    public Object getInstance(Object... args);
    public void initActivity(Context mContext, Map args);
    public void initApplication(Context mContext, Map args);
    public void onResult(int requestCode, int resultCode, Intent data);

}
