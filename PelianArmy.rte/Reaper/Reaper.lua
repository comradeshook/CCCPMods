function Create(self)
	self.range = 500
	self.pixelRatio = 3
	self.beamPixelName = "Yellow Glow Tiny"
end

function Update(self)
	if self.Magazine ~= nil then
		if self:IsActivated() and self.RootID ~= self.ID and self.Magazine.RoundCount > 0 then
			local initPos = Vector(0, 0)
			initPos = self.MuzzlePos
			local oldPos = initPos
			local newPos = Vector(0, 0)
			for i = 0, self.range / self.pixelRatio do
				if i == 0 then
					local start = CreateMOPixel("End Glow")
					start.Pos = self.MuzzlePos
					MovableMan:AddMO(start)
				end
				local dot = CreateMOPixel(self.beamPixelName)
				local aimVector = (Vector(self.pixelRatio, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
				dot.Pos = initPos + aimVector * i
				local endPos = Vector(0, 0)
				local randomRay = SceneMan:CastMORay(oldPos, aimVector, self.RootID, self.Team, 0, false, 0)
				endPos = SceneMan:GetLastRayHitPos()
				local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
				if trueLength < aimVector.Magnitude then
					local mortar = CreateMOPixel("Laser Hurt")
					mortar.Pos = endPos
					mortar.Vel = (Vector(45, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
					MovableMan:AddMO(mortar)
					local hit = CreateMOPixel("End Glow")
					hit.Pos = endPos
					MovableMan:AddMO(hit)
					local sound = CreateMOSRotating("Blasta")
					sound.Pos = endPos
					MovableMan:AddMO(sound)
					sound:GibThis()
					break
				end
				MovableMan:AddMO(dot)
				oldPos = dot.Pos
			end
		end
	end
end
