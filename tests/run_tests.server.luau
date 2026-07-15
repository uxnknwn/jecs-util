--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tests = ReplicatedStorage:WaitForChild("Tests")

local failures = {}
local currentSuite = ""

local function describe(name: string, callback: () -> ())
	local previousSuite = currentSuite
	currentSuite = if previousSuite == "" then name else previousSuite .. " / " .. name

	local ok, err = pcall(callback)
	currentSuite = previousSuite

	if not ok then
		table.insert(failures, string.format("[%s] %s", currentSuite, err))
	end
end

local function it(name: string, callback: () -> ())
	local ok, err = pcall(callback)

	if not ok then
		table.insert(
			failures,
			string.format(
				"[%s] %s",
				if currentSuite == "" then name else currentSuite .. " / " .. name,
				err
			)
		)
	end
end

local specs = {
	"Collect.spec",
	"Registry.spec",
}

for _, specName in ipairs(specs) do
	local ok, specOrError = pcall(require, Tests:WaitForChild(specName))

	if not ok then
		table.insert(failures, string.format("[load %s] %s", specName, specOrError))
	elseif type(specOrError) == "function" then
		specOrError(describe, it)
	end
end

if #failures > 0 then
	error(table.concat(failures, "\n"), 0)
end

print("jecs-util tests passed")
