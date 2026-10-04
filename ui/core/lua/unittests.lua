-- no need for special unlock-handling
-- presentation is recreated upon use

-- private member data
local private = {
	contract = nil
}

-- local functions forward declarations
local test1
local test2
local test3

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	private.contract = getElement("Scene.UIContract")
end

function self:onActivate()
	-- register for test events
	registerForEvent('testevent1', private.contract, test1)
	registerForEvent('testevent2', private.contract, test2)
end

function test1()
	TestCallback("test1")
end

function test2()
	TestCallback("test2")
end
