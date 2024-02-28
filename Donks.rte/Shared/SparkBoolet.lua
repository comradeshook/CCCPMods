function Create(self)
	self.flashColour = 166;
	self.secondaryColour = 5;
	self.drawRadius = 1;
	self.HitsMOs = false;
end

function lightningTrail(startPos, direction, velMag, colour, itersLeft)
	local length = math.min(math.random(3, 6), velMag/3);
	local pieceVector = Vector(length, math.random(-1, 1));
	
	if (math.random() < 0.2 and pieceVector.Y ~= 0 and itersLeft > 0) then
		lightningTrail(startPos, direction + pieceVector.Y/2, velMag, colour, math.random(0, 1));
	end
	
	pieceVector = pieceVector:RadRotate(direction);
	PrimitiveMan:DrawLinePrimitive(startPos, startPos + pieceVector, colour);
	if (itersLeft > 0) then
		lightningTrail(startPos + pieceVector, direction, velMag, colour, itersLeft - 1);
	end
end

function hitCheck(self, startPos)
	local hitRay = SceneMan:CastMORay(startPos, self.Vel/3, self.ID, self.Team, 128, false, 0);
	local hitPos = self.Pos;
	if (hitRay ~= 255) then
		hitPos = SceneMan:GetLastRayHitPos();
		local impact = CreateAEmitter("Spark Bullet Impact", "Donks.rte");
		impact.Pos = hitPos;
		impact.RotAngle = self.Vel.AbsRadAngle;
		MovableMan:AddMO(impact);
		self.Pos = hitPos;
		self.ToDelete = true;
		
		return true;
	else
		return false;
	end
end

function Update(self)
	if (self.ToDelete == false) then
		hitCheck(self, self.Pos - self.Vel/3);
	end
	
	self.iters = math.floor((self.Vel.Magnitude/9)/6);
	if (self.ToDelete == false) then
		local triVector = Vector(0, self.drawRadius):GetRadRotatedCopy(self.Vel.AbsRadAngle);
		PrimitiveMan:DrawTriangleFillPrimitive(self.Pos + triVector, self.Pos - triVector, self.Pos - (self.Vel/9), self.secondaryColour)
		lightningTrail(self.Pos - (self.Vel/9), self.Vel.AbsRadAngle + math.pi, self.Vel.Magnitude, self.secondaryColour, self.iters);
		PrimitiveMan:DrawCircleFillPrimitive(self.Pos, 1, self.flashColour)
	end
end