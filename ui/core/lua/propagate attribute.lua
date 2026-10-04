--[[

Purpose: Common use

Behavior attributes:
* Object reference 'sourceElement'
* Object reference 'targetElement'
* string 'sourceAttributeName'
* string 'targetAttributeName'

Depends on elements:
* Referenced source element
* Referenced target element

Depends on attributes:
* 'sourceAttributeName' on referenced source element
* 'targetAttributeName' on referenced target element

Tasks:
* Propagate an attribute from one element to another

Notes:
If one of the attribute names is set to an empty string the other is used for both.
If both are set to empty strings and/or an object reference is invalid the behavior does nothing.

]]

function self:onInitialize()
	self.sourceElement = getElement(getAttribute(self.element, 'sourceElement'))
	self.targetElement = getElement(getAttribute(self.element, 'targetElement'))
	self.sourceAttributeName = getAttribute(self.element, 'sourceAttributeName')
	self.targetAttributeName = getAttribute(self.element, 'targetAttributeName')
	if self.sourceAttributeName == '' then
		self.sourceAttributeName = self.targetAttributeName
	elseif self.targetAttributeName == '' then
		self.targetAttributeName = self.sourceAttributeName
	end
end

function self:onActivate()
	if self.sourceElement == nil then
		DebugError('ERROR in Propagate Attribute.lua(): invalid source object reference, aborting. - object is: '..tostring(getAttribute(self.element, 'sourceElement')))
		return
	end
	if self.targetElement == nil then
		DebugError('ERROR in Propagate Attribute.lua(): invalid target object reference, aborting. - object is: '..tostring(getAttribute(self.element, 'targetElement')))
		return
	end
	if self.sourceAttributeName == '' and self.targetAttributeName == '' then
		DebugError('ERROR in Propagate Attribute.lua(): no attribute names provided, aborting.')
		return
	end
	registerForChange(self.sourceElement, self.sourceAttributeName, self.onSourceAttributeChanged)
	self:onSourceAttributeChanged()
end

function self:onDeactivate()
	if self.sourceElement ~= nil then
		unregisterForChange(self.sourceElement, self.sourceAttributeName, self.onSourceAttributeChanged)
	end
end

function self:onSourceAttributeChanged()
	if self.targetElement ~= nil then
		setAttribute(self.targetElement, self.targetAttributeName, getAttribute(self.sourceElement, self.sourceAttributeName))
	end
end
