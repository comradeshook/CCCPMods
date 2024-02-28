function Create(self)
	self.skipFrames = 2
	self.frameTimer = 0
end

function Update(self)
	if not self:GetParent() then
		if self.frameTimer == self.skipFrames then
			for MO in MovableMan:GetMOsInRadius(self.Pos, 33, self.Team, true) do
				if IsActor(MO:GetRootParent()) == true then
					self:GibThis()
				end
			end
			self.frameTimer = 0
		else
			self.frameTimer = self.frameTimer + 1
		end
	end
end
