function Create(self)
	self.endPos = Vector(0, 0)
	self.pixelRatio = 4
	self.beamPixelName = "White Dot"
end

function Update(self)
	local PPF = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	self.range = PPF.Magnitude
	local initPos = self.Pos
	if self.started == nil then
		initPos = self.Pos - (PPF - (PPF.Normalized * self.pixelRatio))
		self.adjust = 2
	else
		self.adjust = 1
	end
	local oldPos = initPos
	local newPos = Vector(0, 0)
	for i = 0, (self.range / self.pixelRatio) * self.adjust do
		local dot = CreateMOPixel(self.beamPixelName)
		local angle = self.Vel.AbsRadAngle
		local aimVector = Vector(self.pixelRatio, 0):RadRotate(angle)
		dot.Pos = initPos + aimVector * i
		dot.Vel = Vector(math.random(0, 3), 0):RadRotate(math.random(0, math.pi * 2000) / 1000) + (self.Vel / 20)
		local endPos = Vector(0, 0)
		local randomRay = SceneMan:CastMORay(oldPos, aimVector, self.ID, self.Team, 128, false, 0)
		endPos = SceneMan:GetLastRayHitPos()
		local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
		if trueLength < aimVector.Magnitude then
			break
		end
		MovableMan:AddMO(dot)
		oldPos = dot.Pos
	end
	self.started = 1
end
