# jecs_util

Reusable utilities for Jecs 0.11 and Roblox ECS projects.

## Requirements

- Roblox
- Luau
- Jecs `0.11.0`

This package specifically targets Jecs `0.11.0`.

## Installation

### Wally

Add the package to `wally.toml`:

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

Install the package:

```bash
pesde add uxnknwn/jecs_util
```

The package depends on Jecs `0.11.0`.

## Usage

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local jecs = require(Packages.Jecs)
local JecsUtil = require(Packages.jecs_util)
```

The exact installed Instance names may depend on dependency aliases in the consuming project.

## registry

Create a Jecs 0.11 world and registry:

```luau
local world = jecs.World.new()
local registry = JecsUtil.registry.new(world)
```

Create and register an entity:

```luau
local entity = world:entity()

registry:Define("Players", 12345, entity)
```

Retrieve it:

```luau
local playerEntity = registry:Get("Players", 12345)

if playerEntity ~= nil then
	print("Found entity:", playerEntity)
end
```

Check whether it exists:

```luau
if registry:Has("Players", 12345) then
	print("Player entity exists")
end
```

Remove the mapping without deleting the Jecs entity:

```luau
local removedEntity = registry:Undefine("Players", 12345)
```

Remove the mapping and delete the Jecs entity:

```luau
registry:Delete("Players", 12345)
```

Delete every registered entity in one category:

```luau
registry:Clear("NPCs")
```

Delete every entity registered in the registry:

```luau
registry:Clear()
```

## collect

Queue values from a Roblox signal:

```luau
local event = Instance.new("BindableEvent")

local pop, connection = JecsUtil.collect(event.Event)

event:Fire("RoundStarted", 10)

local eventName, duration = pop()

print(eventName, duration)

connection:Disconnect()
event:Destroy()
```

Events are returned in order:

```luau
event:Fire("First")
event:Fire("Second")

print(pop())
print(pop())
```

Nil arguments are preserved:

```luau
event:Fire("A", nil, "C", nil)

local result = table.pack(pop())

print(result.n)
```

## API

### `registry.new(world)`

Creates an independent registry using a Jecs 0.11-compatible world.

### `registry:Define(category, key, entity)`

Stores an entity under a category and key.

### `registry:Get(category, key)`

Returns the mapped entity or `nil`.

### `registry:Has(category, key)`

Returns whether a mapping exists.

### `registry:Undefine(category, key)`

Removes and returns a mapping without deleting the entity.

### `registry:Delete(category, key)`

Removes the mapping and deletes the entity from the Jecs world.

### `registry:Clear(category?)`

Deletes one category or every registered entity.

### `collect(signal)`

Returns a FIFO queue pop function and the signal connection.

## License

MIT
