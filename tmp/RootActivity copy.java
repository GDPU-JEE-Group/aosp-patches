package com.android.ext.root;

import android.content.pm.PackageInfo;
import android.os.Bundle;
import android.preference.CheckBoxPreference;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceCategory;
import android.preference.SwitchPreference;

import android.annotation.Nullable;

import com.android.ext.R;
import com.android.libutils.Package;

import java.util.List;
import android.content.SharedPreferences;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;


/**
 * @noinspection ALL
 */
public class RootActivity extends PreferenceActivity implements Preference.OnPreferenceChangeListener {

    SwitchPreference mGlobalPreference;
    PreferenceCategory mAppPreference;
    CheckBoxPreference mPromptPreference;
    RootController mRootController;
    // 新增的成员变量
    PreferenceCategory mAppDaemonPreference;
    List<String> appDaemonList;  // 用于存储持久化的包名
    SharedPreferences sharedPreferences;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.root_preferences);

        // 获取SharedPreferences对象
        sharedPreferences = getSharedPreferences("appDaemonPrefs", MODE_PRIVATE);
        appDaemonList = new ArrayList<>(sharedPreferences.getStringSet("app_daemon_list", new HashSet<>()));

        // 打印当前持久化的包名列表
        logAppDaemonList();

        // 初始化RootController
        mRootController = RootController.getInstance(getApplicationContext());
        mRootController.setRootListener(new RootController.OnRootChangedListener() {
            @Override
            public void onRootChanged(String packageName, boolean isGranted) {
                setAppPreferenceStatus(packageName, isGranted);
            }

            @Override
            public void onGlobalRootChanged(boolean isRoot) {
                adjustAllAppPreference(isRoot);
            }
        });

        // 加载已有的控件
        mGlobalPreference = (SwitchPreference) findPreference("global_root");
        mGlobalPreference.setChecked(mRootController.isGlobalRoot());

        mPromptPreference = (CheckBoxPreference) findPreference("prompt");
        mPromptPreference.setChecked(mRootController.isKillApply());
        mPromptPreference.setOnPreferenceChangeListener(this);

        mAppPreference = (PreferenceCategory) findPreference("app_root_details");
        List<PackageInfo> packageInfos = Package.getAllPackages(getApplicationContext());
        SwitchPreference preference;
        for (PackageInfo pi : packageInfos) {
            preference = getAppPreference(pi.packageName);
            preference.setChecked(mRootController.isRootApp(pi.packageName));
            preference.setEnabled(mRootController.isGlobalRoot());
        }

        // 新增appDaemon的PreferenceCategory处理逻辑
        mAppDaemonPreference = (PreferenceCategory) findPreference("app_daemon");
        // 遍历所有应用的包名
        for (PackageInfo pi : packageInfos) {
            // 获取每个应用的SwitchPreference
            SwitchPreference preference = getAppDaemonPreference(pi.packageName);
            
            // 如果包名在持久化的appDaemonList中，设置为选中状态，否则未选中
            if (appDaemonList.contains(pi.packageName)) {
                preference.setChecked(true);
            } else {
                preference.setChecked(false);
            }
            preference.setEnabled(true);  // 根据业务逻辑启用/禁用
        }


        mGlobalPreference.setOnPreferenceChangeListener(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mRootController.removeRootListener();
    }

    public void adjustAllAppPreference(boolean isRoot) {
        mGlobalPreference.setChecked(isRoot);
        int childCount = mAppPreference.getPreferenceCount();
        SwitchPreference preference;
        if (isRoot) {
            for (int i = 0; i < childCount; i++) {
                preference = (SwitchPreference) mAppPreference.getPreference(i);
                preference.setEnabled(true);
                preference.setChecked(mRootController.isRootApp(preference.getKey()));

                if (mRootController.isKillApply()) {
                    Package.killBackgroundProcess(getApplicationContext(), preference.getKey());
                }
            }
        } else {
            for (int i = 0; i < childCount; i++) {
                preference = (SwitchPreference) mAppPreference.getPreference(i);
                preference.setEnabled(false);
                preference.setChecked(false);

                if (mRootController.isKillApply()) {
                    Package.killBackgroundProcess(getApplicationContext(), preference.getKey());
                }
            }
        }
    }

    public void setAppPreferenceStatus(String packageName, boolean isGrant) {
        SwitchPreference preference = getAppPreference(packageName);
        if (preference != null) {
            if (!mRootController.isGlobalRoot()) {
                preference.setEnabled(false);
                preference.setChecked(false);
            } else {
                preference.setEnabled(true);
                preference.setChecked(isGrant);
            }
        }
    }

    public SwitchPreference getAppPreference(String packageName) {
        if (Package.isInstall(getApplicationContext(), packageName)) {
            SwitchPreference preference = (SwitchPreference) mAppPreference.findPreference(packageName);
            if (preference != null) {
                return preference;
            }
            SwitchPreference switchPreference = new SwitchPreference(getApplicationContext());
            switchPreference.setIcon(Package.getAppIcon(getApplicationContext(), packageName));
            switchPreference.setTitle(Package.getAppLabel(getApplicationContext(), packageName));
            switchPreference.setSwitchTextOn(R.string.allow);
            switchPreference.setSwitchTextOff(R.string.disallow);
            switchPreference.setKey(packageName);
            switchPreference.setOnPreferenceChangeListener(this);

            mAppPreference.addPreference(switchPreference);

            return switchPreference;
        } else {
            SwitchPreference preference = (SwitchPreference) mAppPreference.findPreference(packageName);
            if (preference != null) {
                mAppPreference.removePreference(preference);
            }
            return null;
        }
    }
    // 获取或创建SwitchPreference并监听变化
    public SwitchPreference getAppDaemonPreference(String packageName) {
        SwitchPreference preference = new SwitchPreference(getApplicationContext());
        preference.setIcon(Package.getAppIcon(getApplicationContext(), packageName));
        preference.setTitle(Package.getAppLabel(getApplicationContext(), packageName));
        preference.setSwitchTextOn(R.string.allow);
        preference.setSwitchTextOff(R.string.disallow);
        preference.setKey(packageName);
        preference.setOnPreferenceChangeListener((pref, newValue) -> {
            boolean isChecked = (Boolean) newValue;
            if (isChecked) {
                addAppToDaemonList(packageName);
            } else {
                removeAppFromDaemonList(packageName);
            }
            logAppDaemonList();  // 每次更新时打印列表
            return true;
        });
        return preference;
    }

    // 添加包名到appDaemonList，并持久化
    private void addAppToDaemonList(String packageName) {
        appDaemonList.add(packageName);
        saveAppDaemonList();
    }

    // 从appDaemonList中移除包名，并持久化
    private void removeAppFromDaemonList(String packageName) {
        appDaemonList.remove(packageName);
        saveAppDaemonList();
    }

    // 持久化存储appDaemonList
    private void saveAppDaemonList() {
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putStringSet("app_daemon_list", new HashSet<>(appDaemonList));
        editor.apply();
    }

    // 打印当前appDaemonList的内容
    private void logAppDaemonList() {
        System.out.println("App Daemon List: " + appDaemonList.toString());
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        boolean isChecked = (Boolean) newValue;
        String packageName = preference.getKey();
        
        if (isChecked) {
            // 添加包名到appDaemonList
            appDaemonList.add(packageName);
        } else {
            // 移除包名
            appDaemonList.remove(packageName);
        }

        // 持久化更新后的appDaemonList
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putStringSet("app_daemon_list", new HashSet<>(appDaemonList));
        editor.apply();  // 使用apply()而不是commit()，以提高性能

        // 打印日志
        Log.i("App Daemon", "App Daemon List: " + appDaemonList.toString());

        return true;
    }

}

