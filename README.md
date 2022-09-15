# LocalDataStore
Module for Roblox Revivals Map Restorers who needs a replacement for Roblox DataStore

# Usage

Create a new ModuleScript in **ReplicatedStorage** then rename it to **LocalDataStore**
Then copy and paste the code from LocalDataStore.lua into the new ModuleScript after that

Replace
```
game:GetService("DataStoreService")
```
With
```
require(game:GetService("ReplicatedStorage"):WaitForChild("LocalDataStore"))
```

Congrats you just installed LocalDataStore!!!
