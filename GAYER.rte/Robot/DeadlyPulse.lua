function Update(self)
	for MO in MovableMan:GetMOsInRadius(self.Pos, 10, self.Team, true) do
		if IsActor(MO) == true and PresetName ~= "Reflective Robot MK-II" then
			ToActor(MO).Health = 0
		end
	end
end
