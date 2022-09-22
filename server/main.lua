local VorpCore = {}

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore",function(core)
    VorpCore = core
end)
VORP = exports.vorp_core:vorpAPI()

local globalstore = {}
local initialized = false

-- this is a built-in event, but somehow needs to be registered
RegisterNetEvent('playerJoining')

GetSteamID = function(src)
	local sid = GetPlayerIdentifiers(src)[1] or false

	if (sid == false or sid:sub(1,5) ~= "steam") then
		return false
	end

	return sid
end

table.indexOf = function ( tab, value )
    for index, val in ipairs(tab) do
      if value == val then
        return index
      else
        return -1
      end
    end
end


RegisterServerEvent('bcc-storage:addStorage')
AddEventHandler('bcc-storage:addStorage', function(x, y, z, h)
    -- TODO: THIS NEEDS TO PING BACK OUT TO ALL OTHER USERS TO ADD TO THEIR CLIENT VIEW
    local _source = source
    
    local steamid = GetSteamID(_source)

    local User = VorpCore.getUser(_source)
    local id = User.getUsedCharacter.identifier
    local charId = User.getUsedCharacter.charIdentifier
    exports.ghmattimysql:execute("INSERT INTO storage (identifier, charidentifier, inventory, x, y, z, h) VALUES (@identifier, @charidentifier, @inventory, @x, @y, @z, @h)", {["@identifier"] = steamid, ["@charidentifier"] = charId, ["@inventory"] = '{}', ["@x"] = x,  ["@y"] = y,  ["@z"] = z,  ["@h"] = h}, function(result)
        if result ~= nil then
            TriggerClientEvent("vorp:TipBottom", _source, 'New Storage Location Added.', 10000)
            
            for _, otherplayerId in ipairs(GetPlayers()) do
                    local result = {
                        charidentifier = charId,
                        x = x,
                        y = y,
                        z = z,
                        h = h
                    }
                    TriggerClientEvent('bcc:populateSingleStorage', otherplayerId, result, charId)
                -- end
            end
        else
            TriggerClientEvent("vorp:TipBottom", _source, 'An Error has Occurred', 5000)
        end
    end)
end)

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

RegisterServerEvent('bcc-storage:delStorage')
AddEventHandler('bcc-storage:delStorage', function(x, y, z)
    local _source = source
    local steamid = GetSteamID(_source)
    local User = VorpCore.getUser(_source)
    local id = User.getUsedCharacter.identifier
    local charId = User.getUsedCharacter.charIdentifier

    exports.ghmattimysql:execute("DELETE FROM storage WHERE identifier = @identifier AND charidentifier = @charidentifier AND x = @x AND y = @y AND z = @z", {["@identifier"] = steamid, ["@charidentifier"] = charId,  ["@x"] = x,  ["@y"] = y,  ["@z"] = z}, function(result)
        if result ~= nil then
            print(result.affectedRows)
            if result.affectedRows >= 1 then
                TriggerClientEvent('bcc:removeSingleStorage', _source, charId, x, y, z)
                TriggerClientEvent("vorp:TipBottom", _source, 'Storage deleted.', 10000)
            else
                TriggerClientEvent("vorp:TipBottom", _source, 'You do not own this storage', 5000)
            end
        else
            TriggerClientEvent("vorp:TipBottom", _source, 'You do not own this storage', 5000)
        end
    end)
end)

RegisterServerEvent('bcc-storage:populateStorage')
AddEventHandler('bcc-storage:populateStorage', function()
    local _source = source
    local User = VorpCore.getUser(_source)
    local charId = User.getUsedCharacter.charIdentifier
    exports.ghmattimysql:execute("SELECT * FROM storage", {}, function(result)
        if result[1] ~= nil then
            TriggerClientEvent("bcc:populateAllStorage", _source, result, charId)
        end
    end)
end)


--------- INVENTORY SECTION!----------------
RegisterServerEvent('bcc-storage:openStorage')
AddEventHandler('bcc-storage:openStorage', function(x, y, z, storage)
    local _source = source
    local steamid = GetSteamID(_source)
    local User = VorpCore.getUser(_source)
    local charId = User.getUsedCharacter.charIdentifier

    exports.ghmattimysql:execute("SELECT inventory FROM storage WHERE identifier = @identifier AND charidentifier = @charidentifier AND x = @x AND y = @y AND z = @z", {["@identifier"] = steamid, ["@charidentifier"] = charId,  ["@x"] = x,  ["@y"] = y,  ["@z"] = z}, function(result)
        local storageinv = nil
        if result[1].inventory ~= nil then
            storageinv = result[1].inventory
        end

        print(dump(result))

        local sinv =  json.encode(storageinv)
        print(sinv)
        local playerinv = VorpInv.getUserInventory(_source)
        local pinv = json.encode(playerinv)

        TriggerClientEvent('bcc:openStorage', _source, sinv, pinv, storage, x, y, z)
    end)
end)

RegisterServerEvent('bcc-storage:updateStorage')
AddEventHandler('bcc-storage:updateStorage', function(args)
    local coords = args.coords
    local changes = args.changes
    local _source = source
    local steamid = GetSteamID(_source)
    local User = VorpCore.getUser(_source)
    local charId = User.getUsedCharacter.charIdentifier



    -- Update Player Inventory
    for index, val in ipairs(changes.inv.remove) do
        VorpInv.subItem(_source, val.name, val.count)
    end

    for index, val in ipairs(changes.inv.add) do
        VorpInv.addItem(_source, val.name, val.count)
    end

    -- Update Storage
    exports.ghmattimysql:execute("UPDATE storage SET `inventory` = @update WHERE identifier = @identifier AND charidentifier = @charidentifier AND x = @x AND y = @y AND z = @z", {["@update"] = json.encode(changes.str.storage), ["@identifier"] = steamid, ["@charidentifier"] = charId,  ["@x"] = coords.x,  ["@y"] = coords.y,  ["@z"] = coords.z}, function(result)
        TriggerClientEvent('bcc:stopSpinner', _source)
    end)
end)