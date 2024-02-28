function Update(self)
	local radius = math.random(4, 6)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, radius + 3, 198)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, radius, 177)

	if self.ToDelete then
		PrimitiveMan:DrawCircleFillPrimitive(self.Pos, 30, 177)
	end
end
