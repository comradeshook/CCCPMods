function OnCollideWithMO(self, collidedMO, collidedRootMO)
	if not self.ToDelete and self.Vel.Magnitude > 90 and collidedMO.Material.StructuralIntegrity < 200 then
        local woundVector = SceneMan:ShortestDistance(collidedMO.Pos, self.Pos, true):SetMagnitude(2);
        local stuckCicle = CreateAttachable("Stuck Icicle");
        if (self.HFlipped ~= collidedMO.HFlipped) then
            stuckCicle.InheritsHFlipped = -1;
        else
            stuckCicle.InheritsHFlipped = 1;
        end
        
        stuckCicle.InheritedRotAngleOffset = self.RotAngle - collidedMO.RotAngle;
        for i = -1, 1, 2 do
            local wound = CreateAEmitter(collidedMO:GetEntryWoundPresetName());
            woundVector = woundVector + woundVector.Perpendicular:SetMagnitude(2*i);
            wound.HFlipped = collidedMO.HFlipped;
            wound.RotAngle = woundVector.AbsRadAngle;
            collidedMO:AddWound(wound, woundVector + woundVector.Perpendicular:SetMagnitude(2*i), true);
        end
        collidedMO:AddAttachable(stuckCicle, woundVector);
        
        self.ToDelete = true;
	end
end
