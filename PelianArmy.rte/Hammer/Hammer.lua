function Create(self)
	self.fireTimer = Timer()
	self.shotCount = 4
	self.pixelRatio = 4
	self.beamPixelName = "White Dot"
	self.useMuzzlePos = true
	self.offsetVector = Vector(0, 0)
end

function Update(self)
	if self.Magazine ~= nil and self.RootID ~= self.ID then
		local fireDelay = ((self.RateOfFire / 60) ^ -1) * 1000
		if self:IsActivated() and self.Magazine.RoundCount > 0 and self.fireTimer:IsPastSimMS(fireDelay) then
			self.fireTimer:Reset()
			local bulletVel = (Vector(355, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle) + self.Vel
			local PPF = bulletVel * (GetPPM() * TimerMan.DeltaTimeSecs)
			for i = 1, self.shotCount do
				local boolit = CreateMOPixel("Particle Hammer Short")
				boolit.Pos = self.MuzzlePos
				boolit.Vel = bulletVel
				boolit:SetWhichMOToNotHit(MovableMan:GetMOFromID(self.RootID), -1)
				MovableMan:AddMO(boolit)
			end
			self.range = PPF.Magnitude
			local offsetNew = (self.offsetVector:GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
			local initPos = Vector(0, 0)
			if self.useMuzzlePos == true then
				initPos = self.MuzzlePos + offsetNew
			else
				initPos = self.Pos + offsetNew
			end
			local oldPos = initPos
			local newPos = Vector(0, 0)
			for i = 0, self.range / self.pixelRatio do
				local dot = CreateMOPixel(self.beamPixelName) -- this could be changed to CreateMOSParticle or whatever
				local aimVector = (Vector(self.pixelRatio, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
				dot.Pos = initPos + aimVector * i
				dot.Vel = Vector(math.random(0, 3), 0):RadRotate(math.random(0, math.pi * 2000) / 1000)
					+ (bulletVel / 20)
				local endPos = Vector(0, 0)
				local randomRay = SceneMan:CastMORay(
					oldPos,
					aimVector,
					self.RootID,
					self.IgnoresWhichTeam,
					128,
					false,
					0
				)
				endPos = SceneMan:GetLastRayHitPos()
				local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
				if trueLength < aimVector.Magnitude then
					break
				end
				MovableMan:AddMO(dot)
				oldPos = dot.Pos
			end
		end
	else
		self.fireTimer:Reset()
	end
end
