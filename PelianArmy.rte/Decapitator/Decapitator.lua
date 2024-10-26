function Create(self)
	self.Sharpness = 0
end

function Update(self)
	if self.Sharpness > 0 and self.RootID ~= self.ID then
		if self.Sharpness == 1 then
			self:SetNextMagazineName("Magazine Decapitator")
		elseif self.Sharpness == 2 then
			self:SetNextMagazineName("Magazine Decapitator Bomb")
		elseif self.Sharpness == 3 then
			self:SetNextMagazineName("Magazine Decapitator Fire")
		end
		self:Reload()
		self.Sharpness = 0
	end
end
