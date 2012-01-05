# Future plans to make this more useful but it has some value even in this
# minimal state
enabled = no
probe = -> console.log.apply null, arguments if enabled
probe.enable = -> enabled = yes

module.exports = probe
