function Create(self)
	local var = {};
	var.range = Vector(25, 0);
	var.colour = 166;
	var.arc = 2.5; -- Radians
	var.arcSteps = math.ceil(var.range.Magnitude * var.arc);
	var.angleStep = var.arc / var.arcSteps;
	var.Pos = self.Pos;
	self.var = var;
end

local random = math.random;
local GetMaterialFromID = SceneMan.GetMaterialFromID;
local GetTerrMatter = SceneMan.GetTerrMatter;
local CastNotMaterialRay = SceneMan.CastNotMaterialRay;
local DislodgePixel = SceneMan.DislodgePixel;

local dummyVector = Vector(0, 0);
local GetXFlipped = dummyVector.GetXFlipped;
local GetRadRotatedCopy = dummyVector.GetRadRotatedCopy;
dummyVector = nil;

local SIRange = {30, 200.5};

function OnFire(self)
	local var = self.var;
	local rotAngle = self.RotAngle;
	local flip = self.HFlipped;
	local muzzlePos = self.MuzzlePos;
	for i = 1, var.arcSteps, 1 do
		local fireAngle = rotAngle - (var.arc/2) + var.angleStep * i;
		local fireVector = GetRadRotatedCopy(GetXFlipped(var.range, flip), fireAngle);
		local hitPos = var.Pos + fireVector;
		local terrainFound = CastNotMaterialRay(SceneMan, muzzlePos, fireVector, 0, hitPos, 0, false);
		local penetration = random(SIRange[1]*SIRange[1], SIRange[2]*SIRange[2]);
		if (terrainFound) then
			hitX = hitPos.X;
			hitY = hitPos.Y;
			local materialIndex = GetTerrMatter(SceneMan, hitX, hitY);
			local material = GetMaterialFromID(SceneMan, materialIndex);
			local materialSI = material.StructuralIntegrity;
			if (materialSI*materialSI <= penetration) then
				local delete = random() < 0.95 or materialIndex == 2;
				local particle = DislodgePixel(SceneMan, hitX, hitY, delete);
				if (delete == false and particle) then
					local angleOffset = -1 + random() * 2;
					particle.Vel = GetRadRotatedCopy((fireVector * random() * -0.2), angleOffset);
				else
					if (random() < 0.1) then
						local smonk = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte");
						smonk.Pos = hitPos;
						MovableMan:AddParticle(smonk);
					end
				end
			end
		end
	end
end