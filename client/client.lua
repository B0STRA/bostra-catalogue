local QBCore = exports["qb-core"]:GetCoreObject()
Targets = {}
Props = {}
MenuOptions = {}
VehicleModels = {}
VehicleBrands = {}
VehiclePrices = {}
VehicleHashes = {}

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
		if v.shop == Config.shopName then
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
							if v.UseLib then
								lib.showContext("catalogue_menu")
							else
								ToggleNuiFrame(true)
							end
						end,
					},
				},
			}
			Targets[k] = exports.ox_target:addBoxZone(params)
		elseif Config.targetResource == "qb" then
			Targets[k] = exports["qb-target"]:AddBoxZone(v.targetId .. k, v.point, 1.0, 1.0, {
				name = v.targetId,
				heading = v.pointHeading,
				debugPoly = Config.Debug,
				useZ = true,
			}, {
				options = {
					{
						label = "Browse Catalogue",
						icon = "fas fa-car",
						action = function()
							if v.UseLib then
								lib.showContext("catalogue_menu")
							else
								ToggleNuiFrame(true)
							end
						end,
					},
				},
				distance = 3.0,
			})
		elseif Config.targetResource == "dist" then
			for k, v in pairs(Config.targetLocs) do
				Targets[k] = lib.zones.box({
					coords = v.point,
					radius = v.distance,
					rotation = v.pointHeading,
					debug = Config.Debug,
					onEnter = function()
						lib.showTextUI("Press [E] to browse catalogue", {
							position = "right-center",
							icon = "fas fa-car",
							iconColor = "#DA9110",
							style = {
								borderRadius = 10,
								backgroundColor = "#000000",
								color = "#FFFFFF",
							},
						})
					end,
					inside = function()
						if IsControlJustPressed(0, 38) then
							if v.UseLib then
								lib.hideTextUI()
								lib.showContext("catalogue_menu")
							else
								lib.hideTextUI()
								ToggleNuiFrame(true)
							end
						end
					end,
					onExit = function()
						lib.hideTextUI()
					end,
				})
			end
		end
	end
end

if Config.UseCommand then
	RegisterCommand("catalogue", function()
		ToggleNuiFrame(true)
		debugPrint("Show NUI frame")
	end, false)
	RegisterCommand("closecatalogue", function()
		ToggleNuiFrame(false)
		debugPrint("Hide NUI frame")
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
	for k, v in pairs(VehicleModels) do
		local vehicleData = {
			vehicleModel = v,
			vehicleBrand = VehicleBrands[k],
			vehiclePrice = " $" .. VehiclePrices[k],
			vehicleHash = VehicleHashes[k],
		}

		table.insert(vehiclesData, vehicleData)
	end
	cb(vehiclesData)
end)
RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
	SpawnProp(Config.propModel)
	LoadVehicles()
	LoadMenu()
	InitTargets()
end)

AddEventHandler("onResourceStart", function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end
	SpawnProp(Config.propModel)
	LoadVehicles()
	LoadMenu()
	InitTargets()
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
				exports["qb-target"]:RemoveZone(v.targetId)
			end
		end
	end
	ToggleNuiFrame(false)
	DeleteProp(Props)
end)
