--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JecsUtil = require(ReplicatedStorage:WaitForChild("jecs_util"))

type Describe = (name: string, callback: () -> ()) -> ()
type It = (name: string, callback: () -> ()) -> ()

return function(describe: Describe, it: It)
	local function check(condition: boolean, message: string)
		assert(condition, message)
	end

	describe("Collect", function()
		it("returns a pop function and connection", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			check(type(pop) == "function", "expected pop function")
			check(connection ~= nil, "expected connection")

			connection:Disconnect()
			event:Destroy()
		end)

		it("returns nil when empty", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			check(pop() == nil, "expected empty queue")

			connection:Disconnect()
			event:Destroy()
		end)

		it("collects one event", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("RoundStarted", 10)
			task.wait()

			local name, duration = pop()

			check(name == "RoundStarted", "expected event name")
			check(duration == 10, "expected duration")

			connection:Disconnect()
			event:Destroy()
		end)

		it("collects multiple events in fifo order", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("First")
			event:Fire("Second")
			task.wait()

			check(pop() == "First", "expected first event")
			check(pop() == "Second", "expected second event")
			check(pop() == nil, "expected queue drain")

			connection:Disconnect()
			event:Destroy()
		end)

		it("removes an event after popping", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("First")
			task.wait()

			check(pop() == "First", "expected first event")
			check(pop() == nil, "expected queue drain")

			connection:Disconnect()
			event:Destroy()
		end)

		it("preserves multiple arguments", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("A", 1, true)
			task.wait()

			local a, b, c = pop()

			check(a == "A", "expected first arg")
			check(b == 1, "expected second arg")
			check(c == true, "expected third arg")

			connection:Disconnect()
			event:Destroy()
		end)

		it("preserves a nil between values", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("A", nil, "C")
			task.wait()

			local result = table.pack(pop())

			check(result.n == 3, "expected 3 args")
			check(result[1] == "A", "expected arg 1")
			check(result[2] == nil, "expected nil arg 2")
			check(result[3] == "C", "expected arg 3")

			connection:Disconnect()
			event:Destroy()
		end)

		it("preserves trailing nil arguments", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("A", nil, "C", nil)
			task.wait()

			local result = table.pack(pop())

			check(result.n == 4, "expected 4 args")
			check(result[1] == "A", "expected arg 1")
			check(result[2] == nil, "expected nil arg 2")
			check(result[3] == "C", "expected arg 3")
			check(result[4] == nil, "expected nil arg 4")

			connection:Disconnect()
			event:Destroy()
		end)

		it("stops collecting after disconnection", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			connection:Disconnect()
			event:Fire("A")
			task.wait()

			check(pop() == nil, "expected queue empty")

			event:Destroy()
		end)

		it("works with an actual RBXScriptSignal", function()
			local event = Instance.new("BindableEvent")
			local pop, connection = JecsUtil.collect(event.Event)

			event:Fire("Signal")
			task.wait()

			check(pop() == "Signal", "expected signal payload")

			connection:Disconnect()
			event:Destroy()
		end)
	end)
end
