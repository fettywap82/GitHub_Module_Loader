-- [please refer to the GitHub readme for instructions]

-- Gets the ModuleLoader from wherever you put it
local ModuleLoader = require(game.ReplicatedStorage.ModuleLoader)

-- Make sure Debugging is enabled
ModuleLoader.Debug = true

-- Measure the time it takes to load the module
local startTime = tick()
local success, result = pcall(function()
	return ModuleLoader:LoadModule("ModuleTester") -- Name of the module you would like to load (no file extension)
end)
local loadDuration = tick() - startTime

-- Log the loading time if debugging is enabled
if ModuleLoader.Debug then
	print("[GLOBAL] The module loaded in", loadDuration, "seconds.")
end

if success then
	print("[GLOBAL] Module loaded successfully.")
	-- Call a function from the loaded module
	result.testFunction()
else
	warn("[GLOBAL] Failed to load module:", result)
end