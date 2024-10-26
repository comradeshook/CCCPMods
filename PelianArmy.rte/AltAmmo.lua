function LoadFirst(pieMenuOwner, pieMenu, pieSlice)
	local GUB = pieMenuOwner.EquippedItem;
	if (GUB and IsHDFirearm(GUB)) then
		GUB.Sharpness = 1;
	end
end

function LoadSecond(pieMenuOwner, pieMenu, pieSlice)
	local GUB = pieMenuOwner.EquippedItem;
	if (GUB and IsHDFirearm(GUB)) then
		GUB.Sharpness = 2;
	end
end

function LoadThird(pieMenuOwner, pieMenu, pieSlice)
	local GUB = pieMenuOwner.EquippedItem;
	if (GUB and IsHDFirearm(GUB)) then
		GUB.Sharpness = 3;
	end
end
