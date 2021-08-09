local exf_initialize, exf_dropKey -- extended server functions
local exf_config -- server


function playerHasKey1(player) -- overridden
    player = player or Player()
    if callingPlayer then
        player = Player(callingPlayer)
    else
        player = Player()
    end
    if not player then return end

    -- we don't need to check inventory or ships, because there are still too many ways to bypass these checks
    -- just tell when player got the key
    return player:getValue("exodus_key_time") ~= nil
end


if onServer() then


Azimuth = include("azimuthlib-basic")

local exf_configOptions = {
  _version = { default = "1.0", comment = "Config version. Don't touch." },
  ExodusKeyCooldown = { default = 86400, min = 60, format = "floor", comment = "How much time in seconds player has to wait before getting another Exodus Key (86400 - 1 day)" }
}
local exf_config, exf_isModified = Azimuth.loadConfig("ExodusFixes", exf_configOptions)
if exf_isModified then
    Azimuth.saveConfig("ExodusFixes", exf_config, exf_configOptions)
end

exf_initialize = initialize
function initialize(...)
    exf_initialize(...)

    Sector():registerCallback("onPlayerEntered", "exf_checkExodusKeyTime")
end

exf_dropKey = dropKey
function dropKey(...)
    if playerHasKey1() then return end

    exf_dropKey(...)

    local player = Player(callingPlayer)
    local server = Server()
    local serverRuntime = server:getValue("online_time") or 0
    if server:hasAdminPrivileges(player) then
        player:setValue("exodus_key_time", serverRuntime + 600) -- don't make things too difficult in singleplayer
    else
        player:setValue("exodus_key_time", serverRuntime + exf_config.ExodusKeyCooldown)
    end
end

function exf_checkExodusKeyTime(playerIndex)
    local serverRuntime = Server():getValue("online_time") or 0
    local player = Player(playerIndex)
    local exodusTime = player:getValue("exodus_key_time")
    if exodusTime and serverRuntime >= exodusTime then
         player:setValue("exodus_key_time") -- player can receive exodus upgrade again
    end
end


end