local function memoryPatch(libname, offset, hex)
	if libname == "" or libname == 0 or libname == nil or offset == "" or offset == 0 or offset == nil or hex == "" or hex == 0 or hex == nil then return false end
	local targetLibElf = gg.getRangesList(libname) 
	if targetLibElf == nil then return error("failed to find target library.") end
	----------------------// functions \\----------------------
	local function checkHex(hex)
		local chars = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F", "a", "b", "c", "d", "e", "f"}
		for _, v in pairs(chars) do
			for __ = 1, #hex do
				if v == hex:sub(__, __) then
					return true
				else
					--error("hex has error.")
					return false
				end
			end
		end
	end
	local function getMemValue(addr) 
		while (addr ~= nil) or (addr ~= "") or (addr ~= 0) do
			h = {} 
			h[1] = {} 
			h[1].address = targetLibElf + addr
			h[1].flags = gg.TYPE_QWORD 
			res = gg.getValues(h)
			result = res[1].value & 0xFFFFFFFFFFFFFFFF
			return result
		end
		return nil
	end
	local function reverseHex(hex)
    	local newhex = ""
    	if #hex == 0 then return false end
    	if string.find(hex, "%s") then hex = hex::gsub("%s+", "") end
    	if #hex == 16 then
   	 for g=1, #hex, 16 do 
     	 local curhex = string.sub(hex, g, g+15)
	      for i=#curhex, 1, -2 do
	        newhex = newhex..string.sub(curhex, i-1, i)
 	     end
	    end
 	   return newhex:upper()
	    end
	    if #hex == 8 then
 	   for g=1, #hex, 8 do 
 	     local curhex = string.sub(hex, g, g+7)
	      for i=#curhex, 1, -2 do
 	       newhex = newhex..string.sub(curhex, i-1, i)
	      end
   	 end
 	   return newhex:upper()
	    end
	end
	----------------------// some replaces \\----------------------
	if string.sub(hex, "0x") ~= true and not checkHex(hex) then error("hex has error.") end
	local defaultValue = getMemValue(offset)
	if string.sub(hex, "0x") ~= true then local hex = reverseHex(hex) end
	for _, __ in pairs(targetLibElf) do if __["state"] == "Xa" or __["state"] == "Xs" then return __["start"], __["end"]; else return nil end end
	if #hex == 16 or #hex == 8 then local checkValue = true; elseif #hex == 2 or string.sub(hex, "0x" == true then local checkValue = nil; else local checkValue = false end
	if #hex == 16 then local flags = gg.TYPE_QWORD; elseif #hex == 8 then local flags = gg.TYPE_DWORD; elseif #hex == 2 or string.sub(hex, "0x") == true then local flags = gg.TYPE_BYTE; else local flags = gg.TYPE_QWORD 
	local std = {}
	----------------------// Modify and Restore functions \\----------------------
	local std.Modify = function()
		h = {}
		h[1].address = targetLibElf + offset
		h[1].flags = flags
		if checkValue == true then
			h[1].value = hex.."h"
		elseif checkValue == false then
			h[1].value = "h"..hex
		elseif checkValue == nil then
			h[1].value = hex
		end
		if gg.setValues(h) then
			return true
		else
			return false
		end
	end
	local std.Restore = function()
		h = {}
		h[1].address = targetLibElf + offset
		h[1].flags = gg.TYPE_QWORD
		h[1].value = defaultValue
		if gg.setValues(h) then
			return true
		else
			return false
		end
	end
end

----------------------// example usage \\----------------------
examplePatch = memoryPatch("libil2cpp.so", 0xD11294, "00008092C0035FD6") --u can leave spaces between hex.
examplePatch2 = memoryPatch("libil2cpp.so", 0xD11294, "0x03") --also u can use bytes too.
examplePatch.Modify() --modifies the offset to ur hex value.
examplePatch.Restore() --restores the offset to default value.

examplePatch2.Modify() --modifies the offset to ur hex value.
examplePatch2.Restore() --restores the offset to default value.