package.path = package.path .. string.format(";Mods/huegpackomods.rte/Fx/?.lua")
require("MegaGib")

function Create(self)
	self.blastRadius = 200;
	self.blastForce = 1000;
end

local function nestedForce(self, target)
	if IsMOSRotating(target) then
		for thing in ToMOSRotating(target).Attachables do
			local distVec = SceneMan:ShortestDistance(self.Pos, thing.Pos, true)
			if not SceneMan:CastStrengthRay(self.Pos, distVec, 10, Vector(0, 0), 3, 0, true) then
				nestedForce(self, thing);
			end
		end
	end
	local distVector = SceneMan:ShortestDistance(self.Pos, target.Pos, true);
	local forceVector = Vector(self.blastForce/(self.blastRadius/(self.blastRadius-distVector.Magnitude)), 0);
	forceVector:RadRotate(distVector.AbsRadAngle);
	target:AddImpulseForce(forceVector, Vector(0, 0));
end

function Update(self)
	if self.ToDelete then
		for MO in MovableMan:GetMOsInRadius(self.Pos, self.blastRadius) do
			local distVec = SceneMan:ShortestDistance(self.Pos, MO.Pos, true)
			if not SceneMan:CastStrengthRay(self.Pos, distVec, 6, Vector(0, 0), 3, 0, true) then
				nestedForce(self, MO);
			end
		end
	end
end
