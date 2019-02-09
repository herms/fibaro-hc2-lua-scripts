--[[
%% properties
-- Add motion detector deviceIds here, one per line, e.g.:
-- 12 value
%% globals
%% killOtherInstances
--]]

local lights = {} -- Enter device IDs for the lights here, e.g. {1, 2, 3}
local sensors = {} -- Enter device IDs for the sensors here, same as in properties header
local gracePeriodVariable = "" -- Enter global variable name here, e.g. "LastMotionKitchen"
local defaultGracePeriodInSeconds = 1800
local defaultGracePeriodWhenNoMotion = 300

if not gracePeriodVariable or gracePeriodVariable == "" then
	print("Please set global variable name.")
	do
		return
	end
end

if not fibaro:getGlobalValue(gracePeriodVariable) then
	print(string.format("Please create the global variable %s in the variables panel first.", gracePeriodVariable))
	do
		return
	end
end

local startSource = fibaro:getSourceTrigger()
local shouldTurnLightsOn = false
local allSensorsReportNoMotion = false
local gracePeriodInSeconds = defaultGracePeriodInSeconds

if startSource["type"] == "property" then
	local triggeringDeviceId = startSource["deviceID"]
	local triggeringDevicePropertyName = startSource["propertyName"]
	local triggeringDeviceValue = fibaro:getValue(triggeringDeviceId, "value")
	local triggeringDeviceNumericValue = tonumber(triggeringDeviceValue)
	print(
		string.format(
			"Scene triggered by %s %s which has a value of %s.",
			triggeringDeviceId,
			triggeringDevicePropertyName,
			triggeringDeviceValue
		)
	)
	if triggeringDeviceNumericValue == 1 then
		print("Sensor detected motion.")
		shouldTurnLightsOn = true
	elseif triggeringDeviceNumericValue == 0 then
		allSensorsReportNoMotion = true
		gracePeriodInSeconds = defaultGracePeriodWhenNoMotion
		if #sensors > 1 then
			for d, sensorId in ipairs(sensors) do
				if (tonumber(fibaro:getValue(sensorId, "value")) == 1) then
					print(string.format("Sensor %s still reporting motion.", sensorId))
					allSensorsReportNoMotion = false
					gracePeriodInSeconds = defaultGracePeriodInSeconds
					break
				end
			end
		end
	end
elseif startSource["type"] == "other" then
	print("Scene was triggered manually.")
	shouldTurnLightsOn = true
end

print(string.format("Setting grace period to %s seconds.", gracePeriodInSeconds))
fibaro:setGlobal(gracePeriodVariable, gracePeriodInSeconds)

if shouldTurnLightsOn then
	print("Turning on lights.")
	for i, deviceId in ipairs(lights) do
		print(string.format("Turning on %s.", deviceId))
		fibaro:call(deviceId, "turnOn")
	end
	print("Turned on lights.")
end
