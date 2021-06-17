package com.terminus.tms;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.res.AssetManager;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;



import static android.content.Context.MODE_PRIVATE;


public class TMSModulePlugin {

    private static Map<String, Object> config ;
    private static final String ENV_SWITCH_LOCAL_CONFIG_KEY = "env.switch.config";
    private static Context _context;

    public static void init(Context mContext) {

        _context = mContext;

        try {
            config = readConfig(mContext);


            Map<String, Object> modules = (Map<String, Object>) config.get("modules");
            Map<String, Object> tms = (Map<String, Object>) config.get("tms");
            Map<String, Object> nconfig = (Map<String, Object>) config.get("nconfig");

            Map<String, Object> dependencies = (Map<String, Object>) tms.get("dependencies");


            for (String module : modules.keySet()) {
                Map<String, Object> clazzNames = (Map<String, Object>)modules.get(module);
                Map<String, Object>  androidConfigs = clazzNames != null && clazzNames.size()>0 ? (Map<String, Object>)clazzNames.get("android") : null;
                List<String> classes = androidConfigs != null ? (List)androidConfigs.get("mainclass") : null;


                if ( classes == null || classes.size() == 0 ){
                    continue;
                }

                for (String clazzName : classes) {

                    Class<IPluginModuleRule> clasz = getClass(clazzName);
                    if ( clasz == null){ continue; }

                    //开始初始化
                    Method method = clasz.getMethod("getInstance");
                    IPluginModuleRule moduleRule = (IPluginModuleRule) method.invoke(null);


                    Map<String, Object> moduleConfig = dependencies != null ? (Map<String, Object>) dependencies.get(module) : null;

                    //1. 没有参数配置，
                    if (moduleConfig == null) {
                        mainInit(moduleRule, mContext, null);
                        continue;

                    }

                    //2. 没有子渠道参数
                    List<String> subspecs = (List<String>) moduleConfig.get("subspecs");
                    Map<String, Object> defaultArgs = (Map<String, Object>) moduleConfig.get("args");

                    if (subspecs == null || subspecs.size() == 0) {
                        mainInit(moduleRule, mContext, defaultArgs);

                        continue;
                    }

                    //3. 包含子渠道参数， 需要分别注册
                    Map<String, Object> channels = (Map<String, Object>) tms.get("channel");

                    for (String sub : subspecs) {
                        Map<String, Object> args = defaultArgs != null ? defaultArgs : new HashMap();
                        args.put("channel", sub);
                        if (channels != null) {
                            args.putAll((Map<String, Object>) channels.get(sub));
                        }
                        mainInit(moduleRule, mContext, args);
                    }
                }

            }


        } catch (Exception e) {
            String msg = e.getLocalizedMessage();
        }

    }


    public static void handleActivityResult(int requestCode, int resultCode, Intent data) {

        Gson gson = new Gson();
        Map<String, Object> map = new HashMap<String, Object>();

        try {

            config = gson.fromJson(getJson("tmsConfig.json",_context), map.getClass());

            Map<String, Object> modules = (Map<String, Object>) config.get("modules");


            for (String module : modules.keySet()) {
                Map<String, Object> clazzNames = (Map<String, Object>)modules.get(module);
                Map<String, Object> clazzNameConfig = clazzNames != null && clazzNames.size()>0 ? (Map<String, Object>)clazzNames.get("android") : null;

                List<String> classes = (List<String>)clazzNameConfig.get("mainclass");

                for (String clazzName : classes) {
                    Class<IPluginModuleRule> clasz = getClass(clazzName);
                    Method method = clasz.getMethod("getInstance");
                    IPluginModuleRule  moduleRule =  (IPluginModuleRule) method.invoke(null);
                    moduleRule.onResult(requestCode,resultCode,data);
                }
            }

        } catch (Exception e) {

            String msg = e.getLocalizedMessage();

        }

    }

    public static void handleResult(Object args) {


    }



    private static Class<IPluginModuleRule> getClass(String s) {
        
        try {
            Class clazz = Class.forName(s);
            return clazz;

        } catch (ClassNotFoundException e) {

        }
        return null;
    }


    private static void mainInit(IPluginModuleRule ModuleRule, Context mContext,Map args) {

        if (mContext != null && mContext instanceof Activity){
            ModuleRule.initActivity(mContext,args);
            ModuleRule.initApplication(((Activity) mContext).getApplication(),args);
        }else if (mContext != null && mContext instanceof Application){
            ModuleRule.initApplication(mContext,args);

        }

    }


    private static Map<String, Object> readConfig(Context mContext) {

        try {

          SharedPreferences sp = mContext.getSharedPreferences("EnvSwitchConfig", MODE_PRIVATE);
          String localId = sp.getString(ENV_SWITCH_LOCAL_CONFIG_KEY, null);

          Gson gson = new Gson();
          Map<String, Object> map = new HashMap<String, Object>();

          config = gson.fromJson(getJson("tmsConfig.json",mContext), map.getClass());
          Map<String, Object> tms = (Map<String, Object>) config.get("tms");
//          List<EnvComponent> configs = EnvSwitchConfig.shareInstance().getConfigs();

            // 正式固定production
            if (!isDebugApk(mContext)){
                Map<String, Object> r = tms.containsKey("production") ? (Map<String, Object>)tms.get("production") : (Map<String, Object>)tms.values().toArray()[0];
                config.put("tms",r);
                return config;
            }


          //根据保存的环境id获取配置
          if (localId != null &&  tms.get(localId) != null ){
            Map<String, Object> r =  (Map<String, Object>)tms.get(localId);
            config.put("tms",r);
         } else{
            config.put("tms",tms.values().toArray()[0]);
         }




        } catch (Exception e) {


        }

        return config;

    }


    private static boolean isDebugApk(Context mContext) {
        ApplicationInfo info = mContext.getApplicationInfo();
        if ((info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            return true;
        }
        return false;
    }



    private static String getJson(String fileName, Context context){
        StringBuilder stringBuilder = new StringBuilder();
        try {
            //获取assets资源管理器
            AssetManager assetManager = context.getAssets();
            //通过管理器打开文件并读取
            BufferedReader bf = new BufferedReader(new InputStreamReader(
                    assetManager.open(fileName)));
            String line;
            while ((line = bf.readLine()) != null) {
                stringBuilder.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return stringBuilder.toString();
    }

}


