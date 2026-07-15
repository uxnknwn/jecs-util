# jecs_util

Small utilities for Jecs 0.11.0 and Roblox ECS projects.

## Requirements

- Roblox
- Luau
- Jecs `0.11.0`

This package targets Jecs `0.11.0` only.

## Installation

### Wally

```toml
[dependencies]
jecs_util = "uxnknwn/jecs-util@0.1.0"
Jecs = "ukendio/jecs@0.11.0"
```

Then run:

```bash
wally install
```

### Pesde

```bash
pesde add uxnknwn/jecs_util
```

The package depends on Jecs `0.11.0`.

## Import

Use your project’s actual dependency paths:

```luau
local jecs = require(path.to.jecs)
local jecs_util = require(path.to.jecs_util)
```

The exact Instance names can vary with dependency aliases.

## Registry

`registry` maps a category and key to a Jecs entity.

```luau
local world = jecs.World.new()
local registry = jecs_util.registry.new(world)

local entity = world:entity()
registry:Define("Players", 12345, entity)
```

Basic operations:

```luau
local entity = registry:Get("Players", 12345)
local exists = registry:Has("Players", 12345)
local removed = registry:Undefine("Players", 12345)

registry:Delete("Players", 12345)
registry:Clear("NPCs")
registry:Clear()
```

## Collect

`collect` turns a Roblox signal into a FIFO queue.

```luau
local event = Instance.new("BindableEvent")
local pop, connection = jecs_util.collect(event.Event)

event:Fire("RoundStarted", 10)
event:Fire("RoundEnded", 20)

local function processEvents()
	while true do
		local eventName, duration = pop()

		if eventName == nil then
			break
		end

		print("event:", eventName, duration)
	end
end

processEvents()

connection:Disconnect()
event:Destroy()
```

Trailing `nil` values are preserved:

```luau
event:Fire("A", nil, "C", nil)

local result = table.pack(pop())
print(result.n) -- 4
```

## API

### `registry.new(world)`

Creates an independent registry using a Jecs-compatible world.

### `registry:Define(category, key, entity)`

Stores an entity under a category and key.

### `registry:Get(category, key)`

Returns the mapped entity or `nil`.

### `registry:Has(category, key)`

Returns whether a mapping exists.

### `registry:Undefine(category, key)`

Removes and returns a mapping without deleting the entity.

### `registry:Delete(category, key)`

Removes the mapping and deletes the entity from the world.

### `registry:Clear(category?)`

Deletes one category or every registered entity.

### `collect(signal)`

Returns a FIFO `pop` function and the signal connection.

## License

MIT
