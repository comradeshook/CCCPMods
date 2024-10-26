function Create(self)
	local var = {};
	var.pullRadius = 80
	var.maxPull = 50
	var.killRadius = 15
	var.ownerVector = Vector(-50, 0):RadRotate(self.RotAngle)
	var.owner = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, var.ownerVector, self.ID, -2, 0, false, 1))
	if var.owner ~= nil then
		var.ownerRoot = MovableMan:GetMOFromID(var.owner.RootID)
		if var.ownerRoot:HasObject("MARS Singularity Cannon") == false then
			var.ownerRoot = self
		end
	end
	if var.ownerRoot == nil then
		var.ownerRoot = self
	end
	local bigGlow = CreateMOPixel("Big Purple Glow")
	bigGlow.Pos = self.Pos
	MovableMan:AddMO(bigGlow)
	self.var = var;
end

function Update(self)
	local var = self.var;
	for MO in MovableMan:GetMOsInRadius(self.Pos, var.pullRadius, -1, false) do
		if MO:GetRootParent().UniqueID ~= var.ownerRoot.UniqueID then
			local MOVector = SceneMan:ShortestDistance(self.Pos, MO.Pos, true)
			self.gravDist = MOVector.Magnitude
			if MOVector.Magnitude < var.killRadius + (MO.Radius / 2) then
				if MO.ClassName ~= "MOPixel" and MO.ClassName ~= "MOSParticle" then
					ToMOSRotating(MO):GibThis()
				end
			end
			if MO.PresetName ~= "PA MARS" then
				local angle = math.atan2(-MOVector.Y, MOVector.X)
				local pullStrength = Vector((-var.maxPull * (5 / self.gravDist)), 0):RadRotate(angle)
				MO.Vel = MO.Vel + pullStrength
			end
		end
	end
end
