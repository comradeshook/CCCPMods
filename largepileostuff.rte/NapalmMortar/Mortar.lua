function Create(self)
	self.lifeTimer = Timer()
	self.inactive = 0
	if self.Vel.Y < -15 then
		local g = SceneMan.GlobalAcc.Y
		self.triggerDelayMS = (2000 * (-self.Vel.Y / g)) - 200
	else
		self.inactive = 1
	end
end

function Update(self)
	if self.inactive == 0 then
		if self.lifeTimer:IsPastSimMS(self.triggerDelayMS) then
			self:GibThis()
		end
	end
end
