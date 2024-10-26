function Create(self)
	self.range = 1000
	self.pixelRatio = 4
	self.beamPixelName = "Red Glow"
end

function Update(self)
	if self.Magazine ~= nil then
		if self:IsActivated() and self.RootID ~= self.ID and self.Magazine.RoundCount > 0 then
			local initPos = Vector(0, 0)
			initPos = self.MuzzlePos
			local oldPos = initPos
			local newPos = Vector(0, 0)
			for i = 0, self.range / self.pixelRatio do
				local dot = CreateMOPixel(self.beamPixelName)
				local aimVector = (Vector(self.pixelRatio, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
				dot.Pos = initPos + aimVector * i
				local endPos = Vector(0, 0)
				local randomRay = SceneMan:CastMORay(oldPos, aimVector, self.RootID, self.IgnoresWhichTeam, 0, false, 0)
				endPos = SceneMan:GetLastRayHitPos()
				local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
				if trueLength < aimVector.Magnitude then
					for i = 1, 2 do
						local impact = CreateMOPixel("Crosshair")
						impact.Pos = endPos
						impact.Vel = Vector(0, 0)
						MovableMan:AddMO(impact)
					end
					local mortar = CreateAEmitter("Mortar Launcher")
					mortar.Pos = Vector(endPos.X, -10)
					mortar.Vel = Vector(0, 0)
					MovableMan:AddMO(mortar)
					break
				end
				MovableMan:AddMO(dot)
				oldPos = dot.Pos
			end
		end
	end
end
