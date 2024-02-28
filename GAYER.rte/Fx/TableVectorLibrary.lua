Rad = math.rad;
Deg = math.deg;
Max = math.max;
Min = math.min;
Cos = math.cos;
Sin = math.sin;
Sqrt = math.sqrt;
Ceil = math.ceil;
Atan2 = math.atan2;
Floor = math.floor;
Ceil = math.ceil;
Abs = math.abs;
Pi = math.pi;

-- Because we need ShortestDistance baybee
wrapX = SceneMan.SceneWrapsX;
wrapY = SceneMan.SceneWrapsY;
sceneWidth = SceneMan.SceneWidth;
sceneHeight = SceneMan.SceneHeight;

-- TO USE: This library essentially treats tables as vectors, e.g. table.X and table.Y,
-- letting you skip the astonishingly high cost of going back and forth between C++ and Lua.

-- First, you need to create TVectors using either VecNew() for a new one or VecToTable()
-- to create a copy of a vector as a TVector. You can then use basic arithmetic functions
-- on them like you would normally, as well as the many functions here that behave identically
-- to the mirrored functions from vectors.

-- Note, manually adding vector.X and table.X etc is faster than vector + VecTableToVector(table)! 

-- If errors are being thrown in the console and you have trouble locating them, simply go to the
-- function in question and uncomment the VecErrorCheck() functions; they will then point more
-- precisely to where things are going wrong.

-- The conversion functions are unfortunately expensive, so this whole thing is best suited for long scripts;
-- small scripts may have any performance gain completely nulled by the conversion overhead.
-- ~ ComradeShook

--------------

-- ARITHMETIC FUNCTIONS - These change the (first) table! Order of operations is as input.
function VecAdd(a, b)
	--VecErrorCheck(a);
	--VecErrorCheck(b);
	local vec = VecNew(a.X + b.X, a.Y + b.Y);
	return vec;
end

function VecSubtract(a, b)
	--VecErrorCheck(a);
	--VecErrorCheck(b);
	local vec = VecNew(a.X - b.X, a.Y - b.Y);
	return vec
end

function VecMultiply(a, b)
	--VecErrorCheck(a);
	local vec = VecNew(a.X * b, a.Y * b);
	return vec
end

function VecDivide(a, b)
	--VecErrorCheck(a);
	local vec = VecNew(a.X / b, a.Y / b);
	return vec
end

 -- METATABLE BAYBEE
mt = {};
mt.__add = VecAdd;
mt.__sub = VecSubtract;
mt.__mul = VecMultiply;
mt.__div = VecDivide;

-- CREATION - you're gonna need to use this if you want regular arithmetic expressions :V
function VecNew(X, Y)
	local TVector = {};
	TVector.X = X;
	TVector.Y = Y;
	setmetatable(TVector, mt);
	--VecErrorCheck(TVector);
	return TVector;
end

-- DESTRUCTION - i'm just following the source structure honestly
function VecReset(TVector)
	--VecErrorCheck(TVector);
	TVector.X = 0;
	TVector.Y = 0;
	return TVector;
end

-- IMPORTANT MANAGEMENT FUNCTIONS - these aren't really things in source but are nice to have
function VecToTable(vector)
	local returnTable = VecNew(vector.X, vector.Y)
	return returnTable;
end

function VecTableToVector(TVector)
	--VecErrorCheck(TVector);
	return Vector(TVector.X, TVector.Y);
end

function VecCopy(TVector)
	--VecErrorCheck(TVector);
	local returnTable = VecNew(TVector.X, TVector.Y);
	return returnTable;
end

function VecErrorCheck(TVector)
	if type(TVector) ~= "table" then
		error("Expected a Table Vector; Create it with VecNew()", 3);
	end
	
	if type(TVector.X) ~= "number" then
		error("TVector.X is not a number", 3);
	end
	
	if type(TVector.Y) ~= "number" then
		error("TVector.Y is not a number", 3);
	end
end

function VecPrint(TVector)
	print("TVector(" .. TVector.X .. ", " .. TVector.X .. ")");
end

-- apparently std::signbit() returns true if num is negative
function Sign(num)
	return num < 0;
end

function GetSign(num)
	if num < 0 then
		return -1;
	else
		return 1;
	end
end

function Round(num)
	return num >= 0 and Floor(num + 0.5) or Ceil(num - 0.5); -- stole this from StackExchange, thanks ggVGc lol
end

function VecShortestDistance(TVector1, TVector2, toWrap)
	--VecErrorCheck(TVector1);
	--VecErrorCheck(TVector2);
	local returnVector = VecCopy(TVector2);
	returnVector = returnVector - TVector1;

	if toWrap and (wrapX or wrapY) then
		if wrapX then
			local xDiff = returnVector.X;
			if Abs(xDiff) > sceneWidth/2 then
				returnVector.X = xDiff - GetSign(xDiff) * sceneWidth;
			end
		end

		if wrapY then
			local yDiff = returnVector.Y;
			if Abs(yDiff) > sceneHeight/2 then
				returnVector.Y = yDiff - GetSign(yDiff) * sceneHeight;
			end
		end
	end
	
	return returnVector;
