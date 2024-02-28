function Create(self)
	self.optionTable = {
		CreateMOSRotating("HHCannon Shell"),
		CreateAEmitter("Rocket Launchable"),
		CreateAEmitter("Pyro Rocket"),
	}
	self.projectile = self.optionTable[math.random(3)]
	self.projectile.Pos = self.Pos
	self.projectile.Vel = self.Vel
	MovableMan:AddMO(self.projectile)
	self.ToDelete = true
end
