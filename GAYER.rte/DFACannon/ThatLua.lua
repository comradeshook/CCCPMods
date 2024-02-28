function Create(self)
	self.checkBox = self.BoundingBox;
	self.checkBox.Width = 100;
	self.checkBox.Height = 500;
end

function Update(self)
	self.checkBox.Center = self.Pos + Vector(0, self.checkBox.Height/2);
	local dropBomb = false;
	
	for bawks in SceneMan:WrapBox(self.checkBox) do
		if dropBomb == false then
			for MO in MovableMan:GetMOsInBox(self.checkBox, self.Team, true) do
				if dropBomb == false and MovableMan:IsActor(MO:GetRootParent()) and not SceneMan:CastStrengthRay(self.Pos, SceneMan:ShortestDistance(self.Pos, MO.Pos, true), 6, Vector(0, 0), 3, 0, true) then
					dropBomb = true;
				end
			end
		end
	end
	
	if dropBomb then
		local emitter = CreateAEmitter("That Dropper")
		emitter.Pos.X = self.Pos.X
		emitter.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(emitter)
	end
end
