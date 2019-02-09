--[[
%% properties
0 power
%% weather
%% events
%% globals
--]]

local userId = 0 -- Set User ID to send e-mail to
local emailSubject = "" -- Set subject for e-mail report
local deviceId = 0 -- Set which device to monitor. Remember to set it in the file header too!
local consumptionValueVariable = "" -- Global variable to store energy meter value
local upperInactiveThreshold = 100 -- In watts. Report will be sent when load goes below this threshold.
local lowerActiveThreshold = 1000 -- In watts. The consumption variable will be set when load goes above this threshold.

local deviceName = fibaro:getName(deviceId)
local powerMeterValue = fibaro:get(deviceId, "power")
local energyMeterValue = fibaro:get(deviceId, "energy")
local consumptionValueOnStart, consumptionValueTimestamp = fibaro:getGlobal(consumptionValueVariable)
local powerMeterValueAsNumber = tonumber(powerMeterValue)
local energyMeterValueAsNumber = tonumber(energyMeterValue)

function seconds_to_stopwatch(seconds)
    local seconds = tonumber(seconds)

    if seconds <= 0 then
        return "00:00:00"
    else
        hours = string.format("%02.f", math.floor(seconds / 3600))
        mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
        return hours .. ":" .. mins .. ":" .. secs
    end
end

fibaro:debug("Load is " .. powerMeterValue .. " W. " .. consumptionValueVariable .. " is " .. consumptionValueOnStart .. " kWh set at " .. os.date("%Y-%m-%d %H:%M:%S", consumptionValueTimestamp))

if consumptionValueOnStart == nil or tonumber(consumptionValueOnStart) == nil then
    consumptionValueOnStart = 0
end

local consumptionValueOnStartAsNumber = tonumber(consumptionValueOnStart)

if powerMeterValueAsNumber > lowerActiveThreshold and consumptionValueOnStartAsNumber == 0 then
    fibaro:setGlobal(consumptionValueVariable, energyMeterValueAsNumber)
    fibaro:debug("Set " .. consumptionValueVariable .. " to " .. energyMeterValueAsNumber .. " kWh.")
else
    if powerMeterValueAsNumber < upperInactiveThreshold and consumptionValueOnStartAsNumber > 0 then
        fibaro:setGlobal(consumptionValueVariable, 0)
        local secondsSinceHeatPumpActivated = os.time() - consumptionValueTimestamp

        local timeSpent = seconds_to_stopwatch(secondsSinceHeatPumpActivated)
        local energySpent = energyMeterValueAsNumber - consumptionValueOnStartAsNumber
        fibaro:debug("Sending report.")
        fibaro:call(
            userId,
            "sendEmail",
            emailSubject,
            deviceName .. " was on for " .. timeSpent .. " and consumed " .. string.format("%.2f", energySpent) .. " kWh."
        )
    end
end
