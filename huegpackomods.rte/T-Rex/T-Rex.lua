package.path = package.path .. string.format(";Mods/huegpackomods.rte/Fx/?.lua")
require("MegaGib")

function Create(self)
	self.Harmless = 0
	self.owner = nil
	local uber = string.find(self.PresetName, "Uber")
	function floop()
		local selfTotalVel = self.Vel.Magnitude
		if self.Harmless ~= 1 then
			local startRayPos = self.Pos + (self.Vel / 12)
			local rayVector = self.Vel / -3
			local pointed = MovableMan:GetMOFromID(
				SceneMan:CastMORay(startRayPos, rayVector, self.ID, self.Team, 0, true, 1)
			)
			local actorList = {}
			if pointed ~= nil then
				local actorCount = 0
				while pointed do
					actorList[actorCount] = MovableMan:GetMOFromID(pointed.RootID)
					actorCount = actorCount + 1
					local ignoreID = pointed.RootID
					local lastHit = SceneMan:GetLastRayHitPos()
					local newVec = Vector(rayVector.X, rayVector.Y):SetMagnitude(
						rayVector.Magnitude - SceneMan:ShortestDistance(startRayPos, lastHit, true).Magnitude
					)
					pointed = MovableMan:GetMOFromID(
						SceneMan:CastMORay(lastHit, newVec, ignoreID, self.Team, 0, true, 1)
					)
				end

				for i = 0, actorCount - 1, 1 do
					local actor = actorList[i]
					if
						uber
						or (actor.ClassName ~= "ACRocket" and actor.ClassName ~= "ACDropShip" and actor.Radius < 35)
					then
						if actor.PresetName == "Reflective Robot MK-II" then
							actor.Vel = self.Vel * (self.Mass / actor.Mass)
							self.Vel = self.Vel * -1
							self.owner = actor
							self.blorgemitter = CreateAEmitter("Plink")
							self.blorgemitter.Pos.X = actor.Pos.X
							self.blorgemitter.Pos.Y = self.Pos.Y
							if self.Vel.X > 0 then
								self.blorgemitter.RotAngle = math.atan(self.Vel.Y / self.Vel.X)
							else
								self.blorgemitter.RotAngle = math.atan(self.Vel.Y / self.Vel.X) + math.pi
							end
							MovableMan:AddParticle(self.blorgemitter)
						else
							absolutelyFuckingGib(actor, (self.Vel / 5))
							if not uber then
								self.Vel = self.Vel * 0.8
							end
						end
					else
						actor.Vel.X = actor.Vel.X + (self.Vel.X / 20)
						actor.Vel.Y = actor.Vel.Y + (self.Vel.Y / 20)
						self.Pos = self.Pos - (self.Vel / 6)
						self.HitsMOs = true
						self.Harmless = 1
					end
				end
			end
		end
	end
	floop()
	if self.owner == nil then
		self.owner = self
	end
end

function Update(self)
	floop()
end
