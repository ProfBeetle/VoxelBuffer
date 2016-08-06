-- Bitwise operations for version of Lua pre 5.2 (such as Roblox)
-- I don't remember where I got these, but they aren't mine

local function BitXOR(a,b)--Bitwise xor
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end

local function BitOR(a,b)--Bitwise or
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

local function BitNOT(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

local function BitAND(a,b)--Bitwise and
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

function lshift(x, by)
    if by == nil then return x end
  return x * 2 ^ by
end

function rshift(x, by)
    if by == nil then return x end
  return math.floor(x / 2 ^ by)
end

-- Imports --
local band = BitAND
local bor = BitOR
local bxor = BitXOR
local floor = math.floor
local max = math.max

--[[---------------------------------------------
**********************************************************************************
Perlin Noise Module, Translated by Levybreak
Modified by Jared "Nergal" Hewitt for use with MapGen for Love2D
Modified more by ProfBeetle for use in Roblox
Original Source: http://staffwww.itn.liu.se/~stegu/simplexnoise/simplexnoise.pdf
	The code there is in java, the original implementation by Ken Perlin
**********************************************************************************
--]]---------------------------------------------

local Grad = {}
Grad.__index = Grad
function Grad.new(x, y, z)
  local self = setmetatable({}, Grad)
  self.x = x
  self.y = y
    self.z = z
  return self
end

function Grad.dot2(self, x, y)
    return self.x * x + self.y * y
end

function Grad.dot3(self, x, y, z)
    return self.x * x + self.y * y + self.z + z
end

local grad3 = {Grad.new(1, 1, 0), Grad.new(-1, 1, 0), Grad.new(1, -1, 0), Grad.new(-1, -1, 0),
               Grad.new(1,0,1), Grad.new(-1,0,1), Grad.new(1,0,-1), Grad.new(-1,0,-1),
               Grad.new(0,1,1), Grad.new(0,-1,1), Grad.new(0,1,-1), Grad.new(0,-1,-1)}

local p = { 151,160,137,91,90,15,
  131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
  190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
  88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
  77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
  102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
  135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
  5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
  223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
  129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
  251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
  49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
  138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180 }
-- To remove the need for index wrapping, double the permutation table length
local perm = {}
local gradP = {}

-- This isn't a very good seeding function, but it works ok. It supports 2^16
-- different seed values. Write something better if you need more seeds.
function seed(seed) 
	print(seed)
    if(seed > 0 and seed < 1) then
    -- Scale the seed out
      seed = seed * 65536
    end

    seed = math.floor(seed);
    if(seed < 256) then
      seed = bor(seed, lshift(seed, 8))
    end

    for i = 0, 255 do 
      local v = 0
      if (band(i, 1) == 1) then
        v = bxor(p[i+1], band(seed, 255))
      else 
        v = bxor(p[i+1], band(rshift(seed, 8), 255))
      end

      perm[i] = v
      perm[i + 256] = v;
      gradP[i] = grad3[math.fmod(v, 12) + 1]
      gradP[i + 256] = gradP[i]
    end
end

function fade(t)
  return t*t*t*(t*(t*6-15)+10);
end

function lerp(a, b, t)
  return (1-t)*a + t*b;
end

-- 3D Perlin Noise
local function perlin3(x, y, z)
    -- Find unit grid cell containing point
    local X = math.floor(x); local Y = math.floor(y); local Z = math.floor(z);
    -- Get relative xyz coordinates of point within that cell
    x = x - X; y = y - Y; z = z - Z;
    -- Wrap the integer cells at 255 (smaller integer period can be introduced here)
    X = band(X, 255); Y = band(Y, 255); Z = band(Z, 255);

    -- Calculate noise contributions from each of the eight corners
    local n000 = gradP[X+  perm[Y+  perm[Z  ]]]:dot3(x,   y,     z);
    local n001 = gradP[X+  perm[Y+  perm[Z+1]]]:dot3(x,   y,   z-1);
    local n010 = gradP[X+  perm[Y+1+perm[Z  ]]]:dot3(x,   y-1,   z);
    local n011 = gradP[X+  perm[Y+1+perm[Z+1]]]:dot3(x,   y-1, z-1);
    local n100 = gradP[X+1+perm[Y+  perm[Z  ]]]:dot3(x-1,   y,   z);
    local n101 = gradP[X+1+perm[Y+  perm[Z+1]]]:dot3(x-1,   y, z-1);
    local n110 = gradP[X+1+perm[Y+1+perm[Z  ]]]:dot3(x-1, y-1,   z);
    local n111 = gradP[X+1+perm[Y+1+perm[Z+1]]]:dot3(x-1, y-1, z-1);

    -- Compute the fade curve value for x, y, z
    local u = fade(x);
    local v = fade(y);
    local w = fade(z);

    local Interpolate
    return lerp(
        lerp(
          lerp(n000, n100, u),
          lerp(n001, n101, u), w),
        lerp(
          lerp(n010, n110, u),
          lerp(n011, n111, u), w),
       v);
end


--[[---------------------------------------------
**********************************************************************************
The actual VoxelBuffer demo
**********************************************************************************
--]]---------------------------------------------

math.randomseed(tick())
-- the first few calls aren't always that random, I find.
math.random()
math.random()
math.random()
math.random()
math.random()
seed(math.random())

game.workspace.Terrain:Clear()

local voxelBuffer = require(game.ReplicatedStorage["VoxelBuffer"])

local noiseScale = .06

local _width = 64
local _height = 64
local _halfWidth = _width / 2
local _halfHeight = _height / 2

local voxelBuffer = voxelBuffer.VoxelBuffer.new()

for x = -_halfWidth, _halfWidth do
	for y = -_halfWidth, _halfWidth do
    for z = -_halfHeight, _halfHeight do
			local material = Enum.Material.Ground
			local perl = (perlin3(x * noiseScale, y * noiseScale, z * noiseScale) + 1) / 2
			local occupancy = 1
			local random = floor(perl * 5) + 1
			if (random == 1) then
				material = Enum.Material.Granite
			elseif (random == 2) then
				occupancy = 0
			elseif (random == 3) then
				material = Enum.Material.Slate
			elseif (random == 4) then
				material = Enum.Material.Water
			end
			voxelBuffer:setVoxel(x * 4, y * 4, z * 4, material, occupancy)
    end
	end
	wait()
end

print("Finished making regions, committing")

voxelBuffer:commitToTerrian()

wait()

