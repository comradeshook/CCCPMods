function Create(self)
	self.range = Vector(self.Vel.X, self.Vel.Y)/5;
	self.colour = 166;
	self.penetration = math.random(30, 400);
end

function Update(self)
		local hitPos = Vector(0, 0);
		local terrainFound = SceneMan:CastNotMaterialRay(self.Pos, self.range, 0, hitPos, 0, false);
		if (terrainFound) then
			local material = SceneMan:GetMaterialFromID(SceneMan:GetTerrMatter(hitPos.X, hitPos.Y));
			PrimitiveMan:DrawCircleFillPrimitive(hitPos, 3, self.colour);
			PrimitiveMan:DrawLinePrimitive(hitPos, hitPos - self.range:SetMagnitude(8), self.colour);
			if (material.StructuralIntegrity <= self.penetration) then
				local delet = CreateMOSRotating("Donk Tunneller Deletion", "Donks.rte");
				delet.Pos = hitPos;
				delet.RotAngle = self.range.AbsRadAngle;
				MovableMan:AddMO(delet);
			end
		end
end