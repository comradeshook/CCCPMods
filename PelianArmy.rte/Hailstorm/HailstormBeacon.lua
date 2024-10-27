local startDelay = 2000;

function Create(self)
    local var = {};
    var.origin = Vector(self.Pos.X - self.Pos.Y*math.cos(math.rad(65)), 0);
    SceneMan:WrapPosition(var.origin);
    var.timer = Timer();
    self.var = var;
end

function Update(self)
    local var = self.var;

    if (var.timer and var.timer:IsPastSimMS(startDelay)) then
        local emitter = CreateAEmitter("Hailstorm Emitter", "PelianArmy.rte");
        emitter.Pos = var.origin;
        MovableMan:AddMO(emitter);
        var.timer = nil;
    end
end