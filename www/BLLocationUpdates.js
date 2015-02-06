var exec = require('cordova/exec');

exports.configure = function(success, error, config) {
    exec(success, error, "BLLocationUpdates", "configure", [config.url,
        config.maximumAge || 0,
        config.parameters || {},
        config.headers || {}
    ]);
};

exports.start = function(success, error) {
    exec(success, error, "BLLocationUpdates", "start", []);
};
exports.stop = function(success, error) {
    exec(success, error, "BLLocationUpdates", "stop", []);
};
