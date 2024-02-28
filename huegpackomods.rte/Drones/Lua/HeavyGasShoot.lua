function Create(self)
	--create a timer
	self.shottimer = Timer()
	self.damageTimer = Timer()
	self.damageInterval = 100
	self.fireAngle = math.rad(-22)
	self.fireSpread = 0.2
	self.fireRange = 35 * 0.2 * GetPPM()
end

function Update(self)
	--if LMB/fire button is pressed
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		local startPos = Vector(self.Pos.X, self.Pos.Y) + (self.Vel / 3)
		--delay between shots (MS)
		if self.shottimer:IsPastSimMS(15) == true then
			--define what's going to be created
			local emitter = nil
			if self.HFlipped == false then
				emitter = CreateAEmitter("Heavy Gas Shoot Right")
			else
				emitter = CreateAEmitter("Heavy Gas Shoot Left")
			end
			--offsets relative to the scene; positive X is always right and positive Y is always down
			emitter.Pos = startPos
			--self explanatory, though you can always customize it if the angle isn't right. in radians
			emitter.RotAngle = self.RotAngle
			--add the particle
			MovableMan:AddParticle(emitter)
			--reset the shot delay
			self.shottimer:Reset()
		end

		if self.damageTimer:IsPastSimMS(self.damageInterval) then
			for MO in MovableMan:GetMOsInRadius(self.Pos, self.fireRange, self.Team, true) do
				if IsActor(MO) == true then
					local actor = ToActor(MO);
					if not IsACRocket(actor) and not IsACDropShip(actor) and actor.ID ~= self.ID then
						local targetPos = actor.Pos
						if IsAHuman(actor) and ToAHuman(actor).Head then
							targetPos = ToAHuman(actor).Head.Pos
						end
						local distVector = SceneMan:ShortestDistance(startPos, targetPos, true)
						if
							distVector.X * self.FlipFactor > 0
							and not SceneMan:CastStrengthRay(startPos, distVector, 6, Vector(0, 0), 3, 0, true)
						then
							local gunAngle = (self.RotAngle + math.rad(180) * math.max(0, -self.FlipFactor))
								+ self.fireAngle * self.FlipFactor
							if gunAngle >= math.rad(360) then
								gunAngle = gunAngle - math.rad(360)
							elseif gunAngle < 0 then
								gunAngle = gunAngle + math.rad(360)
							end

							local angleDiff = distVector.AbsRadAngle - gunAngle
							if angleDiff < math.rad(-360) then
								angleDiff = angleDiff + math.rad(360)
							end

							if math.abs(angleDiff) < self.fireSpread then
								actor.Health = actor.Health - (8 + math.random(0, 4))
							end
						end
					end
				end
			end
			self.damageTimer:Reset()
		end
	end
end
