# Roblox Cloud-Based Module Loader

A flexible and efficient module loader for Roblox, designed to fetch and load Lua modules from a public GitHub repository with support for caching, retries, debugging, and asynchronous loading.

## Features
- **Load Modules from GitHub**: Fetch and load Lua modules directly from a public GitHub repository.
- **Caching**: Automatically caches modules to improve load times. Supports both in-memory and persistent DataStore caching.
- **Retry Logic**: Includes retry logic to handle network or server failures when fetching modules.
- **Debugging**: Optionally logs detailed debug information about module loading and performance.
- **Asynchronous Loading**: Modules can be loaded asynchronously to prevent blocking the main thread.
- **Preloading**: Preload multiple modules to ensure they're ready when needed.

## Requirements
- **Roblox Studio**: This module works within Roblox Studio.
- **GitHub Repository**: Modules are fetched from a public GitHub repository.
- **Enable `loadstring`**, **`HttpService`**, and **`DataStore`** for full functionality.

## Setup Instructions

### 1. **Prepare the ModuleLoader**
   - Place the `ModuleLoader` ModuleScript in `ReplicatedStorage` within your Roblox game.
   - Set the `BaseURL` in `ModuleLoader` to point to your GitHub repository where modules are stored.

### 2. **Test Example Script**
   To demonstrate how the module loader works, download and use the provided **test example script** from the repository. This script will show you how to load your own public module script into your game.

   - **Example Script**: You can download the test script from the repository in the `ExampleLoader.lua` file.
   - This script fetches a module from your public GitHub repository and measures the time it takes to load, ensuring everything is working as expected.

### 3. **Enable Debugging** (optional)
   To enable debugging and get detailed logs during module loading, set `ModuleLoader.Debug = true` in the `ModuleLoader` script.

### 4. **Caching**
   - **In-memory Cache**: Modules are stored in memory to speed up subsequent loads.
   - **Persistent Cache**: If enabled, modules are also saved to Roblox's `DataStore` for persistence.
   
   You can clear the cache for a module if necessary.

### 5. **Asynchronous Loading**
   For non-blocking loading, you can use the asynchronous function to load modules while allowing other game processes to continue.

### 6. **Preloading Modules**
   If you want to preload multiple modules at once to ensure they're ready when needed, use the preload functionality.

## How It Works

1. **Fetching**: The loader fetches the Lua module code from your specified GitHub repository.
2. **Compilation**: The fetched Lua code is compiled using `loadstring`.
3. **Caching**: The module is cached in memory and optionally stored in Roblox's `DataStore` for persistent caching across sessions.
4. **Execution**: The compiled module is executed and returned for use in your game.

## Troubleshooting
- **Missing `HttpService` or `DataStore`**: Ensure both services are enabled in your game settings to allow module fetching and caching.
- **Invalid GitHub URL**: Ensure that the GitHub repository is public and the URL is correctly formatted.
- **Module Compilation Failure**: If a module fails to compile, check that the module Lua code is valid and properly formatted.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
