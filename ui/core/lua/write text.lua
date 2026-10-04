--[[

Purpose: For designated Component

Depends on elements:
* parent.Text
* parent.Flash (optional)

Depends on attributes:
* string 'textstring' on parent
* string 'textstring' on parent.Text
* float 'initialDelay' on parent
* float 'charDelay' on parent
* float 'blockDelay' on parent
* long 'minBlockSize' on parent
* long 'maxBlockSize' on parent
* string 'cursorChar' on parent
* float 'cursorOnTime' on parent
* float 'cursorOffTime' on parent
* float 'cursorStayTime' on parent
* float 'removalDelay' on parent
* bool 'finished' on parent

Tasks:
* Write the text char by char, depending on the properties

Notes:
If the Flash element is present it will be played just before the text starts writing.

Planned:
* Optimization of current text length calculation

]]

local private = {
	restart   = false, -- indicates whether the script has to be restarted
	startTime = nil    -- time (in s) when the script (re-)started
}

function self:onInitialize()
	self.parent = getElement('parent', self.element)
	self.textElement = getElement('Text', self.parent)
	self.flash = getElement('Flash', self.parent)
end

function self:onActivate()
	registerForChange(self.parent, 'textstring', self.onAttributesChanged)
	registerForChange(self.parent, 'initialDelay', self.onAttributesChanged)
	registerForChange(self.parent, 'charDelay', self.onAttributesChanged)
	registerForChange(self.parent, 'blockDelay', self.onAttributesChanged)
	registerForChange(self.parent, 'minBlockSize', self.onAttributesChanged)
	registerForChange(self.parent, 'maxBlockSize', self.onAttributesChanged)
	registerForChange(self.parent, 'cursorChar', self.onAttributesChanged)
	registerForChange(self.parent, 'cursorOnTime', self.onAttributesChanged)
	registerForChange(self.parent, 'cursorOffTime', self.onAttributesChanged)
	registerForChange(self.parent, 'cursorStayTime', self.onAttributesChanged)
	registerForChange(self.parent, 'removalDelay', self.onAttributesChanged)
	self:onAttributesChanged()
end

function self:onDeactivate()
	unregisterForChange(self.parent, 'textstring', self.onAttributesChanged)
	unregisterForChange(self.parent, 'initialDelay', self.onAttributesChanged)
	unregisterForChange(self.parent, 'charDelay', self.onAttributesChanged)
	unregisterForChange(self.parent, 'blockDelay', self.onAttributesChanged)
	unregisterForChange(self.parent, 'minBlockSize', self.onAttributesChanged)
	unregisterForChange(self.parent, 'maxBlockSize', self.onAttributesChanged)
	unregisterForChange(self.parent, 'cursorChar', self.onAttributesChanged)
	unregisterForChange(self.parent, 'cursorOnTime', self.onAttributesChanged)
	unregisterForChange(self.parent, 'cursorOffTime', self.onAttributesChanged)
	unregisterForChange(self.parent, 'cursorStayTime', self.onAttributesChanged)
	unregisterForChange(self.parent, 'removalDelay', self.onAttributesChanged)
end

