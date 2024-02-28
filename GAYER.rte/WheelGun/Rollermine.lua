function Update(self)
	if self.Vel.X > 0 then
		self.AngularVel = -25
	else
		self.AngularVel = 25
	end
	for MO in MovableMan:GetMOsInRadius(self.Pos, 50, self.Team, true) do
		if IsActor(MO:GetRootParent()) == true then
			self:GibThis()
		end
	end
end
