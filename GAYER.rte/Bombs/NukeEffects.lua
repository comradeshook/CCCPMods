function Destroy(self)
	self.launchVelMin = 40
	self.launchVelMax = 60
	self.balls = 25
	self.initAngle = math.random(0, (math.pi / (self.balls / 2)) * 1000) / 1000
	for i = 1, self.balls do
		local kugel = CreateAEmitter("Seriouslywat")
		kugel.Pos = self.Pos
		local angle = self.initAngle + (math.pi / (self.balls / 2)) * i
		kugel.Vel = Vector(math.random(self.launchVelMin, self.launchVelMax), 0):RadRotate(angle)
		MovableMan:AddMO(kugel)
	end
end