end

-- GETTERS AND SETTERS
function GetX(TVector)
	--VecErrorCheck(TVector);
	return TVector.X;
end

function SetX(TVector, newX)
	--VecErrorCheck(TVector);
	TVector.X = newX;
	return TVector;
end

function GetY(TVector)
	--VecErrorCheck(TVector);
	return TVector.Y;
end

function SetX(TVector, newY)
	--VecErrorCheck(TVector);
	TVector.Y = newY;
	return TVector;
end

function VecSetXY(TVector, newX, newY)
	--VecErrorCheck(TVector);
	TVector.X = newX;
	TVector.Y = newY;
	return TVector;
end

function VecGetLargest(TVector)
	--VecErrorCheck(TVector);
	return Max(Abs(TVector.X), Abs(TVector.Y))
end

function VecGetSmallest(TVector)
	--VecErrorCheck(TVector);
	return Min(Abs(TVector.X), Abs(TVector.Y))
end

function VecGetXFlipped(TVector, xFlip)
	--VecErrorCheck(TVector);
	if xFlip then
		local returnVector = VecNew(-TVector.X, TVector.Y);
		return returnVector;
	else
		return TVector
	end
end

function VecFlipX(TVector, xFlip)
	--VecErrorCheck(TVector);
	local vec = VecGetXFlipped(TVector, xFlip);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecGetYFlipped(TVector, yFlip)
	--VecErrorCheck(TVector);
	if yFlip then
		local returnVector = VecNew(TVector.X, -TVector.Y)
		return returnVector;
	else
		return TVector
	end
end

function VecFlipY(TVector, yFlip)
	--VecErrorCheck(TVector);
	local vec = VecGetXFlipped(TVector, yFlip);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecXIsZero(TVector)
	--VecErrorCheck(TVector);
	return TVector.X == 0;
end

function VecYIsZero(TVector)
	--VecErrorCheck(TVector);
	return TVector.Y == 0;
end

function VecIsZero(TVector)
	--VecErrorCheck(TVector);
	return TVector.X == 0 and TVector.Y == 0;
end

function VecIsOpposedTo(TVector1, TVector2)
	--VecErrorCheck(TVector1);
	--VecErrorCheck(TVector2);
	return ((TVector1.X == 0 and TVector2.X == 0) or (Sign(TVector1.X) ~= Sign(TVector2.X))) and ((TVector1.Y == 0 and TVector2.Y == 0) or (Sign(TVector1.Y) ~= Sign(TVector2.Y)));
end

-- MAGNITUDE
function VecGetSqrMagnitude(TVector)
	--VecErrorCheck(TVector);
	return TVector.X * TVector.X + TVector.Y * TVector.Y;
end

function VecGetMagnitude(TVector)
	--VecErrorCheck(TVector);
	return Sqrt(TVector.X * TVector.X + TVector.Y * TVector.Y);
end

function VecMagnitudeIsLessThan(TVector, magnitude)
	--VecErrorCheck(TVector);
	return VecGetSqrMagnitude(TVector) < magnitude * magnitude;
end

function VecMagnitudeIsGreaterThan(TVector, magnitude)
	--VecErrorCheck(TVector);
	return VecGetSqrMagnitude(TVector) > magnitude * magnitude;
end

function VecSetMagnitude(TVector, magnitude)
	--VecErrorCheck(TVector);
	if (TVector.X ~= 0 or TVector.Y ~= 0) then
		local multiplier = magnitude/VecGetMagnitude(TVector);
		TVector.X = TVector.X * multiplier;
		TVector.Y = TVector.Y * multiplier;
		return TVector;
	else
		TVector.X = magnitude;
		return TVector;
	end
end

function VecCapMagnitude(TVector, cap)
	--VecErrorCheck(TVector);
	if VecGetMagnitude(TVector) > cap then
		VecSetMagnitude(TVector, cap);
	end
	return TVector;
end

function VecClampMagnitude(TVector, lowerMagnitudeLimit, upperMagnitudeLimit)
	--VecErrorCheck(TVector);
	local lowest = Min(lowerMagnitudeLimit, upperMagnitudeLimit);
	local highest = Max(lowerMagnitudeLimit, upperMagnitudeLimit);

	if lowerMagnitudeLimit == 0 and upperMagnitudeLimit == 0 then
		VecReset(TVector);
	elseif VecMagnitudeIsLessThan(TVector, lowest) then
		VecSetMagnitude(TVector, lowest);
	elseif VecMagnitudeIsGreaterThan(TVector, highest) then
		VecSetMagnitude(TVector, highest);
	end

	return TVector;
end

