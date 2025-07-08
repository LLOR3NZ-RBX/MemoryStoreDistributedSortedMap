--!strict

--[[
	Memory Store Distributed Sorted Map
	
	A sorted map that is distributed across multiple sorted map partitions.
	Plug this module directly in place of a normal sorted map and enjoy the auto sharding!
	
	Acknowledgements:
	- binaryheap.lua: https://tieske.github.io/binaryheap.lua/
]]

-- Imports
local Partitions = require(script.Partitions)
local Sorting = require(script.Sorting)
local Types = require(script.Types)

-- Constants
local DEFAULT_NUM_PARTITIONS = 16
local DEFAULT_APPROXIMATE_NUM_PARTITIONS = 1

-- Distributed Sorted Map Class
local MemoryStoreDistributedSortedMap = {}

--[[
	Create a new MemoryStoreDistributedSortedMap object.
	@param name (string): The name of the Sorted Map.
	@param numPartitions (optional number): The number of partitions to use, truncated to the nearest integer 
		if a decimal is provided. Default is 16.
	@return MemoryStoreDistributedSortedMap
]]
function MemoryStoreDistributedSortedMap.new(name: string, numPartitions: number?): Types.MemoryStoreDistributedSortedMap
	numPartitions = numPartitions or DEFAULT_NUM_PARTITIONS
	local map = {
		name = name,
		numPartitions = math.floor(numPartitions)
	}
	setmetatable(map, { __index = MemoryStoreDistributedSortedMap })
	
	math.randomseed(os.time())
	
	return map :: Types.MemoryStoreDistributedSortedMap
end

--[[
	Retrieves the value and sort key of a key in the distributed sorted map.
	@param key (string): The key to retrieve the value and sort key of.
	@return value (any): The value stored at the key.
	@return sortKey (any): The sort key used to sort the key at the value.
]]
function MemoryStoreDistributedSortedMap:GetAsync(key: string): (any, any)
	local mapPartition = Partitions.getDistributedMapPartition(self, key)
	return mapPartition:GetAsync(key)
end

--[[
	Gets items within a sorted range of keys and sort keys.
	@param direction (Enum.SortDirection): The direction to sort by.
	@param count (number): The number of items to retrieve.
	@param exclusiveLowerBound (string): The exclusive lower bound.
	@param exclusiveUpperBound (string): The exclusive upper bound.
	@return items (array): Item keys, values and sort keys in the requested range.
]]
function MemoryStoreDistributedSortedMap:GetRangeAsync(
	direction: Enum.SortDirection, 
	count: number, 
	exclusiveLowerBound: Types.SortedMapBound, 
	exclusiveUpperBound: Types.SortedMapBound
): { Types.SortedMapItem }
	local partitionLists = {}
	for i = 1, self.numPartitions do
		local mapPartition = Partitions.getDistributedMapPartitionByIndex(self, i)
		table.insert(partitionLists, mapPartition:GetRangeAsync(direction, count, exclusiveLowerBound, exclusiveUpperBound))
	end
	
	return Sorting.getFirstNSorted(partitionLists, direction, count)
end

--[[
	Gets the size of the distributed sorted map.
	@param approximated (optional boolean): If set to true, the count will be approximated. Default is false.
	@param numPartitionsToApproximate (optional number): The number of partitions to use when approximating, trunacated to the nearest integer
		if a decimal is provided. Default is 1.
	@return size (number): The size of the sorted map.
]]
function MemoryStoreDistributedSortedMap:GetSizeAsync(approximated: boolean?, numPartitionsToApproximate: number?): number
	local totalSize = 0
	
	if not approximated then
		-- get real count
		for i = 1, self.numPartitions do
			local mapPartition = Partitions.getDistributedMapPartitionByIndex(self, i)
			totalSize += mapPartition:GetSizeAsync()
		end
	else 
		if numPartitionsToApproximate and numPartitionsToApproximate > self.numPartitions then
			error("`numPartitionsToApproximate` cannot be greater than the number of partitions in the distributed sorted map.")
		end
		
		-- get approximate count
		local partitionsUsed = {}
		for i = 1, self.numPartitions do
			table.insert(partitionsUsed, false)
		end
		
		-- sample partitions for size
		local partitionsScanned = 0
		numPartitionsToApproximate = numPartitionsToApproximate or DEFAULT_APPROXIMATE_NUM_PARTITIONS
		numPartitionsToApproximate = math.floor(numPartitionsToApproximate)
		while partitionsScanned < numPartitionsToApproximate do
			local randPartition = math.random(1, self.numPartitions)
			
			-- ensure we are getting a unique partition
			if not partitionsUsed[randPartition] then
				partitionsUsed[randPartition] = true
				
				-- add the size
				local mapPartition = Partitions.getDistributedMapPartitionByIndex(self,randPartition)
				totalSize += mapPartition:GetSizeAsync()
				partitionsScanned += 1
			end
		end
		
		-- correct for proportion
		totalSize *= self.numPartitions / numPartitionsToApproximate
	end
	return math.round(totalSize)
end

--[[
	Removes the provided key from the distributed sorted map.
	@param key (string): The key to remove from the sorted map.
]]
function MemoryStoreDistributedSortedMap:RemoveAsync(key: string): ()
	local mapPartition = Partitions.getDistributedMapPartition(self, key)
	mapPartition:RemoveAsync(key)	
end

--[[
	Sets the value and sort key of the key overwriting any existing key value and sort key.
	@param key (string): The key to set the value and sort key for.
	@param value (any): The value to set.
	@param expiration (number): The item expiration, in seconds.
	@param sortKey (any): The sort key to sort by.
	@return boolean
]]
function MemoryStoreDistributedSortedMap:SetAsync(key: string, value: any, expiration: number, sortKey: any): boolean
	local mapPartition = Partitions.getDistributedMapPartition(self, key)
	return mapPartition:SetAsync(key, value, expiration, sortKey)
end

--[[
	Retrieves the value and sort key of a key from a distributed sorted map,
	and lets you update it to a new value and sort key via a callback function.
	@param key (string): The key to update.
	@param transformFunction (function): A function that takes the old value and sort key and returns a new value and sort key.
	@param expiration (number): The item expiration, in seconds.
	@return value (any): The value stored at the key.
	@return sortKey (any): The sort key used to sort the key at the value.
]]
function MemoryStoreDistributedSortedMap:UpdateAsync(key: string, transformFunction: Types.Function, expiration: number): (any, any)
	local mapPartition = Partitions.getDistributedMapPartition(self, key)
	return mapPartition:UpdateAsync(key, transformFunction, expiration)
end

-- Return MemoryStoreDistributedSortedMap Class
return setmetatable({}, {
	__call = function(_, ...)
		return MemoryStoreDistributedSortedMap.new(...)
	end
})
