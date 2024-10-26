function Create(self)
	self.fireVel = 20
	self.Sharpness = 0
end

function Update(self)
	if self.Magazine ~= nil and self.RootID ~= self.ID then
		local initPos = self.MuzzlePos
		local oldPos = initPos
		local newPos = Vector(0, 0)
		local gravity = SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs
		if self.HFlipped == false then
			self.angle = self.RotAngle
		else
			self.angle = self.RotAngle + math.pi
		end
		for i = 1, 200 do
			local dot = CreateMOPixel("Tracer Particle")
			local aimVector = Vector(self.fireVel, 0):RadRotate(self.angle) + (gravity * i)
			newPos = newPos + (aimVector / 3)
			local dotPos = initPos + newPos;
			SceneMan:WrapPosition(dotPos);
			dot.Pos = dotPos;
			local endPos = oldPos + aimVector;
			if i > 2 then
				local randomRay = SceneMan:CastMORay(oldPos, aimVector, dot.ID, self.Team, 0, false, 0)
				endPos = SceneMan:GetLastRayHitPos()
				local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
				if trueLength < aimVector.Magnitude then
					break
				end
			end
			MovableMan:AddMO(dot)
			oldPos = dot.Pos
		end
	end
	if self.Sharpness > 0 and self.RootID ~= self.ID then
		if self.Sharpness == 1 then
			self:SetNextMagazineName("Magazine Lobber")
		elseif self.Sharpness == 2 then
			self:SetNextMagazineName("Magazine Lobber-P")
		elseif self.Sharpness == 3 then
			self:SetNextMagazineName("Magazine Lobber-N")
		end
		self:Reload()
		self.Sharpness = 0
	end
end
