--!strict

export type entity = number

type world = {
	delete: (self: world, entity: entity) -> (),
}

type categoryData = {
	[any]: entity,
}

type registryData = {
	[string]: categoryData,
}

export type registry = {
	_world: world,
	_data: registryData,
	_warn: (message: string) -> (),

	Define: (self: registry, category: string, key: any, entity: entity) -> (),
	Get: (self: registry, category: string, key: any) -> entity?,
	Has: (self: registry, category: string, key: any) -> boolean,
	Undefine: (self: registry, category: string, key: any) -> entity?,
	Delete: (self: registry, category: string, key: any) -> (),
	Clear: (self: registry, category: string?) -> (),
}

local registry = {}
registry.__index = registry

function registry.new(world: world): registry
	return setmetatable({
		_world = world,
		_data = {},
		_warn = warn,
	}, registry) :: any
end

function registry:Define(category: string, key: any, entity: entity)
	local categoryData = self._data[category]

	if categoryData == nil then
		categoryData = {}
		self._data[category] = categoryData
	end

	if categoryData[key] ~= nil then
		self._warn(
			`[registry] Overwriting entity in category "{category}" for key "{tostring(key)}"`
		)
	end

	categoryData[key] = entity
end

function registry:Get(category: string, key: any): entity?
	local categoryData = self._data[category]

	if categoryData == nil then
		return nil
	end

	return categoryData[key]
end

function registry:Has(category: string, key: any): boolean
	return self:Get(category, key) ~= nil
end

function registry:Undefine(category: string, key: any): entity?
	local categoryData = self._data[category]

	if categoryData == nil then
		return nil
	end

	local entity = categoryData[key]

	if entity == nil then
		return nil
	end

	categoryData[key] = nil

	if next(categoryData) == nil then
		self._data[category] = nil
	end

	return entity
end

function registry:Delete(category: string, key: any)
	local entity = self:Undefine(category, key)

	if entity == nil then
		return
	end

	self._world:delete(entity)
end

function registry:Clear(category: string?)
	if category ~= nil then
		local categoryData = self._data[category]

		if categoryData == nil then
			return
		end

		for _, entity in pairs(categoryData) do
			self._world:delete(entity)
		end

		self._data[category] = nil

		return
	end

	for _, categoryData in pairs(self._data) do
		for _, entity in pairs(categoryData) do
			self._world:delete(entity)
		end
	end

	table.clear(self._data)
end

return registry
