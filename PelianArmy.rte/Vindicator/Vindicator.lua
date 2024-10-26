function Create(self)
	self.Sharpness = 0
	self.heavyTimer = Timer()
end

function Update(self)
	if self.Sharpness > 0 and self.RootID ~= self.ID then
		if self.Sharpness == 1 then
			self:SetNextMagazineName("Magazine Vindicator")
			self.RateOfFire = 600
		elseif self.Sharpness == 2 then
			self:SetNextMagazineName("Magazine Vindicator Heavy")
			self.RateOfFire = 180
		end
		self:Reload()
		self.Sharpness = 0
	end
	if self.Magazine ~= nil then
		if self.Magazine.PresetName ~= "Magazine Vindicator Heavy" then
			self.heavyTimer:Reset()
		end
		local fireDelay = ((self.RateOfFire / 60) ^ -1) * 1000
		if self:IsActivated() and self.Magazine.RoundCount > 0 and self.heavyTimer:IsPastSimMS(fireDelay) then
			self.heavyTimer:Reset()
			local spread = math.rad(math.random(-1000, 1000) / 1000)
			for i = 1, 3 do
				local boolit = CreateMOPixel("Particle Vindicator Heavy")
				boolit.Pos = self.MuzzlePos
				boolit.Vel = (Vector(275, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle + spread) + self.Vel
				boolit:SetWhichMOToNotHit(MovableMan:GetMOFromID(self.RootID), -1)
				MovableMan:AddMO(boolit)
			end
		end
	else
		self.heavyTimer:Reset()
	end
end
