function OnFire(self)
	local fireVel = Vector(250, 0);
	fireVel:RadRotate(self.HFlipped and (self.RotAngle + math.pi) or self.RotAngle);
	
	for i = 1, 10000, 1 do
		local laserFragment = CreateMOPixel("Laser Fragment", "huegpackomods.rte");
		laserFragment.Pos = self.MuzzlePos;
		laserFragment.Vel = self.Vel + fireVel + Vector(math.random()*240, 0):RadRotate(math.random()*math.pi*2);
		MovableMan:AddParticle(laserFragment);
	end
	
	for i = 1, 5000, 1 do
		local fireball = CreateMOSParticle("Bomb Blast Ball 3", "huegpackomods.rte");
		fireball.Pos = self.MuzzlePos;
		fireball.Vel = self.Vel + fireVel + Vector(math.random()*240, 0):RadRotate(math.random()*math.pi*2);
		MovableMan:AddParticle(fireball);
	end
end