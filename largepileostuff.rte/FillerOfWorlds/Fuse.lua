function Create(self)
	self.active = false
	self.timer = Timer()
	self.fillRadius = self:GetNumberValue("FillRadius")

	function lightFuse()
		if not self:IsActivated() and not self:GetParent() then
			self:Activate()
		end
	end

	lightFuse()
end

function Update(self)
	if not self.active then
		lightFuse()
		if self:IsActivated() then
			self.active = true
			self.timer:Reset()
		end
	end

	if self.active and self.timer:IsPastSimMS(1000) then
		self.Frame = self.Frame + 1
		self.timer:Reset()
	end
end

function Destroy(self)
	local particle = CreateMOPixel("World Filling Particle")
	particle.Pos = self.Pos
	particle.Vel = Vector(0, 0)
	particle.PinStrength = self.fillRadius
	MovableMan:AddMO(particle)
end
