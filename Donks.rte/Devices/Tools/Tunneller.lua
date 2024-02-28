function Create(self)
	self.range = Vector(55, 0);
	self.colour = 166;
end

function OnFire(self)
	for i = 1, 6, 1 do
		local penetration = math.random(30*30, 400*400);
		local hitPos = Vector(0, 0);
		local fireVector = self.range:GetXFlipped(self.HFlipped):GetRadRotatedCopy(self.RotAngle + math.rad(math.random(-37, 37)));
		local terrainFound = SceneMan:CastNotMaterialRay(self.MuzzlePos, fireVector, 0, hitPos, 0, false);
		if (terrainFound) then
			local material = SceneMan:GetMaterialFromID(SceneMan:GetTerrMatter(hitPos.X, hitPos.Y));
			PrimitiveMan:DrawCircleFillPrimitive(hitPos, 3, self.colour);
			PrimitiveMan:DrawLinePrimitive(hitPos, hitPos - fireVector:SetMagnitude(8), self.colour);
			if (material.StructuralIntegrity*material.StructuralIntegrity <= penetration) then
				local delet = CreateMOSRotating("Donk Tunneller Deletion", "Donks.rte");
				delet.Pos = hitPos;
				delet.RotAngle = fireVector.AbsRadAngle;
				MovableMan:AddMO(delet);
			end
		end
	end
end