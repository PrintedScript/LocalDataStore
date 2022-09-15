# LocalDataStore
Module for Roblox Revivals Map Restorers who needs a replacement for Roblox DataStore

# Usage
Replace
```
game:GetService("DataStoreService")
```
With
```
require(game:GetService("ReplicatedStorage"):WaitForChild("LocalDataStore"))
```
