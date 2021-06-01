package com.terminus.android;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;

import com.terminus.tms.TMSModulePlugin;


public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        TMSModulePlugin.init(this);
    }

}
