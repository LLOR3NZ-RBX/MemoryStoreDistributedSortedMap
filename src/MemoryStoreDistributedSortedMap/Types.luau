--[[
	Stores shared types.
]]

-- A MemoryStoreDistributedSortedMap Object
export type MemoryStoreDistributedSortedMap = {
	name: string,
	numPartitions: number,
	
	GetAsync: (key: string) -> SortedMapItem,
	GetRangeAsync: (
		direction: Enum.SortDirection,
		count: number, 
		exclusiveLowerBound: SortedMapBound, 
		exclusiveUpperBound: SortedMapBound) 
	-> { SortedMapItem },
	GetSizeAsync: (approximate: boolean?, numPartitionsToApproximate: number?) -> number,
	RemoveAsync: (key: string) -> (),
	SetAsync: (key: string, value: any, expiration: number, sortKey: any) -> boolean,
	UpdateAsync: (key: string, transformFunction: Function, expiration: number) -> (string, string)
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