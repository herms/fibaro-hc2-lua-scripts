--[[
%% properties
%% weather
%% events
%% globals
--]]

local userId = 0
local warningEmailSubject = ""
local deviceId = 0 -- Set device ID
local warningFlagVariable = ""
local maxSecondsSinceReport = 120
local upperSafeLoadThreshold = 6000

local deviceName = fibaro:getName(deviceId)
local powerMeterValue, modificationTime = fibaro:get(deviceId, "power")
local secondsSinceLastModification = os.time() - modificationTime

fibaro:debug(deviceName .. " load was " .. powerMeterValue .. " W at " .. os.date("%Y-%m-%d %H:%M:%S", modificationTime))

if tonumber(powerMeterValue) > upperSafeLoadThreshold and secondsSinceLastModification > maxSecondsSinceReport then
    local warningVariable = fibaro:getGlobal(warningFlagVariable)
    local warningIsSent = warningVariable and tonumber(warningVariable) == 1
    if not warningIsSent then
        fibaro:debug("Sending warning.")
        fibaro:call(
            userId,
            "sendEmail",
            warningEmailSubject,
            deviceName .. " reported consumption of " .. powerMeterValue .. " W at " .. os.date("%Y-%m-%d %H:%M:%S", modificationTime) .. " and has not reported anything since. It has now been " .. secondsSinceLastModification .. " since last modification. The time is currently " .. os.date("%Y-%m-%d %H:%M:%S", os.time()) .. "."
        )
        fibaro:setGlobal(warningFlagVariable, 1)
    end
else
    fibaro:debug("Warning not sent.")
    fibaro:setGlobal(warningFlagVariable, 0)
end
