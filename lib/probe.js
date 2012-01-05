(function() {
  var enabled, probe;

  enabled = false;

  probe = function() {
    if (enabled) return console.log.apply(null, arguments);
  };

  probe.enable = function() {
    return enabled = true;
  };

  module.exports = probe;

}).call(this);
