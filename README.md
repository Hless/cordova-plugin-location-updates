Background location updates for Cordova
=================================

A cordova plugin to send periodical location updates to your backend server.  Just add your API endpoint and you're good to go!

Currently only iOS is supported, but an Android version is on the roadmap.

> *Note:* this plugin is **not** intended to send high precision and realtime location updates, but rather coarse estimates. This is useful
> for weather services, geofencing or location based push notifications.

Installation
-------------

Using the Cordova Command line:
```
cordova plugin add https://github.com/Hless/cordova-plugin-location-updates.git
```

Usage
-------------

There are three javascript functions available:

 - .configure(success, fail, options)
 - .start(success, fail)
 - .stop(success,fail)

After the device ready event has been fired you should configure the plugin:
```javascript
var options = {
    url:"http://www.example.com/your/endpoint", // Your API endpoint
    maximumAge: 0, // Time in seconds before location event is considered too old to be sent to server. 0  means no limit
    parameters: {  // Additional parameters (see chapter server side)
        foo: "bar"
    },
    headers: { // Additional headers
        X-foo: "x-bar"
    }
};
cordova.plugins.BLLocationUpdates.configure(onSuccess,onFail,options );
```

If configuring was a success you should start monitoring for Location Updates:
```javascript
var onSuccess = function(){
    cordova.plugins.BLLocationUpdates.start();
});
cordova.plugins.BLLocationUpdates.configure(onSuccess,onFail,options );
```

To stop monitoring :
```javascript
cordova.plugins.BLLocationUpdates.stop();
```

Receiving location updates
======================

Locations will be send to your backend in JSON format. The structure looks as follows:
```json
{  
  "location":{  
    "altitude":0,
    "horizontalAccuracy":5,
    "latitude":37.69120159,
    "longitude":-122.47024365,
    "verticalAccuracy":-1
  },
  "foo": "bar"
}
```
