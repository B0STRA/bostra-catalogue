local QBCore = exports["qb-core"]:GetCoreObject()
Targets = {}
Props = {}
MenuOptions = {}
VehicleModels = {}
VehicleBrands = {}
VehiclePrices = {}
VehicleHashes = {}
AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	LoadVehicles()
	Wait(10)
	LoadMenu()
	InitTargets()
	SpawnProp(Config.propModel)
end)
function UnloadModel(model)
	if Config.Debug then
		print("Debug:Removing Model:" .. model)
	end
	SetModelAsNoLongerNeeded(model)
end
function SpawnProp(prop)
	for k, v in pairs(Config.targetLocs) do
		if not v.useProp then
			return
		end
		lib.requestModel(prop)
		Props[k] = CreateObject(prop, v.point.x, v.point.y, v.point.z - 1, false, false, false)
		SetEntityHeading(Props[k], v.pointHeading)
		SetEntityAsMissionEntity(Props[k], true, true)
		FreezeEntityPosition(Props[k], true)
		SetEntityCollision(Props[k], false, false)
	end
end
function DeleteProp(Props)
	for i = 1, #Props do
		UnloadModel(Props[i])
		DeleteObject(Props[i])
	end
end
function ToggleNuiFrame(shouldShow)
	SetNuiFocus(shouldShow, shouldShow)
	SendReactMessage("setVisible", shouldShow)
end
function LoadVehicles()
	local vehicles = {}

	for k, v in pairs(QBCore.Shared.Vehicles) do
		if v.shop == "luxury" then
			local vehicleData = {
				model = v.name,
				brand = v.brand,
				price = lib.math.groupdigits(v.price),
				hash = v.model,
			}

			table.insert(vehicles, vehicleData)
		end
	end
	table.sort(vehicles, function(a, b)
		return a.brand < b.brand
	end)
	for k, v in pairs(vehicles) do
		VehicleModels[k] = v.model
		VehicleBrands[k] = v.brand
		VehiclePrices[k] = v.price
		VehicleHashes[k] = v.hash
	end
end
function LoadMenu()
	for k, v in pairs(VehicleModels) do
		MenuOptions[#MenuOptions + 1] = {
			title = v,
			description = "Brand: " .. VehicleBrands[k] .. "\nPrice: $" .. VehiclePrices[k],
			icon = "fas fa-car",
			image = { "https://docs.fivem.net/vehicles/" .. VehicleHashes[k] .. ".webp" } or nil,
		}
		local data = {
			id = "catalogue_menu",
			title = "Vehicle Catalogue",
			icon = "fas fa-car",
			options = MenuOptions,
		}
		lib.registerContext(data)
	end
end
function InitTargets()
	for k, v in pairs(Config.targetLocs) do
		if Config.targetResource == "ox" then
			local params = {
				coords = v.point.xyz,
				size = vec3(1.0, 1.0, 4.0),
				rotation = v.pointHeading,
				debug = Config.Debug,
				options = {
					{
						label = "Browse Catalogue",
						name = v.targetId,
						icon = "fas fa-car",
						iconColor = "#DA9110",
						distance = 3.0,
						onSelect = function()
							if v.useLib then
								lib.showContext("catalogue_menu")
							else
								ToggleNuiFrame(true)
							end
						end,
					},
				},
			}
			Targets[k] = exports.ox_target:addBoxZone(params)
		else
			return
		end
	end
end
if Config.useCommand then
	RegisterCommand("show-nui", function()
		ToggleNuiFrame(true)
		debugPrint("Show NUI frame")
	end, false)
end
RegisterNUICallback("hideFrame", function(_, cb)
	ToggleNuiFrame(false)
	debugPrint("Hide NUI frame")
	cb({})
end)
RegisterNUICallback("getClientData", function(data, cb)
	debugPrint("Data sent by React", json.encode(data))

	local vehiclesData = {}
	for k, v in pairs(QBCore.Shared.Vehicles) do
		if v.shop == "luxury" then
			local vehicleData = {
				vehicleModel = v.name,
				vehicleBrand = v.brand,
				vehiclePrice = " " .. "$ " .. v.price,
				vehicleHash = v.model,
			}

			table.insert(vehiclesData, vehicleData)
		end
	end
	cb(vehiclesData)
end)
AddEventHandler("onResourceStop", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	for k, v in pairs(Config.targetLocs) do
		if Config.targetResource == "ox" then
			exports.ox_target:removeZone(v.targetId)
		else
			if Config.targetResource == "qb" then
				return
			end
		end
	end
	ToggleNuiFrame(false)
	DeleteProp(Props)
end)