function VecGetNormalized(TVector)
	--VecErrorCheck(TVector);
	local returnVector = VecCopy(TVector);
	return returnVector / VecGetMagnitude(TVector);
end

function VecNormalize(TVector)
	--VecErrorCheck(TVector);
	local vec = VecGetNormalized(TVector);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

-- ROTATION
function VecGetAbsRadAngle(TVector)
	--VecErrorCheck(TVector);
	local radAngle = -Atan2(TVector.Y, TVector.X); 
	if radAngle < -Pi/2 then
		return radAngle + Pi*2;
	else
		return radAngle;
	end
end

function VecSetAbsRadAngle(TVector, angle)
	--VecErrorCheck(TVector);
	return VecRadRotate(TVector, angle - VecGetAbsRadAngle(TVector));
end

function VecGetAbsDegAngle(TVector)
	--VecErrorCheck(TVector);
	return Deg(VecGetAbsRadAngle(TVector))
end

function VecSetAbsDegAngle(TVector, angle)
	--VecErrorCheck(TVector);
	return VecDegRotate(TVector, angle - VecGetAbsDegAngle(TVector));
end

function VecGetRadRotatedCopy(TVector, angle)
	--VecErrorCheck(TVector);
	local returnVector = VecNew(TVector.X, TVector.Y);
	local adjustedAngle = -angle;
	returnVector.X = TVector.X * Cos(adjustedAngle) - TVector.Y * Sin(adjustedAngle);
	returnVector.Y = TVector.X * Sin(adjustedAngle) + TVector.Y * Cos(adjustedAngle);
	return returnVector;
end

function VecRadRotate(TVector, angle)
	--VecErrorCheck(TVector);
	local vec = VecGetRadRotatedCopy(TVector, angle);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecGetDegRotatedCopy(TVector, angle)
	--VecErrorCheck(TVector);
	return VecGetRadRotatedCopy(TVector, Rad(angle));
end

function VecDegRotate(TVector, angle)
	--VecErrorCheck(TVector);
	local vec = VecGetDegRotatedCopy(TVector, angle);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecAbsRotateTo(TVector, refVector)
	--VecErrorCheck(TVector);
	return VecRadRotate(TVector, VecGetAbsRadAngle(refVector) - VecGetAbsRadAngle(TVector)); 
end

function VecGetPerpendicular(TVector)
	--VecErrorCheck(TVector);
	local vec = VecNew(TVector.Y, -TVector.X)
	return vec;
end

function VecPerpendicularize(TVector)
	--VecErrorCheck(TVector);
	local vec = VecGetPerpendicular(TVector);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

-- ROUNDING
function VecRound(TVector)
	--VecErrorCheck(TVector);
	local vec = VecGetRounded(TVector);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecToHalf(TVector)
	--VecErrorCheck(TVector);
	TVector.X = Round(TVector.X * 2) / 2;
	TVector.Y = Round(TVector.Y * 2) / 2;
	return TVector;
end

function VecFloor(TVector)
	--VecErrorCheck(TVector);
	local vec = VecGetFloored(TVector);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecCeiling(TVector)
	--VecErrorCheck(TVector);
	local vec = VecGetCeilinged(TVector);
	VecSetXY(TVector, vec.X, vec.Y);
	return TVector;
end

function VecGetRounded(TVector)
	--VecErrorCheck(TVector);
	local vec = VecNew(Round(TVector.X), Round(TVector.Y))
	return vec;
end

function VecGetRoundedX(TVector)
	--VecErrorCheck(TVector);
	return Round(TVector.X)
end

function VecGetRoundedY(TVector)
	--VecErrorCheck(TVector);
	return Round(TVector.Y)
end

function VecGetFloored(TVector)
	--VecErrorCheck(TVector);
	local vec = VecNew(Floor(TVector.X), Floor(TVector.Y));
	return vec;
end

function VecGetFlooredX(TVector)
	--VecErrorCheck(TVector);
	return Floor(TVector.X)
end

function VecGetFlooredY(TVector)
	--VecErrorCheck(TVector);
	return Floor(TVector.Y)
end

function VecGetCeilinged(TVector)
	--VecErrorCheck(TVector);
	local vec = VecNew(Ceil(TVector.X), Ceil(TVector.Y))
	return vec;
end

function VecGetCeilingedX(TVector)
	--VecErrorCheck(TVector);
	return Ceil(TVector.X)
end

function VecGetCeilingedY(TVector)
	--VecErrorCheck(TVector);
	return Ceil(TVector.Y)
end

-- VECTOR PRODUCTS
function VecDot(TVector1, TVector2)
	--VecErrorCheck(TVector1);
	--VecErrorCheck(TVector2);
	return (TVector1.X * TVector2.X) + (TVector1.Y * TVector2.Y);
end

function VecCross(TVector1, TVector2)
	--VecErrorCheck(TVector1);
	--VecErrorCheck(TVector2);
	return (TVector1.X * TVector2.Y) - (TVector2.X * TVector1.Y);
end