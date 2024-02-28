function Create(self)
	self.clamped = false
	self.testVector = Vector(0, 0)
end

function Update(self)
	if self.clamped == false then
		self.clamped = true
		self.testVector:ClampMagnitude(400, 0)
	end
end
