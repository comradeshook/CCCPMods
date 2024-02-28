function Create(self)
	self.Scale = 0
	self.correctedAngle = self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor)
	self.Vel = self.Vel + Vector(0, -5):RadRotate(self.RotAngle)
	self.Frame = 1
	self.frameFactor = GetPPM() * TimerMan.DeltaTimeSecs
end

function Update(self)
	self.Frame = 1
	if self.Scale < 1 then
		self.Scale = self.Scale + 0.1
	end
	local acc = 50
	if self.Age > 100 then
		self.Vel = self.Vel + (Vector(acc, 0):RadRotate(self.correctedAngle) * TimerMan.DeltaTimeSecs)
		local checkPos = self.Pos - (Vector(52, 0):RadRotate(self.correctedAngle))
		local checkVector = (Vector(104, 0):RadRotate(self.correctedAngle))
		local hitCheck = SceneMan:CastMORay(checkPos, checkVector, self.RootID, self.IgnoresWhichTeam, 0, false, 0)
		if hitCheck ~= nil then
			if hitCheck ~= self.ID and hitCheck ~= 255 then
				self:GibThis()
			end
		end
	end
end
