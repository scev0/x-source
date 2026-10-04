--[[

Purpose: Common use

Behavior attributes:
* Object reference 'sourceElement'
* Object reference 'targetElement'

Depends on elements:
* Referenced source element
* Referenced target element

Depends on attributes:
* 'rotation' on referenced source element
* 'rotation' on referenced target element

Tasks:
* Rotate an object inversely to another object

Notes:
The intended use is only countering rotation around one axis!

]]

function self:onInitialize()
	self.sourceElement = getElement(getAttribute(self.element, 'sourceElement'), self.element)
	self.targetElement = getElement(getAttribute(self.element, 'targetElement'), self.element)
end

function self:onActivate()
	if self.sourceElement == nil then
		DebugError('ERROR in Counteract Rotation.lua(): invalid source object reference, aborting. - object is: '..tostring(getAttribute(self.element, 'sourceElement')))
		return
	end
	if self.targetElement == nil then
		DebugError('ERROR in Counteract Rotation.lua(): invalid target object reference, aborting. - object is: '..tostring(getAttribute(self.element, 'targetElement')))
		return
	end
	registerForChange(self.sourceElement, 'rotation', self.onRotationChanged)
	self:onRotationChanged()
end

function self:onDeactivate()
	unregisterForChange(self.sourceElement, 'rotation', self.onRotationChanged)
end

function self:onRotationChanged()
	setAttribute(self.targetElement, 'rotation.x', -getAttribute(self.sourceElement, 'rotation.x'))
	setAttribute(self.targetElement, 'rotation.y', -getAttribute(self.sourceElement, 'rotation.y'))
	setAttribute(self.targetElement, 'rotation.z', -getAttribute(self.sourceElement, 'rotation.z'))
end
