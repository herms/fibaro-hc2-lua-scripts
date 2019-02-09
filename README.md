# fibaro-hc2-lua-scripts
This repo contains some scripts that I have created for use at home. They were written to solve some specific problems at home, and later made  easier for others to use by extracting varibles and moving them to the top of the files.

## DeviceConsumptionReport and CheckMissingPowerMeterReport
These scripts were originally made to monitor the consumption of my heat pump. I had (or still have) a problem when in some cases it decided to pull 11.5 kW of power and blow the fuse. I have a _Qubino Smart Meter_ device set up behind the fuse for the heat pump, so I can monitor the consumption and detect when the fuse is blown.

The **DeviceConsumptionReport** script will set the energy consumption of the _Qubino Smart Meter_ in a global variable when the load exceeds the `upperInactiveThreshold`. When the load goes below the `lowerActiveThreshold` it will calculate the consumption and active time by comparing the current timestamp and energy value with the stored energy value and modification timestamp of the global variable. This script could easily be used for fridges, charging EVs, and other things that you might be curious to find out how much it consumes of energy. 

The **CheckMissingPowerMeterReport** is currently set up to be triggered by another scheduled scene, but could also be modified to loop every X seconds in a `while true do` block. The script will when triggered check the current load on a power meter, and check whether it is above a certain threshold, and also if the reported value is older than a configurable amount of seconds. If the latest value is above the threshold and older than expected (let's say the power meter should report at least every 10 seconds and the value is 30 seconds old), then it could mean the fuse is blown. The script will send a warning e-mail and set a flag in a global variable so that it will not send an e-mail again until the fuse is reset.

## TurnOnLights-MotionDetected and TurnOffLights-NoMotion
Todo.
