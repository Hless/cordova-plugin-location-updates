package com.bocoder.locationupdates;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.preference.PreferenceManager;
import android.util.Log;

import com.bocoder.locationupdates.BLLocationService;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;


public class BLLocationUpdates extends CordovaPlugin {

    // Constants
    private static final String TAG = "BLLocationUpdates";
    public static final int START_REQ_CODE = 0;
    public static final int PERMISSION_DENIED_ERROR = 20;
    protected final static String[] permissions = { Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION };


    private static String action_configure = "configure";
    private static String action_start = "start";
    private static String action_stop = "stop";
    private Context ctx;
    Activity activity;
    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        try {
            this.callbackContext = callbackContext;
            activity =  this.cordova.getActivity();
            ctx = this.cordova.getActivity().getApplicationContext();
            if (action.equalsIgnoreCase(action_configure)) {
                this.configure(args);
            } else if (action.equalsIgnoreCase(action_start)) {

                if (hasPermisssion()) {
                    this.start();
                } else {
                    BLPermissionHelper.requestPermissions(this, START_REQ_CODE, permissions);
                }

            } else if (action.equalsIgnoreCase(action_stop)) {
                this.stop();
            } else {
                return false;
            }

            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, "Command succesfully executed"));

        } catch (Exception e) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
        }

        return true;
    }

    private void configure (JSONArray args) throws JSONException {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(ctx);
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("loc_url", args.getString(0));
        editor.putInt("max_age", args.getInt(1));
        editor.putString("loc_params", args.getString(2));
        editor.putString("loc_headers", args.getString(3));
        editor.commit();
    }

    private void start () {
        Intent myIntent = new Intent(activity , BLLocationService.class);
        activity.startService(myIntent);
    }

    public boolean hasPermisssion() {
        for(String p : permissions)
        {
            if(!BLPermissionHelper.hasPermission(this, p))
            {
                return false;
            }
        }
        return true;
    }

    private void stop () {
        Intent myIntent = new Intent(activity , BLLocationService.class);
        activity.stopService(myIntent);
    }


    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException {
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                Log.d(TAG, "Permission Denied!");
                PluginResult result = new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR);
                result.setKeepCallback(true);
                this.callbackContext.sendPluginResult(result);
                return;
            }
        }
        switch (requestCode) {
            case START_REQ_CODE:
                this.start();
                break;
        }
    }
}