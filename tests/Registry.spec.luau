--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local robloxPackages = ReplicatedStorage:WaitForChild("roblox_packages")
local Jecs = require(robloxPackages:WaitForChild("jecs"))
local registryModule = require(ReplicatedStorage:WaitForChild("jecs_util")).registry

type Describe = (name: string, callback: () -> ()) -> ()
type It = (name: string, callback: () -> ()) -> ()

local function createMockWorld()
	local deletedEntities = {}

	local world = {
		delete = function(_, entity)
			table.insert(deletedEntities, entity)
		end,
	}

	return world, deletedEntities
end

return function(describe: Describe, it: It)
	local function check(condition: boolean, message: string)
		assert(condition, message)
	end

	describe("Registry", function()
		it("creates a registry", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)

			check(registry ~= nil, "expected registry")
		end)

		it("keeps registries isolated", function()
			local world1 = createMockWorld()
			local world2 = createMockWorld()
			local registry1 = registryModule.new(world1)
			local registry2 = registryModule.new(world2)

			registry1:Define("A", "Key", 1)

			check(registry1:Get("A", "Key") == 1, "expected registry1 mapping")
			check(registry2:Get("A", "Key") == nil, "expected isolated registry2")
		end)

		it("stores and retrieves entities", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)

			registry:Define("Players", 123, 10)

			check(registry:Get("Players", 123) == 10, "expected stored entity")
		end)

		it("returns nil for missing category", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)

			check(registry:Get("Missing", 1) == nil, "expected missing category")
		end)

		it("returns nil for missing key", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)

			registry:Define("Players", 1, 10)

			check(registry:Get("Players", 2) == nil, "expected missing key")
		end)

		it("reports existence correctly", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)

			registry:Define("Players", 1, 10)

			check(registry:Has("Players", 1), "expected present mapping")
			check(not registry:Has("Players", 2), "expected missing mapping")
		end)

		it("overwrites an existing mapping", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)
			local originalWarn = registry._warn

			registry._warn = function() end

			registry:Define("Players", 1, 10)
			registry:Define("Players", 1, 11)

			registry._warn = originalWarn
			check(registry:Get("Players", 1) == 11, "expected overwritten entity")
		end)

		it("warns on overwrite", function()
			local messages = {}
			local world = createMockWorld()
			local registry = registryModule.new(world)
			local originalWarn = registry._warn

			registry._warn = function(message)
				table.insert(messages, message)
			end

			registry:Define("Players", 1, 10)
			registry:Define("Players", 1, 11)

			registry._warn = originalWarn

			check(#messages == 1, "expected one warning")
			check(string.find(messages[1], "Players") ~= nil, "expected category in warning")
			check(string.find(messages[1], "1") ~= nil, "expected key in warning")
		end)

		it("undefines and returns the removed entity", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("Players", 1, 10)

			check(registry:Undefine("Players", 1) == 10, "expected removed entity")
			check(registry:Get("Players", 1) == nil, "expected mapping removed")
		end)

		it("does not delete on undefine", function()
			local world, deletedEntities = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("Players", 1, 10)

			registry:Undefine("Players", 1)

			check(#deletedEntities == 0, "expected no delete")
		end)

		it("returns nil for missing undefine", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)

			check(registry:Undefine("Players", 1) == nil, "expected missing undefine")
		end)

		it("deletes mappings", function()
			local world, deletedEntities = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("Players", 1, 10)

			registry:Delete("Players", 1)

			check(registry:Get("Players", 1) == nil, "expected mapping deleted")
			check(deletedEntities[1] == 10, "expected world delete")
		end)

		it("does nothing for missing delete", function()
			local world, deletedEntities = createMockWorld()
			local registry = registryModule.new(world)

			registry:Delete("Players", 1)

			check(#deletedEntities == 0, "expected no delete")
		end)

		it("removes empty categories", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("Players", 1, 10)

			registry:Undefine("Players", 1)

			check(registry:Get("Players", 1) == nil, "expected empty category")
		end)

		it("clears one category", function()
			local world, deletedEntities = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("NPCs", 1, 10)
			registry:Define("NPCs", 2, 11)
			registry:Define("Players", 3, 12)

			registry:Clear("NPCs")

			check(#deletedEntities == 2, "expected category delete count")
			check(registry:Get("NPCs", 1) == nil, "expected category cleared")
			check(registry:Get("Players", 3) == 12, "expected other category intact")
		end)

		it("clears all categories", function()
			local world, deletedEntities = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("NPCs", 1, 10)
			registry:Define("Players", 2, 11)

			registry:Clear()

			check(#deletedEntities == 2, "expected total delete count")
			check(registry:Get("NPCs", 1) == nil, "expected npc cleared")
			check(registry:Get("Players", 2) == nil, "expected player cleared")
		end)

		it("supports number keys", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("Numbers", 123, 10)

			check(registry:Get("Numbers", 123) == 10, "expected number key")
		end)

		it("supports string keys", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)
			registry:Define("Strings", "key", 10)

			check(registry:Get("Strings", "key") == 10, "expected string key")
		end)

		it("supports instance keys", function()
			local world = createMockWorld()
			local registry = registryModule.new(world)
			local key = Instance.new("Folder")

			registry:Define("Instances", key, 10)

			check(registry:Get("Instances", key) == 10, "expected instance key")

			key:Destroy()
		end)

		it("works with a real Jecs world", function()
			local world = Jecs.World.new()
			local registry = registryModule.new(world)
			local entity = world:entity()

			registry:Define("Players", 123, entity)

			check(registry:Get("Players", 123) == entity, "expected registered entity")
			check(world:contains(entity), "expected world to contain entity")
		end)

		it("deletes on a real Jecs world", function()
			local world = Jecs.World.new()
			local registry = registryModule.new(world)
			local entity = world:entity()

			registry:Define("Players", 123, entity)
			registry:Delete("Players", 123)

			check(not world:contains(entity), "expected deleted entity")
		end)
	end)
end
