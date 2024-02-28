function getRandomActor(user, teamToIgnore, ignoreBrainChance, ignoresHealthy, maxRange) --team values below 0 means EVERYONE is targeted; ignoreBrainChance is 0-1
	local potentialVictimsOfCommunism = {}
	local actorsFound = 0

	for actor in MovableMan.Actors do
		if actor.UniqueID ~= user.UniqueID then -- splitting up the "if" here because it's huge
			if not ignoresHealthy or actor.WoundCount > 0 then
				if actor.Team ~= teamToIgnore or teamToIgnore < 0 then
					if actor.ClassName == "Actor" or actor.ClassName == "AHuman" or actor.ClassName == "ACrab" then
						if actor:HasObjectInGroup("Brains") == false or math.random() > ignoreBrainChance then
							if
								SceneMan:ShortestDistance(user.Pos, actor.Pos, true).Magnitude <= maxRange
								or maxRange < 0
							then
								potentialVictimsOfCommunism[actorsFound] = actor
								actorsFound = actorsFound + 1
							end
						end
					end
				end
			end
		end
	end

	local target = nil

	if actorsFound > 0 then
		target = potentialVictimsOfCommunism[math.random(0, actorsFound - 1)]
	end

	if MovableMan:ValidMO(target) then
		return target
	else
		return nil
	end
end

function getRandomLimb(target) --Includes torso!
	local actorLimbTable = {}
	local limbsFound = 0
	for limb in target.Attachables do
		if limb:GetEntryWoundPresetName() ~= "" then
			actorLimbTable[limbsFound] = limb
			limbsFound = limbsFound + 1
		end
	end

	local randomLimb = math.random(0, limbsFound)
	local actorLimb = nil

	if randomLimb == limbsFound then
		actorLimb = target
	else
		actorLimb = actorLimbTable[randomLimb]
	end

	return actorLimb
end

function transferWound(fromActor, toMO) --in this version, not gonna bother removing from specific limbs
	local woundPreset = toMO:GetEntryWoundPresetName()
	if woundPreset ~= "" then
		local wound = CreateAEmitter(woundPreset)
		local woundPos = Vector(math.random(-3, 3), math.random(-3, 3))
		wound.HFlipped = toMO.HFlipped
		ToMOSRotating(toMO):AddWound(wound, woundPos, true)

		fromActor.Health = fromActor.Health + ToActor(fromActor):RemoveWounds(1)
	end
end

function Update(self)
	if self.effectInterval == nil then
		self.user = self:GetRootParent()
		self.effectTimer = Timer()
		self.effectInterval = 200 -- milliseconds
		self.effectRange = 300 -- pixel radius
	end

	self.communismRating = ToMOSRotating(self):GetNumberValue("LPOS_Communism")

	if self.effectTimer:IsPastSimMS(self.effectInterval) then
		if self.communismRating > 0 then
			self.communismRating = self.communismRating - (self.effectInterval / 1000)
			ToMOSRotating(self):SetNumberValue("LPOS_Communism", self.communismRating)

			if self.WoundCount > 0 then
				local target = getRandomActor(self, self.Team, 1, false, self.effectRange)

				if target then
					local targetLimb = getRandomLimb(target)
					if targetLimb then
						transferWound(self, targetLimb)
					end
				end
			end
		else
			local target = getRandomActor(self, -1, 0, true, self.effectRange)
			if target then
				local targetLimb = getRandomLimb(self)
				if targetLimb then
					transferWound(target, targetLimb)
				end
			end
		end

		self.effectTimer:Reset()
	end

	if not self.upArrow then
		self.upArrow = CreateMOSParticle("Sonke Arrow")
	end

	if not self.downArrow then
		self.downArrow = CreateMOSParticle("Sonke Arrow Down")
	end

	if self.communismRating > 0 then
		PrimitiveMan:DrawBitmapPrimitive(self.Pos + Vector(15, -20), self.upArrow, 0, 0, false, false)
	else
		PrimitiveMan:DrawBitmapPrimitive(self.Pos + Vector(15, -20), self.downArrow, 0, 0, false, false)
	end
end
