function Create(self)
	self.inactiveGuns = {};
	self.activeGuns = {};
	self.hasBeenActivated = false;
	self.activateFrameDelay = math.random(0, 4);
end

local function attachGunsFromTable(rootGun, rootParent, gunTable, startIndex)
	local i = startIndex;
	while gunTable[i] do
		local gun = ToHDFirearm(gunTable[i]);
		gun.CollidesWithTerrainWhileAttached = true;
		gun.InheritedRotAngleOffset = math.rad(math.random()*2 - 1);
		local scatter = 1 + math.sqrt(#gunTable)*2;
		rootGun:AddAttachable(gun:Clone(), Vector(5 + math.random(-1, 1), math.random(-scatter, scatter)));
		gun.ToDelete = true;
		gun.PresetName = "delet this";
		rootParent:RemoveInventoryItem("delet this");
		i = i + 1;
	end
end

function Update(self)
	if self:NumberValueExists("InhaleGuns") then
		self:RemoveNumberValue("InhaleGuns");
		local rootParent = self:GetRootParent();
		if IsAHuman(rootParent) then
			rootParent = ToAHuman(rootParent);
			local gunTable = {};
			local sharpRange = 0;
			for item in rootParent.Inventory do
				if IsHDFirearm(item) and item.UniqueID ~= self.UniqueID then
					gunTable[#gunTable + 1] = ToHDFirearm(item);
					sharpRange = sharpRange + gunTable[#gunTable].SharpLength;
					
					if ToMOSRotating(item):NumberValueExists("InhaleGuns") then
						ToMOSRotating(item):RemoveNumberValue("InhaleGuns");
					end
				end
			end
			
			if #gunTable > 0 then
				self.SharpLength = sharpRange/#gunTable;
				attachGunsFromTable(self, rootParent, gunTable, 1);
			end
		end
	end
	
	if self:IsActivated() then
		if self.hasBeenActivated == false then
			self.hasBeenActivated = true;
			for gun in self.Attachables do
				if IsHDFirearm(gun) then
					local gunToAdd = ToHDFirearm(gun);
					self.inactiveGuns[#self.inactiveGuns + 1] = gunToAdd;
					gunToAdd.FullAuto = true;
					
					if gunToAdd:HasScript("largepileostuff.rte/ClusterGun/AutoReload.lua") == false then
						gunToAdd:AddScript("largepileostuff.rte/ClusterGun/AutoReload.lua");
					end
				end
			end
		end
		
		if self.activateFrameDelay <= 0 then
			if #self.inactiveGuns > 0 then
				local gunToActivate = math.random(1, #self.inactiveGuns);
				local gun = ToHDFirearm(self.inactiveGuns[gunToActivate]);
				
				if gun then
					self.activeGuns[#self.activeGuns + 1] = gun;
					table.remove(self.inactiveGuns, gunToActivate);
					
					if gun:IsEmpty() then
						gun:Reload();
					else
						gun:Activate();
					end
				else
					table.remove(self.inactiveGuns, gunToActivate);
				end
			end
			
			self.activateFrameDelay = math.random(0, 4);
		else
			self.activateFrameDelay = self.activateFrameDelay - 1;
		end
	else
		if #self.activeGuns > 0 then
			local gun = ToHDFirearm(self.activeGuns[1]);
			if gun then
				gun:Deactivate();
				if gun:IsEmpty() then
					gun:Reload();
				end
				self.inactiveGuns[#self.inactiveGuns + 1] = gun;
			end
			
			table.remove(self.activeGuns, 1);
		end
	end
end