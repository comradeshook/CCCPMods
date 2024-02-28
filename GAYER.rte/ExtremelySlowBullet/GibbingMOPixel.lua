function SpawnGib(self)
	local hitPos = Vector(self.Pos.X, self.Pos.Y);
	local obstacleRay = SceneMan:CastObstacleRay(self.Pos, self.Vel/3, Vector(0,0), hitPos, self.ID, self.Team, 0, 0);
	local gib = CreateMOSRotating(self.PresetName .. " Gib");
	-- Default gib is an MOSRotating with the same PresetName as the MOPixel, with " Gib" appended
	-- e.g. "Particle SMG Gib", put gib effects on this MO
	gib.Pos = hitPos;
	gib.Vel = Vector(0, 0);
	gib.GibSound = CreateTDExplosive("Small Bomb", "GAYER.rte").GibSound;
	MovableMan:AddMO(gib);
	gib:GibThis();
	self.ToDelete = true;
	self.PinStrength = 999;
	self.Vel = Vector(0, 0);
	self.Pos.Y = -1000; -- Comment this out if you don't mind seeing bullets bounce off on the frame of collision
end

function OnCollideWithMO(self, collidedMO, collidedRootMO)
	if (self.ToDelete == false) then
		SpawnGib(self);
	end
end

function OnCollideWithTerrain(self, terrainMaterial)
	if (self.ToDelete == false) then
		SpawnGib(self);
	end
end
	