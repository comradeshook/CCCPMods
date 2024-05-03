dofile("GAYER.rte/Fx/TableVectorLibrary.lua");

local GetTerrMatter = SceneMan.GetTerrMatter;
local ShortestDistance = SceneMan.ShortestDistance;

function Create(self)
    local var = {};
    var.Pos = self.Pos;
    var.wheelMaxSpeed = 0.6; -- rads/frame
    var.wheelSpeed = 0;
    var.wheelAcc = 0.02;
    var.wheel = nil;
    var.wheelPos = nil;
    var.wheelResolution = 10; -- number of points along the perimeter checked
    var.wheelRadius = Vector(7, 0);
    var.wheelPoints = {};
    self.var = var;
end

function Update(self)
    local var = self.var;
    if (var.wheel == nil) then
        for limb in self.Attachables do
            if (limb.PresetName == "Velo Wheel Leg Thing") then
                for wheel in limb.Attachables do
                    var.wheel = wheel;
                    var.wheelPos = wheel.Pos;

                    for i = 1, var.wheelResolution, 1 do
                        local checkAngle = wheel.RotAngle + math.rad(360/var.wheelResolution)*i;
                        local pointPos = var.wheelRadius:GetRadRotatedCopy(checkAngle);
                        local terrainCheck = SceneMan:CastObstacleRay(var.wheelPos, var.wheelRadius:GetRadRotatedCopy(checkAngle), pointPos, Vector(0, 0), self.ID, self.Team, 0, 0);
                        var.wheelPoints[i] = pointPos;
                    end
                end
            end
        end
    end

    if (var.wheel and #var.wheelPoints > 0) then
        local driving = false;
        if (self:GetController():IsState(Controller.MOVE_LEFT)) then
            var.wheelSpeed = var.wheelSpeed + var.wheelAcc * self.FlipFactor;
            driving = true;
        end

        if (self:GetController():IsState(Controller.MOVE_RIGHT)) then
            var.wheelSpeed = var.wheelSpeed - var.wheelAcc * self.FlipFactor;
            driving = true;
        end

        if (driving) then
            if (var.wheelSpeed > var.wheelMaxSpeed) then
                var.wheelSpeed = var.wheelMaxSpeed;
            end

            if (var.wheelSpeed < -var.wheelMaxSpeed) then
                var.wheelSpeed = -var.wheelMaxSpeed;
            end
        else
            var.wheelSpeed = var.wheelSpeed * 0.97;
        end

        local wheelAccVector = Vector(0, 0);
        local repelVector = Vector(0, 0);
        local pointCount = 0;
        local forcePos = Vector(0, 0);

        for i = 1, var.wheelResolution, 1 do
            local checkAngle = var.wheel.RotAngle + math.rad(360/var.wheelResolution)*i;
            local desiredPos = var.wheelPos + var.wheelRadius:GetRadRotatedCopy(checkAngle);
            local pointPos = desiredPos * 1;
            local terrainCheck = SceneMan:CastObstacleRay(var.wheelPos, var.wheelRadius:GetRadRotatedCopy(checkAngle), pointPos, Vector(0, 0), self.ID, self.Team, 130, 0);

            if (terrainCheck >= 0) then
                wheelAccVector = wheelAccVector - ShortestDistance(SceneMan, var.wheelPoints[i], pointPos, true);
                repelVector = repelVector + ShortestDistance(SceneMan, desiredPos, pointPos, true);
                forcePos = forcePos + (var.wheelPos + ShortestDistance(SceneMan, var.wheelPos, pointPos, true));
                pointCount = pointCount + 1;
            end
            --PrimitiveMan:DrawCirclePrimitive(pointPos, 0, 13);
            --PrimitiveMan:DrawLinePrimitive(var.wheelPoints[i], pointPos, 13);

            --PrimitiveMan:DrawLinePrimitive(var.wheelPos, var.wheelPos + repelVector, 13);

            var.wheelPoints[i] = pointPos;

        end

        if (pointCount > 0) then
            wheelAccVector = (wheelAccVector / pointCount);
            repelVector = (repelVector / pointCount);

            forcePos = forcePos / pointCount;
        end

        var.wheel.InheritedRotAngleOffset = var.wheel.InheritedRotAngleOffset + var.wheelSpeed;
        if (var.lastFlip == self.HFlipped) then
            --self:AddAbsForce((wheelAccVector + repelVector) * self.Mass * 60, forcePos);
            self:AddAbsForce(wheelAccVector * self.Mass * 40, forcePos);
            self:AddAbsForce(wheelAccVector * self.Mass * 20, var.Pos);
            self.Pos = self.Pos + repelVector;
        else
            var.wheelSpeed = -var.wheelSpeed;
        end
        --self.Vel = self.Vel + wheelAccVector;
        --wheel.Vel = wheel.Vel + wheelAccVector;
    end

    var.lastFlip = self.HFlipped;

    if (var.wheel.InheritedRotAngleOffset > math.pi*2) then
        var.wheel.InheritedRotAngleOffset = var.wheel.InheritedRotAngleOffset - math.pi*2;
    end

    if (var.wheel.InheritedRotAngleOffset < 0) then
        var.wheel.InheritedRotAngleOffset = var.wheel.InheritedRotAngleOffset + math.pi*2;
    end
end