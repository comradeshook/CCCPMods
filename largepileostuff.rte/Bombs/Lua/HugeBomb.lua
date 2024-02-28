function Create(self)
	self.blastRadius = self:GetNumberValue("BombGibRadius")
	self.subBlasts = self:GetNumberValue("BombGibCount")
end

function Destroy(self)
	for i = 1, self.subBlasts do
		local distance = math.random(0, self.blastRadius)
		local angle = math.rad(math.random() * 360)
		local spawnVector = Vector(distance, 0):RadRotate(angle)
		local endPos = Vector(self.Pos.X, self.Pos.Y)
		local checkRay = SceneMan:CastObstacleRay(self.Pos, spawnVector, Vector(0, 0), endPos, self.ID, -2, 0, 1)
		local blast = CreateAEmitter("Huge Bomb Boom")
		blast.Pos = endPos
		MovableMan:AddMO(blast)
	end
end
