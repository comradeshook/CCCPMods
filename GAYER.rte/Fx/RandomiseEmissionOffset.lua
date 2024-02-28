function Create(self)
	self.emissionPosRangeX = { -50, 50 } -- Min/Max horizontal distance from center
	self.emissionPosRangeY = { -50, 50 } -- Min/Max vertical distance from center
end

function Update(self)
	for emission in self.Emissions do
		emission.Offset = Vector(
			math.random(self.emissionPosRangeX[1], self.emissionPosRangeX[2]),
			math.random(self.emissionPosRangeY[1], self.emissionPosRangeY[2])
		)
	end
end
