function Create(self)
	self.skipFrames = 2
	self.frameTimer = 0
end

function Update(self)
	if not self:GetParent() then
		if self.frameTimer == self.skipFrames then
			for MO in MovableMan:GetMOsInRadius(self.Pos, 50, self.Team, true) do
				if IsActor(MO:GetRootParent()) == true then
					MO:GetRootParent().Mass = MO:GetRootParent().Mass + 0.6
				end
			end
			self.frameTimer = 0
		else
			self.frameTimer = self.frameTimer + 1
		end
	end
end
