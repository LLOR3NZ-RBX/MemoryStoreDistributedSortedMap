--[[
	Helper module for handling sorting needs.
]]

-- Imports
local BinaryHeap = require(script.BinaryHeap)

--[[
	Less than function.
	@param a (SortedMapItem)
	@param b (SortedMapItem)
	@return (boolean): true if a < b, false otherwise
]]
local function lt(a, b)
	if a.sortKey and not b.sortKey then
		-- a has a sortKey, b does not, a is smaller
		return true
	elseif not a.sortKey and b.sortKey then
		-- a does not have a sortKey, b does, b is smaller
		return false
	elseif a.sortKey and b.sortKey and a.sortKey ~= b.sortKey then
		-- both a and b have a sortKey, compare the sortKeys
		if typeof(a.sortKey) == typeof(b.sortKey) then
			-- both a and b have same sortKey types, compare sortKeys
			return a.sortKey < b.sortKey
		elseif typeof(a.sortKey) == "string" then
			-- a has a string sortKey, b has a number, b is smaller
			return false
		else
			-- a has a number sortKey, b has a string, a is smaller
			return true
		end 
	end
	
	-- compare keys
	return a.key < b.key
end

--[[
	Greater than function.
	@param a (SortedMapItem)
	@param b (SortedMapItem)
	@return (boolean): true if a > b, false otherwise
]]
local function gt(a: Types.SortedMapItem, b: Types.SortedMapItem)
	return not lt(a, b)
end

-- Sorting Module
local Sorting = {}

--[[
	Given a list of partitions' items, return the first n items in sorted order.
	@param partitions ({ { Types.SortedMapItem } }): list of partitions' items
	@param direction (Enum.SortDirection): the sort direction
	@param count (number): the number of items to return
	@return ({ Types.SortedMapItem }): the first n items in sorted order
]]
function Sorting.getFirstNSorted(
	partitions: {{ Types.SortedMapItem }}, 
	direction: Enum.SortDirection, 
	count: number
): { Types.SortedMapItem }	
	
	-- create the min/max heap
	local heap = 
		direction == Enum.SortDirection.Ascending 
		and BinaryHeap.minHeap(lt) 
		or BinaryHeap.maxHeap(gt)

	-- initialize sorting state
	local indexes: { number } = {} -- store the index of each partition
	local backtrack: { [Types.SortedMapItem]: number } = {} -- store mappings from items back to their partition
	
	-- add first item of each partition to the heap
	for i = 1, #partitions do
		-- no items in this partition
		if not partitions[i][1] then
			continue
		end

		-- add the first item to the heap and track from index 2
		heap:insert(partitions[i][1]) 
		indexes[i] = 2

		-- keep track of which partition each item comes from
		backtrack[partitions[i][1]] = i
	
	end

	-- keep on getting items until we have enough or are out
	local firstNSorted: { Types.SortedMapItem } = {}
	local itemsRemaining = count or 1
	while itemsRemaining > 0 and heap:size() > 0 do
		
		-- add the first element to the list
		local firstItem: Types.SortedMapItem = heap:pop()
		table.insert(firstNSorted, firstItem)
		itemsRemaining = itemsRemaining - 1
		
		-- add the next element from the same partition to the heap, if there is one
		local partition: number = backtrack[firstItem]
		if indexes[partition] <= #partitions[partition] then
			-- add the item to the heap
			local nextItem: Types.SortedMapItem = partitions[partition][indexes[partition]]
			heap:insert(nextItem)
			
			-- keep track of its partition
			backtrack[nextItem] = partition
			
			-- increment the partition's index
			indexes[partition] += 1
		end
	end

	return firstNSorted
end

-- Export module
return Sorting
