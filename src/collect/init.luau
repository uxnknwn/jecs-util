--!strict

type PackedArguments = {
	[number]: any,
	n: number,
}

type Signal = {
	Connect: (self: Signal, callback: (...any) -> ()) -> RBXScriptConnection,
}

local function collect(signal: Signal)
	local queue: { PackedArguments } = {}

	local connection = signal:Connect(function(...)
		table.insert(queue, table.pack(...))
	end)

	local function pop()
		local arguments = table.remove(queue, 1)

		if arguments == nil then
			return nil
		end

		return table.unpack(arguments, 1, arguments.n)
	end

	return pop, connection
end

return collect
