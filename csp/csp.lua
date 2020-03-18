-- Section CSP Reporting Module
local csp = {}
local cjson = require "cjson"
local JSON_LOCATION = "/opt/proxy_config/csp/csp.json" --const

function logIt(message)
    if  (_G["ngx"] ~= nil) then 
        _G["ngx"].log(_G["ngx"].ERR, message)
    else 
        io.stderr:write(message .. '\n')
    end
end 

function csp.respondToReport()
    -- return a 204 response to the browser report request
    ngx.req.read_body()
    local data = ngx.req.get_body_data()

    if not data then 
        ngx.status = 400  
        ngx.say("Bad request")  
        return ngx.exit(400)   
    end

    local sectionIoId = ngx.req.get_headers()["section-io-id"]

    -- send the reported body to error logs. Can comment this out if you do not wish to log
    logIt("section-io-id: " .. sectionIoId .. " - ".. data)
    ngx.status = 204  
    ngx.say("No content")  
    return ngx.exit(204) 
end

function csp.injectHeader() 
    -- If JSON has inject header true, then inject the CSP header
    if cspInjectEnabled then
        ngx.header["Content-Security-Policy_Report-Only"] = cspInjectHeader
    end 

end

function csp.loadJSON() 
    -- Load csp.json and store the contents. 
    local file = io.open(JSON_LOCATION, "r")
    if not file then
        logIt("CSP Reporting Module: csp.json not found in module config folder.")
        return false, ""
    end     

    logIt("CSP Reporting Module: loading csp.json")
    local contents = file:read( "*a" )
    contents = cjson.decode(contents);

    if not contents then
        logIt("CSP Reporting Module: csp.json contains invalid JSON.")
        return false, ""
    end  

    injectEnabled = contents.inject_headers;
    header = contents.Content_Security_Policy_Report_Only;

    io.close(file)
    logIt("CSP Reporting Module: csp.json loaded" )
    return injectEnabled, header
end

return csp