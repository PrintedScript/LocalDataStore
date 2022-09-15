--[[

	Local Datastore ( V1.0.0 )
		
		Module for replacing Datastore to a local datastore meant to be a replacement for old roblox revivals where
		datastore does not work.
	
	Written By SomethingElse#0024 ( 15 / 9 / 2022 )
	
]]

local LocalDB = {}

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
		return _G.LocalDataStore[tostring(DatastoreName)][DataKey]
	end

	function Datastore:SetAsync( DataKey, Data)
		--[[
			Sets data to targeted Datastore, does not return anything
		]]
		_G.LocalDataStore[tostring(DatastoreName)][DataKey] = Data
	end

	function Datastore:UpdateAsync( DataKey, transformFunction )
		--[[
			If transformFunction returns nil then it would not be saved
		]]
		local PreviousData = Datastore:GetAsync( DataKey )
		local NewData = transformFunction(PreviousData)

		if NewData ~= nil then
			_G.LocalDataStore[tostring(DatastoreName)][DataKey] = NewData
		end
	end

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
				else
					DataStorePages.IsFinished = true
				end
			end
		end

		function DataStorePages:GetCurrentPage()
			local OrderedData = GetDataStoreTable()
			local StartingIndex = ( pagesize * (PageCount - 1) ) + 1

			local PageData = {}
			for index = 1 , pagesize do
				table.insert(PageData,OrderedData[StartingIndex + (index - 1)])
			end

			return PageData
		end

		return DataStorePages
	end

	return OrderedDatastore
end

function LocalDB:GetGlobalDataStore()
	return LocalDB:GetDataStore("super_awesome_datastore_no_one_would_never_come_up_with_a_datastore_like_this_right?")
end

return LocalDB
