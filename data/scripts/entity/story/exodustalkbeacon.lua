function playerHasKey1() -- overridden
    local player
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


local Azimuth = include("azimuthlib-basic")

local exodusFix_configOptions = {
  _version = { default = "1.0", comment = "Config version. Don't touch." },
  ExodusKeyCooldown = { default = 86400, min = 60, format = "floor", comment = "How much time in seconds player has to wait before getting another Exodus Key (86400 - 1 day)" }
}
local ExodusFixConfig, exodusFix_isModified = Azimuth.loadConfig("ExodusFixes", exodusFix_configOptions)
if exodusFix_isModified then
    Azimuth.saveConfig("ExodusFixes", ExodusFixConfig, exodusFix_configOptions)
end

local exodusFix_initialize = initialize
function initialize()
    exodusFix_initialize()

    Sector():registerCallback("onPlayerEntered", "exodusFix_checkExodusKeyTime")
end

local exodusFix_dropKey = dropKey
function dropKey()
    if playerHasKey1() then return end

    exodusFix_dropKey()

    local player = Player(callingPlayer)
    local server = Server()
    local serverRuntime = server:getValue("online_time") or 0
    if server:hasAdminPrivileges(player) then
        player:setValue("exodus_key_time", serverRuntime + 600) -- don't make things too difficult in singleplayer
    else
        player:setValue("exodus_key_time", serverRuntime + ExodusFixConfig.ExodusKeyCooldown)
    end
end

function exodusFix_checkExodusKeyTime(playerIndex)
    local serverRuntime = Server():getValue("online_time") or 0
    local player = Player(playerIndex)
    local exodusTime = player:getValue("exodus_key_time")
    if exodusTime and serverRuntime >= exodusTime then
         player:setValue("exodus_key_time") -- player can receive exodus upgrade again
    end
end


end