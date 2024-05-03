function OnCollideWithMO(self, hitMO, hitMORootParent)
    if (self.canBonk and self.Vel.Magnitude > 10) then
        local parent = self:GetParent();
        local distVec = SceneMan:ShortestDistance(self.Pos, hitMO.Pos, true);
        local collisionPoint = self.Pos + distVec:SetMagnitude(9);

        hitMO:AddAbsImpulseForce(distVec:SetMagnitude(self.Vel.Magnitude * self.Mass), collisionPoint);
        print("BONK");
        self.canBonk = false;
    end
end

function Update(self)
    self.canBonk = true;
end