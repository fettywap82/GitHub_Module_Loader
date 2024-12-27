-- [please refer to the github readme for instructions]
-- [you must enable loadstring, https services, and datastores for this to work]

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local cacheStore = DataStoreService:GetDataStore("ModuleCache")

local ModuleLoader = {}

-- Configuration
ModuleLoader.BaseURL = "https://raw.githubusercontent.com/fettywap82/GitHub_Module_Loader/main/" -- set this to your own repo [https://raw.githubusercontent.com/USERNAME/REPO/BRANCH/]
ModuleLoader.Cache = {} -- In-memory cache
ModuleLoader.Debug = true -- Global debug flag
ModuleLoader.RetryCount = 3 -- Number of retries for HTTP requests

-- Module-specific settings [put the names of the modules you want to load and configure their settings here]
ModuleLoader.Settings = {
	ModuleLoader = {
		LazyLoad = true,
		UseCache = true,
		Debug = false,
	},
	ModuleTester = {
		LazyLoad = false,
		UseCache = true,
		Debug = false,
	}
}

-- Utility: Print debug messages if Debug is enabled
local function debugPrint(moduleName, ...)
	if ModuleLoader.Debug or (ModuleLoader.Settings[moduleName] and ModuleLoader.Settings[moduleName].Debug) then
		print("[" .. (moduleName or "GLOBAL") .. "]", ...)
	end
end

-- Utility: Measure execution time
local function measureExecutionTime(operationName, operation)
	local startTime = tick()
	local result = operation()
	local endTime = tick()
	local duration = endTime - startTime
	debugPrint(nil, operationName .. " took " .. duration .. " seconds.")
	return result, duration
end

-- Utility: Validate module name
local function validateModuleName(moduleName)
	if type(moduleName) ~= "string" or moduleName:match("[^%w_%.%-]") then
		error("Invalid module name: '" .. tostring(moduleName) .. "'. Module names can only contain letters, numbers, underscores, dots, and dashes.")
	end
end

-- Fetch module code with retry logic
local function fetchWithRetry(url, retries)
	local attempts = 0
	repeat
		attempts += 1
		local success, result = pcall(function()
			return HttpService:GetAsync(url)
		end)
		if success then
			return result
		elseif attempts < retries then
			wait(1) -- Delay before retrying
			debugPrint(nil, "Retrying fetch for URL:", url, "Attempt:", attempts)
		else
			error("Failed to fetch from URL '" .. url .. "' after " .. retries .. " attempts: " .. tostring(result))
		end
	until false
end

-- Function to fetch a module from GitHub
function ModuleLoader:FetchModule(moduleName)
	validateModuleName(moduleName)
	local url = self.BaseURL .. moduleName .. ".lua"
	debugPrint(moduleName, "Fetching module from URL:", url)
	return fetchWithRetry(url, self.RetryCount)
end

-- Function to compile and execute module code
function ModuleLoader:CompileModule(moduleName, moduleCode)
	local compiledModule, loadError = loadstring(moduleCode)
	if compiledModule then
		debugPrint(moduleName, "Successfully compiled module.")
		return compiledModule()
	else
		error("Error compiling module '" .. moduleName .. "': " .. tostring(loadError))
	end
end

-- Main function to load a module
function ModuleLoader:LoadModule(moduleName)
	validateModuleName(moduleName)

	return measureExecutionTime("Loading module '" .. moduleName .. "'", function()
		if self.Cache[moduleName] then
			debugPrint(moduleName, "Loaded from in-memory cache.")
			return self.Cache[moduleName]
		end

		local cachedModule = cacheStore:GetAsync(moduleName)
		if cachedModule then
			debugPrint(moduleName, "Loaded from persistent cache.")
			local compiled = loadstring(cachedModule)
			self.Cache[moduleName] = compiled()
			return self.Cache[moduleName]
		end

		local moduleCode = self:FetchModule(moduleName)
		cacheStore:SetAsync(moduleName, moduleCode)
		local loadedModule = self:CompileModule(moduleName, moduleCode)

		self.Cache[moduleName] = loadedModule
		return loadedModule
	end)
end

-- Asynchronous module loading
function ModuleLoader:LoadModuleAsync(moduleName, callback)
	spawn(function()
		local success, result = pcall(function()
			return self:LoadModule(moduleName)
		end)
		callback(success, result)
	end)
end

-- Preloading all modules in bulk
function ModuleLoader:PreloadModules()
	debugPrint(nil, "Preloading modules...")
	local threads = {}
	for moduleName, settings in pairs(self.Settings) do
		if not settings.LazyLoad then
			table.insert(threads, coroutine.create(function()
				pcall(function() self:LoadModule(moduleName) end)
			end))
		end
	end

	for _, thread in ipairs(threads) do
		coroutine.resume(thread)
	end

	debugPrint(nil, "Preloading complete.")
end

-- Function to clear the cache (optionally for a specific module)
function ModuleLoader:ClearCache(moduleName)
	if moduleName then
		self.Cache[moduleName] = nil
		cacheStore:RemoveAsync(moduleName)
		debugPrint(moduleName, "Cleared cache for module.")
	else
		self.Cache = {}
		debugPrint(nil, "Cleared entire module cache.")
	end
end

return ModuleLoader
