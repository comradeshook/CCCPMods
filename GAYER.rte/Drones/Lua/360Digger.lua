function Create(self)
	--create a timer
	self.shottimer = Timer()
end

function Update(self)
	--if LMB/fire button is pressed
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		--delay between shots (MS)
		if self.shottimer:IsPastSimMS(15) == true then
			--define what's going to be created
			emitter = CreateAEmitter("360 Digger Fire")
			--if the drone isn't flipped, put it on one side
			if self.HFlipped == false then
				--offsets relative to the scene; positive X is always right and positive Y is always down
				emitter.Pos = self.Pos + (self.Vel / 3)
				--self explanatory, though you can always customize it if the angle isn't right. in radians
				emitter.RotAngle = self.RotAngle

				--if it is flipped, then change the offsets
			else
				--same thing for offsets, just negative X
				emitter.Pos = self.Pos + (self.Vel / 3)
				--I am not sure if you'll need the +math.pi, but you probably will. to change the angle just add a small number, or do + (math.pi / whatever)
				emitter.RotAngle = self.RotAngle + math.pi
			end
			--add the particle
			MovableMan:AddParticle(emitter)
			--reset the shot delay
			self.shottimer:Reset()
		end
	end
end
