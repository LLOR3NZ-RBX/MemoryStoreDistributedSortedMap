--[[
	Stores shared types.
]]

-- A MemoryStoreDistributedSortedMap Object
export type MemoryStoreDistributedSortedMap = {
	name: string,
	numPartitions: number,
	
	GetAsync: Function,
	GetRangeAsync: Function,
	GetSizeAsync: Function,
	RemoveAsync: Function,
	SetAsync: Function,
	UpdateAsync: Function
}

-- A SortedMapItem
export type SortedMapItem = {
	key: string,
	value: any,
	sortKey: any
}

-- A SortedMapBound for range queries.
export type SortedMapBound = {
	key: string,
	sortKey: any
}

-- Generic Function
export type Function = (...any) -> ...any

-- Export types
return {}