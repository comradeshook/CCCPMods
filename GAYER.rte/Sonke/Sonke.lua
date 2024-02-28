function Create(self)
	self.idleStance = Vector(5, 5)
	self.drinkStance = Vector(10, -3)
	self.activeStance = Vector(12, 15)
	self.shakeOffset = Vector(0, -30)
	self.animTimer = Timer()
	self.shakeState = false
	self.retaliationFrames = 0
	self.pressure = 0
	self.maxPressure = 60
	self.autoShakePressure = 20
	self.sonkeDuration = 30 --Seconds
	self.full = true

	--Welp guess i'm doing it this way
	ToMOSRotating(self):SetNumberValue("Drinking", 0)
	self.drinking = ToMOSRotating(self):GetNumberValue("Drinking")

	self.wielder = nil
	self.shakeSound = CreateSoundContainer("Sonke Shake", "GAYER.rte")
	self.shakeSound.Volume = 1.5
	self.drinkSound = CreateSoundContainer("Sonke Drink", "GAYER.rte")
	self.drinkSound.Loops = 0
end

function retaliate(can)
	if not string.find(can.PresetName, "Empty") then
		if
			MovableMan:ValidMO(can.wielder) and (not can:IsActivated() and can.retaliationFrames > 0)
			or can.pressure > can.maxPressure
		then
			local existingShake = ToMOSRotating(can.wielder):GetNumberValue("LPOS_ShakeFrames")
			ToMOSRotating(can.wielder):SetNumberValue("LPOS_ShakeFrames", existingShake + can.retaliationFrames)
			if can.pressure > can.maxPressure then
				ToMOSRotating(can.wielder):SetNumberValue("AngeredCommunism", 1)
			end
			if not can.wielder:HasScript("GAYER.rte/Sonke/ShakeBack.lua") then
				can.wielder:AddScript("GAYER.rte/Sonke/ShakeBack.lua")
			end
			can.retaliationFrames = 0
		end
	end
end

function Update(self)
	if self:GetRootParent().UniqueID ~= self.UniqueID then
		self.wielder = self:GetRootParent()
	end

	------- auto-drink function, but it don't work right so i'm commenting it out for now
	--	if self.wielder and self.wielder:IsActor() and ToActor(self.wielder):IsPlayerControlled() == false and self.full then
	--		if self.pressure < 20 and ToAHuman(self.wielder).EquippedItem.UniqueID == self.UniqueID then
	--			self:Activate();
	--		else
	--			self:Deactivate();
	--			retaliate(self);
	--			Drink(ToActor(self.wielder));
	--		end
	--	end

	self.drinking = ToMOSRotating(self):GetNumberValue("Drinking")

	if self:IsActivated() and self.drinking == 0 then
		self.shakeSound.Pos = self.Pos
		if not self.shakeSound:IsBeingPlayed() then
			self.shakeSound:Play()
		end
		if self.animTimer:IsPastSimMS(50) then
			if self.full then
				self.pressure = self.pressure + 1
			end
			self.animTimer:Reset()
			if self.shakeState then
				self.StanceOffset = self.activeStance
				self.shakeState = false
			else
				self.StanceOffset = self.activeStance + self.shakeOffset
				self.shakeState = true
			end
		end
		self.retaliationFrames = self.retaliationFrames + 1
	else
		if self.shakeSound:IsBeingPlayed() then
			self.shakeSound:Stop()
		end
		self.StanceOffset = self.idleStance
	end

	retaliate(self)

	if self.full then
		if self.pressure > self.maxPressure then
			self.pressure = 0
			self:GibThis()
		end
	end

	if self.drinking == 1 then
		self.StanceOffset = self.drinkStance
		self.RotAngle = math.rad(90 * self.FlipFactor)

		if self.full then
			self.full = false
			self.animTimer:Reset()

			self.drinkSound.Pos = self.Pos
			self.drinkSound:Play()

			local communism = ToMOSRotating(self.wielder):GetNumberValue("LPOS_Communism")
			ToMOSRotating(self.wielder):SetNumberValue(
				"LPOS_Communism",
				communism + self.sonkeDuration * math.ceil(1 + (self.pressure / self.maxPressure))
			)
			if not self.wielder:HasScript("GAYER.rte/Sonke/Communism.lua") then
				self.wielder:AddScript("GAYER.rte/Sonke/Communism.lua")
			end
		end

		if self.animTimer:IsPastSimMS(500) then
			self.RotAngle = 0
			ToMOSRotating(self):SetNumberValue("Drinking", 0)
			self.PresetName = self.PresetName .. " (Empty)"
			self.animTimer:Reset()
			ToActor(self.wielder):GetController():SetState(Controller.WEAPON_DROP, true)
		end
	end
end

function Destroy(self)
	retaliate(self)
	self.shakeSound:Stop()
end

function Drink(actor)
	local sonke = ToAHuman(actor).EquippedItem
	if not string.find(sonke.PresetName, "Empty") then
		ToMOSRotating(sonke):SetNumberValue("Drinking", 1)
	end
end
