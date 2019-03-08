local LibRangeCheck = LibStub("LibRangeCheck-2.0")
local Compresser = LibStub:GetLibrary("LibCompress");
local Serializer = LibStub:GetLibrary("AceSerializer-3.0");

function DraduxAutoMarking:GetNpcID(guid)
    -- Don't add players to that list
    if guid:sub(1, 6) == "Player" then
        return
    end

    -- Don't add pets to that list
    if guid:sub(1, 3) == "Pet" then
        return
    end

    return tonumber(guid:sub(-17, -12))
end

function DraduxAutoMarking:GetRange(unit, checkVisible)
    return LibRangeCheck:GetRange(unit, checkVisible);
end

function DraduxAutoMarking:IterateGroupMembers(forceParty)
    local raid = IsInRaid()
    local party = IsInGroup()
    local raidMember = GetNumGroupMembers()
    local partyMember = GetNumSubgroupMembers()
    local i = 1
    return function()
        local ret
        if not raid and not party and i == 1 then
            ret = 'player'
        elseif not forceParty and raid then
            if i <= raidMember then
                ret = "raid" .. i
            end
        elseif forceParty or party then
            if i <= partyMember then
                ret = "party" .. i
            end
        end

        i = i + 1
        return ret
    end
end

function DraduxAutoMarking:CopyTable(destination, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            destination[k] = {}
            DraduxAutoMarking:CopyTable(destination[k], v)
        else
            destination[k] = v
        end
    end
end

function DraduxAutoMarking:TableToString(inTable)
    local serialized = Serializer:Serialize(inTable)
    local compressed = Compresser:CompressHuffman(serialized)
    return encodeB64(compressed)
end

function DraduxAutoMarking:StringToTable(inData)
    local decoded = decodeB64(inData)

    local decompressed, errorMsg = Compresser:Decompress(decoded)
    if not(decompressed) then
        return "DraduxAutoMarking - Error decompressing: " .. errorMsg
    end

    local success, deserialized = Serializer:Deserialize(decompressed)
    if not(success) then
        return "DraduxAutoMarking - Error deserializing " .. deserialized
    end

    return deserialized
end

function DraduxAutoMarking:GetCurrentZone()
    return C_Map.GetBestMapForUnit("player")
end

function DraduxAutoMarking:GetCurrentInstance()
    local name, _, difficultyIndex, _, _, _, _, mapID, _ = GetInstanceInfo()
    return mapID, name, difficultyIndex
end

function DraduxAutoMarking:SplitString(str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
        return { str }
    end
    if maxNb == nil or maxNb < 1 then
        maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gmatch(str, pat) do
        nb = nb + 1
        result[nb] = part
        lastPos = pos
        if nb == maxNb then
            break
        end
    end
    -- Handle the last field
    if nb ~= maxNb then
        result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end


------------------------------------------------------------------------------------------------------------------------
-- Taken from MethodDungeonTools
------------------------------------------------------------------------------------------------------------------------
--Based on code from WeakAuras2, all credit goes to the authors
local bytetoB64 = {
    [0]="a","b","c","d","e","f","g","h",
    "i","j","k","l","m","n","o","p",
    "q","r","s","t","u","v","w","x",
    "y","z","A","B","C","D","E","F",
    "G","H","I","J","K","L","M","N",
    "O","P","Q","R","S","T","U","V",
    "W","X","Y","Z","0","1","2","3",
    "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
    a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
    i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
    q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
    y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
    G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
    O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
    W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
    ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

-- This code is based on the Encode7Bit algorithm from LibCompress
-- Credit goes to Galmok (galmok@gmail.com)
local encodeB64Table = {};

local function encodeB64(str)
    local B64 = encodeB64Table;
    local remainder = 0;
    local remainder_length = 0;
    local encoded_size = 0;
    local l=#str
    local code
    for i=1,l do
        code = string.byte(str, i);
        remainder = remainder + bit_lshift(code, remainder_length);
        remainder_length = remainder_length + 8;
        while(remainder_length) >= 6 do
            encoded_size = encoded_size + 1;
            B64[encoded_size] = bytetoB64[bit_band(remainder, 63)];
            remainder = bit_rshift(remainder, 6);
            remainder_length = remainder_length - 6;
        end
    end
    if remainder_length > 0 then
        encoded_size = encoded_size + 1;
        B64[encoded_size] = bytetoB64[remainder];
    end
    return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}

local function decodeB64(str)
    local bit8 = decodeB64Table;
    local decoded_size = 0;
    local ch;
    local i = 1;
    local bitfield_len = 0;
    local bitfield = 0;
    local l = #str;
    while true do
        if bitfield_len >= 8 then
            decoded_size = decoded_size + 1;
            bit8[decoded_size] = string_char(bit_band(bitfield, 255));
            bitfield = bit_rshift(bitfield, 8);
            bitfield_len = bitfield_len - 8;
        end
        ch = B64tobyte[str:sub(i, i)];
        bitfield = bitfield + bit_lshift(ch or 0, bitfield_len);
        bitfield_len = bitfield_len + 6;
        if i > l then
            break;
        end
        i = i + 1;
    end
    return table.concat(bit8, "", 1, decoded_size)
end