function self:onUpdate()
	if private.restart then
		private.restart   = false
		private.startTime = getElapsedTime()
	end

	if not self.writingFinished then
		local curtime = getElapsedTime() - private.startTime
		-- check if the initial flash should start playing now
		if self.flash ~= nil and not self.flashStarted and curtime > self.initialDelay - 0.15 then
			play(self.flash)
			self.flashStarted = true
		end
		-- check if we can stop refreshing the text after this
		if curtime > self.finishTime + self.cursorStayTime + self.removalDelay then
			self.writingFinished = true
			setAttribute(self.parent, 'finished', true)
			if self.removeOnFinish then
				setAttribute(self.textElement, 'textstring', '')
				-- return so that the text is not set to the full string after this
				return
			end
		end
		-- determine how many characters to write
		local length = 0
		-- add up times of characters and pauses until reaching the current time
		local attime = self.initialDelay
		local finished = false
		while not finished do
			-- try to add the time of a character
			if attime <= curtime then
				-- increase the length
				length = length + 1
				attime = attime + self.charDelay
			end
			-- check if we have a pause after this character
			for i=1,self.numPauses do
				if self.blockIndices[i] == length then attime = attime + self.blockDelay end
			end
			-- check if we're done here
			if attime > curtime or length == self.fullText:len() then
				finished = true
			end
		end
		if length < 0 then length = 0 end
		-- determine whether to add the cursor
		-- first get the number of elapsed cycles
		local numCursorCycles = math.floor(curtime / self.cursorCycleTime)
		-- now check whether the time after the last cycle is smaller than the 'cursor on' time
		if not self.writingFinished and curtime - numCursorCycles * self.cursorCycleTime < self.cursorOnTime then
			cursorStatus = true
		else
			cursorStatus = false
		end
		-- only update string when we need to
		if cursorStatus ~= self.lastCursorStatus or length ~= self.lastLength then
			-- get the substring
			local textstring = self.fullText:sub(1, length)
			if cursorStatus == true then
				-- the cursor is to be visible, append it to the string
				textstring = textstring .. self.cursorChar
			end
			setAttribute(self.textElement, 'textstring', textstring)
			self.lastCursorStatus = cursorStatus
			self.lastLength = length
		end
	end
end

function self:onAttributesChanged()
	-- reset
	private.restart = true
	goToTime(self.element, 0)
	play(self.element)
	self.writingFinished = false
	setAttribute(self.parent, 'finished', false)
	setAttribute(self.textElement, 'textstring', '')
	self.lastLength = 0
	self.lastCursorStatus = false
	self.flashStarted = false
	-- get attributes
	self.fullText = getAttribute(self.parent, 'textstring')
	self.initialDelay = getAttribute(self.parent, 'initialDelay')
	self.charDelay = getAttribute(self.parent, 'charDelay')
	self.blockDelay = getAttribute(self.parent, 'blockDelay')
	self.minBlockSize = getAttribute(self.parent, 'minBlockSize')
	self.maxBlockSize = getAttribute(self.parent, 'maxBlockSize')
	self.cursorChar = getAttribute(self.parent, 'cursorChar')
	self.cursorOnTime = getAttribute(self.parent, 'cursorOnTime')
	self.cursorOffTime = getAttribute(self.parent, 'cursorOffTime')
	self.cursorStayTime = getAttribute(self.parent, 'cursorStayTime')
	self.cursorCycleTime = self.cursorOnTime + self.cursorOffTime
	self.removalDelay = getAttribute(self.parent, 'removalDelay')
	-- make char delay and cursor cycle time safe to divide by
	if self.charDelay == 0 then self.charDelay = 0.00001 end
	if self.cursorCycleTime == 0 then self.cursorCycleTime = 0.00001 end
	-- calculate character blocks
	self.numPauses = 0
	self.blockIndices = {}
	local finished = false
	while not finished do
		local nextindex
		if self.numPauses ~= 0 then
			nextindex = self.blockIndices[self.numPauses] + math.random(self.minBlockSize, self.maxBlockSize)
		else
			nextindex = math.random(self.minBlockSize, self.maxBlockSize)
		end
		if nextindex > self.fullText:len() then
			finished = true
		else
			self.numPauses = self.numPauses + 1
			self.blockIndices[self.numPauses] = nextindex
		end
	end
	-- calculate the time writing is finished
	self.finishTime = self.initialDelay + self.charDelay * self.fullText:len() + self.blockDelay * (self.numPauses)
	if self.removalDelay >= 0 then
		self.removeOnFinish = true
	else
		self.removalDelay = 0
		self.removeOnFinish = false
	end
	-- prevent writing an empty text
	if self.fullText:len() == 0 then
		self.writingFinished = true
		setAttribute(self.parent, 'finished', true)
	end
end
