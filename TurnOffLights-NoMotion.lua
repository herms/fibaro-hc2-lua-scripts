--[[
%% autostart
%% properties
%% globals
%% killOtherInstances
--]]

local gracePeriodVariable = "" -- Enter global variable name here, e.g. "BathroomLightsPeriod"
local lights = {} -- Enter device IDs here, e.g. {1, 2, 3}
local sleepInSeconds = 60 -- Enter how long to wait between each check

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

local sleepInMs = sleepInSeconds * 1000

while true do
	local timestamp = os.time()
	local gracePeriodString, lastModified = fibaro:getGlobal(gracePeriodVariable)

	if gracePeriodString and tonumber(gracePeriodString) ~= nil and lastModified then
		local gracePeriod = tonumber(gracePeriodString)
		local timeToTurnLightsOff = lastModified + gracePeriod

		print(
			string.format(
				"Time to turn off lights: %s. Grace period: %d seconds.",
				os.date("%c", timeToTurnLightsOff),
				gracePeriod
			)
		)

		if timeToTurnLightsOff and timeToTurnLightsOff > 0 and timestamp > timeToTurnLightsOff then
			print(string.format("Turning off lights after set grace period of %d seconds.", gracePeriod))
			for i, deviceId in ipairs(lights) do
				print(string.format("Turning off %s.", deviceId))
				fibaro:call(deviceId, "turnOff")
			end
			print("Turned off lights.")
			fibaro:setGlobal(gracePeriodVariable, "")
		else
			print(
				string.format(
					"Not turning off lights yet. Waiting until grace period of %d seconds has elapsed since last sensor update.",
					gracePeriod
				)
			)
		end
	end

	print(string.format("Sleeping for %s seconds.", sleepInSeconds))
	fibaro:sleep(sleepInMs)
end
