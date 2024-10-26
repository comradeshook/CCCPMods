function Update(self)
	local endPos = Vector(0, 0)
	local downLength = SceneMan:CastObstacleRay(
		Vector(self.Pos.X, 0),
		Vector(0, 2000),
		Vector(0, 0),
		endPos,
		self.ID,
		-2,
		0,
		0
	)
	self.Pos = endPos
end
