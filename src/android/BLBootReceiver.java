package com.bocoder.locationupdates;

import android.content.Context;
import android.content.Intent;
import android.content.BroadcastReceiver;


public class BLBootReceiver extends BroadcastReceiver {   

    @Override
    public void onReceive(Context context, Intent intent) {

      Intent myIntent = new Intent(context, BLLocationService.class);
      context.startService(myIntent);
    }
}
