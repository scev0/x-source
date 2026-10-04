--[[

Purpose: Common use

Behavior attributes:
* object reference 'renderCamera'
* list 'billboardType' {Face Camera,Match Camera Rotation}
* bool 'yOnlyFlag'
* list 'frontAxis' {+X,+Y,+Z,-X,-Y,-Z}

Depends on elements:
* referenced camera

Necessary references:
* [renderCamera].rotation
* parent.rotation

]]

--[[
*********************************************************************
*	Behavior: Billboard.bvs
*
*	For information on how to use this behavior refer to
*	the Gameface Samples Reference included with Anark Studio.
*
*	Tooltips and use for each parameter of this behavior
*	are available in the Inspector Palette of Anark Studio.
*
*	Copyright 2007, Anark Corporation.
*	ALL RIGHTS RESERVED
*
*********************************************************************
--]]

function self:onInitialize()
	self.renderCamera = getElement(getAttribute(self.element, 'renderCamera'))
	if self.renderCamera == nil then
		DebugError('Billboard init: renderCamera attribute on behavior is invalid! Please make sure that it is an absolute, and not a path reference.\nAttribute is: '..getAttribute(self.element, 'renderCamera'))
	end
	self.parent = getElement('parent', self.element)
	self.billboardType = getAttribute(self.element, 'billboardType')
	self.yOnlyFlag = getAttribute(self.element, 'yOnlyFlag')
	self.frontFace = getAttribute(self.element, 'frontFace')

	self.cameraSpot = Vector:new()
	self.parentSpot = Vector:new()
	self.parentRotation = Rotation:new()
	self.rotateRay = Vector:new()
	self.rotationAdd = Rotation:new()
	self.matrix = Matrix:new()

	self.axes = { POSX=0, POSY=1, POSZ=2, NEGX=3, NEGY=4, NEGZ=5 }
	self.billboardTypes = { FACE_CAMERA=0, MATCH_ROTATION=1 }

	local thePiBy2 = math.pi / 2

	if self.yOnlyFlag then
		if self.frontFace == self.axes.NEGZ then
			self.rotationAdd.y = math.pi
		elseif self.frontFace == self.axes.POSX then
			self.rotationAdd.y = -thePiBy2
		elseif self.frontFace == self.axes.NEGX then
			self.rotationAdd.y = thePiBy2
		else -- POSZ, POSY, NEGY
			self.rotationAdd.y = 0
		end
	else
		if self.frontFace == self.axes.POSX then
			self.rotationAdd.x = thePiBy2
			self.rotationAdd.z = thePiBy2
		elseif self.frontFace == self.axes.POSY then
			self.rotationAdd.x = thePiBy2
		elseif self.frontFace == self.axes.POSZ then
			-- #StefanMed test whether this is correct --- just assumed it was a missing case and added the values based on the other cases
			self.rotationAdd.x = -math.pi
			self.rotationAdd.z = -math.pi
		elseif self.frontFace == self.axes.NEGX then
			self.rotationAdd.x = thePiBy2
			self.rotationAdd.z = -thePiBy2
		elseif self.frontFace == self.axes.NEGY then
			self.rotationAdd.x = -thePiBy2
		elseif self.frontFace == self.axes.NEGZ then
			self.rotationAdd.x = math.pi
			self.rotationAdd.z = math.pi
		else
			assert(false, "Invalid Front Face value!! - frontFace is: "..tostring(self.frontFace))
		end
	end

	if self.billboardType == self.billboardTypes.FACE_CAMERA then
		self.updateFunction = self.yOnlyFlag and self.faceCameraGlobalY or self.faceCamera
	elseif self.billboardType == self.billboardTypes.MATCH_ROTATION then
		self.updateFunction = self.yOnlyFlag and self.matchRotationGlobalY or self.matchRotation
	else
		assert(false, "Invalid Billbord Type value!!")
	end
end

function self:onUpdate()
	if self.renderCamera == nil then return end
	self:updateFunction()
end

