function Create(self)
	--Keep track of how long it should be before healing people.
	healTimer = Timer()
	--Interval between healings, in milliseconds.
	healInterval = 150
	--Heal counter.
	self.healnum = 0
end

function Update(self)
	--Heal every interval.
	if healTimer:IsPastSimMS(healInterval) then
		--Cycle through all actors.
		for MO in MovableMan:GetMOsInRadius(self.Pos, 80, -1, true) do
			if IsActor(MO) == true and MO.Team == self.Team then
				local actor = ToActor(MO);
				if actor.Health < 100 and actor.UniqueID ~= self.UniqueID then
					actor.Health = actor.Health + 0.5
					--Every 8 health healed, put a little icon above the actor's head to show that it is indeed healing.
					if self.healnum == 8 then
						--Create the particle.
						local part = CreateMOSParticle("Particle Heal Effect")
						--Set the particle's position to just over the actor's head.
						part.Pos = actor.AboveHUDPos + Vector(0, 4)
						--Add the particle to the world.
						MovableMan:AddParticle(part)
					end
				end
			end
		end
		--Reset the healing timer.
		healTimer:Reset()
		--Increment the heal counter.
		self.healnum = self.healnum + 1
		--Reset it if it's gone too far.
		if self.healnum > 8 then
			self.healnum = 0
		end
	end
end
