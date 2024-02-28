package.path = package.path .. string.format(";Mods/GAYER.rte/Fx/?.lua")
require("MegaGib")

function Create(self)
	for MO in MovableMan:GetMOsInRadius(self.Pos, 120, self.Team, true) do
		if IsMOSRotating(MO) == true then
			local distVec = SceneMan:ShortestDistance(self.Pos, MO.Pos, true)
			if not SceneMan:CastStrengthRay(self.Pos, distVec, 10, Vector(0, 0), 3, 0, true) then
				ToMOSRotating(MO):GibThis();
			end
		end
	end
end
