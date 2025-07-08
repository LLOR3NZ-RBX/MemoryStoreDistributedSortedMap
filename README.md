# MemoryStoreDistributedSortedMap

Creator Store: [[Link](https://create.roblox.com/store/asset/105007100072970/MemoryStoreDistributedSortedMap)]

An implementation of a Distributed Memory Store Sorted Map. I made this as a
scalable alternative to the default [Memory Store Sorted Map](https://create.roblox.com/docs/cloud-services/memory-stores/sorted-map), allowing creators
to define the number of "partitions". Each partition, under the hood, is
actually its own sorted map, but the module orchestrates it so they
act as a single map.

## Interface

To use a Distributed Sorted Map:
1. Import the module with 
```lua
local MemoryStoreDistributedSortedMap = require(<path to script>.MemoryStoreDistributedSortedMap)
```
2. Create a map with 

```lua
MemoryStoreDistributedSortedMap(name: string, numPartitions: number?)
```

Parameter | Description
:--- | :---
`name`: _string_ | The name of the sorted map.
`numPartitions`: _number?_ | The number of the partitions to create in the sorted map. If not provided, defaults to 16.

After getting a Distributed Sorted Map, the method interface is the same as a
regular Memory Store Sorted Map - see
[API](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap#Summary)
- with one exception.

```lua
MemoryStoreDistributedSortedMap:GetSizeAsync(approximate: boolean?, numPartitionsToApproximate: number?)
```

Parameter | Description
:--- | :---
`approximate`: _string?_ | If the size should be approximated. If false or not provided, it will not approximate, and will scan all partitions.
`numPartitionsToApproximate`: _number?_ | The number of the partitions to sample, if `approximate` is true. If not provided, defaults to 1.

**Example:**
```lua
local MemoryStoreDistributedSortedMap = require(game.ServerScriptService.MemoryStoreDistributedSortedMap)

local map = MemoryStoreDistributedSortedMap("myMap", 100)
map:SetAsync("exp", 5, 300)
print(map:GetAsync("exp"))
```

## Limits
Limit Type | Limit
:--- | :---
`# Items` | ~ `numPartitions` * 100000
`Size` | ~ `numPartitions` * 100 kb

## Request Units
Function | Request Unit(s)
:--- | :---
`GetAsync()` | 1
`GetRangeAsync()` | <`numPartitions` * `count`
`GetSizeAsync()` | `numPartitionsToApproximate` or `numPartitions`
`RemoveAsync()` | 1
`SetAsync()` | 2
`UpdateAsync()` | >2 

## Acknowledgements
- https://github.com/Tieske/binaryheap.lua
