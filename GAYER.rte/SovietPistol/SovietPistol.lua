function Create(self)
	-- iterate through all the MOs within 400 pixels of self:
	for i = 1, MovableMan:GetMOIDCount() - 1, 1 do
		self.target = MovableMan:GetMOFromID(i)
		if self.ID ~= i and (self.target.Pos - self.Pos).Magnitude < 50 and self.Harmless ~= 1 then
			--use CastMORay to find out if there are no obstacles between self and target:
			self.pointed = MovableMan:GetMOFromID(
				SceneMan:CastMORay(self.Pos, (self.Vel / -1), self.ID, -2, 0, true, 1)
			)
			if self.pointed ~= nil then
				if self.pointed.RootID == self.target.RootID then
					if self.target:HasObject("Soviet Pistol") == true and self.target.ClassName == "AHuman" then
						local speed = 50
						local angle = math.atan(self.Vel.Y / self.Vel.X)
						local yVel = math.sin(angle) * speed
						local xVel = math.cos(angle) * speed
						self.target.Pos.Y = self.target.Pos.Y - 5
						if self.Vel.X < 0 then
							self.target.Vel.Y = -yVel
							self.target.Vel.X = -xVel
							self.target.AngularVel = 10
						elseif self.Vel.X >= 0 then
							self.target.Vel.Y = yVel
							self.target.Vel.X = xVel
							self.target.AngularVel = -10
						end
					end
				end
			end
		end
	end
end
