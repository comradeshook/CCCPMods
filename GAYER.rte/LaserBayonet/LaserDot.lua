function Create(self)
	self.range = self.Sharpness -- pointer range in pixels
	self.beamPixelName = "Tracer Particle" -- change this to the name of your own MOPixel, if you want
	self.useMuzzlePos = false -- whether or not to have the beam originate from the muzzle; if false then the guns position is used, if it isn't a gun then it should be false
	self.offsetVector = Vector(0, 0) -- the offset of the beam origin from the muzzle or gun center
	self.teamToIgnore = self.Team -- the team you want the laser sight to ignore. Leave it as is to ignore own team mates, or set it to -2 to have it hit everyone.
end

function Update(self)
	local offsetNew = (self.offsetVector:GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
	local initPos = Vector(0, 0)
	if self.useMuzzlePos == true then
		initPos = self.MuzzlePos + offsetNew
	else
		initPos = self.Pos + offsetNew
	end
	local dot = CreateMOPixel(self.beamPixelName) -- this could be changed to CreateMOSParticle or whatever
	local aimVector = (Vector(self.range, 0):GetXFlipped(self.HFlipped)):RadRotate(self.RotAngle)
	local endPos = Vector(0, 0)
	local randomRay = SceneMan:CastMORay(initPos, aimVector, self.RootID, self.teamToIgnore, 0, false, 0)
	endPos = SceneMan:GetLastRayHitPos()
	local trueLength = SceneMan:ShortestDistance(initPos, endPos, true)
	if trueLength.Magnitude < aimVector.Magnitude then
		dot.Pos = endPos - trueLength.Normalized * 2
		MovableMan:AddMO(dot)
	end
end
