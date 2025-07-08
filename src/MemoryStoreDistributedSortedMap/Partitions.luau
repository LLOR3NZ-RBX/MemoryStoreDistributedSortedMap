--!strict

--[[
	Helper module for managing Sorted Map partitions.
]]

-- Imports
local Types = require(script.Parent.Types)

-- Services
local MemoryStoreService = game:GetService("MemoryStoreService")

--[[
	A helper function that hashes a string using the djb2 algorithm.
	@param str (string): The string to hash.
	@return (number): The hash of the string.
]]
local function djb2(str: string)
	local hash = 5381
	for i = 1, #str do
		local c = str:byte(i)
		local c = string.byte(str, i)
		hash = ((hash * 33) + c) % 4294967296
	end
	return hash
end

-- Partitions module
local Partitions = {}

--[[
	Gets the partition responsible for a given key.
	@param distributedMap (MemoryStoreDistributedSortedMap): The map to partition.
	@param key (string): The key to partition.
	@return (MemoryStoreSortedMap): The partition sorted map.
]]
function Partitions.getDistributedMapPartition(distributedMap: Types.MemoryStoreDistributedSortedMap, key: string): MemoryStoreSortedMap
	local hashedMapName = djb2(distributedMap.name)
	local hashedKeyName = djb2(key)
	local mapPartitionIndex = hashedKeyName % distributedMap.numPartitions + 1
	local mapPartitionName = distributedMap.name .. '-' .. hashedMapName .. '-' .. mapPartitionIndex .. '/' .. distributedMap.numPartitions
	return MemoryStoreService:GetSortedMap(mapPartitionName)
end

--[[
	Gets the partition with the given index.
	@param distributedMap (MemoryStoreDistributedSortedMap): The map to partition.
	@param index (number): The index of the partition.
	@return (MemoryStoreSortedMap): The partition sorted map.
]]
function Partitions.getDistributedMapPartitionByIndex(distributedMap: Types.MemoryStoreDistributedSortedMap, index: number): MemoryStoreSortedMap
	local hashedMapName = djb2(distributedMap.name)
	local mapPartitionName = distributedMap.name .. '-' .. hashedMapName .. '-' .. index .. '/' .. distributedMap.numPartitions
	return MemoryStoreService:GetSortedMap(mapPartitionName)
end

-- Export module
return Partitions
