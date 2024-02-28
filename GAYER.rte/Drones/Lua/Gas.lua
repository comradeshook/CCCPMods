function Create(self)
	--Keep track of how long it should be before healing people.
	self.healTimer = Timer()
	--Interval between healings, in milliseconds.
	self.healInterval = 100
	--Heal counter.
	self.healnum = 0
end

function Update(self)
	--Heal every interval.
	if self.healTimer:IsPastSimMS(self.healInterval) then
		--Cycle through all actors.
		for MO in MovableMan:GetMOsInRadius(self.Pos, 40, self.Team, true) do
			if IsActor(MO) == true then
				local actor = ToActor(MO);
				--If the actor is on the right team, has less than 100 health and is not the healer, continue with code.
				if (IsAHuman(actor) == true or IsACrab(actor) == true) and actor.UniqueID ~= self.UniqueID then
					local distVec = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
					if not SceneMan:CastStrengthRay(self.Pos, distVec, 6, Vector(0, 0), 3, 0, true) then
						actor.Health = actor.Health - math.random(2)
					end
				end
			end
		end
		--Reset the healing timer.
		self.healTimer:Reset()
		--Increment the heal counter.
		self.healnum = self.healnum + 1
		--Reset it if it's gone too far.
		if self.healnum > 8 then
			self.healnum = 0
		end
	end
end
