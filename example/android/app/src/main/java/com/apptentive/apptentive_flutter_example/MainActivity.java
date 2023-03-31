package com.apptentive.apptentive_flutter_example;

import android.app.Activity;
import android.os.Bundle;
import android.os.PersistableBundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import apptentive.com.android.feedback.Apptentive;
import apptentive.com.android.feedback.ApptentiveActivityInfo;
import io.flutter.embedding.android.FlutterFragmentActivity;

public class MainActivity extends FlutterFragmentActivity implements ApptentiveActivityInfo {
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState, @Nullable PersistableBundle persistentState) {
        super.onCreate(savedInstanceState, persistentState);
    }

    @Override
    public void onResume() {
        super.onResume();
        Apptentive.registerApptentiveActivityInfoCallback(this);
    }

    @NonNull
    @Override
    public Activity getApptentiveActivityInfo() {
        return this;
    }
}
