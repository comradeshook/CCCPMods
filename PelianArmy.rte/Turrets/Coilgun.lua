function Update(self)
	self.terrainCheck = SceneMan:CastStrengthRay(
		self.Pos,
		(self.Vel * GetPPM() * TimerMan.DeltaTimeSecs),
		1,
		Vector(0, 0),
		0,
		0,
		true
	)
	if self.terrainCheck == true then
		self.Sharpness = 10
	end
end
