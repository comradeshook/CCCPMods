function Create(self)
	--Keep track of how long it should be before healing people.
	self.healTimer = Timer()
	--Interval between healings, in milliseconds.
	self.healInterval = 100
	--Heal counter.
	self.healnum = 0
end

function Update(self)
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		self:GibThis()
	end
	--Heal every interval.
	if self.healTimer:IsPastSimMS(self.healInterval) then
		--Cycle through all actors.
		for MO in MovableMan:GetMOsInRadius(self.Pos, 40, self.Team, true) do
			--If the actor is on the right team, has less than 100 health and is not the healer, continue with code.
			if (IsAHuman(MO) == true or IsACrab(MO) == true) and MO.UniqueID ~= self.UniqueID then
				local actor = ToActor(MO);
				--Trigonometry to find how far the actor is.
				local distVec = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
				if not SceneMan:CastStrengthRay(self.Pos, distVec, 6, Vector(0, 0), 3, 0, true) then
					--If the actor is fairly close, heal them!
					actor.Health = actor.Health - math.random(2)
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
