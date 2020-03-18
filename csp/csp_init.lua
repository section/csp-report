--Load csp.json configuration from file source on startup
cspInjectEnabled = false;
cspInjectHeader = "";

csp = require("/opt/proxy_config/csp/csp")
cspInjectEnabled, cspInjectHeader = csp.loadJSON()