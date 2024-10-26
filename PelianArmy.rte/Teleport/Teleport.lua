local teleportOffset = Vector(0, -50);
local scuttleDelay = 1000 -- ms

function Create(self)
	local var = {};
	var.adjustMass = true;
	var.hasHitGround = false;
	self.var = var;
end

function OnCollideWithTerrain(self, nah)
	local var = self.var;
	if (var.hasHitGround == false) then
		var.hasHitGround = true;
		var.scuttleTimer = Timer();
	end
end

function Update(self)
	local var = self.var;
	if (self.ToDelete) then
		self.Pos = self.Pos + teleportOffset;
	end
	
	if (var.scuttleTimer and var.scuttleTimer:IsPastSimMS(scuttleDelay)) then
		self.Health = -1;
		var.scuttleTimer = nil;
	end
	
	if (var.adjustMass) then
		local adjustedMass = self.IndividualMass*2 - self.Mass;
		self.Mass = adjustedMass;
		var.adjustMass = false;
	end
end