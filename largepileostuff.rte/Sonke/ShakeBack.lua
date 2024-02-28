package.path = package.path .. string.format(";largepileostuff.rte/?.lua")
require("MegaGib")

function Update(self)
	if not self.counterShakeSound then
		self.maxShake = 5
		self.counterShakeSound = CreateSoundContainer("Sonke Shake", "largepileostuff.rte")
		self.counterShakeSound.Volume = 1.5
	end

	self.shakeFrames = ToMOSRotating(self):GetNumberValue("LPOS_ShakeFrames")

	if self.shakeFrames > 0 then
		if self.uhohTimer == nil then
			self.uhohTimer = Timer()
		end

		if self.uhohTimer:IsPastSimMS(1000) then
			self.Pos = self.Pos + Vector(math.random(0, self.maxShake), 0):RadRotate(math.rad(180) * math.random())
			self.shakeFrames = self.shakeFrames - 1
			self:SetNumberValue("LPOS_ShakeFrames", self.shakeFrames)
			self.counterShakeSound.Pos = self.Pos
			self.counterShakeSound.Pitch = 1.2
			if not self.counterShakeSound:IsBeingPlayed() then
				self.counterShakeSound:Play()
			end
		end
	end

	if self.shakeFrames <= 0 then
		if self.uhohTimer then
			self.uhohTimer = nil
		end

		if self.counterShakeSound:IsBeingPlayed() then
			self.counterShakeSound:Stop()
		end

		if ToMOSRotating(self):GetNumberValue("AngeredCommunism") == 1 then
			absolutelyFuckingGib(self, Vector(0, 0))
		end
	end
end
