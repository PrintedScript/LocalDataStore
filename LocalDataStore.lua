--[[
	Local Datastore ( V1.0.1 )
		
		Module for replacing Datastore to a local datastore meant to be a replacement for old roblox revivals where
		datastore does not work.
	
	Written By SomethingElse#0024 ( 15 / 9 / 2022 )
	
]]

local LocalDB = {}
LocalDB.DebugMode = false

if _G.LocalDataStore == nil then
	_G.LocalDataStore = {}
end

local function GetLengthofDictionary( Dictionary )
	local Length = 0
	for _,v in pairs(Dictionary) do
		Length += 1
	end
	return Length
end

local function ConsoleLog(LogType, LogContent)
	if LocalDB.DebugMode then
		print("LocalDataStore - "..LogType.." - "..LogContent)
	end
end

function LocalDB:SetDebugMode( Enabled )
	if type( Enabled ) == "boolean" then
		LocalDB.DebugMode = Enabled
	else
		error("LocalDB SetDebugMode - Argument needs to be a boolean")
	end
end

function LocalDB:GetDataStore( DatastoreName )
	local Datastore = {}
	Datastore.Name = DatastoreName

	if _G.LocalDataStore[DatastoreName] == nil then
		_G.LocalDataStore[DatastoreName] = {}
	end

	function Datastore:GetAsync( DataKey )
		--[[
			Gets data from requested Datastore, returns nil if there is no data
		]]
		ConsoleLog(DatastoreName.."/Datastore/GetAsync","GET Request for "..DatastoreName.." [ "..DataKey.." ]")
		return _G.LocalDataStore[tostring(DatastoreName)][DataKey]
	end

	function Datastore:SetAsync( DataKey, Data)
		--[[
			Sets data to targeted Datastore, does not return anything
		]]
		ConsoleLog(DatastoreName.."/Datastore/SetAsync","SET Request for "..DatastoreName.." [ "..DataKey.." ] / Content / "..tostring(Data))
		_G.LocalDataStore[tostring(DatastoreName)][DataKey] = Data
	end

	function Datastore:UpdateAsync( DataKey, transformFunction )
		--[[
			If transformFunction returns nil then it would not be saved
		]]
		local PreviousData = Datastore:GetAsync( DataKey )
		local NewData = transformFunction(PreviousData)

		if NewData ~= nil then
			ConsoleLog(DatastoreName.."/Datastore/UpdateAsync","UPDATE Request passed for "..DatastoreName.." [ "..DataKey.." ] / Content / "..tostring(NewData))
			_G.LocalDataStore[tostring(DatastoreName)][DataKey] = NewData
		else
			ConsoleLog(DatastoreName.."/Datastore/UpdateAsync","UPDATE Request failed for "..DatastoreName.." [ "..DataKey.." ] / transformFunction returned nil")
		end
	end
	
	ConsoleLog("Datastore","Returned datastore for "..DatastoreName)
	
	return Datastore
end

function LocalDB:GetOrderedDataStore( DatastoreName )
	--[[
		OrderedDataStore inherits functions from GlobalDataStore
		https://developer.roblox.com/en-us/api-reference/class/OrderedDataStore
	]]
	local OrderedDatastore = LocalDB:GetDataStore( DatastoreName )

	function OrderedDatastore:GetSortedAsync( ascending, pagesize, minValue, maxValue)
		local DataStorePages = {}
		local PageCount = 1
		DataStorePages.IsFinished = false

		local function GetDataStoreTable()
			local CurrenDataStore = _G.LocalDataStore[tostring(DatastoreName)]
			local NewData = {}

			for datakey , value in pairs(CurrenDataStore) do
				if type(value) == "number" then

					if minValue and value < minValue then continue end
					if maxValue and value > maxValue then continue end

					table.insert(NewData, {
						key = datakey,
						value = value
					})
				end
			end

			if ascending then
				table.sort(NewData, function( a, b)
					return b["value"] > a["value"]
				end)
			else
				table.sort(NewData, function( a, b)
					return a["value"] > b["value"]
				end)
			end

			return NewData
		end

		function DataStorePages:AdvanceToNextPageAsync()
			if not DataStorePages.IsFinished then
				local OrderedData = GetDataStoreTable()
				local DataLength = GetLengthofDictionary(OrderedData)

				local CurrentKeyIndex = pagesize * PageCount
				if DataLength > CurrentKeyIndex then
					PageCount += 1
					ConsoleLog(tostring(DatastoreName).."/OrderedDatastore/GetSortedAsync/DatastorePages/AdvanceToNextPageAsync","Successfully advanced to page "..tostring(PageCount))
				else
					DataStorePages.IsFinished = true
					ConsoleLog(tostring(DatastoreName).."/OrderedDatastore/GetSortedAsync/DatastorePages/AdvanceToNextPageAsync","Reached last page / "..tostring(PageCount))
				end
			else
				ConsoleLog(tostring(DatastoreName).."/OrderedDatastore/GetSortedAsync/DatastorePages/AdvanceToNextPageAsync","Already reached last page but still being requested to advance")
			end
		end

		function DataStorePages:GetCurrentPage()
			local OrderedData = GetDataStoreTable()
			local StartingIndex = ( pagesize * (PageCount - 1) ) + 1

			local PageData = {}
			for index = 1 , pagesize do
				table.insert(PageData,OrderedData[StartingIndex + (index - 1)])
			end
			
			ConsoleLog(tostring(DatastoreName).."/OrderedDatastore/GetSortedAsync/DataStorePages/GetCurrentPage","Requested page "..tostring(PageCount).." / starting index "..tostring(StartingIndex).." / total records returned "..tostring(#PageData))
			return PageData
		end

		return DataStorePages
	end
	
	ConsoleLog("OrderedDatastore","Returned OrderedDataStore "..DatastoreName)
	return OrderedDatastore
end

function LocalDB:GetGlobalDataStore()
	ConsoleLog("GetGlobalDataStore","Returned global datastore")
	return LocalDB:GetDataStore("super_awesome_datastore_no_one_would_never_come_up_with_a_datastore_like_this_right?")
end

return LocalDB
