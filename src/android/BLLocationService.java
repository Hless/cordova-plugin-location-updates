package com.bocoder.locationupdates;

import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.LocationListener;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;




public class BLLocationService extends Service {

    private String TAG = "BLLocationUpdates";
    private String url;
    private int maximumAge;
    private JSONObject params;
    private JSONObject headers;


    @Override
    public IBinder onBind(Intent intent) {
        // TODO Auto-generated method stub
        Log.i(TAG, "OnBind" + intent);
        return null;
    }

    @Override
    public void onCreate() {

        // android.os.Debug.waitForDebugger();
        super.onCreate();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        this.initializeVariables();

        this.startListeningForLocationUpdates();

        //We want this service to continue running until it is explicitly stopped
        return START_REDELIVER_INTENT;
    }

    public void initializeVariables() {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);

        url = prefs.getString("loc_url", null);
        maximumAge = prefs.getInt("max_age", 0);
        try {
            params = new JSONObject(prefs.getString("loc_params", "{}"));
            headers = new JSONObject(prefs.getString("loc_headers", "{}"));
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    public void startListeningForLocationUpdates (){
        // Luister hier naar location updates


    }

    public void postToServer() {
        // Post hier naar server
        try {
            JSONObject location = new JSONObject();
            //Vul JSON object hier:
        /*
             location.put("latitude", l.getLatitude());
            location.put("longitude", l.getLongitude());
            location.put("accuracy", l.getAccuracy());
            location.put("speed", l.getSpeed());
            location.put("bearing", l.getBearing());
            location.put("altitude", l.getAltitude());
            location.put("recorded_at", dao.dateToString(l.getRecordedAt()));
         */
            this.params.put("location", location);
        } catch (JSONException e) {
            // Handle exception
        }


        // Stuur request naar:  this.url;
        // Met: this.params als body
        // En met: this.headers als headers
        // Wanneer tijd van location event niet ouder is als currentTime - this.maximumAge (indien this.maximumAge 0 is geen limit hanteren)


    }


    @Override
    public boolean stopService(Intent intent) {
        return super.stopService(intent);
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }

}