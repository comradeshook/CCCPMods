function Create(self)
	self.bonusAmmo = 16
	self.baseROF = 200
	self.bonusROF = 250
	self.onGround = 1
	self.incompatible = true
end

function Update(self)
	local owner = self:GetRootParent();
	if owner then
		if owner.PresetName == "Pelian Assault Robot" then
			if self.incompatible then
				self:SetNextMagazineName("Magazine Destroyer")
				self.Mass = 40
				self.RateOfFire = self.baseROF + self.bonusROF
				self.BaseReloadTime = 2000;
				self.incompatible = false
			end
		else
			if self.incompatible == false then
				self:SetNextMagazineName("Magazine Destroyer Smol")
				self.Mass = 80
				self.RateOfFire = self.baseROF
				self.BaseReloadTime = 3000;
				self.incompatible = true
			end
		end
	end
	
	if (self.FiredFrame) then
		for i = 1, 3 do
			local smonk = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte");
			local smonkVel = Vector(45 + math.random()*5, math.random()*5);
			smonk.Pos = self.MuzzlePos;
			smonk.Vel = smonkVel:GetXFlipped(self.HFlipped):RadRotate(self.RotAngle);
			MovableMan:AddParticle(smonk);
		end
	end
end