function Create(self)
	self.trailRandom = Vector(self.Vel.Magnitude, 0)
		+ Vector(math.random((self.Vel.Magnitude / -3.75), (self.Vel.Magnitude / 15)), 0)
	self.trailSpread = math.random(-50, 50) / 1000
	local trail = CreateMOPixel("watthis")
	trail.Pos = self.Pos
	trail.Vel = self.trailRandom:RadRotate(
		self.RotAngle + self.trailSpread + math.rad(180) * math.min(0, self.FlipFactor)
	)
	MovableMan:AddMO(trail)

	function bloatAdd(range)
		for MO in MovableMan:GetMOsInRadius(self.Pos, range, -1, true) do
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

function Update(self)
	self.trailRandom = Vector(self.Vel.Magnitude, 0)
		+ Vector(math.random((self.Vel.Magnitude / -3.75), (self.Vel.Magnitude / 15)), 0)
	self.trailSpread = math.random(-25, 25) / 1000
	local trail = CreateMOPixel("watthis")
	trail.Pos = self.Pos
	trail.Vel = self.trailRandom:RadRotate(
		self.RotAngle + self.trailSpread + math.rad(180) * math.min(0, self.FlipFactor)
	)
	MovableMan:AddMO(trail)
	if self.Age > 1500 then
		self:GibThis()
	end

	bloatAdd(20)
end
