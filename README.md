# MemoryStoreDistributedSortedMap

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
MemoryStoreDistributedSortedMap.new(name, numPartitions)
```

Parameter | Description
:--- | :---
`name`: _string_ | The name of the sorted map.
`numPartitions`: _number_ | The number of the partitions to create in the sorted map.

After getting a Distributed Sorted Map, the method interface is the same as a
regular Memory Store Sorted Map - see
[API](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap#Summary).


**Example:**
```lua
local MemoryStoreDistributedSortedMap = require(game.ServerScriptService.MemoryStoreDistributedSortedMap)

local map = MemoryStoreDistributedSortedMap.new("myMap", 100)
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
`GetRangeAsync()` | `numPartitions` * `count`
`GetSizeAsync()` | `numPartitions`
`RemoveAsync()` | 1
`SetAsync()` | 2
`UpdateAsync()` | >2 