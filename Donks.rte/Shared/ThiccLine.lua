local function drawThiccLineTaper(startPos, endPos, thiccnessStart, thiccnessEnd, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos2 = startPos - dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos3 = endPos + dirVector:SetMagnitude((thiccnessEnd - 1)/2)
	local pos4 = endPos - dirVector:SetMagnitude((thiccnessEnd - 1)/2)

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
	PrimitiveMan:DrawTriangleFillPrimitive(pos3, pos4, pos2, color)
end

local function drawTrianglePoint(startPos, endPos, thiccnessStart, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos2 = startPos - dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos3 = endPos

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
end