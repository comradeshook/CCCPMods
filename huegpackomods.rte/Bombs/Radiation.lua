function Create(self)
	--Keep track of how long it should be before healing people.
	self.healTimer = Timer()
	--Interval between healings, in milliseconds.
	self.healInterval = 400
	--Heal counter.
	self.healnum = 0
	self.radiationRadius = 150
	self.radiationTimer = { Timer(), Timer(), Timer() }
	self.radiationInterval = { 40, 105, 125 }
	self.radiationParticle = { "Nuke Radiation Tiny", "Nuke Radiation Smol", "Nuke Radiation Streak" }
end

function Update(self)
	--Heal every interval.
	if self.healTimer:IsPastSimMS(self.healInterval) then
		--Cycle through all actors.
		
		for MO in MovableMan:GetMOsInRadius(self.Pos, self.radiationRadius, -1, true) do
			if IsAHuman(MO) or IsACrab(MO) then
				local actor = ToActor(MO);
				local distVec = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
				if not SceneMan:CastStrengthRay(self.Pos, distVec, 6, Vector(0, 0), 3, 0, true) then
					actor.Health = actor.Health - 1
				end
			end
		end
		--Reset the healing timer.
		self.healTimer:Reset()
	end

	for i = 1, 3, 1 do
		if self.radiationTimer[i]:IsPastSimMS(self.radiationInterval[i]) then
			local targetPos = Vector(
				math.random(-self.radiationRadius, self.radiationRadius),
				math.random(-self.radiationRadius, self.radiationRadius)
			)
			while targetPos:MagnitudeIsGreaterThan(self.radiationRadius) do
				targetPos = Vector(
					math.random(-self.radiationRadius, self.radiationRadius),
					math.random(-self.radiationRadius, self.radiationRadius)
				)
			end

			if not SceneMan:CastStrengthRay(self.Pos, targetPos, 6, Vector(0, 0), 3, 0, true) then
				local particle = CreateMOPixel(self.radiationParticle[i], "huegpackomods.rte")
				particle.Pos = Vector(self.Pos.X + targetPos.X, self.Pos.Y + targetPos.Y)
				particle.Vel = Vector(math.random(30, 60), 0):RadRotate(math.rad(math.random() * 360))
				MovableMan:AddMO(particle)
			end

			self.radiationTimer[i]:Reset()
		end
	end

	local rayAngle = math.rad(math.random() * 360)
	local edgePos = Vector(self.radiationRadius, 0):RadRotate(rayAngle)
	if not SceneMan:CastStrengthRay(self.Pos, edgePos, 6, Vector(0, 0), 3, 0, true) then
		local particle = CreateMOPixel("Nuke Radiation Streak", "huegpackomods.rte")
		particle.Pos = Vector(self.Pos.X + edgePos.X, self.Pos.Y + edgePos.Y)
		particle.Vel = Vector(-9 + 18 * math.random(0, 1), 0):RadRotate(rayAngle + math.rad(90))
		MovableMan:AddMO(particle)
	end
end
