(function() {
  var enabled, probe;

  enabled = false;

  probe = function() {
    if (enabled) return console.log.apply(null, arguments);
  };

  probe.enable = function() {
    return enabled = true;
  };

  if (process.env.PROBE != null) probe.enable();

  module.exports = probe;

}).call(this);
