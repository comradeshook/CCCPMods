local scuttleDelay = 1000 -- ms

function Create(self)
	self.hasHitGround = false;
end

function OnCollideWithTerrain(self, nah)
	if (self.hasHitGround == false) then
		self.hasHitGround = true;
		self.scuttleTimer = Timer();
	end
end

function Update(self)
	if (self.scuttleTimer and self.scuttleTimer:IsPastSimMS(scuttleDelay)) then
		self.Health = -1;
		self.scuttleTimer = nil;
	end
end