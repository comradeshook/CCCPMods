function Create(self)
	--Keep track of how long it should be before healing people.
	self.healTimer = Timer()
	--Interval between healings, in milliseconds.
	self.healInterval = 100
end

function Update(self)
	--Heal every interval.
	if self.healTimer:IsPastSimMS(self.healInterval) then
		--Cycle through all actors.
		for MO in MovableMan:GetMOsInRadius(self.Pos, 150, self.Team, true) do
			if IsActor(MO:GetRootParent()) == true and MO:GetRootParent().UniqueID ~= self.UniqueID then
				local actor = ToActor(MO:GetRootParent());
				actor.Health = actor.Health - 100
			end
		end
		--Reset the healing timer.
		self.healTimer:Reset()
	end
end
