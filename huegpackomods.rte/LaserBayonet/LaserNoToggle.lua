function Create(self)
	self.range = 500 -- pointer range in pixels
	self.pixelRatio = 10 -- how many pixels to highlight, i.e. 4 for every 4th pixel, 5 for every 5th pixel...
	self.beamPixelName = "Tracer Particle" -- change this to the name of your own MOPixel, if you want
	self.useMuzzlePos = true -- whether or not to have the beam originate from the muzzle; if false then the guns position is used
	self.offsetVector = Vector(0, 0) -- the offset of the beam origin from the muzzle or gun center
	self.teamToIgnore = self.IgnoresWhichTeam -- the team you want the laser sight to ignore. Leave it as is to ignore own team mates, or set it to -2 to have it hit everyone.
end

function Update(self)
	self.owner = MovableMan:GetMOFromID(self.RootID)
	if self.owner.ClassName ~= "HDFirearm" then
		local offsetNew = (self.offsetVector:GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
		local initPos = Vector(0, 0)
		if self.useMuzzlePos == true then
			initPos = self.MuzzlePos + offsetNew
		else
			initPos = self.Pos + offsetNew
		end
		local oldPos = initPos
		local newPos = Vector(0, 0)
		for i = 0, self.range / self.pixelRatio do
			local dot = CreateMOPixel(self.beamPixelName) -- this could be changed to CreateMOSParticle or whatever
			local aimVector = (Vector(self.pixelRatio, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
			dot.Pos = initPos + aimVector * i
			local endPos = Vector(0, 0)
			local randomRay = SceneMan:CastMORay(oldPos, aimVector, self.RootID, self.teamToIgnore, 0, false, 0)
			endPos = SceneMan:GetLastRayHitPos()
			local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true)
			if trueLength.Magnitude < aimVector.Magnitude then
				dot.Pos = endPos - trueLength.Normalized
				MovableMan:AddMO(dot)
				break
			end
			MovableMan:AddMO(dot)
			oldPos = dot.Pos
		end
	end
end
