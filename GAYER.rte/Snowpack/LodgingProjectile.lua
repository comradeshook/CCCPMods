function OnCollideWithMO(self, collidedMO, collidedRootMO)
    -- Penetration power calculated as if it were an MOPixel or MOSParticle; set sharpness in INI
    local penetrationPower = self.Vel.Magnitude*self.Mass*self.Sharpness;
	if not self.ToDelete and collidedMO.Material.StructuralIntegrity <= penetrationPower then
        -- Initialise variables; this is the easy tweaking stuff
        local stickOffset = Vector(0, 0);                       -- X,Y Offset of the stuck projectile from its position on impact
        local stuckProjectile = "Stuck Icicle";                 -- PresetName of the attachable that gets stuck on hit
        local woundName = collidedMO:GetExitWoundPresetName();  -- PresetName of the wound emitter
        local woundCount = 3;   -- Number of wounds caused
        local woundWidth = 3;   -- Wounds are spread across this many pixels, perpendicular to impact
        local angleOffset = 0;  -- Angle offset of the stuck projectile and wounds in radians
        
        
        -- Code stuff from here, tweak at your own peril :V
        stickOffset = stickOffset:RadRotate(self.Vel.AbsRadAngle);
        stuckProjectile = CreateAttachable(stuckProjectile);
        local woundPos = Vector(0, 0); -- Gets filled out by ray cast
		local flipmas = self.FlipFactor * collidedMO.FlipFactor;
        --local angle = (self.RotAngle + angleOffset)*collidedMO.FlipFactor - collidedMO.RotAngle; -- aghgshdgjh
		local angle = self.Vel:GetXFlipped(collidedMO.HFlipped).AbsRadAngle - (collidedMO.RotAngle * collidedMO.FlipFactor);
        
        -- Cast ray to find wound position
        if not (SceneMan:CastFindMORay(self.Pos, self.Vel, collidedRootMO.ID, woundPos, 0, true, 0)) then
            return; -- Exit script if the MO is somehow not found in the flight path that resulted in a direct collision; may happen if projectile is very long and slow
        end
        
        -- Convert wound position to an offset
        --woundPos = (self.Pos + stickOffset) - collidedMO.Pos;
        woundPos = (woundPos + stickOffset) - collidedMO.Pos;
		woundPos = woundPos:GetRadRotatedCopy(-collidedMO.RotAngle):GetXFlipped(collidedMO.HFlipped);
        
        --stuckProjectile.InheritsHFlipped = flipmas;
        
        stuckProjectile.InheritedRotAngleOffset = angle;
        stuckProjectile.DrawAfterParent = true;
		collidedMO:AddAttachable(stuckProjectile, woundPos);
        
		if (woundCount > 0) then
			local woundRadius = woundWidth/2;
			local woundIncrement = woundWidth/woundCount;
			
			for i = -woundRadius, woundRadius, woundIncrement do
				local wound = CreateAEmitter(woundName);
				wound.InheritedRotAngleOffset = angle + math.pi;
				collidedMO:AddWound(wound, woundPos:GetXFlipped(collidedMO.HFlipped) + woundPos.Perpendicular:SetMagnitude(i), true);
			end
		end
        
        self.ToDelete = true;
	end
end
