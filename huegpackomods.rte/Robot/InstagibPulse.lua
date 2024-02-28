package.path = package.path .. string.format(";Mods/huegpackomods.rte/Fx/?.lua")
require("MegaGib")

function Update(self)
	for MO in MovableMan:GetMOsInRadius(self.Pos, 10, -1, true) do
		if MO:GetRootParent().PresetName ~= "Reflective Robot MK-II" then
			absolutelyFuckingGib(MO, Vector(0, 0))
		end
	end
end
