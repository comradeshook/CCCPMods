function Create(self)
	--create a timer
	self.shottimer = Timer()
end

function Update(self)
	--if LMB/fire button is pressed
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		--delay between shots (MS)
		if self.shottimer:IsPastSimMS(10) == true then
			--define what's going to be created
			if self.HFlipped == false then
				emitter = CreateAEmitter("Heavy Concrete Fire Right")
			else
				emitter = CreateAEmitter("Heavy Concrete Fire Left")
			end
			--offsets relative to the scene; positive X is always right and positive Y is always down
			emitter.Pos = self.Pos + (self.Vel / 3)
			--self explanatory, though you can always customize it if the angle isn't right. in radians
			emitter.RotAngle = self.RotAngle
			--add the particle
			MovableMan:AddParticle(emitter)
			--reset the shot delay
			self.shottimer:Reset()
		end
	end
end