function self:faceCamera()
	-- Find the global location of the camera eye (accounts for pivot offset)
	calculateGlobalTransform(self.renderCamera, self.matrix)
	self.cameraSpot:set(self.matrix._41, self.matrix._42, self.matrix._43)

	-- Find the global location of the parent (accounts for pivot offset)
	calculateGlobalTransform(self.parent, self.matrix)
	self.parentSpot:set(self.matrix._41, self.matrix._42, self.matrix._43)

	-- Find the look at direction, first in global space...
	self.rotateRay:setVector(self.cameraSpot)
	self.rotateRay:subtract(self.parentSpot)

	-- ...and then move it into the local space of the parent object
	calculateGlobalTransform(getElement('parent', self.parent), self.matrix)
	self.matrix:invert();
	self.matrix._41 = 0
	self.matrix._42 = 0
	self.matrix._43 = 0
	self.rotateRay:transform(self.matrix)

	-- Rotate the parent to match the ray, and then adjust for which axis is desired
	self:getAttributeVector(self.parent, 'rotation', self.parentRotation)
	self.parentRotation:lookAt(self.rotateRay)
	self.parentRotation:add(self.rotationAdd)
	self:setAttributeVector(self.parent, 'rotation', self.parentRotation)
end

function self:matchRotation()
	-- Find the global location of the camera eye (accounts for pivot offset)
	calculateGlobalTransform(self.renderCamera, self.matrix)
	self.cameraSpot:set(self.matrix._41, self.matrix._42, self.matrix._43)

	-- Create a ray that represents the camera's global rotation...
	self.rotateRay:set(0, 0, 1)
	self.rotateRay:transform(self.matrix)
	self.rotateRay:subtract(self.cameraSpot)

	-- ...and then move it into the local space of the parent object
	calculateGlobalTransform(getElement('parent', self.parent), self.matrix)
	self.matrix:invert();
	self.matrix._41 = 0
	self.matrix._42 = 0
	self.matrix._43 = 0
	self.rotateRay:transform(self.matrix)

	-- Rotate the parent to match the ray, and then adjust for which axis is desired
	self:getAttributeVector(self.parent, 'rotation', self.parentRotation)
	self.parentRotation:lookAt(self.rotateRay)
	self.parentRotation:add(self.rotationAdd)
	self:setAttributeVector(self.parent, 'rotation', self.parentRotation)
end

function self:faceCameraGlobalY()
	-- Find the global location of the camera eye (accounts for pivot offset)
	calculateGlobalTransform(self.renderCamera, self.matrix)
	self.cameraSpot:set(self.matrix._41, self.matrix._42, self.matrix._43)

	-- Find the global location of the parent (accounts for pivot offset)
	calculateGlobalTransform(self.parent, self.matrix)
	self.parentSpot:set(self.matrix._41, self.matrix._42, self.matrix._43)

	-- ...and subtract from the camera spot to determine the offset
	self.cameraSpot:subtract(self.parentSpot)

	-- Calculate the global y rotation needed to look at the camera
	self:getAttributeVector(self.parent, 'rotation', self.parentRotation)
	self.parentRotation.y = math.atan2(self.cameraSpot.x, self.cameraSpot.z)
	self.parentRotation:add(self.rotationAdd)
	self:setAttributeVector(self.parent, 'rotation', self.parentRotation)
end

function self:matchRotationGlobalY()
	-- Find the global location of the camera eye (accounts for pivot offset)
	calculateGlobalTransform(self.renderCamera, self.matrix)
	self.cameraSpot:set(self.matrix._41, self.matrix._42, self.matrix._43)

	-- Create a ray that represents the camera's global rotation...
	self.rotateRay:set(0, 0, 1)
	self.rotateRay:transform(self.matrix)
	self.rotateRay:subtract(self.cameraSpot)

	-- Save the X/Z rotations of the parent
	self:getAttributeVector(self.parent, 'rotation', self.parentRotation)
	local theOldX = self.parentRotation.x
	local theOldZ = self.parentRotation.z
	self.parentRotation:lookAt(self.rotateRay)
	self.parentRotation:add(self.rotationAdd)
	self.parentRotation.x = theOldX
	self.parentRotation.z = theOldZ
	self:setAttributeVector(self.parent, 'rotation', self.parentRotation)
end

--[[ Helper Functions --]]

function self:getAttributeVector(inElement, inAttribute, inVector)
	inVector.x = getAttribute(inElement, inAttribute .. '.x')
	inVector.y = getAttribute(inElement, inAttribute .. '.y')
	inVector.z = getAttribute(inElement, inAttribute .. '.z')
end

function self:setAttributeVector(inElement, inAttribute, inVector)
	setAttribute(inElement, inAttribute .. '.x', inVector.x)
	setAttribute(inElement, inAttribute .. '.y', inVector.y)
	setAttribute(inElement, inAttribute .. '.z', inVector.z)
end
