# MemoryStoreDistributedSortedMap

An implementation of a Distributed Memory Store Sorted Map. I made this as a
scalable alternative to the default [Memory Store Sorted Map](https://create.roblox.com/docs/cloud-services/memory-stores/sorted-map), allowing creators
to define the number of "partitions". Each partition, under the hood, is
actually its own sorted map, but the module orchestrates it so they
act as a single map.

## Interface

To get a Distributed Sorted Map
1. Import the module with 
```lua
    local MemoryStoreDistributedSortedMap = require(game.ServerScriptService.MemoryStoreDistributedSortedMap)
```
2. Create a map with `MemoryStoreDistributedSortedMap.new(name, numPartitions)`
Parameter | Description
:--- | :---
`name`: _string_ | The name of the sorted map.
`numPartitions`: _number_ | The number of the partitions to create in the sorted
map.

**Example:**
```lua
    local map = MemoryStoreDistributedSortedMap.new("myMap", 100)
```

After getting a Distributed Sorted Map, the method interface is the same as a
regular Memory Store Sorted Map - see [API](https://create.roblox.com/docs/reference/engine/classes/MemoryStoreSortedMap#Summary).

## Limits
- #Items: ~ 100000 * (# partitions)
- Size: ~ 100 kb * (# partitions)

## Request Units
Function | Request Unit(s)
:--- | :---
`GetAsync()` | 1
`GetRangeAsync()` | # items * #partitions
`GetSizeAsync()` | #partitions
`RemoveAsync()` | 1
`SetAsync()` | 2
`UpdateAsync()` | >2