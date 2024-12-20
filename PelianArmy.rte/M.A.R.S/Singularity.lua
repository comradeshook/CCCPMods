function Create(self)
	local var = {};
	var.pullRadius = 80
	var.maxPull = 50
	var.killRadius = 15
	var.ownerVector = Vector(-50, 0):RadRotate(self.RotAngle)
	var.owner = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, var.ownerVector, self.ID, -2, 0, false, 1))
	var.Pos = self.Pos;
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

local ShortestDistance = SceneMan.ShortestDistance;
local DislodgePixelCircle = SceneMan.DislodgePixelCircle;

function Update(self)
	local var = self.var;
	local GetRootParent = self.GetRootParent;
	local RadRotate = var.Pos.RadRotate;
	for MO in MovableMan:GetMOsInRadius(var.Pos, var.pullRadius, -1, false) do
		if GetRootParent(MO).UniqueID ~= var.ownerRoot.UniqueID then
			local MOVector = ShortestDistance(SceneMan, var.Pos, MO.Pos, true)
			local gravDist = MOVector.Magnitude
			if IsMOSRotating(MO) then
				local MOSR = ToMOSRotating(MO);
				if MOVector.Magnitude < var.killRadius + (MOSR.IndividualRadius / 2) then
					local hasGibs = false;
					for gib in MOSR.Gibs do
						hasGibs = true;
					end
					if (hasGibs) then
						MOSR:GibThis()
					end
				end
			end
			if MO.PresetName ~= "PA MARS" then
				local angle = MOVector.AbsRadAngle;
				local pullStrength = RadRotate(Vector((-var.maxPull * (5 / gravDist)), 0), angle)
				MO.Vel = MO.Vel + pullStrength
			end
		end
	end

	---- Enable for terrain deletion :D
	-- for pixel in DislodgePixelCircle(SceneMan, var.Pos, 8) do
	-- 	if (math.random() < 0.7) then
	-- 		pixel.ToDelete = true;
	-- 	end
	-- end
end
