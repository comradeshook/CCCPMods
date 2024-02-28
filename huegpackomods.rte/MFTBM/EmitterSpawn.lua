function OnFire(self)
	local muzzleemitter = CreateAEmitter("MFTBM Effects")
	muzzleemitter.Pos = self.MuzzlePos;
	muzzleemitter.RotAngle = self.HFlipped and (self.RotAngle + math.pi) or self.RotAngle;
	MovableMan:AddParticle(muzzleemitter)
end
