local addMode = false
local globalstore = {}
local limit = 1
local current = 0

SceneTarget = function()
    local Cam = GetGameplayCamCoord()
    local handle = Citizen.InvokeNative(0x377906D8A31E5586, Cam, GetCoordsFromCam(10.0, Cam), -1, PlayerPedId(), 4)
    local _, Hit, Coords, _, Entity = GetShapeTestResult(handle)
    return Coords
end

GetCoordsFromCam = function(distance, coords)
    local rotation = GetGameplayCamRot()
    local adjustedRotation = vector3((math.pi / 180) * rotation.x, (math.pi / 180) * rotation.y, (math.pi / 180) * rotation.z)
    local direction = vector3(-math.sin(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.cos(adjustedRotation[3]) * math.abs(math.cos(adjustedRotation[1])), math.sin(adjustedRotation[1]))
    return vector3(coords[1] + direction[1] * distance, coords[2] + direction[2] * distance, coords[3] + direction[3] * distance)
end

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

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

function indexOfStorage(array, charid, x, y, z, bypass)
    for i, storage in ipairs(array) do
        if storage.charid == charid or bypass == true then
			local dist = GetDistanceBetweenCoords(storage.x, storage.y, storage.z, x, y, z, 1)
			if dist < 2 then
				return i	
			end
        end
    end
    return nil
end

Citizen.CreateThread(function()
	TriggerServerEvent('bcc-storage:populateStorage')	

	while true do
		Citizen.Wait(2)
		if addMode then
			x, y, z = table.unpack(SceneTarget())
            Citizen.InvokeNative(0x2A32FAA57B937173, 0x50638AB9, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.15, 0.15, 0.15, 93, 17, 100, 255, false, false, 2, false, false)
		end
	end
end)

function getClosestStorage(ecoords)
	for index, gs in ipairs(globalstore) do
		local dist = GetDistanceBetweenCoords(ecoords.x, ecoords.y, ecoords.z, gs.x, gs.y, gs.z, 1)
		if dist < 0.5 then
			return gs
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)
		local size = GetNumberOfEvents(0)
		if size > 0 then
			local fired = false
			for index = 0, size - 1 do
				local event = GetEventAtIndex(0, index)
				if event == -1118609128 and fired == false then
					fired = true
					local view = exports["bcc-storage"]:DataViewNativeGetEventData(0, index, 3)
					local pedInteracting = view['0']
					local entity = view['4']
					local objectid = GetEntityModel(entity)
					if (PlayerPedId() == pedInteracting and objectid == -1027584093) then
						local store = getClosestStorage(GetEntityCoords(entity))
						if store ~= nil then
							TriggerServerEvent('bcc-storage:openStorage', store.x, store.y, store.z, entity)		
						end
					end
					Wait(3000)
					fired = false
					
				end
			end
		end
	end
end)


RegisterCommand('storage:edit', function(source, args, raw)
	if addMode then
		addMode = false
	elseif not addMode then
		addMode = true
	end
end)

RegisterCommand('storage:save', function(source, args, raw)
	local _source = source

	if addMode then
		if current < limit then 
			local x, y, z = table.unpack(SceneTarget())

			-- Ensure a storage box is not already in the coords
			local isNotAvailable = DoesObjectOfTypeExistAtCoords(x, y, z, 1.0, -1027584093, false)

			if isNotAvailable then
				TriggerEvent("vorp:TipBottom", 'Storage already exists in this location.', 10000)
			else
				local h = GetEntityHeading(PlayerPedId())
				addMode = false
				local playerid = PlayerPedId()
				TriggerServerEvent('bcc-storage:addStorage', round(x, 3), round(y, 3), round(z, 3), h)				
			end
		else
			TriggerEvent("vorp:TipBottom", 'You have reached max amount of storage chests.', 10000)
		end
	else
		TriggerEvent("vorp:TipBottom", 'Must use /storage:edit first.', 10000)
	end
end)


RegisterCommand('storage:del', function(source, args, raw)
	local _source = source
	if addMode then
		x, y, z = table.unpack(SceneTarget())
		local playerid = PlayerPedId()

		-- Ensure the correct prop is being targeted 
		local exists = DoesObjectOfTypeExistAtCoords(x, y, z, 2.0, -1027584093, false)
		if exists then
			addMode = false
			local index = indexOfStorage(globalstore, nil, x, y, z, true)
			local store = globalstore[index]
			if store ~= nil then
				TriggerServerEvent('bcc-storage:delStorage', store.x, store.y, store.z)
			end
		else
			addMode = false
			TriggerEvent("vorp:TipBottom", 'Nothing to delete.', 10000)
		end
	else
		TriggerEvent("vorp:TipBottom", 'Must use /storage:edit first.', 10000)
	end
end)

RegisterCommand('storage:clear', function(source, args, raw)
	local _source = source
	RemoveAllPickupsOfType(
		-1027584093
	)
end)

function addStorage(v, id)
	local exists = DoesObjectOfTypeExistAtCoords( v.x + 0.0, v.y + 0.0, v.z + 0.0, 2.0, -1027584093, false)
	local storage = CreateObject(-1027584093, v.x + 0.0, v.y + 0.0, v.z + 0.0, true, false, true);
	SetEntityHeading(storage, v.h + 0.0)
	PlaceObjectOnGroundProperly(storage)

	if id == v.charidentifier then 
		current = current + 1
	end
	
	table.insert(globalstore, {
		charid = v.charidentifier,
		storage = storage,
		x = v.x,
		y = v.y,
		z = v.z,
		h = v.h
	})	
end 

RegisterNetEvent('bcc:populateSingleStorage')
AddEventHandler('bcc:populateSingleStorage', function(result, id)
	addStorage(result, id)	
end)

RegisterNetEvent('bcc:removeSingleStorage')
AddEventHandler('bcc:removeSingleStorage', function(charId, x, y, z)
	local index = indexOfStorage(globalstore, charId, x, y, z, false)
	if index ~= nil then
		if (current > 0) then
			current = current - 1
		end
		DeleteObject(globalstore[index].storage)
		table.remove(globalstore, index)
	end
end)

RegisterNetEvent('bcc:populateAllStorage')
AddEventHandler('bcc:populateAllStorage', function(results, id)
	for index, v in ipairs(results) do
		addStorage(v, id)
	end
end)

RegisterNetEvent('bcc:openStorage')
AddEventHandler('bcc:openStorage', function(storageinv, playerinv, storage, x, y, z)
	SendNUIMessage({
		type = 'bccopen',
		playerstorage = storageinv,
		playerinventory = playerinv,
		entity = storage,
		x = x,
		y = y,
		z = z
	})
	SetNuiFocus(true, true)
end)

RegisterNetEvent('bcc:stopSpinner')
AddEventHandler('bcc:stopSpinner', function()
	SendNUIMessage({
		type = 'bccstopspinner'
	})
end)

RegisterNUICallback('bccclose', function(args, cb)
    SetNuiFocus(false, false)

	-- TODO: This will set state back to closed, but does not animate or make the model look closed. Add animation?
	Citizen.InvokeNative(0x188F8071F244B9B8, args.storage, 0)
    cb('ok')
end)

RegisterNUICallback('updateStorage', function(args, cb)
	TriggerServerEvent('bcc-storage:updateStorage', args)	
    cb('ok')
end)
