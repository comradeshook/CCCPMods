function Update(self)
	if self.ToDelete then
		for MO in MovableMan:GetMOsInRadius(self.Pos, 100, -1, true) do
			if MovableMan:ValidMO(MO) and (IsAHuman(MO) or IsACrab(MO)) 
				and MO.PresetName ~= "Reflective Robot MK-II"
				and MO:HasScript("largepileostuff.rte/Bombs/Lua/BloatActor.lua") == false
				and SceneMan:CastStrengthRay(self.Pos, SceneMan:ShortestDistance(self.Pos, MO.Pos, true), 6, Vector(0, 0), 3, 0, true) == false 
			then
				MO:AddScript("largepileostuff.rte/Bombs/Lua/BloatActor.lua");
			end
		end
	end
end
